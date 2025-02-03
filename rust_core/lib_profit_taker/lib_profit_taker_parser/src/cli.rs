use lib_profit_taker_core::Run;

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

pub fn pretty_print_run(run: &Run) -> String {
    let total_flight_time = run.total_times.total_flight_time;
    let total_time = run.total_times.total_time;
    let total_fight_duration: f64 = run.total_times.total_time - total_flight_time;

    let formatted_total = format_duration(total_time);
    let formatted_flight = format!("{total_flight_time:.3}s");
    let formatted_fight = format_duration(total_fight_duration);

    let mut output = String::new();

    // Header
    output.push('\n');
    output.push_str("------------------------------------------------------------------------\n\n");
    output.push_str(&format!(
        "Profit-Taker Run #{} by {} cleared in {}\n\n",
        run.run_id, run.player_name, formatted_total
    ));
    //TODO: fetch run id from db
    output.push_str(&format!("From elevator to Profit-Taker took {formatted_flight}. Fight duration: {formatted_fight}.\n\n"));

    // Phases
    for phase in &run.phases {
        let phase_time = phase.total_time;
        output.push_str(&format!(
            "> Phase {} [{phase_time:.3}]\n",
            phase.phase_number
        ));

        // Shield changes
        if !phase.shield_changes.is_empty() {
            let shield_sum: f64 = phase.shield_changes.iter().map(|s| s.shield_time).sum();
            let shield_parts: Vec<String> = phase
                .shield_changes
                .iter()
                .map(|s| format!("{:?} {:.3}s", s.status_effect, s.shield_time))
                .collect();

            output.push_str(&format!(
                " Shield change:   {shield_sum:.3}s - {}\n",
                shield_parts.join(" | ")
            ));
        }

        // Leg breaks
        if !phase.leg_breaks.is_empty() {
            let leg_sum: f64 = phase.leg_breaks.iter().map(|l| l.leg_break_time).sum();
            let leg_parts: Vec<String> = phase
                .leg_breaks
                .iter()
                .map(|l| format!("{:.3}s", l.leg_break_time))
                .collect();
            output.push_str(&format!(
                " Leg break:       {leg_sum:.3}s - {}\n",
                leg_parts.join(" | ")
            ));
        }

        // Body killed
        if phase.total_body_kill_time > 0.0 {
            output.push_str(&format!(
                " Body killed:     {:.3}s\n",
                phase.total_body_kill_time
            ));
        }

        // Pylons
        output.push_str(&format!(
            " Pylons:          {:.3}s\n",
            phase.total_pylon_time
        ));

        output.push('\n');
    }

    // Sum of parts
    let sum_shield: f64 = run.total_times.total_shield_time;
    let sum_leg: f64 = run.total_times.total_leg_time;
    let sum_body: f64 = run.total_times.total_body_time;
    let sum_pylon: f64 = run.total_times.total_pylon_time;
    let sum_total = sum_shield + sum_leg + sum_body + sum_pylon;
    let formatted_sum_total = sum_total;

    output.push_str(&format!("> Sum of parts [{formatted_sum_total:.3}]\n"));
    output.push_str(&format!(" Shield change:  {sum_shield:.3}s\n"));
    output.push_str(&format!(" Leg Break:      {sum_leg:.3}s\n"));
    output.push_str(&format!(" Body Killed:    {sum_body:.3}s\n"));
    output.push_str(&format!(" Pylons:         {sum_pylon:.3}s\n"));

    output.push_str("------------------------------------------------------------------------\n");

    output
}
