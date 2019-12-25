#define event_name
return "kin";

#define event_start
var message = "TwitchVotes In a few levels, all enemies will be of the same type! Vote to choose the enemy type: ";
with (mod_variable_get("mod", "nttlive", "controller")) {
    kin_voting = [];
    var maxtypes = 3;

    for (var i = 0; i < maxtypes; i++) {
        var enemydifficulty = "easy";
        if (random((1 / (0.1 * GameCont.hard + 1)) * 100) < 1) enemydifficulty = "medium";
        if (random((1 / (0.02 * GameCont.hard + 1)) * 100) < 1) enemydifficulty = "hard";
        var myenemy = noone;
        var whiletries = 1000;
        while (whiletries > 0) {
            myenemy = getenemy(enemydifficulty);
            if (myenemy != noone) {
                var alreadypicked = 0;
                for (var k = 0; k < array_length(kin_voting); k++) {
                    if (kin_voting[k].type == myenemy) alreadypicked = 1;
                }
                if (!alreadypicked) {
                    whiletries = 0;
                }
            }
            whiletries--;
        }
        var enemysprite = sprErrorGun;
        with (instance_create(-9999, -9999, myenemy)) {
            enemysprite = spr_idle;
            instance_delete(self);
        }
        array_push(kin_voting, {type: myenemy, sprt: enemysprite, frame: 0, votes: 0, visual_height: 0});
        message += "e" + string(i + 1) + " for " + mod_script_call("mod", "nttlive_util", "enemy_get_alias", myenemy);
        if (i < maxtypes - 1) {
            message += ", v";
        }
    }
}
mod_script_call("mod", "nttlive", "send_message", message);
mod_variable_set("mod", "nttlive_events", "eventtext", "b:@y:bVOTE TO SET ALL ENEMIES TO:");

#define event_step
for (var i = 0; i < array_length(mod_variable_get("mod", "nttlive", "messages")); i++) if (mod_script_call("mod", "nttlive", "message_flag_check", mod_variable_get("mod", "nttlive", "messages")[i], "kin")) {
    with (mod_variable_get("mod", "nttlive", "controller")) {
        if (string_copy(mod_variable_get("mod", "nttlive", "messages")[i].content, 1, 1) == "e") {
            mod_script_call("mod", "nttlive", "message_flag_check", mod_variable_get("mod", "nttlive", "messages")[i], "enemychatterhidden");
            var typenum = real(string_delete(mod_variable_get("mod", "nttlive", "messages")[i].content, 1, 1)) - 1;
            if (typenum >= 0 && typenum < array_length(kin_voting)) {
                kin_voting[typenum].votes++;
            }
        }
    }
}

with (mod_variable_get("mod", "nttlive", "controller")) {
    var total_votes = 0;
    for (var i = 0; i < array_length(kin_voting); i++) total_votes += kin_voting[i].votes;
    for (var i = 0; i < array_length(kin_voting); i++) {
        kin_voting[i].visual_height += (kin_voting[i].votes / max(total_votes, 1) - kin_voting[i].visual_height) * 0.2 * current_time_scale;
        kin_voting[i].frame += 0.4 * current_time_scale;
    }
}

#define event_end
var winners = [];
var winner_votes = 0;
with (mod_variable_get("mod", "nttlive", "controller")) {
    for (var i = 0; i < array_length(kin_voting); i++) {
        if (kin_voting[i].votes >= winner_votes) {
            if (kin_voting[i].votes > winner_votes) {
                winner_votes = kin_voting[i].votes;
                winners = [];
            }
            array_push(winners, kin_voting[i].type);
        }
    }
}
var winnertype = mod_script_call("mod", "nttlive_util", "array_random", winners);
var message = "TwitchVotes The voting is over! The next level will have only " + mod_script_call("mod", "nttlive_util", "enemy_get_alias", winnertype) + "s!";
mod_script_call("mod", "nttlive", "send_message", message);
mod_variable_set("mod", "nttlive_events", "eventtext", "UP NEXT: b:@r:b" + string_upper(mod_script_call("mod", "nttlive_util", "enemy_get_alias", winnertype)) + "S!");
kin_replacer_create(winnertype);

