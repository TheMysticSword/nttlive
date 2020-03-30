#macro c_twitch make_color_rgb(145, 70, 255);

#define init
global.messages = [];
global.erase_messages = 0;

global.timedupdate_time = 0;
global.timedupdate_maxtime = 30 * 10;

global.chatters = [];
global.viewers = 0;

global.viewer_rads = 0;

global.skill_voting_type = "";
global.skill_voting_types = [
    {displayname: "mutation", button_object: SkillIcon},
    {displayname: "ultra mutation", button_object: EGSkillIcon},
    {displayname: "crown", button_object: CrownIcon}
];
global.skill_voting = [];
global.skill_voting_maxtime = 30 * 20;
global.skill_voting_time = 0;

global.secondlife = 0;
global.secondlife_count = 1;
global.secondlife_votes = 0;
global.secondlife_maxvotes = 1;
global.secondlife_visual = 0;
global.secondlife_time = 0;
global.secondlife_maxtime = 30 * 20;
global.secondlife_filling = -1;

global.controller = noone;
with (instances_matching(CustomObject, "name", "NTTLiveCont")) instance_destroy();

end_step_create();

global.config = {
    displayMessagesInNTTChat: true,
    displayMessagesAboveEnemies: true,
    mutationAndCrownVoting: true,
    chatControlsTheThrone: true,
    timedEvents: true,
    revivesPerRun: 1,
    specialAmmoPerMessage: 5,
    viewerScalingFactor: 0.2
};
var config_file = "config.json";
wait file_load(config_file);
if (file_exists(config_file)) {
    global.config = json_decode(string_load(config_file));
}

#define end_step_create
with (instances_matching(CustomEndStep, "name", mod_current)) instance_destroy();
with (script_bind_end_step(end_step, 0)) {
    name = mod_current;
    persistent = 1;
}

#define game_start
global.secondlife = 0;
global.secondlife_count = global.config.revivesPerRun;
global.skill_voting = [];
global.skill_voting_time = 0;
global.timedupdate_time = 0;

#define step
// create the controller
if (!instance_exists(global.controller)) {
    with (instance_create(0, 0, CustomObject)) {
        name = "NTTLiveCont";
        persistent = 1;
        global.controller = self;
    }
}

// mark explo floors to differentiate from regular floors
with (FloorExplo) {
    nttlive_floorexplo = 1;
}

// disable skill voting in menu
if (instance_exists(Menu)) {
    global.skill_voting = [];
    global.skill_voting_time = global.skill_voting_maxtime;
    global.secondlife = 0;
}

// update the chatter list and viewer count, also clear the message array
global.timedupdate_time -= current_time_scale;
if (global.timedupdate_time <= 0) {
    global.timedupdate_time = global.timedupdate_maxtime;

    refill_available_enemy_usernames();
    end_step_create();

    global.messages = [];

    global.chatters = [];
    wait file_load("chatters.txt");
    if (file_exists("chatters.txt")) {
        global.chatters = json_decode(string_load("chatters.txt"));
    }

    global.viewers = 0;
    wait file_load("viewer_count.txt");
    if (file_exists("viewer_count.txt")) {
        global.viewers = real(string_load("viewer_count.txt"));
    }
}

// fetch messages
var files = [];
wait file_find_all("messages", files);
for (var i = 0; i < array_length(files); i++) {
    if (string_pos("message_", files[i].path) != 0 && files[i].ext == ".txt" && files[i].is_data) {
        wait file_load(files[i].path);
        if (file_exists(files[i].path)) {
            var file_message = string_load(files[i].path);
            var message_data = json_decode(file_message);
            message_data.flaglist = ds_list_create();
            array_push(global.messages, message_data);
            file_delete(files[i].path);
        }
    }
}

// erase the messages if needed
if (global.erase_messages) {
    var files = [];
    wait file_find_all("messages", files);
    for (var i = 0; i < array_length(files); i++) {
        if (string_pos("message_", files[i].path) != 0 && files[i].ext == ".txt" && files[i].is_data) {
            wait file_load(files[i].path);
            if (file_exists(files[i].path)) {
                file_delete(files[i].path);
            }
        }
    }
    global.erase_messages = 0;
}

