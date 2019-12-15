#define init
global.messages = [];
global.erase_messages = 0;

global.fileupdate_time = 0;
global.fileupdate_maxtime = 30 * 60;

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
global.skill_voting_maxtime = 30 * 15;
global.skill_voting_time = 0;

#macro c_twitch make_color_rgb(145, 70, 255);

global.controller = noone;
with (instances_matching(CustomObject, "name", "NTTLiveCont")) instance_destroy();

#define game_start
global.skill_voting = [];
global.skill_voting_time = 0;

#define step
// mark explo floors to differentiate from regular floors
with (FloorExplo) {
    nttlive_floorexplo = 1;
}

// disable skill voting in menu
if (instance_exists(Menu)) {
    global.skill_voting = [];
    global.skill_voting_time = global.skill_voting_maxtime;
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

// update the chatter list and viewer count
global.fileupdate_time -= current_time_scale;
if (global.fileupdate_time <= 0) {
    global.fileupdate_time = global.fileupdate_maxtime;

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

// create the controller
if (!instance_exists(global.controller)) {
    with (instance_create(0, 0, CustomObject)) {
        name = "NTTLiveCont";
        persistent = 1;
        global.controller = self;
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
with (Nothing) {
    // disable the AI
    alarm1 = 9999;
    alarm2 = 9999;

    if ("nttlive_throne_initmessage" not in self) {
        nttlive_throne_initmessage = 1;
        send_message("twitchLit BROADCASTER_NAME reached the Throne! This is your chance to defeat them - you control the Throne! Type the following words to perform respective actions: walk back fire laser");
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
    if ("nttlive_throne_maxlasercharge" not in self) nttlive_throne_maxlasercharge = 10 + global.viewers;
    if ("nttlive_throne_lasershake_x" not in self) nttlive_throne_lasershake_x = 0;
    if ("nttlive_throne_lasershake_y" not in self) nttlive_throne_lasershake_y = 0;
    nttlive_throne_lasercharge -= 0.01 * current_time_scale;
    if (nttlive_throne_lasercharge < 0) {
        nttlive_throne_lasercharge = 0;
    }
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
                walk = 20;
                walkdir = 90;
                break;
            case "laser":
                nttlive_throne_lasercharge++;
                break;
        }
    }
}

with (GenCont) {
    if ("nttlive_levelcheck" not in self) {
        nttlive_levelcheck = 1;

        // on each portal, give rads based on the number of viewers
        // global.viewer_rads = round(global.viewers * 0.5);
        // GameCont.rad += global.viewer_rads;

        // also refill the chatter list
        global.controller.available_usernames = ds_list_create();
        for (var i = 0; i < array_length(global.chatters); i++) {
            ds_list_add(global.controller.available_usernames, global.chatters[i]);
        }
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
    with (enemies) if (instance_exists(self)) {
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
            for (var i = 0; i < array_length(global.messages); i++) if (message_flag_check(global.messages[i], "enemychatter")) {
                if (string_lower(global.messages[i].author) == string_lower(nttlive_nickname)) {
                    nttlive_messagetime = 30 * 2;
                    nttlive_message = global.messages[i].content;
                    nttlive_colour = make_color_rgb(global.messages[i].color.red, global.messages[i].color.green, global.messages[i].color.blue);
                    trace_color("[" + string_upper(enemy_get_alias(self)) + "] " + global.messages[i].author + ": " + global.messages[i].content, make_color_rgb(global.messages[i].color.red, global.messages[i].color.green, global.messages[i].color.blue));
                }
            }
        }
    }
} else {
    global.controller.available_usernames = ds_list_create();
}

// mutation/ultra/crown voting
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

#define draw_pause
global.erase_messages = 1;

#define send_message(msg)
string_save(msg, "sendmessage/message_" + string(irandom(current_frame)) + ".txt");

#define draw_timebar(time_left)
draw_set_color(c_white);
draw_rectangle(0, 0, game_width, 2, 0);
draw_set_color(c_twitch);
draw_rectangle((game_width / 2) * (1 - time_left), 0, game_width / 2, 2, 0);
draw_rectangle(game_width / 2, 0, game_width / 2 + (game_width / 2) * time_left, 2, 0);
draw_set_color(c_white);

#define message_flag_check(message, flag)
var not_flagged = 1;
if (ds_list_find_index(message.flaglist, flag) != -1) {
    not_flagged = 0;
}
ds_list_add(message.flaglist, flag);
return not_flagged;

#define enemy_get_alias(_obj)
switch (_obj.object_index) {
    case BanditBoss: return "Big Bandit";
    case ScrapBoss: return "Big Dog";
    case ScrapBossMissile: return "Missile";
    case LilHunter: return "Lil' Hunter";
    case Nothing: return "Throne";
    case Nothing2: return "Throne II";
    case FrogQueen: return "Mom";
    case HyperCrystal: return "Hyper Crystal";
    case TechnoMancer: return "Technomancer";
    case Last: return "Captain";
    case MeleeBandit: return "Assassin";
    case SuperMimic: return "Health Mimic";
    case SnowTank: return "Snowtank";
    case GoldSnowTank: return "Golden Snowtank";
    case SnowBot: return "Snowbot";
    case SnowBotCar: return "Snowbot";
    case FireBaller: return "Fireballer";
    case SuperFireBaller: return "Super Fireballer";
    case OasisBoss: return "Big Fish";
    case BoneFish: return "Bonefish";
    case InvLaserCrystal: return "Laser Crystal";
    case InvSpider: return "Spider";
    case EnemyHorror: return "Horror";
    case CustomHitme:
        var str = "CustomEnemy";
        if ("name" in _obj) str = _obj.name;
        var newstr = "";
        for (var i = 1; i <= string_length(str); i++) {
            var char = string_char_at(str, i);
            if (char == string_upper(char) && i > 1) newstr += " ";
            newstr += char;
        }
        return;
    default:
        var str = object_get_name(_obj.object_index);
        var newstr = "";
        for (var i = 1; i <= string_length(str); i++) {
            var char = string_char_at(str, i);
            if (char == string_upper(char) && i > 1) newstr += " ";
            newstr += char;
        }
        return newstr;
}

#define enemy_chatter_display_create()
with (instance_create(0, 0, CustomObject)) {
    depth = -12;
    name = "EnemyChatterDisplay";
    on_draw = script_ref_create(enemy_chatter_display_draw);
    return self;
}

#define enemy_chatter_display_draw
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

#define throne_chatter_display_create()
with (instance_create(0, 0, CustomObject)) {
    depth = -12;
    name = "ThroneChatterDisplay";
    on_draw = script_ref_create(throne_chatter_display_draw);
    return self;
}

#define throne_chatter_display_draw
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