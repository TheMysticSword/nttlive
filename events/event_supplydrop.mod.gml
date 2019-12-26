#define event_name
return "supply drop";

#define event_start
var message = "TwitchVotes It's time for the supply drop! Which weapon should BROADCASTER_NAME get? V";
with (mod_variable_get("mod", "nttlive", "controller")) {
    supplydrop_voting = [];
    var weaponlist = ds_list_create();
    var maxweps = 3;
    weapon_get_list(weaponlist, 0);
    ds_list_shuffle(weaponlist);
    for (var i = 0; i < maxweps; i++) {
        var mywep = ds_list_find_value(weaponlist, 1);
        ds_list_delete(weaponlist, 1);
        array_push(supplydrop_voting, {wep: mywep, votes: 0, visual_height: 0});
        message += "ote w" + string(i + 1) + " for " + weapon_get_name(mywep);
        if (i < maxweps - 1) {
            message += ", v";
        }
    }
}
mod_script_call("mod", "nttlive", "send_message", message);
mod_variable_set("mod", "nttlive_events", "eventtext", "b:@y:bVOTE FOR A WEAPON TO GIVE!");

#define event_step
for (var i = 0; i < array_length(mod_variable_get("mod", "nttlive", "messages")); i++) if (mod_script_call("mod", "nttlive", "message_flag_check", mod_variable_get("mod", "nttlive", "messages")[i], "supplydrop")) {
    with (mod_variable_get("mod", "nttlive", "controller")) {
        if (string_copy(mod_variable_get("mod", "nttlive", "messages")[i].content, 1, 1) == "w") {
            mod_script_call("mod", "nttlive", "message_flag_check", mod_variable_get("mod", "nttlive", "messages")[i], "enemychatterhidden");
            mod_script_call("mod", "nttlive", "message_flag_check", mod_variable_get("mod", "nttlive", "messages")[i], "weaponignore");
            var wepnum = real(string_delete(mod_variable_get("mod", "nttlive", "messages")[i].content, 1, 1)) - 1;
            if (wepnum >= 0 && wepnum < array_length(supplydrop_voting)) {
                supplydrop_voting[wepnum].votes++;
            }
        }
    }
}

with (mod_variable_get("mod", "nttlive", "controller")) {
    var total_votes = 0;
    for (var i = 0; i < array_length(supplydrop_voting); i++) total_votes += supplydrop_voting[i].votes;
    for (var i = 0; i < array_length(supplydrop_voting); i++) {
        supplydrop_voting[i].visual_height += (supplydrop_voting[i].votes / max(total_votes, 1) - supplydrop_voting[i].visual_height) * 0.2 * current_time_scale;
    }
}

#define event_end
var winners = [];
var winner_votes = 0;
with (mod_variable_get("mod", "nttlive", "controller")) {
    for (var i = 0; i < array_length(supplydrop_voting); i++) {
        if (supplydrop_voting[i].votes >= winner_votes) {
            if (supplydrop_voting[i].votes > winner_votes) {
                winner_votes = supplydrop_voting[i].votes;
                winners = [];
            }
            array_push(winners, supplydrop_voting[i].wep);
        }
    }
}
sound_play(sndVenuz);
var winnerwep = mod_script_call("mod", "nttlive_util", "array_random", winners);
var message = "TwitchVotes The voting is over! BROADCASTER_NAME gets " + weapon_get_name(winnerwep);
mod_script_call("mod", "nttlive", "send_message", message);
mod_variable_set("mod", "nttlive_events", "eventtext", "b:@b:bSUPPLY DROP INCOMING!");
with (mod_script_call("mod", "nttlive_util", "instance_random", Player)) {
    with (supply_drop_create(x, y)) wep = winnerwep;
}

#define event_draw_gui
draw_set_halign(1);
draw_set_valign(0);
draw_set_font(fntChat);
with (mod_variable_get("mod", "nttlive", "controller")) {
    var wep_offset = 32;
    for (var i = 0; i < array_length(supplydrop_voting); i++) {
        var draw_x = game_width / 2 - wep_offset * array_length(supplydrop_voting) / 2 + i * wep_offset;
        var draw_y = 30 - supplydrop_voting[i].visual_height * 12 + 12;
        var sprite = weapon_get_sprite(supplydrop_voting[i].wep);
        draw_x += sprite_get_width(sprite) / 2 - (sprite_get_width(sprite) - sprite_get_xoffset(sprite)) + wep_offset / 2;
        draw_sprite(
            sprite, 0,
            draw_x,
            draw_y + sprite_get_height(sprite) / 2 - (sprite_get_height(sprite) - sprite_get_yoffset(sprite))
        );
        draw_text_nt(draw_x - sprite_get_xoffset(sprite) + sprite_get_width(sprite) / 2, draw_y + 2, string(supplydrop_voting[i].votes));
        draw_text_nt(draw_x - sprite_get_xoffset(sprite) + sprite_get_width(sprite) / 2, draw_y + 2 + string_height("W"), "w" + string(i + 1));
    }
}
draw_set_halign(0);
draw_set_font(fntM);

#define supply_drop_create(_x, _y)
with (instance_create(_x, _y, CustomObject)) {
    depth = -12;
    sprite_index = mod_script_call("mod", "nttlive_sprites", "get", "sprStreamChest");
    image_speed = 0;
    name = "ViewerSupplyDrop";
    wep = wep_screwdriver;
    fall_x = 0;
    fall_y = 200;
    fall_speed = 2;
    on_step = script_ref_create(supply_drop_step);
    on_draw = script_ref_create(supply_drop_draw);
    on_destroy = script_ref_create(supply_drop_destroy);
    return self;
}

#define supply_drop_step
fall_x = sin(fall_y / fall_speed / 10) * 16;
fall_y -= fall_speed * current_time_scale;
if (fall_y <= 0) {
    with (instance_create(x, y, WepPickup)) {
        roll = 0;
        wep = other.wep;
        ammo = 1;
    }
    var dusts = irandom_range(6, 12);
    for (var i = 0; i < dusts; i++) {
        with (instance_create(x, y, Dust)) {
            motion_add(360 / dusts * i, random_range(0.5, 2));
        }
    }
    sound_play(sndWeaponChest);
    instance_destroy();
}

#define supply_drop_draw
image_alpha = abs(image_alpha);
draw_sprite_ext(shd16, 0, x + fall_x, y, 1, 1, 0, c_white, 0.3);
draw_sprite_ext(sprite_index, image_index, x + fall_x, y - fall_y, image_xscale, image_yscale, image_angle, image_blend, image_alpha);
draw_sprite_ext(mod_script_call("mod", "nttlive_sprites", "get", "sprSupplyDropParachute"), 0, x + fall_x, y - fall_y - 2, image_xscale, image_yscale, image_angle, image_blend, image_alpha);
image_alpha *= -1;

#define supply_drop_destroy
with (instance_create(x, y, ChestOpen)) sprite_index = mod_script_call("mod", "nttlive_sprites", "get", "sprStreamChestOpen");
instance_create(x, y, FXChestOpen);