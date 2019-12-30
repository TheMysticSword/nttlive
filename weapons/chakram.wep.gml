#macro c_twitch make_color_rgb(145, 70, 255);

#define weapon_name
var colortag = "";
if (instance_is(self, WepPickup)) colortag = `@(color:${c_twitch})`;
return colortag + "CHAKRAM";

#define weapon_type
return 6;

#define weapon_auto
return 0;

#define weapon_cost
return 1;

#define weapon_load
return 2;

#define weapon_sprt
return mod_script_call("mod", "nttlive_sprites", "get", "sprChakram");

#define weapon_sprt_hud
return mod_script_call("mod", "nttlive_sprites", "get", "sprChakramHUD");

#define weapon_area
return 6;

#define weapon_swap
return sndSwapSword;

#define weapon_text
return `@(color:${c_twitch})` + "arcing";

#define step(primary)
if ("nttlive_chakram_retrieved" not in self) nttlive_chakram_retrieved = 1;
if (!nttlive_chakram_retrieved) {
	if (primary) reload = weapon_get_load(mod_current);
	if (!primary) breload = weapon_get_load(mod_current);
}

#define weapon_fire
nttlive_chakram_retrieved = 0;
sound_play(sndChickenThrow);
with (chakram_create(x, y)) {
	team = other.team;
	creator = other;
	direction = other.gunangle + random_range(-8, 8) * other.accuracy;
	image_angle = direction;
}
weapon_post(0, 10, 0);

#define chakram_create(_x, _y)
with (instance_create(_x, _y, CustomProjectile)) {
	depth = -11;
    sprite_index = mod_script_call("mod", "nttlive_sprites", "get", "sprChakram");
	image_speed = 0;
    name = "Chakram";
    damage = 7;
    typ = 3;
	speed = 12;
	returnspeed = speed / 15;
	spinspeed = 30;
	pickdelay = 5;
    on_step = script_ref_create(chakram_step);
    on_hit = script_ref_create(chakram_hit);
    on_wall = script_ref_create(chakram_wall);
	on_draw = script_ref_create(chakram_draw);
    return self;
}

#define chakram_step
if (speed <= 0) {
	mask_index = sprite_index;
	if (place_meeting(x, y, Wall)) mask_index = mskNone;
	if (instance_exists(creator)) {
		direction = point_direction(creator.x, creator.y, x, y);
	}
}

image_angle += spinspeed;

speed -= returnspeed;

if (fork()) {
	var _creator = creator;
	wait 1;
	if (!instance_exists(self)) {
		with (_creator) nttlive_chakram_retrieved = 1;
	}
	exit;
}

pickdelay -= current_time_scale;
if (distance_to_object(creator) <= 2 && pickdelay <= 0) {
	instance_destroy();
}

#define chakram_hit
if (projectile_canhit_melee(other)) {
	projectile_hit(other, damage);
	if (speed > 0) speed = -speed;
	pickdelay = 0;
}

#define chakram_wall
if (speed > 0) {
	speed = -speed;
	pickdelay = 0;
} else {
	mask_index = mskNone;
}

#define chakram_draw
draw_self();
draw_set_blend_mode(bm_add);
draw_sprite_ext(sprite_index, image_index, x, y, image_xscale * 2, image_yscale * 2, image_angle, image_blend, image_alpha * 0.1);
draw_set_blend_mode(bm_normal);