// chat controls the throne
if (!mod_script_call("mod", "nttlive_util", "custom_object_exists", "ThroneChatterDisplay")) {
    throne_chatter_display_create();
}
if (global.config.chatControlsTheThrone == json_true) {
    with (Nothing) {
        // disable the AI
        alarm1 = 9999;
        alarm2 = 9999;

        if ("nttlive_throne_initmessage" not in self) {
            nttlive_throne_initmessage = 1;
            send_message("TwitchLit BROADCASTER_NAME reached the Throne! This is your chance to defeat them - you control the Throne! Type the following words to perform respective actions: walk back fire laser");
        }

        // change the bullet barrage angle every few seconds
        if ("nttlive_throne_anglechange" not in self) nttlive_throne_anglechange = 0;
        nttlive_throne_anglechange -= current_time_scale;
        if (nttlive_throne_anglechange <= 0) {
            nttlive_throne_anglechange = 30 * 4;
            addangle = choose(-30, 0, 30);
        }

        // laser charging
        if ("nttlive_throne_lasercharge" not in self) nttlive_throne_lasercharge = 0;
        if ("nttlive_throne_maxlasercharge" not in self) nttlive_throne_maxlasercharge = 10 + global.viewers * global.config.viewerScalingFactor;
        if ("nttlive_throne_lasershake_x" not in self) nttlive_throne_lasershake_x = 0;
        if ("nttlive_throne_lasershake_y" not in self) nttlive_throne_lasershake_y = 0;
        var maxshake = (nttlive_throne_lasercharge / nttlive_throne_maxlasercharge) * 20;
        nttlive_throne_lasershake_x += (random_range(-maxshake, maxshake) - nttlive_throne_lasershake_x) * 0.4 * current_time_scale;
        nttlive_throne_lasershake_y += (random_range(-maxshake, maxshake) - nttlive_throne_lasershake_y) * 0.4 * current_time_scale;
        if (nttlive_throne_lasercharge >= nttlive_throne_maxlasercharge) {
            nttlive_throne_lasercharge = 0;
            with (instance_create(0, 0, NothingBeam)) {
                creator = other;
            }
        }

        // controls
        for (var i = 0; i < array_length(global.messages); i++) if (message_flag_check(global.messages[i], "thronecontrol")) {
            var is_control = 1;
            switch (global.messages[i].content) {
                case "fire":
                    ammo = 1;
                    event_perform(ev_alarm, 2);
                    break;
                case "walk":
                    walk = 5;
                    walkdir = 270;
                    break;
                case "back":
                    walk = 15;
                    walkdir = 90;
                    break;
                case "laser":
                    nttlive_throne_lasercharge++;
                    break;
                default:
                    is_control = 0;
                    break;
            }
            if (is_control) {
                message_flag_check(global.messages[i], "enemychatterhidden");
            }
        }
    }
}

with (GenCont) {
    if ("nttlive_levelcheck" not in self) {
        nttlive_levelcheck = 1;

        // on each portal, give rads based on the number of viewers
        // global.viewer_rads = round(global.viewers * 0.5);
        // GameCont.rad += global.viewer_rads;
    }
}

// shake the screen when people type a specific emote
for (var i = 0; i < array_length(global.messages); i++) if (message_flag_check(global.messages[i], "screenshake")) {
    if (string_pos("Kreygasm", global.messages[i].content) != 0) {
        with (Player) view_shake_at(x, y, 50);
    }
}

