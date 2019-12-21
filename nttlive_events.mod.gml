#macro c_twitch make_color_rgb(145, 70, 255);

#define init
mod_sideload();
global.events = [];
global.currentevent = "";
global.eventmaxcooldown = 30 * 60;
//global.eventmaxcooldown = 30;
global.eventcooldown = global.eventmaxcooldown;
global.eventmaxtime = 30 * 30;
//global.eventmaxtime = 30 * 10;
global.eventtime = global.eventmaxtime;
global.eventname = "";

var events = [];
wait file_find_all("./events", events, 1);
for (var i = 0; i < array_length(events); i++) {
    if (!events[i].is_dir && events[i].ext == ".gml") {
        mod_load(events[i].path);
        var event_name = string_replace_all(string_replace_all(events[i].name, ".mod.gml", ""), "event_", "");
        array_push(global.events, event_name);
    }
}

#define game_start
global.currentevent = "";
global.eventcooldown = global.eventmaxcooldown;
global.eventtime = global.eventmaxtime;

#define step
if (!instance_exists(Menu)) {
    if (!instance_exists(GenCont) && !instance_exists(LevCont)) {
        if (global.currentevent == "") {
            global.eventcooldown -= current_time_scale;
            if (global.eventcooldown <= 0) {
                var myevent = mod_script_call("mod", "nttlive_util", "array_random", global.events);
                myevent = "invasion";
                global.currentevent = myevent;
                global.eventcooldown = global.eventmaxcooldown;
                global.eventtime = global.eventmaxtime;
                global.eventname = mod_script_call("mod", "event_" + global.currentevent, "event_name");
                mod_script_call("mod", "event_" + global.currentevent, "event_start");
                sound_play(sndTVOn);
            }
        } else {
            mod_script_call("mod", "event_" + global.currentevent, "event_step");
            global.eventtime -= current_time_scale;
            if (global.eventtime <= 0) {
                mod_script_call("mod", "event_" + global.currentevent, "event_end");
                global.currentevent = "";
            }
        }
    }

    if (!instance_exists(Player)) {
        global.eventtime = 0;
    }
} else {
    global.currentevent = "";
    global.eventcooldown = global.eventmaxcooldown;
    global.eventtime = global.eventmaxtime;
}

// end all events if the Throne exists
if (instance_exists(Nothing)) {
    global.eventtime = 0;
    global.eventcooldown = global.eventmaxcooldown;
}

#define draw_gui
if (!instance_exists(LevCont)) {
    if (global.currentevent != "") {
        draw_set_halign(1);
        draw_set_valign(0);
        draw_set_font(fntChat);
        draw_text_nt(game_width / 2, 2, `@(color:${c_twitch})` + string_upper(global.eventname) + " - event ends in " + string(ceil(global.eventtime / 30)) + "s");
        draw_set_halign(0);
        draw_set_font(fntM);

        mod_script_call("mod", "event_" + global.currentevent, "event_draw_gui");

        mod_script_call("mod", "nttlive", "draw_timebar", global.eventtime / global.eventmaxtime);
    } else if (instance_exists(Player) && !instance_exists(Nothing)) {
        draw_set_halign(1);
        draw_set_valign(0);
        draw_set_font(fntChat);
        draw_text_nt(game_width / 2, 2, `@(color:${c_twitch})` + "Next event in " + string(ceil(global.eventcooldown / 30)) + "s");
        draw_set_halign(0);
        draw_set_font(fntM);

        mod_script_call("mod", "nttlive", "draw_timebar", 1 - global.eventcooldown / global.eventmaxcooldown);
    }
}