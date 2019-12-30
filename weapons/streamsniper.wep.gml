#macro c_twitch make_color_rgb(145, 70, 255);

#define init
with (instances_matching(CustomDraw, "name", mod_current)) instance_destroy();
with (script_bind_draw(target_draw, -12)) {
	name = mod_current;
	persistent = 1;
}

#define weapon_name
var colortag = "";
if (instance_is(self, WepPickup)) colortag = `@(color:${c_twitch})`;
return colortag + "STREAM SNIPER";

#define weapon_type
return 6;

#define weapon_auto
return 0;

#define weapon_cost
return 2;

#define weapon_load
return 13;

#define weapon_sprt
return mod_script_call("mod", "nttlive_sprites", "get", "sprStreamSniper");

#define weapon_sprt_hud
return mod_script_call("mod", "nttlive_sprites", "get", "sprStreamSniperHUD");

#define weapon_laser_sight
return mod_script_call("mod", "nttlive_sprites", "get", "sprStreamLaserSight");

#define weapon_area
return 6;

#define weapon_swap
return sndSwapMachinegun;

#define weapon_text
return `@(color:${c_twitch})` + "mark and kill";

#define step(primary)
if ("nttlive_streamsniper_target" not in self) nttlive_streamsniper_target = noone;
if ("nttlive_streamsniper_visualbump" not in self) nttlive_streamsniper_visualbump = 0;
if ("nttlive_streamsniper_visualangle" not in self) nttlive_streamsniper_visualangle = 0;
if ("nttlive_streamsniper_visualangle_speed" not in self) nttlive_streamsniper_visualangle_speed = 1;
if ("nttlive_streamsniper_visualangle_add" not in self) nttlive_streamsniper_visualangle_add = 0;
if ("nttlive_streamsniper_canaim" not in self) nttlive_streamsniper_canaim = 0;
if ("nttlive_streamsniper_customaim" not in self) nttlive_streamsniper_customaim = 0;
nttlive_streamsniper_visualbump += (0 - nttlive_streamsniper_visualbump) * 0.1 * current_time_scale;
nttlive_streamsniper_visualangle += (3 + nttlive_streamsniper_visualangle_add) * nttlive_streamsniper_visualangle_speed * current_time_scale;
nttlive_streamsniper_visualangle_add += (0 - nttlive_streamsniper_visualangle_add) * 0.1 * current_time_scale;

if (nttlive_streamsniper_customaim) {
	if (instance_exists(nttlive_streamsniper_target)) {
		var dir = point_direction(x, y, nttlive_streamsniper_target.x, nttlive_streamsniper_target.y);
		gunangle += angle_difference(dir, gunangle) * 0.4 * current_time_scale;
	}
}

with (instances_matching(projectile, "creator", other)) {
	if (fork()) {
		var _x = x;
		var _y = y;
		var _hspeed = hspeed;
		var _vspeed = vspeed;
		var _mask_index = mask_index;
		var _image_angle = image_angle;
		var _image_xscale = image_xscale;
		var _image_yscale = image_yscale;
		var _creator = creator;
		wait 1;
		if (!instance_exists(self)) {
			with (instance_create(_x + _hspeed, _y + _vspeed, CustomObject)) {
				mask_index = _mask_index;
				image_angle = _image_angle;
				image_xscale = _image_xscale;
				image_yscale = _image_yscale;
				with (enemy) if (place_meeting(x, y, other)) _creator.nttlive_streamsniper_target = self;
				instance_destroy();
			}
		}
		exit;
	}
}

#define weapon_fire
if (instance_exists(nttlive_streamsniper_target)) {
	nttlive_streamsniper_visualbump = 0.5;
	nttlive_streamsniper_visualangle_add = 4;
	if (!nttlive_streamsniper_customaim) {
		nttlive_streamsniper_canaim = canaim;
		nttlive_streamsniper_customaim = 1;
		canaim = 0;
	}
	sound_play_pitch(sndSniperTarget, random_range(1.8, 2.2));
	with (hitscan_bullet_create(x, y)) {
		team = other.team;
		creator = other;
		target = other.nttlive_streamsniper_target;
	}
} else {
	sound_play_pitch(sndServerBreak, random_range(1.9, 2.1));
	with (instance_create(x, y, PopupText)) mytext = "NO TARGETS";
	ammo[nttlive_streamammo_index] += weapon_get_cost(mod_current);
	nttlive_streamammo_last += weapon_get_cost(mod_current);
}
weapon_post(4, -12, 12);

#define hitscan_bullet_create(_x, _y)
with (instance_create(_x, _y, CustomProjectile)) {
    image_speed = 1;
    name = "StreamSniperBullet";
    damage = 15;
    typ = 3;
	firedelay = 10;
	decay = 30;
	target = noone;
	nobullethit = 0;
    on_step = script_ref_create(hitscan_bullet_step);
	on_destroy = script_ref_create(hitscan_bullet_destroy);
    return self;
}

#define hitscan_bullet_step
firedelay -= current_time_scale;
if (firedelay <= 0) {
	firedelay = 1000000;
	with (creator) {
		other.x = x;
		other.y = y;
		canaim = nttlive_streamsniper_canaim;
		nttlive_streamsniper_customaim = 0;
	}
	if (instance_exists(target)) {
		direction = point_direction(x, y, target.x, target.y);
		mask_index = mod_script_call("mod", "nttlive_sprites", "get", "mskStreamSniperBullet");
		var trail_x = x;
		var trail_y = y;
		var whiletries = 1000;
		while (whiletries > 0) {
			var targethit = 0;
			with (target) if (place_meeting(x, y, other)) {
				targethit = 1;
			}
			if (!targethit) {
				x += lengthdir_x(2, direction);
				y += lengthdir_y(2, direction);
			} else {
				whiletries = 0;
			}
			whiletries--;
		}
		sound_play_pitch(sndSniperFire, random_range(1.8, 2.2));
		x += lengthdir_x(2, direction);
		y += lengthdir_y(2, direction);
		with (instance_create(trail_x, trail_y, BoltTrail)) {
			depth = other.depth;
			image_xscale = point_distance(trail_x, trail_y, other.x, other.y);
			image_angle = point_direction(trail_x, trail_y, other.x, other.y);
			image_blend = c_twitch;
		}
	}
}
decay -= current_time_scale;
if (decay <= 0) {
	nobullethit = 1;
	instance_destroy();
}

#define hitscan_bullet_destroy
if (!nobullethit) {
	with (instance_create(x, y, BulletHit)) {
		sprite_index = mod_script_call("mod", "nttlive_sprites", "get", "sprStreamSniperBulletHit");
	}
}

#define target_draw
with (Player) if ("nttlive_streamsniper_target" in self) with (nttlive_streamsniper_target) {
	draw_sprite_ext(mod_script_call("mod", "nttlive_sprites", "get", "sprStreamSniperCrosshair"), 5, x, y, 1 + other.nttlive_streamsniper_visualbump, 1 + other.nttlive_streamsniper_visualbump, other.nttlive_streamsniper_visualangle, c_twitch, 1);
}