// display viewer usernames and messages above enemies
if (!mod_script_call("mod", "nttlive_util", "custom_object_exists", "EnemyChatterDisplay")) {
    enemy_chatter_display_create();
}
if ("available_usernames" in global.controller) {
    var enemies = mod_script_call("mod", "nttlive_util", "array_shuffle", instances_matching(enemy, "", undefined));
    with (enemies) {
        if (instance_exists(self)) {
            if ("nttlive_message" not in self) {
                nttlive_message = "";
                nttlive_messagetime = 0;
                nttlive_colour = -1;
            }
            nttlive_messagetime -= current_time_scale;
            if ("nttlive_nickname" not in self) {
                if (ds_list_size(global.controller.available_usernames) > 0) {
                    var new_username_ind = irandom(ds_list_size(global.controller.available_usernames) - 1);
                    var new_username = ds_list_find_value(global.controller.available_usernames, new_username_ind);
                    nttlive_nickname = new_username;
                    nttlive_colour = mod_script_call("mod", "nttlive_util", "array_random", [
                        c_red,
                        c_green,
                        c_blue,
                        make_color_rgb(178, 34, 34),
                        make_color_rgb(255, 127, 80),
                        make_color_rgb(154, 205, 50),
                        make_color_rgb(255, 69, 0),
                        make_color_rgb(46, 139, 87),
                        make_color_rgb(218, 165, 32),
                        make_color_rgb(210, 105, 30),
                        make_color_rgb(95, 158, 160),
                        make_color_rgb(30, 144, 255),
                        make_color_rgb(255, 105, 180),
                        make_color_rgb(138, 43, 226),
                        make_color_rgb(0, 255, 127)
                    ]);
                    ds_list_delete(global.controller.available_usernames, new_username_ind);

                    // the messages don't show up while there are no enemies with that nickname
                    // as a result, all of these messages will immeditately show up when this nickname gets assigned to an enemy
                    // to prevent that, we will mark these messages as already shown
                    for (var i = 0; i < array_length(global.messages); i++) {
                        if (string_lower(global.messages[i].author) == string_lower(nttlive_nickname)) {
                            message_flag_check(global.messages[i], "enemychatter");
                        }
                    }
                }
            } else {
                for (var i = 0; i < array_length(global.messages); i++) {
                    var msg = global.messages[i];
                    if (!message_has_flag(msg, "enemychatter")) {
                        if (string_lower(msg.author) == string_lower(nttlive_nickname)) {
                            message_flag_check(msg, "enemychatter");
                            if (fork()) {
                                wait 2;
                                if (instance_exists(self) && message_flag_check(msg, "enemychatterhidden")) {
                                    nttlive_messagetime = 30 * 2;
                                    nttlive_message = msg.content;
                                    nttlive_colour = make_color_rgb(msg.color.red, msg.color.green, msg.color.blue);
                                    if (global.config.displayMessagesInNTTChat == json_true) {
                                        var tracemsg = msg.author + ": " + msg.content;
                                        if (global.config.displayMessagesAboveEnemies == json_true) {
                                            tracemsg = "[" + string_upper(mod_script_call("mod", "nttlive_util", "enemy_get_alias_inst", self)) + "] " + tracemsg;
                                        }
                                        trace_color(tracemsg, make_color_rgb(msg.color.red, msg.color.green, msg.color.blue));
                                    }
                                }
                                exit;
                            }
                        }
                    }
                }
            }
        }
    }
} else {
    global.controller.available_usernames = ds_list_create();
    refill_available_enemy_usernames();
}

with (Menu) {
    if ("nttlive_campchar_viewers" not in self) {
        nttlive_campchar_viewers = 0;
    }
    var viewersleft = global.viewers - nttlive_campchar_viewers;
    if (viewersleft > 0) {
        nttlive_campchar_viewers++;
        with (mod_script_call("mod", "nttlive_util", "instance_random", Floor)) {
            if ("nttlive_floorexplo" not in self && distance_to_object(Campfire) >= 16) {
                with (instance_create(x + 16 + random_range(-10, 10), y + 16 + random_range(-10, 10), CampChar)) {
                    nttlive_viewer_campchar = 1;
                    var campsprites = [sprCrystalMenu, sprEyesMenu, sprMeltingMenu, sprPlantMenu, sprVenuzMenu, sprSteroidsMenu, sprRobotMenu, sprRebelMenu, sprHorrorMenu, sprRogueMenu];
                    sprite_index = mod_script_call("mod", "nttlive_util", "array_random", campsprites);
                    spr_slct = sprite_index;
                    spr_menu = sprite_index;
                    spr_from = sprite_index;
                    spr_to = sprite_index;
                    image_index = random(image_number);
                    image_xscale = choose(1, -1);
                    image_blend = make_color_rgb(100, 100, 100);
                }
                viewersleft--;
            }
        }
    }
    if (viewersleft < 0) {
        nttlive_campchar_viewers--;
        var whiletries = 1000;
        while (whiletries > 0) {
            var campchars = instances_matching(CampChar, "nttlive_viewer_campchar", 1);
            if (array_length(campchars) > 0) {
                var viewer_campchar = mod_script_call("mod", "nttlive_util", "array_random", campchars);
                with (viewer_campchar) {
                    instance_destroy();
                }
                whiletries = 0;
            }
            whiletries--;
        }
    }
}

