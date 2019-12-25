#define event_name
return "autocontrol";

#define event_start
with (mod_variable_get("mod", "nttlive", "controller")) {
    autocontrol_fired = 0;
    autocontrol_specd = 0;
}
with (Player) {
    autocontrol_canfire = canfire;
    autocontrol_canspec = canspec;
    canfire = 0;
    canspec = 0;
    autocontrol_resetfire = 0;
    autocontrol_resetspec = 0;
    autocontrol_resetauto = 0;
}
mod_script_call("mod", "nttlive", "send_message", "TwitchLit The controls are now in your hands! Type PowerUpL to shoot and PowerUpR to use the special ability!");
mod_variable_set("mod", "nttlive_events", "eventtext", "b:@r:bPowerUpL - FIRE | PowerUpR - ABILITY");

#define event_step
with (Player) {
    clicked = 0;
    bclicked = 0;
    usespec = 0;
    if (autocontrol_resetfire) canfire = 0;
    if (autocontrol_resetspec) canspec = 0;
    if (autocontrol_resetauto) autocontrol_resetauto = weapon_set_auto(wep, 1);
    autocontrol_resetfire = 0;
    autocontrol_resetspec = 0;
    autocontrol_resetauto = 0;
}
for (var i = 0; i < array_length(mod_variable_get("mod", "nttlive", "messages")); i++) if (mod_script_call("mod", "nttlive", "message_flag_check", mod_variable_get("mod", "nttlive", "messages")[i], "autocontrol")) {
    if (string_pos("PowerUpL", mod_variable_get("mod", "nttlive", "messages")[i].content) != 0) {
        mod_script_call("mod", "nttlive", "message_flag_check", mod_variable_get("mod", "nttlive", "messages")[i], "enemychatterhidden");
        with (Player) {
            canfire = 1;
            clicked = 1;
            autocontrol_resetfire = 1;
            autocontrol_resetauto = weapon_get_auto(wep);
            weapon_set_auto(wep, 0);
        }
    }
    if (string_pos("PowerUpR", mod_variable_get("mod", "nttlive", "messages")[i].content) != 0) {
        mod_script_call("mod", "nttlive", "message_flag_check", mod_variable_get("mod", "nttlive", "messages")[i], "enemychatterhidden");
        with (Player) {
            canspec = 1;
            usespec = 1;
            autocontrol_resetspec = 1;
        }
    }
}

#define event_end
var totalfired = 0;
var totalspecd = 0;
with (mod_variable_get("mod", "nttlive", "controller")) {
    totalfired = autocontrol_fired;
    totalspecd = autocontrol_specd;
}
mod_script_call("mod", "nttlive", "send_message", "imGlitch BROADCASTER_NAME gets the controls back! We fired " + string(totalfired) + " times and used the special ability " + string(totalspecd) + " times!");
mod_variable_set("mod", "nttlive_events", "eventtext", "b:@b:bCONTROL REGAINED");

#define event_draw_gui