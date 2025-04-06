//! This module is responsible for parsing the run logs and updating the run state accordingly.
//!
//! It contains utilities for:
//! - Handling run start/end conditions
//! - Detecting phase changes and shield transitions
//! - Managing pylon launches and leg breaks
//! - Processing state changes and body vulnerability events
//!
//! The main function, `parse_run`, parses each line of the log and updates the run state.
//! Helper functions within the module manage specific aspects of parsing, such as registering
//! start times, shield changes, and other events.
use crate::constants::{
    ABORT_MISSION, BACK_TO_TOWN, BODY_VULNERABLE, ELEVATOR_EXIT, LEG_KILL, NICKNAME, PHASE_1_START,
    PHASE_ENDS_1, PHASE_ENDS_2, PHASE_ENDS_3, PHASE_START, PYLONS_LAUNCHED, SHIELD_PHASE_ENDING,
    SHIELD_PHASE_ENDINGS, SHIELD_SWITCH, SQUAD_MEMBER, STATE_CHANGE,
};
use crate::line_utils::{
    handle_names, leg_break_from_line, shield_change_from_line, status_from_line, time_from_line,
};
use crate::parser::phase::{prepare_and_submit_phase, run_ended};
use crate::parser_state::ParserState;
use lib_profit_taker_core::{Run, StatusEffect};


/// Parses a run log line and updates the current run state accordingly.
///
/// This function takes a single line from a run log, along with the current run and parser state,
/// and updates the state of the run based on the content of the log.
///
/// It handles various types of events in the log, including:
/// - **Run start events** - Detects and registers the start of a new run.
/// - **Shield changes** - Captures and processes shield transition events.
/// - **Leg breaks** - Tracks leg breaks.
/// - **Phase changes** - Detects and prepares for transitions between fight phases.
/// - **Pylon launches** - Records pylon launches.
/// - **Body vulnerability** - Detects and tracks when the body becomes vulnerable.
/// - **Abort/run end conditions** - Identifies when the run is aborted or completed.
///
/// The function uses helper methods for specific event types and maintains consistency
/// across the `Run` and `ParserState` structures.
///
/// # Arguments
///
/// - `run`: Mutable reference to the current `Run`. Contains the state of the ongoing run.
/// - `line`: The log line to parse, provided as a `&str`.
/// - `parser_state`: Mutable reference to the state of the parser. Manages flags and
///   intermediate states during log parsing.
///
/// # Behavior
///
/// - **Aborted runs**: A run is considered aborted if the log contains the `ABORT_MISSION`
///   or `BACK_TO_TOWN` event strings.
/// - **Run completions**: A run is considered completed if three `BODY_VULNERABLE` events occur
///   during a single phase.
/// - **Handling bugs**: Handles specific cases where logs may be bugged, such as missing events
///   or corrupted phases.
pub(crate) fn parse_run(
    run: &mut Run,
    line: &str,
    parser_state: &mut ParserState,
) {
    //println!("{}", line); //printing all log lines for debugging
    if line.contains(NICKNAME) || line.contains(SQUAD_MEMBER) {
        handle_names(line, run);
    }
    // run starts
    else if line.contains(ELEVATOR_EXIT) {
        register_start_time(line, parser_state, run);
    }
    // register shield changes
    else if line.contains(SHIELD_SWITCH)
        || SHIELD_PHASE_ENDINGS
            .iter()
            .any(|&ending| line.contains(ending))
    {
        register_shield_changes(line, parser_state, run);
    }
    // register leg breaks
    else if line.contains(LEG_KILL) {
        register_leg_breaks(line, parser_state, run);
    }
    // register body
    else if line.contains(BODY_VULNERABLE) {
        // only the first BODY_VULNERABLE is relevant for determining the body kill time
        if parser_state.kill_sequence == 0 {
            parser_state.body_vuln_time = time_from_line(line);
            //println!("Body vulnerable at {}", time_from_line(line));
        }

        // 3x BODY_VULNERABLE in one phase means PT dies and run is over
        parser_state.kill_sequence += 1;
    }
    // register body kill
    else if line.contains(STATE_CHANGE) {
        register_state_change(line, parser_state);
    }
    // register pylon launch
    else if line.contains(PYLONS_LAUNCHED) {
        register_pylon_launch(line, parser_state);
    }
    // register phase changes
    else if line.contains(PHASE_START) {
        handle_phase_changes(line, run, parser_state);
    }
    // Check for abort&end conditions
    if line.contains(ABORT_MISSION) || line.contains(BACK_TO_TOWN) {
        // line.contains(HEIST_START) || TODO: check if this is even necessary, like does that ever happen?
        //println!("Run {run_number} aborted");
        run.is_aborted_run = true;
        run_ended(run, parser_state);
    } else if parser_state.kill_sequence == 3 {
        // 3x BODY_VULNERABLE in one phase means PT dies and the run is over
        parser_state.body_kill_time = time_from_line(line);
        prepare_and_submit_phase(line, run, parser_state);
        //println!("Run {run_number} completed");
        run_ended(run, parser_state);
    }
}