#define event_draw_gui
draw_set_halign(1);
draw_set_valign(0);
draw_set_font(fntChat);
with (mod_variable_get("mod", "nttlive", "controller")) {
    var type_offset = 32;
    for (var i = 0; i < array_length(kin_voting); i++) {
        var draw_x = game_width / 2 - type_offset * array_length(kin_voting) / 2 + i * type_offset;
        var draw_y = 30 - kin_voting[i].visual_height * 12 + 12;
        var sprite = kin_voting[i].sprt;
        draw_x += sprite_get_width(sprite) / 2 - (sprite_get_width(sprite) - sprite_get_xoffset(sprite)) + type_offset / 2;
        draw_sprite(
            sprite, kin_voting[i].frame,
            draw_x,
            draw_y + sprite_get_height(sprite) / 2 - (sprite_get_height(sprite) - sprite_get_yoffset(sprite))
        );
        draw_text_nt(draw_x - sprite_get_xoffset(sprite) + sprite_get_width(sprite) / 2, draw_y + 2, string(kin_voting[i].votes));
        draw_text_nt(draw_x - sprite_get_xoffset(sprite) + sprite_get_width(sprite) / 2, draw_y + 2 + string_height("E"), "e" + string(i + 1));
    }
}
draw_set_halign(0);
draw_set_font(fntM);

#define getenemy(difficulty)
var easylist = [Bandit, Exploder, Gator, Rat, Sniper, Raven, Freak, Guardian, Molefish, Grunt, BoneFish, ExploFreak];
var mediumlist = [Scorpion, MeleeBandit, Spider, LaserCrystal, SnowTank, SnowBot, Wolf, FireBaller, Jock, Molesarge, Turtle, Shielder, Inspector, Crab, InvLaserCrystal, InvSpider, JungleAssassin, JungleBandit];
var hardlist = [GoldScorpion, SuperFrog, BuffGator, Salamander, LightningCrystal, GoldSnowTank, Turret, RhinoFreak, ExploGuardian, DogGuardian, SuperFireBaller, PopoFreak, EliteGrunt, EliteShielder, EliteInspector];

var myenemy = noone;
switch (difficulty) {
    case "easy":
        myenemy = mod_script_call("mod", "nttlive_util", "array_random", easylist);
        break;
    case "medium":
        myenemy = mod_script_call("mod", "nttlive_util", "array_random", mediumlist);
        break;
    case "hard":
        myenemy = mod_script_call("mod", "nttlive_util", "array_random", hardlist);
        break;
}

return myenemy;

#define kin_replacer_create(type)
with (instance_create(0, 0, CustomObject)) {
    name = "KinReplacer";
    enemytype = type;
    previous_area = GameCont.area;
    previous_subarea = GameCont.subarea;
    previous_hard = GameCont.hard;
    current_area = 0;
    current_subarea = 0;
    active = 0;
    replaced = 0;
    persistent = 1;
    on_step = script_ref_create(kin_replacer_step);
}

#define kin_replacer_step
if (instance_exists(Menu) || !instance_exists(Player)) {
    instance_destroy();
    exit;
}

if (!active) {
    if (GameCont.hard != previous_hard && (GameCont.area != previous_area || GameCont.subarea != previous_subarea) && !instance_exists(GenCont) && instance_exists(enemy)) {
        current_area = GameCont.area;
        current_subarea = GameCont.subarea;
        active = 1;
    }
} else {
    if (GameCont.area == current_area && GameCont.subarea == current_subarea) {
        if (!replaced) {
            with (enemy) if (object_index != other.enemytype) {
                instance_create(x, y, other.enemytype);
                instance_delete(self);
            }
            replaced = 1;
        } else {
            with (enemy) if (object_index != other.enemytype) instance_delete(self);
        }
    } else {
        instance_destroy();
    }
}