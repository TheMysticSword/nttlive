#macro c_twitch make_color_rgb(145, 70, 255);

#define weapon_name
var colortag = "";
if (instance_is(self, WepPickup)) colortag = `@(color:${c_twitch})`;
return colortag + "BANHAMMER";

#define weapon_type
return 6;

#define weapon_auto
return 0;

#define weapon_cost
return 40;

#define weapon_load
return 90;

#define weapon_sprt
return mod_script_call("mod", "nttlive_sprites", "get", "sprBanhammer");

#define weapon_sprt_hud
return mod_script_call("mod", "nttlive_sprites", "get", "sprBanhammerHUD");

#define weapon_area
return 13;

#define weapon_swap
return sndSwapHammer;

#define weapon_text
return `@(color:${c_twitch})` + "the ban hammer has spoken";

#define weapon_melee
return true;

#define weapon_fire
sound_play_pitch(sndBasicUltra, random_range(0.4, 0.6));
sound_play_pitch(sndChickenSword, random_range(0.09, 0.11));
with (slash_create(x + lengthdir_x(14, gunangle), y + lengthdir_y(14, gunangle))) {
	team = other.team;
	creator = other;
	direction = other.gunangle;
	image_angle = direction;
	image_yscale = sign(other.wepflip);
}
weapon_post(-10, 30, 200);
wepangle = -wepangle;

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