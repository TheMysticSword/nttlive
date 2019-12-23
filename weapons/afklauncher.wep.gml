#macro c_twitch make_color_rgb(145, 70, 255);

#define weapon_name
return `@(color:${c_twitch})` + "AFK LAUNCHER";

#define weapon_type
return 0;

#define weapon_auto
return 0;

#define weapon_cost
return 0;

#define weapon_load
return 0;

#define weapon_sprt
return mod_script_call("mod", "nttlive_sprites", "get", "sprAFKLauncher");

#define weapon_area
return 3;

#define weapon_swap
return sndSwapEnergy;

#define weapon_text
return `@(color:${c_twitch})` + "rely on your chat";

#define step(primary)
for (var i = 0; i < array_length(mod_variable_get("mod", "nttlive", "messages")); i++) if (mod_script_call("mod", "nttlive", "message_flag_check", mod_variable_get("mod", "nttlive", "messages")[i], "banhammer")) {
	if (fork()) {
		var missiles = irandom_range(1, 3);
		for (var k = 0; k < missiles; k++) {
			if (instance_exists(self)) {
				sound_play_pitchvol(sndFlamerStart, random_range(0.6, 0.8), 0.5);
				with (missile_create(x - 3 * right + random_range(-2, 2), y - 5 + random_range(-2, 2))) {
					team = other.team;
					creator = other;
					direction = 90 + 20 * other.right;
					image_angle = direction;
				}
			}
			wait 5;
		}
		exit;
	}
}

if (primary) {
	wepangle = 1;
	wepflip = 1;
	if (gunangle > 90 && gunangle < 270) wepflip = -1;

	if (fork()) {
		wait 1;
		if (instance_exists(self)) {
			if (wep != mod_current) {
				wepangle = 0;
			}
		}
		exit;
	}
}

#define weapon_reloaded(primary)

#define weapon_fire

#define missile_create(_x, _y)
with (instance_create(_x, _y, CustomObject)) {
	depth = -12;
    sprite_index = mod_script_call("mod", "nttlive_sprites", "get", "sprAFKLauncherMissile");
	image_speed = 0.4;
    name = "AFKLauncherMissile";
	damage = 1;
	speed = 3;
	speed_target = speed + random_range(4, 8);
	turnspeed = 0;
	turnspeed_target = random_range(16, 22);
	target = noone;
	decay = 30 * random_range(10, 17);
	trail_x = x;
	trail_y = y;
	on_step = script_ref_create(missile_step);
	on_destroy = script_ref_create(missile_destroy);
    return self;
}

#define missile_step
if (speed < speed_target) speed += speed_target * 0.04 * current_time_scale;
if (speed > speed_target) speed = speed_target;

if (turnspeed < turnspeed_target) turnspeed += turnspeed_target * 0.02 * current_time_scale;
if (turnspeed > turnspeed_target) turnspeed = turnspeed_target;

if (!instance_exists(target)) {
	var possible_targets = [];
	with (enemy) array_push(possible_targets, self);
	if (!instance_exists(enemy)) {
		with (prop) array_push(possible_targets, self);
		with (Corpse) array_push(possible_targets, self);
	}
	if (array_length(possible_targets) > 0) {
		target = mod_script_call("mod", "nttlive_util", "array_random", possible_targets);
	}
}

if (instance_exists(target)) {
	direction += sign(angle_difference(point_direction(x, y, target.x, target.y), direction)) * turnspeed * current_time_scale;
	image_angle = direction;
} else {
	direction += random_range(-turnspeed, turnspeed) * current_time_scale;
	image_angle = direction;
}

with (instance_create(trail_x, trail_y, BoltTrail)) {
	depth = other.depth + 1;
	image_xscale = point_distance(other.trail_x, other.trail_y, other.x, other.y);
	image_yscale = 2;
	image_angle = point_direction(other.trail_x, other.trail_y, other.x, other.y);
	image_blend = c_twitch;
}
trail_x = x;
trail_y = y;

decay -= current_time_scale;
if (decay <= 0 || (instance_exists(target) && place_meeting(x, y, target))) instance_destroy();

#define missile_destroy
with (instance_create(x, y, SmallExplosion)) {
	sound_play(sndExplosionS);
	team = other.team;
	damage = other.damage;
	creator = other.creator;
}