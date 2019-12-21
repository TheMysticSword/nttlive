#macro c_twitch make_color_rgb(145, 70, 255);

#define weapon_name
return `@(color:${c_twitch})` + "SHARDSTREAM";

#define weapon_type
return 0;

#define weapon_auto
return 1;

#define weapon_cost
return 0;

#define weapon_load
return 0;

#define weapon_sprt
return mod_script_call("mod", "nttlive_sprites", "get", "sprShardstream");

#define weapon_area
return 7;

#define weapon_swap
return sndSwapEnergy;

#define weapon_text
return `@(color:${c_twitch})` + "type to fire";

#define step(primary)
for (var i = 0; i < array_length(mod_variable_get("mod", "nttlive", "messages")); i++) if (mod_script_call("mod", "nttlive", "message_flag_check", mod_variable_get("mod", "nttlive", "messages")[i], "shardstream")) {
	sound_play_pitchvol(sndPlasmaHit, random_range(1.8, 2.2), 0.5);
	with (shard_create(x + lengthdir_x(14, gunangle), y + lengthdir_y(14, gunangle))) {
		team = other.team;
		creator = other;
		direction = other.gunangle + random_range(-45, 45) * other.accuracy;
		image_angle = direction;
	}
}

if (primary) {
	wepangle = 1;
	wepflip = 1;
	if (gunangle > 90 && gunangle < 270) wepflip = -1;
}

if (fork()) {
	wait 1;
	if (instance_exists(self)) {
		if (wep != mod_current) {
			wepangle = 0;
		}
	}
	exit;
}

#define weapon_reloaded(primary)

#define weapon_fire
if (random(100) < 1) {
	with (instance_create(x + lengthdir_x(14, gunangle), y + lengthdir_y(14, gunangle), PlasmaTrail)) {
		sprite_index = mod_script_call("mod", "nttlive_sprites", "get", "sprStreamTrail");
		var len = random_range(20, 30);
		var dir = other.gunangle + random_range(-120, 120);
		x += lengthdir_x(len, dir);
		y += lengthdir_y(len, dir);
		direction = dir + 180;
		speed = len / 10;
	}
}

#define shard_create(_x, _y)
with (instance_create(_x, _y, CustomProjectile)) {
    sprite_index = mod_script_call("mod", "nttlive_sprites", "get", "sprStreamShard");
    image_speed = 1;
    name = "StreamShard";
    damage = 3;
	force = 5;
    typ = 2;
	target = noone;
	speed = random_range(4, 10);
	hitcooldown = 0;
	hitmaxcooldown = 30;
	turnspeed = 0;
	turnspeed_target = random_range(16, 22);
    on_step = script_ref_create(shard_step);
    on_hit = script_ref_create(shard_hit);
    on_draw = script_ref_create(shard_draw);
    return self;
}

#define shard_step
if (turnspeed < turnspeed_target) turnspeed += turnspeed_target * 0.06 * current_time_scale;
if (turnspeed > turnspeed_target) turnspeed = turnspeed_target;

var dist = 1000000;
var angdiff = 1000000;
if (instance_exists(target)) {
	dist = distance_to_object(target);
	angdiff = angle_difference(point_direction(x, y, target.x, target.y), direction);
}
with (enemy) {
	if (collision_line(x, y, other.x, other.y, Wall, 0, 1) == noone) {
		var dist2 = distance_to_object(other);
		var angdiff2 = angle_difference(point_direction(x, y, other.x, other.y), other.direction);
		if (dist2 < dist && angdiff2 < angdiff) {
			other.target = self;
			dist = dist2;
			angdiff = angdiff2;
		}
	}
}

if (instance_exists(target)) {
	direction += sign(angle_difference(point_direction(x, y, target.x, target.y), direction)) * turnspeed * current_time_scale;
	image_angle = direction;
}

if (random(2) < 1) {
    with (instance_create(random_range(bbox_left, bbox_right), random_range(bbox_top, bbox_bottom), PlasmaTrail)) {
        sprite_index = mod_script_call("mod", "nttlive_sprites", "get", "sprStreamTrail");
    }
}
if (image_index >= image_number - image_speed) {
    image_speed = 0;
	image_xscale *= 0.8;
	image_yscale *= 0.5;
}

hitcooldown -= current_time_scale;

#define shard_hit
if (hitcooldown <= 0) {
	if (projectile_canhit(other)) {
		sound_play_pitchvol(sndMenuSword, random_range(1.7, 2.3), 0.5);
		projectile_hit(other, damage);
		hitcooldown = hitmaxcooldown;
		image_xscale -= 0.1;
		image_yscale = image_xscale;
		with (instance_create(random_range(bbox_left, bbox_right), random_range(bbox_top, bbox_bottom), PlasmaTrail)) {
			sprite_index = mod_script_call("mod", "nttlive_sprites", "get", "sprStreamTrail");
			direction = other.direction + 180 + random_range(-30, 30);
			speed = random_range(4, 10);
		}
		damage--;
		if (damage <= 0) instance_destroy();
	}
}

#define shard_draw
draw_self();
draw_set_blend_mode(bm_add);
draw_sprite_ext(sprite_index, image_index, x, y, image_xscale * 2, image_yscale * 2, image_angle, image_blend, image_alpha * 0.1);
draw_set_blend_mode(bm_normal);