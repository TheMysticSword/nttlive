#define event_name
return "bomb drop";

#define event_start
with (mod_variable_get("mod", "nttlive", "controller")) {
    bombdrop_total = 0;
}
mod_script_call("mod", "nttlive", "send_message", "TwitchLit Nuke time! Type twitchRaid to drop a bomb");
mod_variable_set("mod", "nttlive_events", "eventtext", "b:@r:bTYPE twitchRaid TO DROP A BOMB!");

#define event_step
for (var i = 0; i < array_length(mod_variable_get("mod", "nttlive", "messages")); i++) if (mod_script_call("mod", "nttlive", "message_flag_check", mod_variable_get("mod", "nttlive", "messages")[i], "bombdrop")) {
    if (string_pos("twitchRaid", mod_variable_get("mod", "nttlive", "messages")[i].content) != 0) {
        mod_script_call("mod", "nttlive", "message_flag_check", mod_variable_get("mod", "nttlive", "messages")[i], "enemychatterhidden");
        with (mod_script_call("mod", "nttlive_util", "instance_random", Player)) {
            falling_nuke_create(x, y);
        }
        with (mod_variable_get("mod", "nttlive", "controller")) {
            bombdrop_total++;
        }
    }
}

#define event_end
var total = 0;
with (mod_variable_get("mod", "nttlive", "controller")) {
    total = bombdrop_total;
}
mod_script_call("mod", "nttlive", "send_message", "imGlitch Bomb drop is over! A total of " + string(total) + " bombs were dropped!");
mod_variable_set("mod", "nttlive_events", "eventtext", "b:@b:bBOMB DROP IS OVER");

#define event_draw_gui

#define falling_nuke_create(_x, _y)
with (instance_create(_x, _y, CustomObject)) {
    depth = -12;
    sprite_index = mod_script_call("mod", "nttlive_sprites", "get", "sprStreamNuke");
    image_speed = 0;
    image_angle = 270;
    name = "FallingNuke";
    fall_y = 200;
    fall_speed = 0;
    warning_rotation = random(360);
    warning_surf = noone;
    rotspeed = choose(-10, 10);
    on_step = script_ref_create(falling_nuke_step);
    on_draw = script_ref_create(falling_nuke_draw);
    on_destroy = script_ref_create(falling_nuke_destroy);
    return self;
}

#define falling_nuke_step
fall_y -= fall_speed * current_time_scale;
fall_speed += 0.3 * current_time_scale;
warning_rotation += rotspeed * current_time_scale;
if (fall_y <= 0) {
    with (instance_create(x, y, Explosion)) {
        hitid = [mod_script_call("mod", "nttlive_sprites", "get", "sprStreamNuke"), "CHAT"];
        with (Player) view_shake_at(other.x, other.y, 5);
        sound_play_gun(sndExplosion, 0.3, 0.9);
    }
    instance_destroy();
}

#define falling_nuke_draw
image_alpha = abs(image_alpha);
var width = 20;
var height = 10;
var size = max(width, height);

if (!surface_exists(warning_surf)) {
    warning_surf = surface_create(size, size);
} else {
    surface_set_target(warning_surf);
    draw_clear_alpha(c_black, 0);

    draw_set_color(c_red);
    draw_circle(size / 2, size / 2, size / 2 - 1, 0);
    draw_set_color(c_white);
    draw_set_blend_mode(bm_subtract);
    draw_circle(size / 2, size / 2, size / 2 - 1 - 2, 0);
    draw_set_blend_mode(bm_normal);

    draw_set_color(c_red);
    draw_line_width(
        size / 2 + lengthdir_x(size / 2, warning_rotation),
        size / 2 + lengthdir_y(size / 2, warning_rotation),
        size / 2 - lengthdir_x(size / 2, warning_rotation),
        size / 2 - lengthdir_y(size / 2, warning_rotation),
        2
    );
    draw_line_width(
        size / 2 + lengthdir_x(size / 2, warning_rotation + 90),
        size / 2 + lengthdir_y(size / 2, warning_rotation + 90),
        size / 2 - lengthdir_x(size / 2, warning_rotation + 90),
        size / 2 - lengthdir_y(size / 2, warning_rotation + 90),
        2
    );
    draw_set_color(c_white);

    surface_reset_target();

    draw_surface_ext(warning_surf, x - width / 2, y - height / 2 + 4, width / size, height / size, 0, c_white, 1);
}
draw_sprite_ext(sprite_index, image_index, x, y - fall_y, image_xscale, image_yscale, image_angle, image_blend, image_alpha);
image_alpha *= -1;

#define falling_nuke_destroy
surface_destroy(warning_surf);