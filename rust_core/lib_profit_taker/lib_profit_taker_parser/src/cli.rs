use lib_profit_taker_core::Run;
use owo_colors::OwoColorize;

fn format_duration(total_seconds: f64) -> String {
    let total_seconds_abs = total_seconds.abs();
    let minutes = (total_seconds_abs / 60.0).floor() as u64;
    let remaining_seconds = total_seconds_abs % 60.0;
    let seconds = remaining_seconds.floor() as u64;
    let milliseconds = ((remaining_seconds - seconds as f64) * 1000.0).round() as u64;

    if minutes > 0 {
        format!("{minutes}m {seconds}s {milliseconds:03}ms")
    } else {
        format!("{seconds}s {milliseconds:03}ms")
    }
}

fn format_phase_duration(seconds: f64) -> String {
    let total_seconds = seconds as u64;
    let minutes = total_seconds / 60;
    let remaining_seconds = total_seconds % 60;
    format!("{minutes}:{remaining_seconds:02}")
}

pub fn pretty_print_run(run: &Run) -> String {
    let total_flight_time = run.total_times.total_flight_time;
    let total_time = run.total_times.total_time;
    let total_fight_duration: f64 = run.total_times.total_time - total_flight_time;

    let formatted_total = format_duration(total_time);
    let formatted_flight = format!("{:.3}s", total_flight_time);
    let formatted_fight = format_duration(total_fight_duration);

    let mut output = String::new();

    // Header
    output.push('\n');
    output.push_str("------------------------------------------------------------------------\n\n");
    output.push_str(&
        format!(
        "{}{}{}{}{}{}\n\n",
        "Profit-Taker Run #".cyan(),
        run.run_id.cyan(), " by ".cyan(),
        run.player_name.bright_cyan(),
        " cleared in ".cyan(),
        formatted_total.bright_cyan()
    )
    );
    output.push_str(&format!("{}", format!(
        "From elevator to Profit-Taker took {}. Fight duration: {}.\n\n",
        formatted_flight, formatted_fight
    ).red()));

    // Phases
    for phase in &run.phases {
        let phase_time = phase.total_time;
        output.push_str(&format!(
            "{} {}\n",
            format!("> Phase {}", phase.phase_number).bright_green(), format!("[{phase_time:.3}]").bright_cyan()
        ));

        // Shield changes
        if !phase.shield_changes.is_empty() {
            let shield_sum: f64 = phase.shield_changes.iter().map(|s| s.shield_time).sum();
            let shield_parts: Vec<String> = phase.shield_changes
                .iter()
                .map(|s| format!("{:?} {:.3}s", s.status_effect, s.shield_time))
                .collect();
            if run.is_bugged_run && phase.phase_number == 4 {
                output.push_str(&format!(
                    " Shield change:   {} - {}\n",
                    format!("{shield_sum:.3}s").bright_red(), shield_parts.join(" | ").bright_yellow()
                ));
            } else {
                output.push_str(&format!(
                    " Shield change:   {} - {}\n",
                    format!("{shield_sum:.3}s").bright_green(), shield_parts.join(" | ").bright_yellow()
                ));
            }
            ;
        }

        // Leg breaks
        if !phase.leg_breaks.is_empty() {
            let leg_sum: f64 = phase.leg_breaks.iter().map(|l| l.leg_break_time).sum();
            let leg_parts: Vec<String> = phase.leg_breaks
                .iter()
                .map(|l| format!("{:.3}s", l.leg_break_time))
                .collect();
            output.push_str(&format!(
                " Leg break:       {} - {}\n",
                format!("{:.3}s", leg_sum).bright_green(),
                leg_parts.join(" | ").bright_yellow()
            ));
        }

        // Body killed
        if phase.total_body_kill_time > 0.0 {
            output.push_str(&format!(
                " Body killed:     {}\n",
                format!("{:.3}s", phase.total_body_kill_time).bright_green()

            ));
        }

        // Pylons
        if phase.total_pylon_time > 0.0 {
            output.push_str(&format!(
                " Pylons:          {}\n",
                format!("{:.3}s", phase.total_pylon_time).bright_green()

            ));
        } else if run.is_bugged_run && phase.phase_number == 3 {
            output.push_str(&format!(
                " Pylons:          {}\n",
                format!("{:.3}s", phase.total_pylon_time).bright_red()

            ));
        }

        output.push('\n');
    }

    // Sum of parts
    let sum_shield: f64 = run.total_times.total_shield_time;
    let sum_leg: f64 = run.total_times.total_leg_time;
    let sum_body: f64 = run.total_times.total_body_time;
    let sum_pylon: f64 = run.total_times.total_pylon_time;
    let sum_total = sum_shield + sum_leg + sum_body + sum_pylon;
    let formatted_sum_total = sum_total;


    if run.is_bugged_run {
        output.push_str(&format!("{} {}\n",
                                 "> Sum of parts".bright_green(), format!("[{formatted_sum_total:.3}]").bright_red()));
        output.push_str(&format!(" Shield change:  {}\n", format!("{sum_shield:.3}s").bright_red()));
        output.push_str(&format!(" Leg Break:      {}\n", format!("{sum_leg:.3}s").bright_green()));
        output.push_str(&format!(" Body Killed:    {}\n", format!("{sum_body:.3}s").bright_green()));
        output.push_str(&format!(" Pylons:         {}\n", format!("{sum_pylon:.3}s").bright_red()));
    } else {
        output.push_str(&format!("{} {}\n",
                                 "> Sum of parts".bright_green(), format!("[{formatted_sum_total:.3}]").bright_cyan()));
        output.push_str(&format!(" Shield change:  {}\n", format!("{sum_shield:.3}s").bright_green()));
        output.push_str(&format!(" Leg Break:      {}\n", format!("{sum_leg:.3}s").bright_green()));
        output.push_str(&format!(" Body Killed:    {}\n", format!("{sum_body:.3}s").bright_green()));
        output.push_str(&format!(" Pylons:         {}\n", format!("{sum_pylon:.3}s").bright_green()));
    }


    output.push_str("------------------------------------------------------------------------\n");

    println!("{output}");
    format!("{output:?}")
}