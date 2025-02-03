use lib_profit_taker_core::{Phase, Run};
use crate::line_utils::time_from_line;
use crate::parser_state::ParserState;

/// When a phase ends, calculate the total times for the phase, add it to the run and reset phase variables
pub fn prepare_and_submit_phase(line: &str, run: &mut Run, parser_state: &mut ParserState) {
    //println!(
    //    "Phase {} ended at {}\n",
    //    parser_state.current_phase.phase_number,
    //    time_from_line(line)
    //);
    
    //calculate total times for the current phase
    parser_state.current_phase.total_time = time_from_line(line) - parser_state.phase_end_timestamp;
    parser_state.current_phase.total_shield_time = calculate_total_shield_time(parser_state);
    parser_state.current_phase.total_leg_time = calculate_total_leg_time(parser_state);
    parser_state.current_phase.total_body_kill_time =
        parser_state.body_kill_time - parser_state.body_vuln_time;
    parser_state.current_phase.total_pylon_time = calculate_total_pylon_time(line, parser_state);

    // phase number, shield_change and leg_breaks are already set at this point
    
    let phase_nr = parser_state.current_phase.phase_number;
    run.phases.push(parser_state.current_phase.clone());
    parser_state.current_phase = Phase::new(phase_nr + 1);
    //if parser_state.current_phase.phase_number < 5 {
    //    println!("Phase {} started", parser_state.current_phase.phase_number);
    //}

    //reset phase-specific variables
    reset_phase_variables(line, parser_state);
}

/// Calculates the total shield time for the current phase, zero if no shield in phase
fn calculate_total_shield_time (parser_state: &ParserState) -> f64 {
    // total shield time is the sum of all shield changes
    if parser_state.current_phase.shield_changes.is_empty() {
        0.0
    } else {
        parser_state
            .current_phase
            .shield_changes
            .iter()
            .map(|x| x.shield_time)
            .sum()
    }
}

/// Calculates the total leg time for the current phase
fn calculate_total_leg_time(parser_state: &ParserState) -> f64 {
    parser_state //total leg time is the sum of all leg breaks
        .current_phase
        .leg_breaks
        .iter()
        .map(|x| x.leg_break_time)
        .sum()
}

/// Calculates the total pylon time for the current phase, zero if no pylon launch in phase
fn calculate_total_pylon_time(line: &str, parser_state: &ParserState) -> f64 {
    if parser_state.pylon_launch_time == 0.0 {
        0.0
    } else {
        time_from_line(line) - parser_state.pylon_launch_time
    }
}

/// Resets the phase-specific variables to their default values
fn reset_phase_variables(line: &str, parser_state: &mut ParserState) {
    parser_state.body_vuln_time = 0.0;
    parser_state.pylon_launch_time = 0.0;
    parser_state.kill_sequence = 0;
    parser_state.previous_time = time_from_line(line);
    parser_state.phase_end_timestamp = time_from_line(line);
}

/// When a run has ended, calculate the total times and set the ``run_ended`` flag to true, so the parser can start parsing a new run
pub fn run_ended(run: &mut Run, parser_state: &mut ParserState) {
    run.time_stamp = chrono::Utc::now().timestamp(); // TODO: implement relative timestamp from the log
    post_process(run);
    //println!("{run:#?}");
    parser_state.run_ended = true;
    parser_state.shield_phase_ended = false;
    //println!("{}", pretty_print_run(run))
}

/// After all phases have been parsed, calculate the total times for the run,
/// sets total pylons and second pylons to 0 if the run is bugged
fn post_process(run: &mut Run) {
    run.total_times.total_time =
        run.phases.iter().map(|x| x.total_time).sum::<f64>() + run.total_times.total_flight_time;
    run.total_times.total_shield_time = run.phases.iter().map(|x| x.total_shield_time).sum();
    run.total_times.total_leg_time = run.phases.iter().map(|x| x.total_leg_time).sum();
    run.total_times.total_body_time = run.phases.iter().map(|x| x.total_body_kill_time).sum();
    run.total_times.total_pylon_time = if run.is_bugged_run {
        0.0
    } else {
        run.phases.iter().map(|x| x.total_pylon_time).sum()
    };
    if run.is_bugged_run && run.phases.len() >= 3 {
        run.phases[2].total_pylon_time = 0.0;
    }
}