/// Registers the start time of the run for consistent timestamps.
///
/// # Arguments
///
/// - `line`: A reference to the log line containing the timestamp information.
/// - `parser_state`: A mutable reference to the current `ParserState`, which tracks the state of the parser.
/// - `run`: A mutable reference to the current `Run`, which contains the state of the ongoing run.
///
/// # Behavior
///
/// - Extracts the timestamp from the log line using the `time_from_line` function.
/// - Updates the parser state with the start time of the run.
/// - Computes the run's `time_stamp` by adding the parsed log start time to the timestamp.
fn register_start_time(line: &str, parser_state: &mut ParserState, run: &mut Run) {
    let line_time = time_from_line(line);
    parser_state.start_time = line_time;
    //println!("Run started at {}", parser_state.start_time);

    // Set timestamp for when run was started
    run.time_stamp = parser_state.log_start_time + line_time as i64;
}

/// Handles shield changes and also detects if a run is considered "bugged" during phase 4.
///
/// # Arguments
///
/// - `line`: A reference to the log line containing information about a shield change.
/// - `parser_state`: A mutable reference to the current `ParserState`, which tracks the state of the parser
///   and helps determine the flow of the run.
/// - `run`: A mutable reference to the current `Run`, which contains all relevant information about the ongoing run.
///
/// # Behavior
///
/// - Detects if the run is "bugged" by checking conditions in phase 3 involving shield changes
///   and performs appropriate adjustments.
/// - Registers new shield changes within the current phase and updates the parser state.
/// - Determines the initial shield state at the start of a run or phase.
/// - Handles edge cases for shields switched during pylons.
/// - Identifies the end of a shield phase by marking the appropriate flags and storing data.
fn register_shield_changes(line: &str, parser_state: &mut ParserState, run: &mut Run) {
    // handling bugged log
    // if the run is bugged, the shield count is used to determine if phase 4 has started
    // shield usually changes once during pylons, so if there are more shield changes, it's phase 4
    if parser_state.current_phase.phase_number == 3
        && parser_state.pylon_check
        && parser_state.shield_count > 0
    //TODO: 25s timer maybe?
    {
        run.is_bugged_run = true;
        parser_state.previous_time = time_from_line(line);
        parser_state.shield_phase_ended = false;
        //println!("shield count: {}", parser_state.shield_count);
        //println!("Bugged run detected, phase 4 started");
        //prepare_and_submit_phase(line, run, parser_state);
    } else {
        parser_state.shield_count += 1;
    }

    // register shields
    if line.contains(SHIELD_SWITCH) && !parser_state.shield_phase_ended {
        // ignore shield changes before run start
        if parser_state.previous_shield == StatusEffect::NoShield {
            //shield switches on run start, need this info for first shield break
            parser_state.previous_shield = status_from_line(line);
            //println!("First shield element: {:?}", parser_state.previous_shield);
            if parser_state.current_phase.phase_number != 3 {
                //TODO: what even does this do lmao i forgor :skull: will have to double check
                parser_state.previous_time = time_from_line(line);
            }
        } else {
            // set end of flight time as reference for first shield of first phase
            if run.phases.is_empty() && parser_state.current_phase.shield_changes.is_empty() {
                parser_state.previous_time =
                    run.total_times.total_flight_time + parser_state.start_time;
            }
            let shield = shield_change_from_line(line, parser_state);
            parser_state.current_phase.shield_changes.push(shield);

            // debug prints
            //println!(
            //    "New shield change: {:?}: {:.3}",
            //    parser_state
            //        .current_phase
            //        .shield_changes
            //        .last()
            //        .unwrap()
            //        .status_effect,
            //    parser_state
            //        .current_phase
            //        .shield_changes
            //        .last()
            //        .unwrap()
            //        .shield_time
            //);
        }
    // when shield changes during pylons we register the element for the next shield break after pylons
    } else if line.contains(SHIELD_SWITCH)
        && parser_state.current_phase.phase_number == 3
        && parser_state.shield_phase_ended
    {
        parser_state.previous_shield = status_from_line(line);
    }
    // detect end of shield phase. Line appears twice,
    // first time set reference shield element to `NoShield` for next phase,
    // set shield phase ended to true, second time we ignore it
    else if line.contains(SHIELD_PHASE_ENDING)
        && !parser_state.current_phase.shield_changes.is_empty()
        && !parser_state.shield_phase_ended
    {
        let shield = shield_change_from_line(line, parser_state);
        parser_state.current_phase.shield_changes.push(shield);
        parser_state.shield_phase_ended = true;
        parser_state.previous_shield = StatusEffect::NoShield;

        // debug prints
        //println!(
        //    "New shield change: {:?}: {:.3}",
        //    parser_state
        //        .current_phase
        //        .shield_changes
        //        .last()
        //        .unwrap()
        //        .status_effect,
        //    parser_state
        //        .current_phase
        //        .shield_changes
        //        .last()
        //        .unwrap()
        //        .shield_time
        //);
        //println!(
        //    "shield phase ends at {}, leg phase starting",
        //    time_from_line(line)
        //);
        //println!();
    }
}


