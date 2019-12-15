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