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

/// Parses a line of the log file, and updates the current run with the information
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

/// Registers the start time of the run for consistent timestamps
fn register_start_time(line: &str, parser_state: &mut ParserState, run: &mut Run) {
    let line_time = time_from_line(line);
    parser_state.start_time = line_time;
    //println!("Run started at {}", parser_state.start_time);

    // Set timestamp for when run was started
    run.time_stamp = parser_state.log_start_time + line_time as i64;
}

/// Registers shield changes (and phase change 3->4 if run is bugged) to the current phase
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
        prepare_and_submit_phase(line, run, parser_state);
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

/// Registers leg breaks to the current phase, resets shield count to ensure correct phase detection,
/// and sets the run as bugged if there are more than 4 leg breaks in a phase
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

/// Registers the time of the body kill in phases 1-3 by reading the state change line
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

/// Registers the time of the pylon launch, and sets the pylon check to true to handle bugged runs
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

/// Handles phase changes, and submits the current phase to the run if a phase ends
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
}
