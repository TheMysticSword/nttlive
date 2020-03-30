#define event_name
return "teleport";

#define event_start
var message = "TwitchVotes Let's teleport BROADCASTER_NAME to a different area! Vote ";
with (mod_variable_get("mod", "nttlive", "controller")) {
    teleport_voting = [];
    var arealist = ds_list_create();
    ds_list_add(arealist,
        {name: "desert", icon: sprCactus, index: 1},
        {name: "sewers", icon: sprToxicBarrel, index: 2},
        {name: "scrapyards", icon: sprCarIdle, index: 3},
        {name: "crystal caves", icon: sprCrystalProp, index: 4},
        {name: "frozen city", icon: sprIcicle, index: 5},
        {name: "labs", icon: sprTerminal, index: 6},
        {name: "palace", icon: sprSmallGenerator, index: 7}
    );
    var secretareas = [
        {name: "night desert", icon: sprNightCactus, index: 0},
        {name: "oasis", icon: sprAnchor, index: 101},
        {name: "pizza sewers", icon: sprPizzaBox, index: 102},
        {name: "mansion", icon: sprMoneyPile, index: 103},
        {name: "cursed caves", icon: sprCrystalPropBlue, index: 104},
        {name: "jungle", icon: sprBushIdle, index: 105}
    ];
    if (random(5) < 1) {
        ds_list_add(arealist, mod_script_call("mod", "nttlive_util", "array_random"), secretareas);
    }
    var delete_pos = -1;
    for (var i = 0; i < ds_list_size(arealist); i++) {
        if (ds_list_find_value(arealist, i).index == GameCont.area) delete_pos = i;
    }
    if (delete_pos != -1) ds_list_delete(arealist, delete_pos);
    var maxareas = 3;
    ds_list_shuffle(arealist);
    for (var i = 0; i < maxareas; i++) {
        var myarea = ds_list_find_value(arealist, 1);
        ds_list_delete(arealist, 1);
        array_push(teleport_voting, {area: myarea, votes: 0, visual_height: 0});
        message += "a" + string(i + 1) + " for " + string_upper(myarea.name);
        if (i < maxareas - 1) {
            message += ", ";
        }
    }
}
mod_script_call("mod", "nttlive", "send_message", message);
mod_variable_set("mod", "nttlive_events", "eventtext", "b:@y:bVOTE FOR AN AREA TO TELEPORT!");

#define event_step
for (var i = 0; i < array_length(mod_variable_get("mod", "nttlive", "messages")); i++) if (mod_script_call("mod", "nttlive", "message_flag_check", mod_variable_get("mod", "nttlive", "messages")[i], "teleport")) {
    with (mod_variable_get("mod", "nttlive", "controller")) {
        if (string_copy(mod_variable_get("mod", "nttlive", "messages")[i].content, 1, 1) == "a") {
            mod_script_call("mod", "nttlive", "message_flag_check", mod_variable_get("mod", "nttlive", "messages")[i], "enemychatterhidden");
            var areanum = real(string_delete(mod_variable_get("mod", "nttlive", "messages")[i].content, 1, 1)) - 1;
            if (areanum >= 0 && areanum < array_length(teleport_voting)) {
                teleport_voting[areanum].votes++;
            }
        }
    }
}

with (mod_variable_get("mod", "nttlive", "controller")) {
    var total_votes = 0;
    for (var i = 0; i < array_length(teleport_voting); i++) total_votes += teleport_voting[i].votes;
    for (var i = 0; i < array_length(teleport_voting); i++) {
        teleport_voting[i].visual_height += (teleport_voting[i].votes / max(total_votes, 1) - teleport_voting[i].visual_height) * 0.2 * current_time_scale;
    }
}

#define event_end
var winners = [];
var winner_votes = 0;
with (mod_variable_get("mod", "nttlive", "controller")) {
    for (var i = 0; i < array_length(teleport_voting); i++) {
        if (teleport_voting[i].votes >= winner_votes) {
            if (teleport_voting[i].votes > winner_votes) {
                winner_votes = teleport_voting[i].votes;
                winners = [];
            }
            array_push(winners, teleport_voting[i].area);
        }
    }
}
var winnerarea = mod_script_call("mod", "nttlive_util", "array_random", winners);
var message = "TwitchVotes The voting is over! BROADCASTER_NAME gets teleported to " + string_upper(winnerarea.name);
mod_script_call("mod", "nttlive", "send_message", message);
mod_variable_set("mod", "nttlive_events", "eventtext", "YOU ARE ON YOUR WAY TO: b:@y:b" + string_upper(winnerarea.name));
with (mod_script_call("mod", "nttlive_util", "instance_random", Player)) {
    if ((winnerarea.index % 2) == 1) {
        GameCont.area = winnerarea.index;
        GameCont.subarea = 0;
    } else {
        GameCont.area = winnerarea.index - 1;
        GameCont.subarea = 4;
    }
    with (instance_create(x, y, Portal)) {
        endgame = 30 * 2;
    }
}

#define event_draw_gui
draw_set_halign(1);
draw_set_valign(0);
draw_set_font(fntChat);
with (mod_variable_get("mod", "nttlive", "controller")) {
    var area_offset = 32;
    for (var i = 0; i < array_length(teleport_voting); i++) {
        var draw_x = game_width / 2 - area_offset * array_length(teleport_voting) / 2 + i * area_offset;
        var draw_y = 30 - teleport_voting[i].visual_height * 12 + 12;
        var sprite = teleport_voting[i].area.icon;
        draw_x += sprite_get_width(sprite) / 2 - (sprite_get_width(sprite) - sprite_get_xoffset(sprite)) + area_offset / 2;
        draw_sprite(
            sprite, current_frame * (1 / current_time_scale) * 0.4,
            draw_x,
            draw_y + sprite_get_height(sprite) / 2 - (sprite_get_height(sprite) - sprite_get_yoffset(sprite))
        );
        draw_text_nt(draw_x - sprite_get_xoffset(sprite) + sprite_get_width(sprite) / 2, draw_y + 2, string(teleport_voting[i].votes));
        draw_text_nt(draw_x - sprite_get_xoffset(sprite) + sprite_get_width(sprite) / 2, draw_y + 2 + string_height("A"), "a" + string(i + 1));
    }
}
draw_set_halign(0);
draw_set_font(fntM);