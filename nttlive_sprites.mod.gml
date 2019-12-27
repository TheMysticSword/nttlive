#define init
global.sprites = [];

load("sprSupplyDropParachute", 1, 18, 32);
load("sprStreamChest", 7, 8, 8);
load("sprStreamChestOpen", 1, 8, 8);
load("sprStreamNuke", 1, 6, 8);
load("sprInvasionPortalCharge", 4, 4, 4);
load("sprInvasionPortalClose", 14, 16, 16);
load("sprStreamShard", 2, 8, 8);
load("sprStreamTrail", 3, 4, 4);
load_wep("sprShardstream", 3, 3);
load_wep("sprBanhammer", 8, 12);
load("sprBanhammerSlash", 8, 0, 64);
load_wep("sprAFKLauncher", 5, 5);
load("sprAFKLauncherMissile", 4, 5.5, 3);

load_wep("sprStreamSniper", 11, 8);
load("mskStreamSniperBullet", 1, 1, 1);
load("sprStreamSniperBulletHit", 4, 8, 8);
load("sprStreamLaserSight", 1, 0, 0);
load("sprStreamSniperCrosshair", 1, 16, 16);
load("sprSecondLifeContainer", 1, 23, 23);
load("sprSecondLifePulse", 1, 23, 23);
load("sprSecondLifeErase", 1, 0, 0);
load("sprSecondLifeFilling", 7, 0, 0);
load_wep("sprGravityCannon", 17, 7);
load("sprGravityCannonCrosshair", 1, 16, 16);
load("sprGravityCannonCrosshairBump", 1, 16, 16);
load("sprGravityCannonDebuff", 3, 4, 4.5);
load("sprGravityCannonDebuffExplo", 1, 5, 5.5);
load("sprGravityCannonEffect", 1, 0.5, 6);
load("sprGravityCannonBullet", 2, 24, 8);
load("mskGravityCannonBullet", 1, 24, 8);
load("sprGravityCannonBulletHit", 3, 8, 8);
load("sprGravityCannonTrail", 3, 4, 4);

load_wep("sprScythePistol", 4, 4);
load("sprScythePistolSlash", 4, 0, 8);
load("sprScythePistolHeal", 8, 4, 5);
#define load(_name, _frames, _xoffset, _yoffset)
var newsprite = sprite_add("sprites/" + _name + ".png", _frames, _xoffset, _yoffset);
array_push(global.sprites, {name: _name, spr: newsprite});

#define load_wep(_name, _xoffset, _yoffset)
var newsprite = sprite_add_weapon("sprites/" + _name + ".png", _xoffset, _yoffset);
array_push(global.sprites, {name: _name, spr: newsprite});

#define get(_name)
for (var i = 0; i < array_length(global.sprites); i++) {
    if (global.sprites[i].name == _name) {
        return global.sprites[i].spr;
    }
}
return mskNone;