/// Registers leg breaks to the current phase.
///
/// This function tracks leg breaks that occur during a run and performs the following:
/// 1. Adds the detected leg break to the current phase's list of leg breaks.
/// 2. Checks if the number of leg breaks in the current phase exceeds 4.
///    - If this happens, it flags the run as bugged (indicating a possible phase reset).
/// 3. Resets the `shield_count` to ensure proper phase detection later on.
///
/// # Parameters
/// - `line`: A string slice representing the current line being processed.
/// - `parser_state`: A mutable reference to the `ParserState`, where the current state of parsing is stored.
/// - `run`: A mutable reference to the `Run`, representing the overall run being analyzed.
fn register_leg_breaks(line: &str, parser_state: &mut ParserState, run: &mut Run) {
    let leg = leg_break_from_line(line, parser_state);
    parser_state.current_phase.leg_breaks.push(leg);

    // if there are more than 4 leg breaks in a phase, the run is bugged
    // (a phase reset has occurred, most likely)
    if parser_state.current_phase.leg_breaks.len() > 4 {
        run.is_bugged_run = true;
    }

    parser_state.shield_count = 0;

    // for debugging
    //println!(
    //    "New leg break: {:?}: {:.3}",
    //    parser_state
    //        .current_phase
    //        .leg_breaks
    //        .last()
    //        .unwrap()
    //        .leg_position,
    //    parser_state
    //        .current_phase
    //        .leg_breaks
    //        .last()
    //        .unwrap()
    //        .leg_break_time
    //);
}

/// Registers the time of the body kill in phases 1-3 by parsing the relevant state change from the log line.
///
/// This function keeps track of specific state changes during the Profit-Taker fight.
/// 
/// # Parameters
///
/// - `line`: A string slice representing the current log line being processed.
/// - `parser_state`: A mutable reference to the `ParserState` struct, which tracks the progress and
///   parsed data of the run.
///
/// # Panics
///
/// This function expects the log line to contain at least 9 whitespace-separated fields,
/// where the state change value is at the 8th index (zero-based). If this is not the case,
/// or if the state value cannot be parsed to an `i8`, the function will panic.
fn register_state_change(line: &str, parser_state: &mut ParserState) {
    let state: i8 = line
        .split_whitespace()
        .nth(8)
        .expect("No state found")
        .parse()
        .expect("State couldn't be extracted from line");
    //println!("State change to {} at {}", state, time_from_line(line)); //for debugging
    if state == 3 || state == 5 || state == 6 {
        parser_state.body_kill_time = time_from_line(line);
        //println!("Body killed at {}", parser_state.body_kill_time);
    }
}


