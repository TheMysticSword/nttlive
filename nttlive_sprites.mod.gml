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

#define load(_name, _frames, _xoffset, _yoffset)
var newsprite = sprite_add("sprites/" + _name + ".png", _frames, _xoffset, _yoffset);
array_push(global.sprites, {name: _name, spr: newsprite});

#define get(_name)
for (var i = 0; i < array_length(global.sprites); i++) {
    if (global.sprites[i].name == _name) {
        return global.sprites[i].spr;
    }
}
return mskNone;