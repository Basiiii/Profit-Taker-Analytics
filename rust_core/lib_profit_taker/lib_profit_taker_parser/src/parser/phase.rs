//! # Phase Parsing Utilities
//!
//! This module provides functions for managing and processing phases within a run. It includes
//! functionality for preparing phases, computing timings, resetting phase-specific variables, 
//! and processing runs after all phases have been parsed.
//!
//! ## Key Functions
//! - [`prepare_and_submit_phase`]: Handles phase termination and prepares the next one.
//! - [`run_ended`]: Finalizes run data and sets the appropriate parser state.
//! - Helper functions such as:
//!     - [`calculate_total_shield_time`]
//!     - [`calculate_total_leg_time`]
//!     - [`calculate_total_pylon_time`]
//!     - [`reset_phase_variables`]
//! - Post-processing logic to update total run times for debugging or finalization.

use lib_profit_taker_core::{Phase, Run};
use crate::line_utils::time_from_line;
use crate::parser_state::ParserState;

/// # Prepares the current phase for submission and starts a new phase.
///
/// This function handles the termination of the current phase by calculating
/// key metrics such as total time, shield time, leg time, body kill time, and
/// pylon time. After the phase metrics are calculated, the current phase is 
/// cloned and added to the list of phases for the current run. Subsequently, 
/// the parser state is reset and a new phase is initialized.
///
/// # Arguments
///
/// - `line`: A reference to a string slice representing the current log line.
/// - `run`: A mutable reference to the current [`Run`] being parsed. 
///          This is where phases are stored.
/// - `parser_state`: A mutable reference to [`ParserState`] containing information
///                   about the current phase and the parser's state.
///
/// # Behavior
///
/// - Calculates and assigns the time-related metrics for the current phase.
/// - Appends the current phase to the provided `run`.
/// - Resets parser state variables pertaining to the phase.
/// - Initializes a new phase in the parser state.
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

/// Calculates the total shield time for the current phase.
///
/// This function computes the total shield time by summing the shield time values
/// from all shield change events recorded in the current phase.
///
/// If there are no shield change events for the phase, the function returns `0.0`.
///
/// # Arguments
///
/// - `parser_state`: A reference to the [`ParserState`] which contains information 
///   about the current phase, including all shield change events.
///
/// # Returns
///
/// - The total shield time for the current phase as a `f64`.

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

/// Calculates the total leg time for the current phase.
///
/// This function computes the total leg time by summing the leg break times
/// from all leg break events recorded in the current phase.
///
/// If there are no leg break events in the current phase, the function returns `0.0`.
///
/// # Arguments
///
/// - `parser_state`: A reference to the [`ParserState`] which contains information 
///   about the current phase, including all leg break events.
///
/// # Returns
///
/// - The total leg time for the current phase as a `f64`.
fn calculate_total_leg_time(parser_state: &ParserState) -> f64 {
    parser_state //total leg time is the sum of all leg breaks
        .current_phase
        .leg_breaks
        .iter()
        .map(|x| x.leg_break_time)
        .sum()
}

/// Calculates the total pylon time for the current phase.
///
/// This function determines the time spent in the pylon phase of the current phase 
/// by computing the difference between the timestamp of the current log line 
/// and the timestamp of when the pylons were launched.
///
/// If no pylon launch event is recorded for the phase (pylon launch time is zero),
/// the function returns `0.0`.
///
/// # Arguments
///
/// - `line`: A reference to a string slice representing the current log line.
/// - `parser_state`: A reference to the [`ParserState`] that contains information 
///                   about the current phase, including the pylon launch time.
///
/// # Returns
///
/// - The total amount of time spent in the pylon phase as a `f64`. Returns `0.0`
///   if no pylon launch event occurred.
fn calculate_total_pylon_time(line: &str, parser_state: &ParserState) -> f64 {
    if parser_state.pylon_launch_time == 0.0 {
        0.0
    } else {
        time_from_line(line) - parser_state.pylon_launch_time
    }
}

/// Resets the phase-specific variables to their default values.
///
/// This function resets various parser state variables for the current phase,
/// ensuring that the parser starts with a clean slate before parsing the next phase.
///
/// Specifically, it sets the body vulnerability time, pylon launch time, kill sequence,
/// and timestamps to their default values based on the current log line.
///
/// # Arguments
///
/// - `line`: A reference to a string slice representing the current log line.
/// - `parser_state`: A mutable reference to the [`ParserState`] which contains
///   information about the parser's state and variables for the current phase.
fn reset_phase_variables(line: &str, parser_state: &mut ParserState) {
    parser_state.body_vuln_time = 0.0;
    parser_state.pylon_launch_time = 0.0;
    parser_state.kill_sequence = 0;
    parser_state.previous_time = time_from_line(line);
    parser_state.phase_end_timestamp = time_from_line(line);
}

/// Ends the current run by calculating its total times and setting the `run_ended` flag.
///
/// This function performs the following actions:
/// - Updates the run's timestamp with the current UTC time.
/// - Processes the run to compute any remaining metrics or finalize data structures.
/// - Sets the parser state's `run_ended` flag to `true`, allowing the parser to start parsing a new run.
///
/// # Arguments
///
/// - `run`: A mutable reference to the [`Run`] object that stores information about the current run.
/// - `parser_state`: A mutable reference to the [`ParserState`] which tracks the state of the parser.
pub fn run_ended(run: &mut Run, parser_state: &mut ParserState) {
    run.time_stamp = chrono::Utc::now().timestamp(); // TODO: implement relative timestamp from the log
    post_process(run);
    //println!("{run:#?}");
    parser_state.run_ended = true;
    parser_state.shield_phase_ended = false;
    //println!("{}", pretty_print_run(run))
}

/// Performs post-processing on the run after all phases have been parsed.
///
/// This function calculates the total times for the run, including the total
/// shield time, leg time, body time, and pylon time. Additionally, it ensures
/// that if the run is identified as a bugged run, the total pylon times are set
/// to `0.0`. For bugged runs with at least three phases, the total pylon
/// time for the third phase is explicitly set to `0.0`.
///
/// # Arguments
///
/// - `run`: A mutable reference to the [`Run`] object that contains data for
///   the parsed run.
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
