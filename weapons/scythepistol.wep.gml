#macro c_twitch make_color_rgb(145, 70, 255);

#define init
with (instances_matching(CustomDraw, "name", mod_current)) instance_destroy();
with (script_bind_draw(heal_draw, -12)) {
	name = mod_current;
	persistent = 1;
}

#define weapon_name
return `@(color:${c_twitch})` + "SCYTHE PISTOL";

#define weapon_type
return 0;

#define weapon_auto
return 1;

#define weapon_cost
return 0;

#define weapon_load
return 0;

#define weapon_sprt
var spr = mod_script_call("mod", "nttlive_sprites", "get", "sprScythePistol");
if (instance_is(self, Player)) {
	draw_sprite_ext(spr, 0, x - lengthdir_x(wkick, gunangle), y - lengthdir_y(wkick, gunangle) + ("z" not in self ? 0 : z), 1, right, gunangle + wepangle, c_white, 1);
	return mskNone;
} else {
	return spr;
}

#define weapon_sprt_hud
return mod_script_call("mod", "nttlive_sprites", "get", "sprScythePistol");

#define weapon_area
return 6;

#define weapon_swap
return sndSwapEnergy;

#define weapon_text
return `@(color:${c_twitch})` + "resurgence";

#define step(primary)
if ("nttlive_scythepistol_charge" not in self) nttlive_scythepistol_charge = 0;
if ("nttlive_scythepistol_maxcharge" not in self) nttlive_scythepistol_maxcharge = 10;
if (nttlive_scythepistol_charge >= nttlive_scythepistol_maxcharge) {
	nttlive_scythepistol_charge = 0;
	my_health += 1;
	if (my_health >= maxhealth) my_health = maxhealth;
	sound_play(sndBloodlustProc);
	with (instance_create(x, y, BloodLust)) creator = other;
	with (instance_create(x, y, PopupText)) mytext = "+1 HP";
}

for (var i = 0; i < array_length(mod_variable_get("mod", "nttlive", "messages")); i++) if (mod_script_call("mod", "nttlive", "message_flag_check_weapon", mod_variable_get("mod", "nttlive", "messages")[i], "scythepistol")) {
	sound_play_pitchvol(sndPistol, random_range(2, 2.2), 0.5);
	sound_play_pitchvol(sndMenuSword, random_range(2, 2.2), 0.5);
	sound_play_pitchvol(sndChickenThrow, random_range(1.2, 1.4), 0.5);
	with (slash_create(x + lengthdir_x(14, gunangle), y + lengthdir_y(14, gunangle))) {
		team = other.team;
		creator = other;
		direction = other.gunangle + random_range(-4, 4) * other.accuracy;
		image_angle = direction;
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

#define slash_create(_x, _y)
with (instance_create(_x, _y, CustomSlash)) {
    sprite_index = mod_script_call("mod", "nttlive_sprites", "get", "sprScythePistolSlash");
	image_xscale = 1.5;
	image_yscale = 1.3;
    name = "ScythePistolSlash";
    damage = 1;
    typ = 2;
	canheal = 1;
	candeflect = 0;
	on_hit = script_ref_create(slash_hit);
	on_wall = script_ref_create(slash_wall);
	on_grenade = script_ref_create(slash_grenade);
	on_projectile = script_ref_create(slash_projectile);
    return self;
}

#define slash_hit
if (projectile_canhit_melee(other)) {
	projectile_hit(other, damage);
	if (canheal) {
		with (creator) {
			nttlive_scythepistol_charge++;
		}
		canheal = 0;
	}
}

#define slash_wall

#define slash_grenade

#define slash_projectile

#define heal_draw
var spr = mod_script_call("mod", "nttlive_sprites", "get", "sprScythePistolHeal");
with (Player) if ("nttlive_scythepistol_charge" in self && (wep == mod_current || bwep = mod_current)) {
	draw_sprite(spr, (nttlive_scythepistol_charge / nttlive_scythepistol_maxcharge) * sprite_get_number(spr), x, bbox_top - 4);
}