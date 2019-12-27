#macro c_twitch make_color_rgb(145, 70, 255);

#define init
with (instances_matching(CustomDraw, "name", mod_current)) instance_destroy();
with (script_bind_draw(charge_draw, -12)) {
	name = mod_current;
	persistent = 1;
}

#define weapon_name
return `@(color:${c_twitch})` + "INCENDIARY";

#define weapon_type
return 0;

#define weapon_auto
return 1;

#define weapon_cost
return 0;

#define weapon_load
return 0;

#define weapon_sprt
var spr = mod_script_call("mod", "nttlive_sprites", "get", "sprIncendiary");
if (instance_is(self, Player)) {
	draw_sprite_ext(spr, 0, x - lengthdir_x(wkick, gunangle), y - lengthdir_y(wkick, gunangle) + ("z" not in self ? 0 : z), 1, right, gunangle + wepangle, c_white, 1);
	return mskNone;
} else {
	return spr;
}

#define weapon_sprt_hud
return mod_script_call("mod", "nttlive_sprites", "get", "sprIncendiary");

#define weapon_area
return 6;

#define weapon_swap
return sndSwapEnergy;

#define weapon_text
return `@(color:${c_twitch})` + "inferno";

#define step(primary)
if ("nttlive_incendiary_charge" not in self) nttlive_incendiary_charge = 0;
if ("nttlive_incendiary_maxcharge" not in self) nttlive_incendiary_maxcharge = 4;
if ("nttlive_incendiary_visualangle" not in self) nttlive_incendiary_visualangle = 0;

nttlive_incendiary_visualangle += 4 * current_time_scale;

if (nttlive_incendiary_charge >= nttlive_incendiary_maxcharge) {
	nttlive_incendiary_charge = 0;
	sound_play_pitchvol(sndDragonStop, random_range(0.7, 0.9), 0.5);
	var bullets = nttlive_incendiary_maxcharge;
	var cone = 60;
	for (var i = 0; i < bullets; i++) {
		with (bullet_create(x + lengthdir_x(14, gunangle), y + lengthdir_y(14, gunangle))) {
			team = other.team;
			creator = other;
			direction = other.gunangle + (cone / 2) * (i + 0.5 - bullets / 2) * other.accuracy;
			image_angle = direction;
		}
	}
}

for (var i = 0; i < array_length(mod_variable_get("mod", "nttlive", "messages")); i++) if (mod_script_call("mod", "nttlive", "message_flag_check_weapon", mod_variable_get("mod", "nttlive", "messages")[i], "incendiary")) {
	nttlive_incendiary_charge++;
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

#define bullet_create(_x, _y)
with (instance_create(_x, _y, CustomProjectile)) {
    sprite_index = mod_script_call("mod", "nttlive_sprites", "get", "sprIncendiaryBullet");
    image_speed = 1;
    name = "IncendiaryBullet";
    damage = 2;
    typ = 2;
	speed = 10;
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

#define charge_draw
var spr = mod_script_call("mod", "nttlive_sprites", "get", "sprIncendiaryCharge");
with (Player) if ("nttlive_incendiary_charge" in self && "nttlive_incendiary_maxcharge" in self && "nttlive_incendiary_visualangle" in self && (wep == mod_current || bwep = mod_current)) {
	var flamedisplays = nttlive_incendiary_maxcharge - 1;
	for (var i = 0; i < flamedisplays; i++) {
		if (nttlive_incendiary_charge > i) {
			var len = max(bbox_right - bbox_left, bbox_bottom - bbox_top);
			var dir = nttlive_incendiary_visualangle + (i / flamedisplays) * 360;
			draw_sprite(spr, current_frame * (1 / current_time_scale) * 0.4, x + lengthdir_x(len, dir), y + lengthdir_y(len, dir));
			draw_set_blend_mode(bm_add);
			draw_sprite_ext(spr, current_frame * (1 / current_time_scale) * 0.4, x + lengthdir_x(len, dir), y + lengthdir_y(len, dir), 2, 2, 0, c_white, 0.2);
			draw_set_blend_mode(bm_normal);
		}
	}
}