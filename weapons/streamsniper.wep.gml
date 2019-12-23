#macro c_twitch make_color_rgb(145, 70, 255);

#define init
with (instances_matching(CustomDraw, "name", mod_current)) instance_destroy();
with (script_bind_draw(cursor_draw, -9999)) {
	name = mod_current;
	persistent = 1;
}

#define weapon_name
return `@(color:${c_twitch})` + "STREAM SNIPER";

#define weapon_type
return 0;

#define weapon_auto
return 1;

#define weapon_cost
return 0;

#define weapon_load
return 0;

#define weapon_sprt
return mod_script_call("mod", "nttlive_sprites", "get", "sprStreamSniper");

#define weapon_area
return 3;

#define weapon_swap
return sndSwapEnergy;

#define weapon_text
return `@(color:${c_twitch})` + "pew pew pew";

#define step(primary)
for (var i = 0; i < array_length(mod_variable_get("mod", "nttlive", "messages")); i++) if (mod_script_call("mod", "nttlive", "message_flag_check", mod_variable_get("mod", "nttlive", "messages")[i], "streamsniper")) {
	nttlive_streamsniper_visualbump = 0.1;
	sound_play_pitchvol(sndSniperTarget, random_range(1.8, 2.2), 0.5);
	with (hitscan_bullet_create(x + lengthdir_x(14, gunangle), y + lengthdir_y(14, gunangle))) {
		team = other.team;
		creator = other;
	}
}

if (button_pressed(index, "horn")) {
	nttlive_streamsniper_visualbump = 0.5;
	nttlive_streamsniper_visualangle_add = 4;
	sound_play_pitchvol(sndSniperTarget, random_range(1.8, 2.2), 0.5);
	with (hitscan_bullet_create(x + lengthdir_x(14, gunangle), y + lengthdir_y(14, gunangle))) {
		team = other.team;
		creator = other;
	}
}

if ("nttlive_streamsniper_visualbump" not in self) nttlive_streamsniper_visualbump = 0;
if ("nttlive_streamsniper_visualangle" not in self) nttlive_streamsniper_visualangle = 0;
if ("nttlive_streamsniper_visualangle_speed" not in self) nttlive_streamsniper_visualangle_speed = 1;
if ("nttlive_streamsniper_visualangle_add" not in self) nttlive_streamsniper_visualangle_add = 0;
nttlive_streamsniper_visualbump += (0 - nttlive_streamsniper_visualbump) * 0.1 * current_time_scale;
nttlive_streamsniper_visualangle += (3 + nttlive_streamsniper_visualangle_add) * nttlive_streamsniper_visualangle_speed;
nttlive_streamsniper_visualangle_add += (0 - nttlive_streamsniper_visualangle_add) * 0.1 * current_time_scale;

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

#define cursor_draw
if (!instance_exists(LevCont) && !instance_exists(GenCont)) {
	for (var p = 0; p < maxp; p++) {
		with (instances_matching(Player, "index", p)) if (wep == mod_current || bwep == mod_current) {
			if ("nttlive_streamsniper_visualbump" in self && "nttlive_streamsniper_visualbump" in self) {
				for (var p2 = 0; p2 < maxp; p2++) draw_set_visible(p2, (p == p2));
				draw_sprite_ext(mod_script_call("mod", "nttlive_sprites", "get", "sprStreamSniperCrosshair"), 5, mouse_x[p] + mouse_delta_x[p], mouse_y[p] + mouse_delta_y[p], 1 + nttlive_streamsniper_visualbump, 1 + nttlive_streamsniper_visualbump, nttlive_streamsniper_visualangle, c_twitch, 1);
				draw_set_visible_all(1);
			}
		}
	}
}

#define weapon_laser_sight
return mod_script_call("mod", "nttlive_sprites", "get", "sprStreamLaserSight");

#define weapon_reloaded(primary)

#define weapon_fire

#define hitscan_bullet_create(_x, _y)
with (instance_create(_x, _y, CustomProjectile)) {
    image_speed = 1;
    name = "StreamSniperBullet";
    damage = 5;
    typ = 2;
	firedelay = 10;
	decay = 30;
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
		other.direction = gunangle;
	}
	mask_index = mod_script_call("mod", "nttlive_sprites", "get", "mskStreamSniperBullet");
	var trail_x = x;
	var trail_y = y;
	var whiletries = 1000;
	while (whiletries > 0) {
		if (!place_meeting(x + lengthdir_x(2, direction), y + lengthdir_y(2, direction), Wall) && place_meeting(x + lengthdir_x(2, direction), y + lengthdir_y(2, direction), Floor)) {
			var targethit = 0;
			with (instances_matching_ne(hitme, "team", team)) if (place_meeting(x, y, other)) {
				targethit = 1;
			}
			if (!targethit) {
				x += lengthdir_x(2, direction);
				y += lengthdir_y(2, direction);
			} else {
				whiletries = 0;
			}
		} else {
			whiletries = 0;
		}
		whiletries--;
	}
	sound_play_pitchvol(sndSniperFire, random_range(1.8, 2.2), 0.5);
	x += lengthdir_x(2, direction);
	y += lengthdir_y(2, direction);
	with (instance_create(trail_x, trail_y, BoltTrail)) {
		depth = other.depth;
		image_xscale = point_distance(trail_x, trail_y, other.x, other.y);
		image_angle = point_direction(trail_x, trail_y, other.x, other.y);
		image_blend = c_twitch;
	}
}
decay -= current_time_scale;
if (decay <= 0 || place_meeting(x, y, Wall)) {
	instance_destroy();
}

#define hitscan_bullet_destroy
with (instance_create(x, y, BulletHit)) {
	sprite_index = mod_script_call("mod", "nttlive_sprites", "get", "sprStreamSniperBulletHit");
}