// mutation/ultra/crown voting
if (global.config.mutationAndCrownVoting == json_true) {
    if (instance_exists(LevCont)) {
        for (var i = 0; i < array_length(global.skill_voting_types); i++) {
            if (array_length(instances_matching(global.skill_voting_types[i].button_object, "nttlive_votedskill", undefined)) > 0) {
                global.skill_voting_type = global.skill_voting_types[i];
                var message = "TwitchVotes Vote for the " + global.skill_voting_type.displayname + "! ";
                var skillnum = 1;
                global.skill_voting = [];
                with (global.skill_voting_type.button_object) {
                    array_push(global.skill_voting, {skillicon: mod_script_call("mod", "nttlive_util", "instance_variables_grab", self), skill_name: name, skill_sprite: {spr: sprite_index, subimg: image_index}, votes: 0, visual_height: 0});
                    message += string(skillnum) + " for " + string_upper(name);
                    instance_destroy();
                    if (instance_exists(global.skill_voting_type.button_object)) {
                        message += ", ";
                    }
                    skillnum++;
                }
                send_message(message);
                global.skill_voting_time = global.skill_voting_maxtime;
            }
        }

        if (array_length(global.skill_voting) > 0) {
            for (var i = 0; i < array_length(global.messages); i++) if (message_flag_check(global.messages[i], "skillvoting")) {
                var skillnum = real(global.messages[i].content) - 1;
                if (skillnum >= 0 && skillnum < array_length(global.skill_voting)) {
                    message_flag_check(global.messages[i], "enemychatterhidden");
                    global.skill_voting[skillnum].votes++;
                }
            }

            with (LevCont) splatanim = 0;

            var total_votes = 0;
            for (var i = 0; i < array_length(global.skill_voting); i++) total_votes += global.skill_voting[i].votes;
            for (var i = 0; i < array_length(global.skill_voting); i++) {
                global.skill_voting[i].visual_height += (global.skill_voting[i].votes / max(total_votes, 1) - global.skill_voting[i].visual_height) * 0.2 * current_time_scale;
            }

            global.skill_voting_time -= current_time_scale;
            if (global.skill_voting_time <= 0) {
                var winners = [];
                var winner_votes = 0;
                for (var i = 0; i < array_length(global.skill_voting); i++) {
                    if (global.skill_voting[i].votes >= winner_votes) {
                        if (global.skill_voting[i].votes > winner_votes) {
                            winner_votes = global.skill_voting[i].votes;
                            winners = [];
                        }
                        array_push(winners, global.skill_voting[i]);
                    }
                }
                sound_play(sndMenuCredits);
                var winnerskill = mod_script_call("mod", "nttlive_util", "array_random", winners);
                var message = "TwitchVotes The voting is over! BROADCASTER_NAME gets " + winnerskill.skill_name;
                send_message(message);

                with (instance_create(0, 0, global.skill_voting_type.button_object)) {
                    mod_script_call("mod", "nttlive_util", "instance_variables_replace", self, winnerskill.skillicon);
                    nttlive_votedskill = 1;
                    num = 0;
                }

                with (LevCont) splatanim = 1;

                global.skill_voting = [];
            }
        }
        LevCont.select = 0;
        LevCont.maxselect = 0;
    } else {
        for (var i = 0; i < array_length(global.messages); i++) {
            message_flag_check(global.messages[i], "skillvoting");
        }
    }
}

// clear messages during level gen
if (instance_exists(GenCont)) {
    global.erase_messages = 1;
}

