#macro c_twitch make_color_rgb(145, 70, 255);

#define init
with (instances_matching(CustomStep, "name", mod_current)) instance_destroy();
with (instances_matching(CustomDraw, "name", mod_current)) instance_destroy();
with (script_bind_draw(debuff_step, 1000)) {
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
return colortag + "MEGAPHONE";

#define weapon_type
return 6;

#define weapon_auto
return 0;

#define weapon_cost
return 3;

#define weapon_load
return 50;

#define weapon_sprt
return mod_script_call("mod", "nttlive_sprites", "get", "sprMegaphone");

#define weapon_sprt_hud
return mod_script_call("mod", "nttlive_sprites", "get", "sprMegaphoneHUD");

#define weapon_area
return 6;

#define weapon_swap
return sndSwapEnergy;

#define weapon_text
return `@(color:${c_twitch})` + "aaaaaaaaaaaaaaaaaaaa";

#define weapon_fire
if (fork()) {
	var repeattimes = 4;
	var repeatdelay = 6;
	var falloff = 0.3;
	var vol = 1;
	var scream = choose(snd_chst, snd_crwn, snd_dead);
	var pitch = random_range(1, 1.2);
	for (var i = 0; i < repeattimes; i++) if (instance_exists(self)) {
		var mysnd = audio_play_sound(scream, 0, 0);
		audio_sound_gain(mysnd, vol, 0);
		audio_sound_pitch(mysnd, pitch);

		vol -= falloff;
		wait repeatdelay;
	}
	exit;
}
if (fork()) {
	var repeattimes = 9;
	var repeatdelay = 5;
	var falloff = 0.15;
	var vol = 1;
	for (var i = 0; i < repeattimes; i++) if (instance_exists(self)) {
		var mysnd = audio_play_sound(sndDiscHit, 0, 0);
		audio_sound_gain(mysnd, vol, 0);
		audio_sound_pitch(mysnd, 0.9);

		vol -= falloff;
		wait repeatdelay;
	}
	exit;
}
var _gunangle = gunangle;
if (fork()) {
	for (var i = 0; i < 3; i++) if (instance_exists(self)) {
		with (sonicwave_create(x, y)) {
			team = other.team;
			creator = other;
			direction = _gunangle;
			image_angle = direction;
		}
		wait 4;
	}
	exit;
}
weapon_post(-5, 20, 30);

#define sonicwave_create(_x, _y)
with (instance_create(_x, _y, CustomObject)) {
	depth = -12;
    name = "SonicWave";
	speed = 6;
	damage = 3;
	force = 6;
	maxdist = 32 * 2;
	fadedist = 32 * 1;
	hitlist = ds_list_create();
	wavepoints = [];
	waverange = 0;
	waveoffset = 12;
	waveminrange = 120;
	wavemaxrange = 180;
	becamevisible = 0;
	visible = 0;
	hittime = 0;
	hitmaxtime = 6;
	hitlist = ds_list_create();
    on_step = script_ref_create(sonicwave_step);
	on_draw = script_ref_create(sonicwave_draw);
    return self;
}

#define sonicwave_step
var dist = distance_to_point(xstart, ystart) - waveoffset;
if (dist > 0 && !becamevisible) {
	becamevisible = 1;
	visible = 1;
}

wavepoints = [];
waverange = waveminrange + (dist / maxdist) * (wavemaxrange - waveminrange);
var angle1 = direction - waverange / 2;
var angle2 = direction + waverange / 2;
var precision = 4; // higher value = less precise wave = better performance
for (var i = abs(angle_difference(angle1, angle2) / precision); i > 0; i--) {
	var _ang = angle2 + i * precision * sign(angle_difference(angle1, angle2));
	array_push(wavepoints, {px: x + lengthdir_x(dist, _ang), py: y + lengthdir_y(dist, _ang)});
}

hittime -= current_time_scale;
if (hittime <= 0) {
	hittime = hitmaxtime;
	with (mod_script_call("mod", "nttlive_util", "collision_cone", x, y, dist, direction - waverange / 2, direction + waverange / 2, hitme)) if (team != other.team) {
		var target = self;
		with (other) if (projectile_canhit(target) && ds_list_find_index(hitlist, target) == -1) {
			ds_list_add(hitlist, target);
			projectile_hit(target, damage, force);
			debuff_apply(target, 30 * 10);
		}
	}
}

if (dist >= fadedist) image_alpha = (maxdist - dist) / (maxdist - fadedist);
if (dist >= maxdist) instance_destroy();

#define sonicwave_draw
draw_set_alpha(image_alpha);
draw_primitive_begin(pr_trianglestrip);
for (var i = 0; i < array_length(wavepoints) - 1; i++) {
	var w = ((abs(i - array_length(wavepoints) / 2) - array_length(wavepoints) / 2) / (array_length(wavepoints) / 2)) * 6;
    var ang = point_direction(wavepoints[i].px, wavepoints[i].py, wavepoints[i + 1].px, wavepoints[i + 1].py) + 90;
    draw_vertex(wavepoints[i].px + lengthdir_x(w / 2, ang), wavepoints[i].py + lengthdir_y(w / 2, ang));
    draw_vertex(wavepoints[i + 1].px + lengthdir_x(w / 2, ang + 180), wavepoints[i + 1].py + lengthdir_y(w / 2, ang + 180));
}
draw_primitive_end();
draw_set_alpha(1);

#define debuff_apply(target, time)
with (target) {
	if ("weaken_active" not in self) weaken_active = 0;
	if ("weaken_time" not in self) weaken_time = 0;
	if ("weaken_lasthp" not in self) weaken_lasthp = 0;
	weaken_lasthp = my_health;
	weaken_active = 1;
	weaken_time = time;
}

#define debuff_step
var damage_mult = 2;
with (instances_matching(hitme, "weaken_active", 1)) {
	if (my_health < weaken_lasthp) {
		var difference = weaken_lasthp - my_health;
		my_health -= difference * (damage_mult - 1);
	}
	weaken_lasthp = my_health;
	weaken_time -= current_time_scale;
	if (weaken_time <= 0) {
		weaken_active = 0;
	}
}

#define debuff_draw
with (instances_matching(hitme, "weaken_active", 1)) {
	draw_sprite(mod_script_call("mod", "nttlive_sprites", "get", "sprMegaphoneDebuff"), 0, x, bbox_top - 4);
}