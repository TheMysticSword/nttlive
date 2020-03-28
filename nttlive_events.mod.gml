#macro c_twitch make_color_rgb(145, 70, 255);

#define init
mod_sideload();
global.events = [];
global.currentevent = "";
global.eventmaxcooldown = 30 * 60 * 1;
//global.eventmaxcooldown = 30;
global.eventcooldown = global.eventmaxcooldown;
global.eventmaxtime = 30 * 30;
//global.eventmaxtime = 30 * 10;
global.eventtime = global.eventmaxtime;
global.eventname = "";
global.eventtext = "";
global.eventtext_time = 0;
global.eventtext_maxtime = 30 * 4;

var events = [];
wait file_find_all("./events", events, 1);
for (var i = 0; i < array_length(events); i++) {
    if (!events[i].is_dir && events[i].ext == ".gml") {
        mod_load(events[i].path);
        var event_name = string_replace_all(string_replace_all(events[i].name, ".mod.gml", ""), "event_", "");
        array_push(global.events, event_name);
    }
}

#define events_enabled()
return mod_variable_get("mod", "nttlive", "config").timedEvents == json_true;

#define game_start
global.currentevent = "";
global.eventcooldown = global.eventmaxcooldown;
global.eventtime = global.eventmaxtime;
global.eventtext = "";

#define step
if (events_enabled()) {
    if (!instance_exists(Menu)) {
        if (!instance_exists(GenCont) && !instance_exists(LevCont)) {
            if (global.currentevent == "") {
                global.eventtext_time -= current_time_scale;
                if (global.eventtext_time <= 0) {
                    global.eventtext = "";
                }

                global.eventcooldown -= current_time_scale;
                if (global.eventcooldown <= 0) {
                    if (array_length(global.events) > 0) {
                        var myevent = mod_script_call("mod", "nttlive_util", "array_random", global.events);
                        global.currentevent = myevent;
                        global.eventcooldown = global.eventmaxcooldown;
                        global.eventtime = global.eventmaxtime;
                        global.eventname = mod_script_call("mod", "event_" + global.currentevent, "event_name");
                        global.eventtext = "";
                        mod_script_call("mod", "event_" + global.currentevent, "event_start");
                        sound_play(sndTVOn);
                    }
                }
            } else {
                mod_script_call("mod", "event_" + global.currentevent, "event_step");
                global.eventtime -= current_time_scale;
                if (global.eventtime <= 0) {
                    global.eventtext = "";
                    global.eventtext_time = global.eventtext_maxtime;
                    mod_script_call("mod", "event_" + global.currentevent, "event_end");
                    global.currentevent = "";
                    sound_play_pitch(sndTurnChair, 0.7);
                }
            }
        }

        if (!instance_exists(Player)) {
            global.eventtime = 0;
            global.eventcooldown = global.eventmaxcooldown;
            global.eventtext = "";
        }
    } else {
        global.currentevent = "";
        global.eventcooldown = global.eventmaxcooldown;
        global.eventtime = global.eventmaxtime;
        global.eventtext = "";
    }

    // end all events if the Throne exists or a revival event is in progress
    if (instance_exists(Nothing) || mod_variable_get("mod", "nttlive", "secondlife")) {
        global.eventtime = 0;
        global.eventcooldown = global.eventmaxcooldown;
        global.eventtext = "";
    }
}

#define draw_gui
if (!instance_exists(LevCont) && !mod_variable_get("mod", "nttlive", "secondlife") && events_enabled()) {
    if (global.currentevent != "") {
        draw_set_halign(1);
        draw_set_valign(0);
        draw_set_font(fntChat);
        draw_text_nt(game_width / 2, 2, `@(color:${c_twitch})` + string_upper(global.eventname) + " - event ends in " + string(ceil(global.eventtime / 30)) + "s");
        if (global.eventtext != "") draw_text_nt(game_width / 2, 12, format_eventtext(global.eventtext));
        draw_set_halign(0);
        draw_set_font(fntM);

        mod_script_call("mod", "event_" + global.currentevent, "event_draw_gui");

        mod_script_call("mod", "nttlive", "draw_timebar", global.eventtime / global.eventmaxtime);
    } else if (instance_exists(Player) && !instance_exists(Nothing)) {
        draw_set_halign(1);
        draw_set_valign(0);
        draw_set_font(fntChat);
        draw_text_nt(game_width / 2, 2, `@(color:${c_twitch})` + "Next event in " + string(ceil(global.eventcooldown / 30)) + "s");
        if (global.eventtext != "") draw_text_nt(game_width / 2, 12, format_eventtext(global.eventtext));
        draw_set_halign(0);
        draw_set_font(fntM);

        mod_script_call("mod", "nttlive", "draw_timebar", 1 - global.eventcooldown / global.eventmaxcooldown);
    }
}

#define format_eventtext(str)
var whiletries = 1000;
while (whiletries > 0) {
    var formatting_ended = 1;
    // blink tag - used to make blinking colours
    var blinktag_start = "b:";
    var blinktag_end = ":b";
    var blinktag_pos = string_pos(blinktag_start, str);
    if (blinktag_pos != 0) {
        formatting_ended = 0;

        var blinktag_endpos = string_pos(blinktag_end, str);
        var blinkvalue = string_copy(str, blinktag_pos + string_length(blinktag_start), blinktag_endpos - blinktag_pos - string_length(blinktag_start));
        str = string_delete(str, blinktag_pos, string_length(blinktag_start) + string_length(blinkvalue) + string_length(blinktag_end));
        str = string_insert(mod_script_call("mod", "nttlive_util", "text_blink", blinkvalue), str, blinktag_pos);
    }
    if (formatting_ended) whiletries = 0;
    whiletries--;
}
return str;