// revive voting
if (global.secondlife) {
    global.secondlife_visual += (global.secondlife_votes - global.secondlife_visual) * 0.3 * current_time_scale;
    global.secondlife_time -= current_time_scale;
    if (global.secondlife_time > 0) {
        for (var i = 0; i < array_length(global.messages); i++) if (message_flag_check(global.messages[i], "secondlife")) {
            switch (string_upper(global.messages[i].content)) {
                case "YES":
                    message_flag_check(global.messages[i], "enemychatterhidden");
                    global.secondlife_votes++;
                    break;
                case "NO":
                    message_flag_check(global.messages[i], "enemychatterhidden");
                    global.secondlife_votes--;
                    break;
            }
        }
        if (global.secondlife_votes < 0) global.secondlife_votes = 0;
        if (global.secondlife_votes >= global.secondlife_maxvotes) {
            global.secondlife = 0;
            sound_play(sndMutLastWish);
            with (Player) if ("secondlife_dead" in self && secondlife_dead) {
                my_health = round(maxhealth / 2);
                candie = 1;
                nexthurt = current_frame + 30;
                canfire = secondlife_canfire;
                canspec = secondlife_canspec;
                canswap = secondlife_canswap;
                canaim = secondlife_canaim;
                mask_index = secondlife_mask;
                secondlife_dead = 0;
                with (instances_matching_ne(projectile, "team", team)) if (distance_to_object(other) <= 32) instance_delete(self);
                with (instances_matching_ne(enemy, "team", team)) if (distance_to_object(other) <= 32) {
                    var pushdist = 32 - distance_to_object(other);
                    var pushdir = point_direction(other.x, other.y, x, y);
                    var whiletries = 1000;
                    while (whiletries > 0) {
                        var new_x = x + lengthdir_x(pushdist, pushdir);
                        var new_y = y + lengthdir_y(pushdist, pushdir);
                        if (!place_meeting(new_x, new_y, Wall)) {
                            x = new_x;
                            y = new_y;
                            whiletries = 0;
                        } else {
                            pushdir = random(360);
                        }
                        whiletries--;
                    }
                }
            }
            send_message("TwitchVotes The voting is over! BROADCASTER_NAME was given another chance!");
        }
    } else {
        global.secondlife = 0;
        sound_play(sndStatueDead);
        with (Player) if ("secondlife_dead" in self && secondlife_dead) {
            my_health = 0;
            candie = 1;
            canfire = secondlife_canfire;
            canspec = secondlife_canspec;
            canswap = secondlife_canswap;
            canaim = secondlife_canaim;
            mask_index = secondlife_mask;
        }
        send_message("TwitchVotes The voting is over! BROADCASTER_NAME does not get another chance riPepperonis");
    }
}

// custom ammo
with (Player) {
    if ("nttlive_streamammo_index" not in self) nttlive_streamammo_index = ammo_create("MESSAGES", 2, 100);
    if ("nttlive_streamammo_last" not in self) nttlive_streamammo_last = 0;
    if (nttlive_streamammo_last > ammo[nttlive_streamammo_index]) {
        nttlive_streamammo_last = ammo[nttlive_streamammo_index];
    }
    // if a player gets messages from an ammo pickup, remove that ammo and give another ammo type instead
    if (ammo[nttlive_streamammo_index] > nttlive_streamammo_last) {
        var picked = (ammo[nttlive_streamammo_index] - nttlive_streamammo_last) / typ_ammo[nttlive_streamammo_index];
        ammo[nttlive_streamammo_index] = nttlive_streamammo_last;
        var types = [];
        for (var i = 0; i < array_length(ammo); i++) if (i != 0 && i != nttlive_streamammo_index) array_push(types, i);
        var mytype = mod_script_call("mod", "nttlive_util", "array_random", types);
        var amount = typ_ammo[mytype] * picked;
        var str = "+" + string(amount);
        ammo[mytype] += amount;
        if (ammo[mytype] > typ_amax[mytype]) {
            ammo[mytype] = typ_amax[mytype];
            str = "MAX";
        }
        with (instance_create(x, y, PopupText)) mytext = str + " " + other.typ_name[mytype];
        with (PopupText) if (string_pos(other.typ_name[other.nttlive_streamammo_index], mytext) != 0) {
            instance_destroy();
        }
    }
    for (var i = 0; i < array_length(global.messages); i++) if (message_flag_check(global.messages[i], "customammocheck")) {
        var msg = global.messages[i];
        if (fork()) {
            wait 3;
            if (instance_exists(self) && message_flag_check(msg, "enemychatterhidden")) {
                ammo[nttlive_streamammo_index] += global.config.specialAmmoPerMessage;
                if (ammo[nttlive_streamammo_index] > typ_amax[nttlive_streamammo_index]) ammo[nttlive_streamammo_index] = typ_amax[nttlive_streamammo_index];
                nttlive_streamammo_last = ammo[nttlive_streamammo_index];
            }
            exit;
        }
    }
}

#define end_step
if (global.secondlife_count > 0) {
    var dead_players = 0; // check if all existing players are dead (for co-op support)
    with (Player) {
        if (mod_script_call("mod", "nttlive_util", "player_died", self)) {
            dead_players++;
        }
    }
    if (dead_players >= instance_number(Player)) {
        with (Player) {
            global.secondlife = 1;
            global.secondlife_count--;
            global.secondlife_votes = 0;
            global.secondlife_maxvotes = 10 + global.viewers * global.config.viewerScalingFactor;
            global.secondlife_visual = 0;
            global.secondlife_time = global.secondlife_maxtime;
            secondlife_revive_x = x;
            secondlife_revive_y = y;
            secondlife_canfire = canfire;
            canfire = 0;
            secondlife_canspec = canspec;
            canspec = 0;
            secondlife_canswap = canswap;
            canswap = 0;
            secondlife_canaim = canaim;
            canaim = 0;
            secondlife_dead = 1;
            candie = 0;
            secondlife_mask = mask_index;
            mask_index = mskNone;
            send_message("TwitchVotes BROADCASTER_NAME has died! Do we want to revive them? Vote YES or NO!");
        }
    }
}
if (global.secondlife) {
    with (Player) if ("secondlife_dead" in self && secondlife_dead) {
        candie = 0;
        if ("secondlife_revive_x" in self) x = secondlife_revive_x;
        if ("secondlife_revive_y" in self) y = secondlife_revive_y;
        canfire = 0;
        canspec = 0;
        canswap = 0;
        canaim = 0;
        mask_index = mskNone;
    }
}

