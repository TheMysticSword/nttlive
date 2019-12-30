#macro c_twitch make_color_rgb(145, 70, 255);

#define init
with (instances_matching(CustomStep, "name", mod_current)) instance_destroy();
with (instances_matching(CustomDraw, "name", mod_current)) instance_destroy();
with (script_bind_draw(debuff_step, 0)) {
	name = mod_current;
	persistent = 1;
}
with (script_bind_draw(debuff_draw, -12)) {
	name = mod_current;
	persistent = 1;
}

#define weapon_name
var colortag = "";
if (instance_is(self, WepPickup)) colortag = `@(color:${c_twitch})`;
return colortag + "GRAVITY CANNON";

#define weapon_type
return 6;

#define weapon_auto
return 0;

#define weapon_cost
return 1;

#define weapon_load
return 11;

#define weapon_sprt
return mod_script_call("mod", "nttlive_sprites", "get", "sprGravityCannon");

#define weapon_sprt_hud
return mod_script_call("mod", "nttlive_sprites", "get", "sprGravityCannonHUD");

#define weapon_area
return 6;

#define weapon_swap
return sndSwapEnergy;

#define weapon_text
return `@(color:${c_twitch})` + "binding eclipse";

#define weapon_fire
sound_play_pitch(sndBigBallFire, random_range(0.55, 0.65));
with (bullet_create(x + lengthdir_x(5, gunangle), y + lengthdir_y(5, gunangle))) {
	team = other.team;
	creator = other;
	direction = other.gunangle + random_range(-3, 3) * other.accuracy;
	image_angle = direction;
}
weapon_post(4, -6, 6);

#define bullet_create(_x, _y)
with (instance_create(_x, _y, CustomProjectile)) {
    sprite_index = mod_script_call("mod", "nttlive_sprites", "get", "sprGravityCannonBullet");
	mask_index = mod_script_call("mod", "nttlive_sprites", "get", "mskGravityCannonBullet");
    image_speed = 1;
    name = "GravityCannonBullet";
    damage = 4;
    typ = 1;
	speed = 6;
    on_step = script_ref_create(bullet_step);
	on_hit = script_ref_create(bullet_hit);
	on_destroy = script_ref_create(bullet_destroy);
    return self;
}

#define bullet_step
if (random(2) < 1) {
    with (instance_create(random_range(bbox_left, bbox_right), random_range(bbox_top, bbox_bottom), PlasmaTrail)) {
		depth = other.depth - 1;
        sprite_index = mod_script_call("mod", "nttlive_sprites", "get", "sprGravityCannonTrail");
    }
}

if (image_index >= image_number - image_speed) {
    image_speed = 0;
	image_xscale *= 0.8;
	image_yscale *= 0.8;
}

#define bullet_hit
if (projectile_canhit(other)) {
	projectile_hit(other, damage);
	debuff_apply(other, 30 * 4);
	repeat (12) {
		with (slowdown_effect_create(random_range(bbox_left - 4, bbox_right + 4) - x, random_range(bbox_top - 24, bbox_bottom) - y)) {
			depth = other.depth - 1;
			creator = other;
		}
	}
	instance_destroy();
}

#define bullet_destroy
with (instance_create(x, y, BulletHit)) {
	sprite_index = mod_script_call("mod", "nttlive_sprites", "get", "sprGravityCannonBulletHit");
}

#define debuff_apply(target, time)
with (target) {
	if ("slowdown_active" not in self) slowdown_active = 0;
	if ("slowdown_stack" not in self) slowdown_stack = 0;
	if ("slowdown_time" not in self) slowdown_time = 0;
	if ("slowdown_exploded" not in self) slowdown_exploded = 0;
	if ("slowdown_lastx" not in self) slowdown_lastx = 0;
	if ("slowdown_lasty" not in self) slowdown_lasty = 0;
	slowdown_lastx = x;
	slowdown_lasty = y;
	slowdown_stack++;
	slowdown_active = 1;
	slowdown_time = time;
}

#define debuff_step
var slow_power = 0.3;
var expl_damage = 15;
with (instances_matching(hitme, "slowdown_active", 1)) {
	if (slowdown_stack <= 0) {
		slowdown_stack = 0;
		slowdown_active = 0;
	}
	if (slowdown_stack > 3) slowdown_stack = 3;
	x -= (x - slowdown_lastx) * slow_power * slowdown_stack;
	y -= (y - slowdown_lasty) * slow_power * slowdown_stack;
	slowdown_lastx = x;
	slowdown_lasty = y;
	if (slowdown_stack >= 3 && !slowdown_exploded) {
		slowdown_exploded = 1;
		sound_play_pitch(sndBigBallExplo, random_range(0.35, 0.45));
		projectile_hit_raw(self, expl_damage, 2);
		repeat (12) {
			with (instance_create(x, y, PlasmaTrail)) {
				sprite_index = mod_script_call("mod", "nttlive_sprites", "get", "sprStreamTrail");
				direction = random(360);
				speed = random_range(4, 6);
			}
		}
	}
	slowdown_time -= current_time_scale;
	if (slowdown_time <= 0) {
		slowdown_stack--;
		slowdown_time = 30;
	}
}

#define debuff_draw
with (instances_matching(hitme, "slowdown_active", 1)) {
	draw_sprite(mod_script_call("mod", "nttlive_sprites", "get", "sprGravityCannonDebuff"), slowdown_stack - 1, x, bbox_top - 4);
	if (!slowdown_exploded) {
		draw_sprite(mod_script_call("mod", "nttlive_sprites", "get", "sprGravityCannonDebuffExplo"), 0, x, bbox_top - 4);
	}
}

#define slowdown_effect_create(_x, _y)
with (instance_create(_x, _y, CustomObject)) {
    name = "GravityCannonEffect";
	sprite_index = mod_script_call("mod", "nttlive_sprites", "get", "sprGravityCannonEffect");
	image_alpha = 0.9;
	image_blend = c_twitch;
	fallspeed = random_range(0.8, 3);
	offset_x = x;
	offset_y = y;
	fall_y = 0;
	creator = noone;
    on_step = script_ref_create(slowdown_effect_step);
    return self;
}

#define slowdown_effect_step
if (!instance_exists(creator)) {
	y += fallspeed * current_time_scale;
} else {
	x = creator.x + offset_x;
	y = creator.y + offset_y + fall_y;
	fall_y += fallspeed * current_time_scale;
}
image_alpha -= 0.06 * current_time_scale;

if (image_alpha <= 0) instance_destroy();