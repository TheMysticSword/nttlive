#define event_name
return "difficulty shift";

#define event_start
with (mod_variable_get("mod", "nttlive", "controller")) {
    difficultyshift_add = 0;
    difficultyshift_visual = 0.5;
}
mod_script_call("mod", "nttlive", "send_message", "TwitchVotes This run is going too well, so let's make the game harder! Vote + to increase the difficulty, vote - to decrease it!");
mod_variable_set("mod", "nttlive_events", "eventtext", "b:@r:bVOTE TO CHANGE DIFFICULTY!");

#define event_step
for (var i = 0; i < array_length(mod_variable_get("mod", "nttlive", "messages")); i++) if (mod_script_call("mod", "nttlive", "message_flag_check", mod_variable_get("mod", "nttlive", "messages")[i], "difficultyshift")) {
    with (mod_variable_get("mod", "nttlive", "controller")) {
        var division = max(mod_variable_get("mod", "nttlive", "viewers") * mod_variable_get("mod", "nttlive", "config").viewerScalingFactor, 1);
        if (mod_variable_get("mod", "nttlive", "messages")[i].content == "+") {
            mod_script_call("mod", "nttlive", "message_flag_check", mod_variable_get("mod", "nttlive", "messages")[i], "enemychatterhidden");
            difficultyshift_add += 1 / division;
        }
        if (mod_variable_get("mod", "nttlive", "messages")[i].content == "-") {
            mod_script_call("mod", "nttlive", "message_flag_check", mod_variable_get("mod", "nttlive", "messages")[i], "enemychatterhidden");
            difficultyshift_add -= 1 / division;
        }
    }
}

with (mod_variable_get("mod", "nttlive", "controller")) {
    if (GameCont.hard + difficultyshift_add < 1) {
        difficultyshift_add = 1 - GameCont.hard;
    }
    difficultyshift_visual += ((difficultyshift_add + 0.5) - difficultyshift_visual) * 0.5 * current_time_scale;
}

#define event_end
var result = 0;
with (mod_variable_get("mod", "nttlive", "controller")) {
    result = round(difficultyshift_add);
    GameCont.hard += round(difficultyshift_add);
    var loops = floor(GameCont.hard / 16);
    if (GameCont.loops < loops) {
        GameCont.loops = loops;
    }
}
mod_script_call("mod", "nttlive", "send_message", "imGlitch The voting is over! The difficulty was " + (result >= 0 ? "increased" : "decreased") + " by " + string(abs(result)) + " levels!");
mod_variable_set("mod", "nttlive_events", "eventtext", "DIFFICULTY " + (result >= 0 ? "b:@r:b+" : "b:@g:b") + string(abs(result)) + "!");

#define event_draw_gui
draw_set_halign(fa_middle);
draw_set_valign(fa_top);
draw_set_font(fntM);
draw_set_alpha(0.3);
draw_set_color(c_black);
draw_roundrect(game_width / 2 - 40 - 7, 26 + 3 - 7, game_width / 2 - 40 + 7, 26 + 3 + 7, 0);
draw_roundrect(game_width / 2 + 40 - 7, 26 + 3 - 7, game_width / 2 + 40 + 7, 26 + 3 + 7, 0);
draw_set_color(c_white);
draw_set_alpha(1);
draw_text_nt(game_width / 2 - 40, 26, "@g" + mod_script_call("mod", "nttlive_util", "text_blink", "@w") + "-");
draw_text_nt(game_width / 2 + 40, 26, "@r" + mod_script_call("mod", "nttlive_util", "text_blink", "@w") + "+");
with (mod_variable_get("mod", "nttlive", "controller")) {
    draw_text_nt(game_width / 2, 24, (difficultyshift_add >= 0 ? "+" : "") + string(round(difficultyshift_add)));
    var linewidth = 40;
    var linecurrent = (difficultyshift_visual % 1) * 40;
    draw_set_color(c_black);
    draw_line_width(game_width / 2 - linewidth / 2 + 1, 34, game_width / 2 + linewidth / 2 + 1, 34, 2);
    draw_line_width(game_width / 2 - linewidth / 2, 34 + 1, game_width / 2 + linewidth / 2, 34 + 1, 2);
    draw_line_width(game_width / 2 - linewidth / 2 + 1, 34 + 1, game_width / 2 + linewidth / 2 + 1, 34 + 1, 2);
    draw_line_width(game_width / 2 - linewidth / 2 + linecurrent + 1, 34 - 4, game_width / 2 - linewidth / 2 + linecurrent + 1, 34 + 4, 2);
    draw_line_width(game_width / 2 - linewidth / 2 + linecurrent, 34 - 4 + 1, game_width / 2 - linewidth / 2 + linecurrent, 34 + 4 + 1, 2);
    draw_line_width(game_width / 2 - linewidth / 2 + linecurrent + 1, 34 - 4 + 1, game_width / 2 - linewidth / 2 + linecurrent + 1, 34 + 4 + 1, 2);
    draw_set_color(c_white);
    draw_line_width(game_width / 2 - linewidth / 2, 34, game_width / 2 + linewidth / 2, 34, 2);
    draw_line_width(game_width / 2 - linewidth / 2 + linecurrent, 34 - 4, game_width / 2 - linewidth / 2 + linecurrent, 34 + 4, 2);
}
draw_set_halign(fa_left);
draw_set_valign(fa_top);