#define draw_gui
if (instance_exists(GenCont)) {
    if (global.viewer_rads > 0) {
        draw_set_font(fntM);
        draw_set_halign(fa_middle);
        draw_text_nt(game_width / 2, 50, mod_script_call("mod", "nttlive_util", "text_blink", "@g") + string(global.viewer_rads) + " VIEWERS   +" + string(global.viewer_rads) + " RADS!");
        draw_set_halign(fa_left);
    }
}
if (array_length(global.skill_voting) > 0) {
    draw_set_halign(fa_middle);
    draw_set_valign(fa_top);
    draw_set_font(fntChat);
    draw_text_nt(game_width / 2, 2, `@(color:${c_twitch})` + "Voting ends in " + string(ceil(global.skill_voting_time / 30)) + "s");
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_font(fntM);

    draw_set_halign(fa_middle);
    draw_set_valign(fa_top);
    draw_set_font(fntM);
    var topmsgoffset = 0;
    with (LevCont) topmsgoffset = titley;
    draw_sprite_ext(sprMainMenuSplat, 3, game_width / 2, 68 + 4 + topmsgoffset, 1.5, 0.6, 0, c_white, 1);
    draw_text_nt(game_width / 2, 68 + topmsgoffset, mod_script_call("mod", "nttlive_util", "text_blink", "@g") + "VOTE FOR THE " + string_upper(global.skill_voting_type.displayname) + "!");
    draw_set_font(fntChat);
    with (global.controller) {
        var skill_offset = 32;
        for (var i = 0; i < array_length(global.skill_voting); i++) {
            var draw_x = game_width / 2 - skill_offset * array_length(global.skill_voting) / 2 + i * skill_offset;
            var draw_y = game_height - 40;
            var height_offset = global.skill_voting[i].visual_height * (game_height - 140);
            var sprite = global.skill_voting[i].skill_sprite.spr;
            var subimage = global.skill_voting[i].skill_sprite.subimg;
            draw_x += sprite_get_width(sprite) / 2 - (sprite_get_width(sprite) - sprite_get_xoffset(sprite)) + skill_offset / 2;
            draw_sprite(
                sprite, subimage,
                draw_x,
                draw_y - height_offset + sprite_get_height(sprite) / 2 - (sprite_get_height(sprite) - sprite_get_yoffset(sprite))
            );
            draw_text_nt(draw_x - sprite_get_xoffset(sprite) + sprite_get_width(sprite) / 2, draw_y - height_offset + 2, string(global.skill_voting[i].votes));
            draw_set_font(fntM);
            draw_text_nt(draw_x - sprite_get_xoffset(sprite) + sprite_get_width(sprite) / 2, draw_y + 20, string(i + 1));
            draw_set_font(fntChat);
        }
    }
    draw_set_halign(fa_left);
    draw_set_font(fntM);

    draw_timebar(global.skill_voting_time / global.skill_voting_maxtime);
}
if (global.config.chatControlsTheThrone == json_true) {
    with (Nothing) {
        draw_set_halign(fa_middle);
        draw_set_valign(fa_top);
        draw_set_font(fntChat);
        draw_text_nt(game_width / 2, 2, `@(color:${c_twitch})` + string(floor(my_health / maxhealth * 100)) + "% done!");
        draw_text_nt(game_width / 2, 12, mod_script_call("mod", "nttlive_util", "text_blink", "@r") + "THE THRONE IS CONTROLLED BY THE CHAT!");
        draw_text_nt(game_width / 2, 12 + string_height("W"), "@r" + mod_script_call("mod", "nttlive_util", "text_blink", "@w") + "WALK | BACK | FIRE | LASER");
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        draw_set_font(fntM);

        draw_timebar(my_health / maxhealth);
    }
}
if (instance_exists(Menu)) {
    draw_set_halign(fa_middle);
    draw_set_valign(fa_top);
    draw_set_font(fntChat);
    draw_text_nt(game_width / 2, 12, `@(color:${c_twitch})` + string(global.viewers) + " viewers sitting by the campfire");
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_font(fntM);
}
if (global.secondlife) {
    draw_set_color(c_black);
    draw_set_alpha(0.5);
    draw_rectangle(0, 0, game_width, game_height, 0);
    draw_set_alpha(1);
    draw_set_color(c_white);

    draw_set_halign(fa_middle);
    draw_set_valign(fa_top);
    draw_set_font(fntChat);
    draw_text_nt(game_width / 2, 2, `@(color:${c_twitch})` + string(ceil(global.secondlife_time / 30)) + "s left!");
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_font(fntM);

    draw_timebar(1 - (global.secondlife_time / global.secondlife_maxtime));

    draw_set_halign(fa_middle);
    draw_text_nt(game_width / 2, game_height / 2 - 50, mod_script_call("mod", "nttlive_util", "text_blink", "@y") + "VOTE TO REVIVE!");
    draw_set_font(fntChat);
    if (global.config.revivesPerRun > 1) {
        draw_text_nt(game_width / 2, game_height / 2 - 50 + 8, "@s(" + string(global.secondlife_count + 1) + " revive" + (global.secondlife_count > 1 ? "s" : "") + " left)");
    }
    draw_set_font(fntM);

    var containersprt = mod_script_call("mod", "nttlive_sprites", "get", "sprSecondLifeContainer");
    var fillingsprt = mod_script_call("mod", "nttlive_sprites", "get", "sprSecondLifeFilling");
    var pulsesprt = mod_script_call("mod", "nttlive_sprites", "get", "sprSecondLifePulse");

    if (surface_exists(global.secondlife_filling)) {
        draw_surface(global.secondlife_filling, game_width / 2 - surface_get_width(global.secondlife_filling) / 2, game_height / 2 - surface_get_height(global.secondlife_filling) / 2);
    }
    draw_sprite(containersprt, 0, game_width / 2, game_height / 2);
    var pulsetime = 30 * 1.2;
    var pulsescale = 1 + 0.5 * ((current_frame * (1 / current_time_scale) % pulsetime) / 30);
    var pulsealpha = 0.8 * (1 - (current_frame * (1 / current_time_scale) % pulsetime) / 30);
    draw_sprite_ext(pulsesprt, 0, game_width / 2, game_height / 2, pulsescale, pulsescale, 0, c_white, pulsealpha);

    draw_set_valign(fa_center);
    draw_text_nt(game_width / 2 - sprite_get_width(containersprt) / 2 - 40, game_height / 2, mod_script_call("mod", "nttlive_util", "text_blink", "@r") + "NO");
    draw_text_nt(game_width / 2 + sprite_get_width(containersprt) / 2 + 40, game_height / 2, mod_script_call("mod", "nttlive_util", "text_blink", "@g") + "YES");
    draw_set_valign(fa_top);
    draw_set_halign(fa_left);
}

