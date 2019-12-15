#define event_name
return "shards";

#define event_start
with (mod_variable_get("mod", "nttlive", "controller")) {
    shards_total = 0;
}
mod_script_call("mod", "nttlive", "send_message", "TwitchLit Type any angle between 0 and 360 to fire a shard!");

#define event_step
with (mod_variable_get("mod", "nttlive", "controller")) {
    for (var i = 0; i < array_length(mod_variable_get("mod", "nttlive", "messages")); i++) if (mod_script_call("mod", "nttlive", "message_flag_check", mod_variable_get("mod", "nttlive", "messages")[i], "shards")) {
        if (string_digits(mod_variable_get("mod", "nttlive", "messages")[i].content) == mod_variable_get("mod", "nttlive", "messages")[i].content) {
            mod_script_call("mod", "nttlive", "message_flag_check", mod_variable_get("mod", "nttlive", "messages")[i], "enemychatterhidden");
            shards_total++;
            with (mod_script_call("mod", "nttlive_util", "instance_random", Player)) {
                with (shard_create(x, y)) {
                    team = other.team;
                    creator = other;
                    direction = real(mod_variable_get("mod", "nttlive", "messages")[i].content);
                    image_angle = direction;
                }
            }
        }
    }
}

#define event_end
var total = 0;
with (mod_variable_get("mod", "nttlive", "controller")) {
    total = shards_total;
}
mod_script_call("mod", "nttlive", "send_message", "imGlitch Well done! We fired a total of " + string(total) + " shards!");

#define event_draw_gui
draw_set_halign(fa_middle);
draw_set_valign(fa_top);
draw_set_font(fntChat);
draw_text_nt(game_width / 2, 12, mod_script_call("mod", "nttlive_util", "text_blink", "@r") + "TYPE AN ANGLE (0-360) TO FIRE A SHARD!");
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_font(fntM);

#define shard_create(_x, _y)
with (instance_create(_x, _y, CustomProjectile)) {
    sprite_index = mod_script_call("mod", "nttlive_sprites", "get", "sprStreamShard");
    image_speed = 1;
    name = "StreamShard";
    damage = 5;
    speed = random_range(15, 18);
    typ = 2;
    on_step = script_ref_create(shard_step);
    on_hit = script_ref_create(shard_hit);
    on_draw = script_ref_create(shard_draw);
    return self;
}

#define shard_step
if (random(2) < 1) {
    with (instance_create(x + random_range(-4, 4), y + random_range(-4, 4), PlasmaTrail)) {
        sprite_index = mod_script_call("mod", "nttlive_sprites", "get", "sprStreamTrail");
    }
}
if (image_index >= image_number - image_speed) {
    image_speed = 0;
}
force = speed;
speed -= 1.4 * current_time_scale;
if (speed < 0) {
    speed = 0;
    instance_destroy();
}

#define shard_hit
if (projectile_canhit(other)) {
    projectile_hit(other, damage);
    image_xscale -= 0.1;
    image_yscale = image_xscale;
    if (damage > 0) {
        with (instance_create(x + random_range(-4, 4), y + random_range(-4, 4), PlasmaTrail)) {
            sprite_index = mod_script_call("mod", "nttlive_sprites", "get", "sprStreamTrail");
            direction = other.direction + 180 + random_range(-30, 30);
            speed = random_range(4, 10);
        }
    }
    damage--;
}

#define shard_draw
draw_self();
draw_set_blend_mode(bm_add);
draw_sprite_ext(sprite_index, image_index, x, y, image_xscale * 2, image_yscale * 2, image_angle, image_blend, image_alpha * 0.1);
draw_set_blend_mode(bm_normal);