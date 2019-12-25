#define array_random(array)
return array[irandom(array_length(array) - 1)];

#define array_shuffle(array)
var shuffled_array = array_clone(array);
for (var i = 0; i < array_length(array); i++) {
    var randind = irandom(array_length(array) - 1);
    var oldval = shuffled_array[i];
    shuffled_array[i] = array[randind];
    array[@randind] = oldval;
}
return shuffled_array;

#define instance_random(_obj)
if (instance_exists(_obj)) {
    var instances = instances_matching(_obj, "", undefined);
    return array_random(instances);
} else {
    return noone;
}

#define object_random(_obj)
if (instance_exists(_obj)) {
    var instances = instances_matching(_obj, "", undefined);
    var objects = [];
    with (instances) {
        var already_added = 0;
        for (var i = 0; i < array_length(objects); i++) if (object_index == objects[i]) already_added = 1;
        if (!already_added) array_push(objects, object_index);
    }
    return array_random(objects);
} else {
    return noone;
}

#define instance_variables_grab(from)
var variables = variable_instance_get_names(from);
var grabbed_variables = [];
for (var k = 0; k < array_length(variables); k++) {
    var varname = variables[k];
    switch (varname) {
        case "sprite_width": case "sprite_height":
        case "sprite_xoffset": case "sprite_yoffset":
        case "image_number":
        case "bbox_left": case "bbox_right": case "bbox_top": case "bbox_bottom":
        case "object_index":
        case "id":
        case "alias": case "p": break;
        default:
            array_push(grabbed_variables, {name: varname, val: variable_instance_get(from, varname)});
            break;
    }
}
return grabbed_variables;

#define instance_variables_replace(to, variables)
for (var i = 0; i < array_length(variables); i++) {
    variable_instance_set(to, variables[i].name, variables[i].val);
}

#define custom_object_exists(_name)
if (array_length(instances_matching(CustomObject, "name", _name)) > 0) return true;
return false;

#define text_blink(tag)
return (current_frame % 30 < 15 ? tag : "");

#define enemy_get_alias(_obj)
switch (_obj) {
    case BanditBoss: return "Big Bandit";
    case ScrapBoss: return "Big Dog";
    case ScrapBossMissile: return "Missile";
    case LilHunter: return "Lil' Hunter";
    case Nothing: return "Throne";
    case Nothing2: return "Throne II";
    case FrogQueen: return "Mom";
    case HyperCrystal: return "Hyper Crystal";
    case TechnoMancer: return "Technomancer";
    case Last: return "Captain";
    case MeleeBandit: return "Assassin";
    case SuperMimic: return "Health Mimic";
    case SnowTank: return "Snowtank";
    case GoldSnowTank: return "Golden Snowtank";
    case SnowBot: return "Snowbot";
    case SnowBotCar: return "Snowbot";
    case FireBaller: return "Fireballer";
    case SuperFireBaller: return "Super Fireballer";
    case OasisBoss: return "Big Fish";
    case BoneFish: return "Bonefish";
    case InvLaserCrystal: return "Laser Crystal";
    case InvSpider: return "Spider";
    case EnemyHorror: return "Horror";
    default:
        var str = object_get_name(_obj);
        var newstr = "";
        for (var i = 1; i <= string_length(str); i++) {
            var char = string_char_at(str, i);
            if (char == string_upper(char) && i > 1) newstr += " ";
            newstr += char;
        }
        return newstr;
}

#define enemy_get_alias_inst(_inst)
switch (_inst.object_index) {
    case BanditBoss: return "Big Bandit";
    case ScrapBoss: return "Big Dog";
    case ScrapBossMissile: return "Missile";
    case LilHunter: return "Lil' Hunter";
    case Nothing: return "Throne";
    case Nothing2: return "Throne II";
    case FrogQueen: return "Mom";
    case HyperCrystal: return "Hyper Crystal";
    case TechnoMancer: return "Technomancer";
    case Last: return "Captain";
    case MeleeBandit: return "Assassin";
    case SuperMimic: return "Health Mimic";
    case SnowTank: return "Snowtank";
    case GoldSnowTank: return "Golden Snowtank";
    case SnowBot: return "Snowbot";
    case SnowBotCar: return "Snowbot";
    case FireBaller: return "Fireballer";
    case SuperFireBaller: return "Super Fireballer";
    case OasisBoss: return "Big Fish";
    case BoneFish: return "Bonefish";
    case InvLaserCrystal: return "Laser Crystal";
    case InvSpider: return "Spider";
    case EnemyHorror: return "Horror";
    case CustomHitme:
        var str = "CustomEnemy";
        if ("name" in _inst) str = _inst.name;
        var newstr = "";
        for (var i = 1; i <= string_length(str); i++) {
            var char = string_char_at(str, i);
            if (char == string_upper(char) && i > 1) newstr += " ";
            newstr += char;
        }
        return;
    default:
        var str = object_get_name(_inst.object_index);
        var newstr = "";
        for (var i = 1; i <= string_length(str); i++) {
            var char = string_char_at(str, i);
            if (char == string_upper(char) && i > 1) newstr += " ";
            newstr += char;
        }
        return newstr;
}