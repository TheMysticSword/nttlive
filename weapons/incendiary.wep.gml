#macro c_twitch make_color_rgb(145, 70, 255);

#define weapon_name
var colortag = "";
if (instance_is(self, WepPickup)) colortag = `@(color:${c_twitch})`;
return colortag + "INCENDIARY";

#define weapon_type
return 6;

#define weapon_auto
return 0;

#define weapon_cost
return 2;

#define weapon_load
return 30;

#define weapon_sprt
return mod_script_call("mod", "nttlive_sprites", "get", "sprIncendiary");

#define weapon_sprt_hud
return mod_script_call("mod", "nttlive_sprites", "get", "sprIncendiaryHUD");

#define weapon_area
return 6;

#define weapon_swap
return sndSwapDragon;

#define weapon_text
return `@(color:${c_twitch})` + "inferno";

#define weapon_fire
sound_play_pitch(sndDragonStop, random_range(0.7, 0.9));
with (super_bullet_create(x + lengthdir_x(14, gunangle), y + lengthdir_y(14, gunangle))) {
	team = other.team;
	creator = other;
	direction = other.gunangle + random_range(-4, 4) * other.accuracy;
	image_angle = direction;
}
weapon_post(10, 20, 18);

#define super_bullet_create(_x, _y)
with (instance_create(_x, _y, CustomProjectile)) {
    sprite_index = mod_script_call("mod", "nttlive_sprites", "get", "sprIncendiaryBullet");
    image_speed = 1;
    name = "IncendiarySuperBullet";
	image_xscale *= 1.5;
	image_yscale *= 1.5;
    damage = 8;
    typ = 1;
	speed = 6;
	nobullethit = 0;
	explode = 0;
	maxdist = 32 * 1;
	on_step = script_ref_create(super_bullet_step);
    on_hit = script_ref_create(super_bullet_hit);
    on_draw = script_ref_create(bullet_draw);
	on_destroy = script_ref_create(super_bullet_destroy);
    return self;
}

#define super_bullet_step
if (image_index >= image_number - image_speed) {
    image_speed = 0;
}

var dist = point_distance(x, y, xstart, ystart);
if (dist >= maxdist) {
	nobullethit = 1;
	explode = 1;
	instance_destroy();
}

#define super_bullet_hit
if (projectile_canhit(other)) {
	projectile_hit(other, damage);
	explode = 1;
	instance_destroy();
}

#define super_bullet_destroy
if (explode) {
	sound_play_pitch(sndDragonStart, random_range(0.7, 0.9));
	var bullets = 4;
	var cone = 30;
	for (var i = 0; i < bullets; i++) {
		with (bullet_create(x, y)) {
			team = other.team;
			creator = other;
			direction = other.direction + (cone / 2) * (i + 0.5 - bullets / 2);
			image_angle = direction;
		}
	}
}
if (!nobullethit) {
	with (instance_create(x, y, BulletHit)) {
		sprite_index = mod_script_call("mod", "nttlive_sprites", "get", "sprStreamBulletHit");
		image_xscale *= 1.5;
		image_yscale *= 1.5;
	}
}

#define bullet_create(_x, _y)
with (instance_create(_x, _y, CustomProjectile)) {
    sprite_index = mod_script_call("mod", "nttlive_sprites", "get", "sprIncendiaryBullet");
    image_speed = 1;
    name = "IncendiaryBullet";
    damage = 2;
    typ = 1;
	speed = 12;
	maxdist = 32 * 3;
	fadedist = 32 * 2;
	nobullethit = 0;
	flame_cooldown = 0;
	flame_maxcooldown = 3;
	hitenemies = ds_list_create();
    on_step = script_ref_create(bullet_step);
    on_hit = script_ref_create(bullet_hit);
    on_draw = script_ref_create(bullet_draw);
	on_destroy = script_ref_create(bullet_destroy);
    return self;
}

#define bullet_step
flame_cooldown -= current_time_scale;
if (flame_cooldown <= 0) {
	flame_cooldown = flame_maxcooldown;
	with (instance_create(x, y, Flame)) {
		sprite_index = mod_script_call("mod", "nttlive_sprites", "get", "sprStreamFire");
		team = other.team;
		creator = other.creator;
	}
}

if (image_index >= image_number - image_speed) {
    image_speed = 0;
}

var dist = point_distance(x, y, xstart, ystart);
if (dist >= fadedist) {
	image_alpha = (maxdist - dist) / (maxdist - fadedist);
}
if (dist >= maxdist) {
	nobullethit = 1;
	instance_destroy();
}

#define bullet_hit
if (projectile_canhit(other) && ds_list_find_index(hitenemies, other) == -1) {
	projectile_hit(other, damage);
	ds_list_add(hitenemies, other);
}

#define bullet_draw
draw_self();
draw_set_blend_mode(bm_add);
draw_sprite_ext(sprite_index, image_index, x, y, image_xscale * 2, image_yscale * 2, image_angle, image_blend, image_alpha * 0.1);
draw_set_blend_mode(bm_normal);

#define bullet_destroy
if (!nobullethit) {
	with (instance_create(x, y, BulletHit)) {
		sprite_index = mod_script_call("mod", "nttlive_sprites", "get", "sprStreamBulletHit");
	}
}