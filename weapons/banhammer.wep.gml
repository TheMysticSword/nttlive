#macro c_twitch make_color_rgb(145, 70, 255);

#define init
with (instances_matching(CustomDraw, "name", mod_current)) instance_destroy();
with (script_bind_draw(charge_draw, -8)) {
	name = mod_current;
	persistent = 1;
}

#define weapon_name
return `@(color:${c_twitch})` + "BANHAMMER";

#define weapon_type
return 0;

#define weapon_auto
return 0;

#define weapon_cost
return 0;

#define weapon_load
return 0;

#define weapon_sprt
return mod_script_call("mod", "nttlive_sprites", "get", "sprBanhammer");

#define weapon_area
return 13;

#define weapon_swap
return sndSwapEnergy;

#define weapon_text
return `@(color:${c_twitch})` + "charged by messages";

#define step(primary)
if ("nttlive_banhammer_charge" not in self) nttlive_banhammer_charge = 0;
if ("nttlive_banhammer_maxcharge" not in self) nttlive_banhammer_maxcharge = 40 + mod_variable_get("mod", "nttlive", "viewers") * 0.3;
if ("nttlive_banhammer_shake_x" not in self) nttlive_banhammer_shake_x = 0;
if ("nttlive_banhammer_shake_y" not in self) nttlive_banhammer_shake_y = 0;
var maxshake = (nttlive_banhammer_charge / nttlive_banhammer_maxcharge) * 4;
nttlive_banhammer_shake_x += (random_range(-maxshake, maxshake) - nttlive_banhammer_shake_x) * 0.4 * current_time_scale;
nttlive_banhammer_shake_y += (random_range(-maxshake, maxshake) - nttlive_banhammer_shake_y) * 0.4 * current_time_scale;
if (nttlive_banhammer_charge >= nttlive_banhammer_maxcharge) {
	nttlive_banhammer_charge = 0;
	sound_play_pitch(sndBasicUltra, random_range(0.4, 0.6));
	sound_play_pitch(sndChickenSword, random_range(0.09, 0.11));
	with (slash_create(x + lengthdir_x(14, gunangle), y + lengthdir_y(14, gunangle))) {
		team = other.team;
		creator = other;
		direction = other.gunangle;
		image_angle = direction;
	}
	with (Player) {
		view_shake_at(other.x, other.y, 200);
	}
}
for (var i = 0; i < array_length(mod_variable_get("mod", "nttlive", "messages")); i++) if (mod_script_call("mod", "nttlive", "message_flag_check", mod_variable_get("mod", "nttlive", "messages")[i], "banhammer")) {
	nttlive_banhammer_charge++;
}

if (random(nttlive_banhammer_maxcharge - nttlive_banhammer_charge) < 3) {
	var len = random_range(20, 40);
	var dir = random(360);
	with (instance_create(x + hspeed * len / 10, y + vspeed * len / 10, PlasmaTrail)) {
		sprite_index = mod_script_call("mod", "nttlive_sprites", "get", "sprStreamTrail");
		x += lengthdir_x(len, dir);
		y += lengthdir_y(len, dir);
		direction = dir + 180;
		speed = len / 10;
	}
}

if (primary) {
	wepflip = 1;
}

#define weapon_reloaded(primary)

#define weapon_fire

#define charge_draw
with (Player) {
	if (wep == mod_current || bwep == mod_current) {
		if ("nttlive_banhammer_charge" in self && "nttlive_banhammer_maxcharge" in self) {
			var chargeradius = 1.5 * max(sprite_width, sprite_height) / 2 * (nttlive_banhammer_charge / nttlive_banhammer_maxcharge);
			draw_set_color(c_twitch);
			draw_set_alpha(0.5);
			draw_set_blend_mode(bm_add);
			draw_circle(x + nttlive_banhammer_shake_x * 0.25, y + nttlive_banhammer_shake_y * 0.25, chargeradius, 0);
			draw_circle(x + nttlive_banhammer_shake_x * 0.5, y + nttlive_banhammer_shake_y * 0.5, chargeradius * 0.5, 0);
			draw_circle(x + nttlive_banhammer_shake_x, y + nttlive_banhammer_shake_y, chargeradius * 0.25, 0);
			draw_set_blend_mode(bm_normal);
			draw_set_color(c_white);
			draw_set_alpha(1);
		}
	}
}

#define slash_create(_x, _y)
sleep(100);
with (instance_create(_x, _y, CustomSlash)) {
    sprite_index = mod_script_call("mod", "nttlive_sprites", "get", "sprBanhammerSlash");
	image_speed = 0.3;
    name = "BanhammerSlash";
    damage = 100;
	force = 50;
	candeflect = 1;
	on_hit = script_ref_create(slash_hit);
	on_wall = script_ref_create(slash_wall);
    return self;
}

#define slash_hit
if (projectile_canhit_melee(other)) {
	projectile_hit(other, damage, force, direction);
}

#define slash_wall
sleep(5);
sound_play_pitch(sndMeleeWall, random_range(0.4, 0.6));
instance_create(other.x, other.y, FloorExplo);
with (other) instance_destroy();