/// Registers the time of the pylon launch in the Profit-Taker fight and sets the pylon check flag to handle specific scenarios in bugged runs.
///
/// This function is responsible for handling pylon-related events that occur during the fight.
/// When pylons are launched:
/// 1. It logs the time of the launch by parsing the provided `line`.
/// 2. If the current phase is phase 3, it sets the `pylon_check` flag in `parser_state` to handle cases where phase 4 is not properly detected.
///
/// # Parameters
/// - `line`: A string slice containing the log line to process. This log line is expected to represent the pylon launch.
/// - `parser_state`: A mutable reference to the `ParserState`, which tracks the state and progress of the parsing process.
fn register_pylon_launch(line: &str, parser_state: &mut ParserState) {
    parser_state.pylon_launch_time = time_from_line(line);
    //println!("Pylons launched at {}", parser_state.pylon_launch_time);

    // for bugged runs that are missing the phase 4 start
    // see shield change function: if there is more than 1 shield change during pylons,
    // phase 4 has started and run is bugged
    if parser_state.current_phase.phase_number == 3 {
        parser_state.pylon_check = true;
    }
}

/// Handles the transition between different phases of the Profit-Taker fight by monitoring log lines.
///
/// This function serves the following purposes:
/// 1. Detects Phase 1 start and calculates total flight time.
/// 2. Detects the end of any phase and processes the current phase, submitting its information to the run.
/// 3. Resets specific flags and counters relevant to tracking states between phases.
///
/// # Parameters
/// - `line`: A string slice containing the current log line to be analyzed.
/// - `run`: A mutable reference to the `Run` struct, which stores all parsed data for the current run.
/// - `parser_state`: A mutable reference to the `ParserState` struct, which tracks the progress and state of the fight parsing.
///
/// # Behavior
/// Depending on the content of the `line`, the following actions occur:
/// - When the line indicates Phase 1 has started:
///   - Sets the current phase to Phase 1.
///   - Calculates and stores the total flight time by subtracting the start time from the current timestamp.
///   - Updates the phase end timestamp for Phase 1 time calculation.
/// - When the line indicates the end of a phase (e.g., 1, 2, or 3):
///   - Prepares and submits the current phase data through `prepare_and_submit_phase`.
///   - Resets the `shield_phase_ended` or `pylon_check` flags depending on the phase.
/// - Clears the `leg_order` counter at the end to ensure a fresh start for subsequent phases.
fn handle_phase_changes(line: &str, run: &mut Run, parser_state: &mut ParserState) {
    match line {
        _ if line.contains(PHASE_1_START) => {
            run.total_times.total_flight_time = time_from_line(line) - parser_state.start_time;
            parser_state.current_phase.phase_number = 1;
            parser_state.phase_end_timestamp = time_from_line(line); // this is needed to calculate phase 1 time
            //println!(
            //    "Phase 1 started, flight time: {}",
            //    run.total_times.total_flight_time,
            //);
        }
        _ if line.contains(PHASE_ENDS_1) => {
            prepare_and_submit_phase(line, run, parser_state);
        }
        _ if line.contains(PHASE_ENDS_2) => {
            parser_state.shield_phase_ended = false;
            prepare_and_submit_phase(line, run, parser_state);
        }
        _ if line.contains(PHASE_ENDS_3) => {
            parser_state.pylon_check = false;
            parser_state.shield_phase_ended = false;
            prepare_and_submit_phase(line, run, parser_state);
        }
        _ => {}
    }
    parser_state.leg_order = 0;
    parser_state.shield_order = 0;
}
