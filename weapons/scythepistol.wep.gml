#macro c_twitch make_color_rgb(145, 70, 255);

#define init
with (instances_matching(CustomDraw, "name", mod_current)) instance_destroy();
with (script_bind_draw(heal_draw, -12)) {
	name = mod_current;
	persistent = 1;
}

#define weapon_name
var colortag = "";
if (instance_is(self, WepPickup)) colortag = `@(color:${c_twitch})`;
return colortag + "SCYTHE PISTOL";

#define weapon_type
return 6;

#define weapon_auto
return 1;

#define weapon_cost
return 1;

#define weapon_load
return 10;

#define weapon_sprt
return mod_script_call("mod", "nttlive_sprites", "get", "sprScythePistol");;

#define weapon_sprt_hud
return mod_script_call("mod", "nttlive_sprites", "get", "sprScythePistolHUD");

#define weapon_area
return 6;

#define weapon_swap
return sndSwapPistol;

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

#define weapon_fire
sound_play_pitch(sndPistol, random_range(2, 2.2));
sound_play_pitch(sndMenuSword, random_range(2, 2.2));
sound_play_pitch(sndChickenThrow, random_range(1.2, 1.4));
with (slash_create(x + lengthdir_x(14, gunangle), y + lengthdir_y(14, gunangle))) {
	team = other.team;
	creator = other;
	direction = other.gunangle + random_range(-4, 4) * other.accuracy;
	image_angle = direction;
}
weapon_post(4, -4, 0);

#define slash_create(_x, _y)
with (instance_create(_x, _y, CustomSlash)) {
    sprite_index = mod_script_call("mod", "nttlive_sprites", "get", "sprScythePistolSlash");
	image_xscale = 1.5;
	image_yscale = 1.3;
    name = "ScythePistolSlash";
    damage = 5;
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