#define draw
if (global.secondlife) {
    var containersprt = mod_script_call("mod", "nttlive_sprites", "get", "sprSecondLifeContainer");
    var fillingsprt = mod_script_call("mod", "nttlive_sprites", "get", "sprSecondLifeFilling");
    var erasesprt = mod_script_call("mod", "nttlive_sprites", "get", "sprSecondLifeErase");

    if (!surface_exists(global.secondlife_filling)) {
        if (sprite_get_width(containersprt) != 16) {
            global.secondlife_filling = surface_create(sprite_get_width(containersprt), sprite_get_height(containersprt));
        }
    } else {
        surface_set_target(global.secondlife_filling);
        draw_clear_alpha(c_white, 0);
        draw_sprite(fillingsprt, current_frame * (1 / current_time_scale) * 0.4, 0, surface_get_height(global.secondlife_filling) - sprite_get_height(fillingsprt) * (global.secondlife_visual / global.secondlife_maxvotes));
        draw_set_blend_mode(bm_subtract);
        draw_sprite(erasesprt, 0, 0, 0);
        draw_set_blend_mode(bm_normal);
        surface_reset_target();
    }
}

#define draw_pause
global.erase_messages = 1;

#define cleanup
if (surface_exists(global.secondlife_filling)) surface_destroy(global.secondlife_filling);

