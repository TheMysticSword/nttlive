#define event_name
return "idpd invasion";

#define event_start
var message = "TwitchLit Let's invade the game! Type these words repeatedly to activate IDPD portals! ";
var words = ds_list_create();
ds_list_add(words, "air", "brain", "crown", "drill", "east", "fungus", "gun", "health", "ions", "jar", "king", "lemon", "mind", "nest", "ozone");
ds_list_add(words, "power", "quarry", "record", "stone", "throne", "unity", "vertigo", "wonder", "xmas", "yolk", "zap");
with (mod_variable_get("mod", "nttlive", "controller")) {
    invasion_portals = [];
    var maxwords = 5;
    for (var i = 0; i < maxwords; i++) {
        var wordindex = irandom(ds_list_size(words) - 1);
        array_push(invasion_portals, {portal: noone, word: ds_list_find_value(words, wordindex), charge: 0, maxcharge: 5 + 0.4 * mod_variable_get("mod", "nttlive", "viewers"), shake_x: 0, shake_y: 0, typedtimes: 0});
        message += ds_list_find_value(words, wordindex);
        ds_list_delete(words, wordindex);
        if (i + 1 < maxwords) {
            message += ", "
        }
    }
}
mod_script_call("mod", "nttlive", "send_message", message);
mod_variable_set("mod", "nttlive_events", "eventtext", "b:@r:bTYPE THE WORDS TO ACTIVATE IDPD PORTALS!");

#define event_step
with (mod_variable_get("mod", "nttlive", "controller")) if ("invasion_portals" in self) {
    for (var i = 0; i < array_length(invasion_portals); i++) {
        for (var k = 0; k < array_length(mod_variable_get("mod", "nttlive", "messages")); k++) if (mod_script_call("mod", "nttlive", "message_flag_check", mod_variable_get("mod", "nttlive", "messages")[k], "invasion_" + string_lower(invasion_portals[i].word))) {
            if (string_lower(mod_variable_get("mod", "nttlive", "messages")[k].content) == string_lower(invasion_portals[i].word)) {
                mod_script_call("mod", "nttlive", "message_flag_check", mod_variable_get("mod", "nttlive", "messages")[k], "enemychatterhidden");
                invasion_portals[i].charge++;
                invasion_portals[i].typedtimes++;
            }
        }
        if (invasion_portals[i].charge < 0) invasion_portals[i].charge = 0;
        if (!instance_exists(invasion_portals[i].portal)) {
            var randomfloor = noone;
            var tries = 1000;
            while (tries > 0 && (!instance_exists(randomfloor))) {
                randomfloor = mod_script_call("mod", "nttlive_util", "instance_random", Floor);
                with (randomfloor) {
                    if ("nttlive_floorexplo" in self || place_meeting(x, y, Wall)) randomfloor = noone;
                }
                tries--;
            }
            if (instance_exists(randomfloor)) {
                var myportal = invasion_portal_create(randomfloor.x + 16, randomfloor.y + 16);
                invasion_portals[i].portal = myportal;
            }
        }
        with (invasion_portals[i].portal) {
            charge = other.invasion_portals[i].charge;
            maxcharge = other.invasion_portals[i].maxcharge;
        }
        var maxshake = (invasion_portals[i].charge / invasion_portals[i].maxcharge) * 8;
        invasion_portals[i].shake_x += (random_range(-maxshake, maxshake) - invasion_portals[i].shake_x) * 0.4 * current_time_scale;
        invasion_portals[i].shake_y += (random_range(-maxshake, maxshake) - invasion_portals[i].shake_y) * 0.4 * current_time_scale;
        if (invasion_portals[i].charge >= invasion_portals[i].maxcharge) {
            sound_play(sndVanWarning);
            with (invasion_portals[i].portal) {
                spawn = 1;
            }
            invasion_portals[i].charge = 0;
        }
    }
}

#define event_end
var total = 0;
with (mod_variable_get("mod", "nttlive", "controller")) {
    for (var i = 0; i < array_length(invasion_portals); i++) {
        total += invasion_portals[i].typedtimes;
        with (invasion_portals[i].portal) {
            instance_destroy();
        }
    }
}
mod_script_call("mod", "nttlive", "send_message", "imGlitch The invasion is over! We typed a total of " + string(total) + " words!");
mod_variable_set("mod", "nttlive_events", "eventtext", "b:@b:bTHE INVASION IS OVER!");

#define event_draw_gui
draw_set_font(fntChat);
with (mod_variable_get("mod", "nttlive", "controller")) if ("invasion_portals" in self) {
    for (var i = 0; i < array_length(invasion_portals); i++) {
        with (invasion_portals[i].portal) {
            var text = string_upper(other.invasion_portals[i].word);
            var draw_w = string_width(text);
            var draw_h = string_height(text);
            var draw_x = x - view_xview_nonsync + other.invasion_portals[i].shake_x;
            var draw_y = y - view_yview_nonsync + other.invasion_portals[i].shake_y;
            if (draw_x - draw_w / 2 < 0) draw_x = draw_w / 2;
            if (draw_x + draw_w / 2 > game_width) draw_x = game_width - draw_w / 2;
            if (draw_y - draw_h / 2 < 0) draw_y = draw_h / 2;
            if (draw_y + draw_h / 2 > game_height) draw_y = game_height - draw_h / 2;
            draw_set_color(c_black);
            draw_set_alpha(0.2);
            draw_roundrect(draw_x - draw_w / 2 - 2, draw_y - draw_h / 2, draw_x + draw_w / 2 + 2, draw_y + draw_h / 2, 0);
            draw_set_alpha(1);
            draw_set_color(c_white);
            draw_text_nt(draw_x - draw_w / 2, draw_y - draw_h / 2, text);
        }
    }
}
draw_set_font(fntM);

#define invasion_portal_create(_x, _y)
with (instance_create(_x, _y, CustomObject)) {
    depth = -1;
    sprite_index = mod_script_call("mod", "nttlive_sprites", "get", "sprInvasionPortalCharge");
    image_speed = 0.4;
    image_alpha = 0.8;
    name = "InvasionPortal";
    charge = 0;
    maxcharge = 0;
    spawn = 0;
    on_step = script_ref_create(invasion_portal_step);
    return self;
}

#define invasion_portal_step
if (random(maxcharge - charge) < 1) {
    with (instance_create(x + random_range(-48, 48), y + random_range(-48, 48), IDPDPortalCharge)) {
        motion_add(point_direction(x, y, other.x, other.y), random_range(2, 3));
        alarm0 = point_distance(x, y, other.x, other.y) / speed + 1;
        sprite_index = mod_script_call("mod", "nttlive_sprites", "get", "sprInvasionPortalCharge");
        image_alpha = other.image_alpha;
    }
}
if (spawn) {
    with (instance_create(x, y, IDPDSpawn)) {
        alarm0 = 1;
        alarm1 = 9999;
        creator = other;
    }
    sound_stop(sndIDPDPortalSpawn);
    sound_stop(sndEliteIDPDPortalSpawn);
    spawn = 0;
}
with (instances_matching(IDPDSpawn, "creator", self)) {
    x = other.x;
    y = other.y;
    if (sprite_index == sprIDPDPortalClose) {
        sprite_index = mod_script_call("mod", "nttlive_sprites", "get", "sprInvasionPortalClose");
    }
    if (image_index >= image_number - image_speed) {
        instance_destroy();
    }
}