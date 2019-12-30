#macro c_twitch make_color_rgb(145, 70, 255);

#define weapon_name
var colortag = "";
if (instance_is(self, WepPickup)) colortag = `@(color:${c_twitch})`;
return colortag + "AFK LAUNCHER";

#define weapon_type
return 6;

#define weapon_auto
return 1;

#define weapon_cost
return 1;

#define weapon_load
return 3;

#define weapon_sprt
return mod_script_call("mod", "nttlive_sprites", "get", "sprAFKLauncher");

#define weapon_sprt_hud
return mod_script_call("mod", "nttlive_sprites", "get", "sprAFKLauncherHUD");

#define weapon_area
return 3;

#define weapon_swap
return sndSwapExplosive;

#define weapon_text
return `@(color:${c_twitch})` + "rely on your chat";

#define step(primary)
if (!primary && race != "steroids") {
	if (breload > 0) {
		breload -= reloadspeed * current_time_scale;
		if (breload < 0) breload = 0;
	}
}
if (instance_exists(enemy) && (!primary && race != "steroids")) {
	if (ammo[weapon_get_type(mod_current)] >= weapon_get_cost(mod_current) && ((primary && reload <= 0) || (!primary && breload <= 0))) {
		ammo[weapon_get_type(mod_current)] -= weapon_get_cost(mod_current);
		if (primary) reload = weapon_get_load(mod_current);
		if (!primary) breload = weapon_get_load(mod_current);
		sound_play_pitch(sndFlamerStart, random_range(0.6, 0.8));
		with (player_fire_ext(90 + 20 * right, mod_current, x - 3 * right + random_range(-2, 2), y - 5 + random_range(-2, 2), team, self)) {
			returnammo = 1;
		}
	}
}

#define weapon_fire
sound_play_pitchvol(sndFlamerStart, random_range(0.6, 0.8), 0.3);
with (missile_create(x + lengthdir_x(4, gunangle) + random_range(-2, 2), y + lengthdir_y(4, gunangle) + random_range(-2, 2))) {
	team = other.team;
	creator = other;
	direction = other.gunangle;
	image_angle = direction;
	if (instance_is(other, Player)) targetnearest = 1;
}

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
	targetnearest = 0;
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
		with (Wall) array_push(possible_targets, self);
	}
	if (array_length(possible_targets) > 0) {
		target = mod_script_call("mod", "nttlive_util", "array_random", possible_targets);
		if (targetnearest) {
			var nearest = possible_targets[0];
			var dist = 1000000;
			with (nearest) dist = distance_to_object(other);
			with (possible_targets) {
				if (distance_to_object(other) < dist) {
					nearest = self;
					dist = distance_to_object(other);
				}
			}
			target = nearest;
		}
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
if (decay <= 0 || (instance_exists(target) && place_meeting(x, y, target)) || (!instance_exists(enemy) && "returnammo" in creator)) instance_destroy();

#define missile_destroy
var explode = 1;
if (!instance_exists(enemy)) {
	with (creator) {
		if (instance_is(self, FireCont) && "returnammo" in self) {
			with (creator) if (instance_is(self, Player)) {
				ammo[nttlive_streamammo_index] += weapon_get_cost(mod_current);
				nttlive_streamammo_last += weapon_get_cost(mod_current);
				explode = 0;
			}
		}
	}
}
if (explode) {
	with (instance_create(x, y, SmallExplosion)) {
		sound_play(sndExplosionS);
		team = other.team;
		damage = other.damage;
		creator = other.creator;
	}
}