#define ammo_create(_name, _pickup, _max)
array_push(ammo, 0);
array_push(typ_name, _name);
array_push(typ_ammo, _pickup);
array_push(typ_amax, _max);
return array_length(ammo) - 1;

#define send_message(msg)
string_save(msg, "sendmessage/message_" + string(irandom(current_frame)) + ".txt");

#define draw_timebar(time_left)
draw_set_color(c_white);
draw_rectangle(0, 0, game_width, 2, 0);
draw_set_color(c_twitch);
draw_rectangle((game_width / 2) * (1 - time_left), 0, game_width / 2, 2, 0);
draw_rectangle(game_width / 2, 0, game_width / 2 + (game_width / 2) * time_left, 2, 0);
draw_set_color(c_white);

#define message_has_flag(message, flag)
var has_flag = 0;
if (ds_list_find_index(message.flaglist, flag) != -1) {
    has_flag = 1;
}
return has_flag;

// applies this flag to the message. returns 1 if the flag wasn't added before, otherwise returns 0
#define message_flag_check(message, flag)
var not_flagged = !message_has_flag(message, flag);
if (not_flagged) ds_list_add(message.flaglist, flag);
return not_flagged;

#define refill_available_enemy_usernames()
if (instance_exists(global.controller)) {
    for (var i = 0; i < array_length(global.chatters); i++) {
        if (ds_list_find_index(global.controller.available_usernames, global.chatters[i]) == -1) {
            var claimed_by_enemy = false;
            with (instances_matching(enemy, "nttlive_nickname", global.chatters[i])) {
                claimed_by_enemy = true;
            }
            if (!claimed_by_enemy) {
                ds_list_add(global.controller.available_usernames, global.chatters[i]);
            }
        }
    }
}

#define enemy_chatter_display_create()
with (instance_create(0, 0, CustomObject)) {
    depth = -12;
    name = "EnemyChatterDisplay";
    on_draw = script_ref_create(enemy_chatter_display_draw);
    return self;
}

#define enemy_chatter_display_draw
if (global.config.displayMessagesAboveEnemies == json_true) {
    with (instances_matching_ne(hitme, "nttlive_nickname", undefined)) {
        if (nttlive_colour != -1) {
            draw_set_font(fntSmall);
            draw_set_halign(fa_middle);
            draw_set_valign(fa_bottom);
            draw_text_nt(x, bbox_top, `@(color:${nttlive_colour})` + nttlive_nickname);
            if (nttlive_messagetime > 0 && nttlive_message != "") {
                var add_dots = 0;
                var maxlength = 32;
                if (string_length(nttlive_message) > maxlength) add_dots = 1;
                draw_text_nt(x, bbox_top - string_height("A"), `"` + string_copy(nttlive_message, 1, maxlength) + (add_dots ? "..." : "") + `"`);
            }
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
            draw_set_font(fntM);
        }
    }
}

#define throne_chatter_display_create()
with (instance_create(0, 0, CustomObject)) {
    depth = -12;
    name = "ThroneChatterDisplay";
    on_draw = script_ref_create(throne_chatter_display_draw);
    return self;
}

#define throne_chatter_display_draw
if (global.config.chatControlsTheThrone == json_true) {
    with (Nothing) {
        if ("nttlive_throne_lasershake_x" in self and "nttlive_throne_lasershake_y" in self) {
            draw_set_font(fntM);
            draw_set_halign(fa_middle);
            draw_set_valign(fa_top);
            draw_text_nt(x, bbox_bottom + 4, mod_script_call("mod", "nttlive_util", "text_blink", "v") + " WALK " + mod_script_call("mod", "nttlive_util", "text_blink", "v"));
            draw_set_valign(fa_bottom);
            draw_text_nt(x, bbox_top - 4, mod_script_call("mod", "nttlive_util", "text_blink", "^") + " BACK " + mod_script_call("mod", "nttlive_util", "text_blink", "^"));
            draw_set_valign(fa_center);
            draw_text_nt(x + nttlive_throne_lasershake_x, bbox_bottom - 45 + nttlive_throne_lasershake_y, "LASER");
            draw_set_valign(fa_top);
            draw_set_halign(fa_left);
            draw_text_nt(bbox_left + 45, bbox_bottom - 30, "FIRE");
            draw_set_halign(fa_right);
            draw_text_nt(bbox_right - 45, bbox_bottom - 30, "FIRE");
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
            draw_set_font(fntM);
        }
    }
}