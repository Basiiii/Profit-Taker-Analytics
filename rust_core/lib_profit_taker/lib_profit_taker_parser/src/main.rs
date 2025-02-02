#![warn(clippy::nursery, clippy::pedantic)]
mod cli;
mod constants;
mod line_utils;

use std::fs::File;
use std::io::{self, BufRead, BufReader, Seek, SeekFrom};
use std::time::Duration;
use std::{env, fs, thread};

use cli::pretty_print_run;
use constants::{ABORT_MISSION, BACK_TO_TOWN, BODY_VULNERABLE, ELEVATOR_EXIT, ENV_PATH, HEIST_START, LEG_KILL, LOG_PATH, NICKNAME, PHASE_1_START, PHASE_ENDS_1, PHASE_ENDS_2, PHASE_ENDS_3, PHASE_START, PYLONS_LAUNCHED, SHIELD_PHASE_ENDING, SHIELD_SWITCH, SQUAD_MEMBER, STATE_CHANGE};
use lib_profit_taker_core::{Phase, Run, StatusEffect};
use line_utils::{handle_names, leg_break_from_line, shield_change_from_line, status_from_line, time_from_line};
use crate::constants::{SHIELD_PHASE_ENDINGS};

// This struct holds all the different temporary variables needed for calculating and sorting the run data
struct ParserState {
    phase_nr: i32,
    start_time: f64,
    leg_order: i32,
    current_phase: Phase,
    body_vuln_time: f64,
    pylon_launch_time: f64,
    phase_end_timestamp: f64,
    kill_sequence: i32,
    previous_shield: StatusEffect,
    previous_time: f64,
    shield_phase_ended: bool,
    body_kill_time: f64,
    run_ended: bool,
    pylon_check: bool, // needed to parse phase 4 in bugged runs
    shield_count: i8, // needed to parse phase 4 in bugged runs
}
impl ParserState {
    const fn new() -> Self {
        Self {
            phase_nr: 0,
            start_time: 0.0,
            leg_order: 0,
            current_phase: Phase::new(0),
            body_vuln_time: 0.0,
            pylon_launch_time: 0.0,
            phase_end_timestamp: 0.0,
            kill_sequence: 0,
            previous_shield: StatusEffect::NoShield,
            previous_time: 0.0,
            shield_phase_ended: false,
            body_kill_time: 0.0,
            run_ended: false,
            pylon_check: false,
            shield_count: 0,
        }
    }
}

fn parser_loop(path: &str, mut pos: u64, mut run_number: i32) -> io::Result<()> {
    let mut current_run: Option<Run> = None; // current run is an option so that parse_run is only called when a run is found
    let mut parser_state = ParserState::new();
    let mut known_size = fs::metadata(path)?.len();

    // Main loop, reads the log file line by line, and processes the lines
    // calls parse_run when a run is found, and updates the current run with the information
    loop {
        let mut file = File::open(path)?;
        file.seek(SeekFrom::Start(pos))?;
        let mut reader = BufReader::new(file);
        let mut line = String::new();

        // Check if the file has been reset
        let new_size = fs::metadata(path)?.len();
        if new_size < known_size {
            println!("Restart detected.");
            pos = 0;
            println!(
                "Successfully reconnected to EE.log. Now listening for new Profit-Taker runs."
            );
        }
        known_size = new_size;

        while reader.read_line(&mut line)? > 0 {
            // this is to handle the case when the line is incomplete
            if !line.ends_with('\n') {
                // Option 1: Simply wait a little and try again.
                thread::sleep(Duration::from_millis(10));
                continue;
            }

            if line.contains(HEIST_START) && current_run.is_none() {
                run_number += 1; //TODO remove this when done because it's just for testing
                let new_run = Run::new(run_number);
                current_run = Some(new_run);
                println!("Run #{run_number} found, analysing...");
                parser_state.run_ended = false;
            }

            // Process line if inside a run
            if let Some(ref mut run) = current_run {
                parse_run(run, run_number, &line, &mut parser_state);
                if parser_state.run_ended {
                    current_run = None;
                    parser_state = ParserState::new(); //TODO: check if this fixes aborted runs
                    println!("Done analysing run #{run_number}");
                }
            }

            pos = reader.seek(SeekFrom::Current(0))?;
            line.clear();
            //TODO: check if run is over
            // save to database, set to none
            // something like: if (run is over) {save_to_db(run); current_run = None;}
        }
        thread::sleep(Duration::from_millis(100));
    }
}

/// Parses a line of the log file, and updates the current run with the information
fn parse_run(run: &mut Run, run_number: i32, line: &str, parser_state: &mut ParserState) {
    //println!("{}", line); //for debug purposes
    if line.contains(NICKNAME) || line.contains(SQUAD_MEMBER) {
        handle_names(line, run);
    }
    // run starts
    else if line.contains(ELEVATOR_EXIT) {
        parser_state.start_time = time_from_line(line);
        println!("Run started at {}", parser_state.start_time);
    }
    // register shield changes
    else if line.contains(SHIELD_SWITCH) || SHIELD_PHASE_ENDINGS.iter().any(|&ending| line.contains(ending))  {
        // handling bugged log
        if parser_state.current_phase.phase_number == 3 
            && parser_state.pylon_check 
            && parser_state.shield_count > 0 {
                run.is_bugged_run = true;
                parser_state.previous_time = time_from_line(line);
                parser_state.shield_phase_ended = false;
                println!("shield count: {}", parser_state.shield_count);
                println!("Bugged run detected, phase 4 started");
                prepare_and_submit_phase(line, run, parser_state);
        } else { 
            parser_state.shield_count += 1;
        }
        register_shield_changes(line, parser_state, run);
    }
    // register leg breaks
    else if line.contains(LEG_KILL) {
        let leg = leg_break_from_line(line, parser_state);
        parser_state.current_phase.leg_breaks.push(leg);
        println!(
            "New leg break: {:?}: {:.3}",
            parser_state.current_phase.leg_breaks.last().unwrap().leg_position,
            parser_state.current_phase.leg_breaks.last().unwrap().leg_break_time
        );
        if parser_state.current_phase.leg_breaks.len() == 4 {
            run.is_bugged_run = true;
        }
        parser_state.shield_count = 0;
    }
    // register body
    else if line.contains(BODY_VULNERABLE) {
        if parser_state.kill_sequence == 0 {
            parser_state.body_vuln_time = time_from_line(line);
            println!("Body vulnerable at {}", time_from_line(line));
        }
        parser_state.kill_sequence += 1; // 3x BODY_VULNERABLE in one phase means PT dies.
    }
    // register body kill
    else if line.contains(STATE_CHANGE) {
        //this is needed to calculate body times in phases 1-3
        let state: i8 = line
            .split_whitespace()
            .nth(8)
            .expect("No state found")
            .parse()
            .expect("State couldn't be extracted from line");
        //println!("State change to {} at {}", state, time_from_line(line));
        if state == 3 || state == 5 || state == 6 {
            parser_state.body_kill_time = time_from_line(line);
            println!("Body killed at {}", parser_state.body_kill_time);
        }
    }
    // register pylon TODO: bugged pylons
    else if line.contains(PYLONS_LAUNCHED) {
        parser_state.pylon_launch_time = time_from_line(line);
        println!("Pylons launched at {}", parser_state.pylon_launch_time);
        if parser_state.current_phase.phase_number == 3 {
            parser_state.pylon_check = true;
        }
    }
    //current phase
    else if line.contains(PHASE_START) {
        //TODO check bugged runs
        match line {
            _ if line.contains(PHASE_1_START) => {
                run.total_times.total_flight_time = time_from_line(line) - parser_state.start_time;
                parser_state.current_phase.phase_number = 1;
                parser_state.phase_end_timestamp = time_from_line(line); // this is needed to calculate phase 1 time
                println!(
                    "Phase 1 started, flight time: {}",
                    run.total_times.total_flight_time,
                );
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
    // Check for abort&end conditions
    if line.contains(ABORT_MISSION) || line.contains(BACK_TO_TOWN) {
        // line.contains(HEIST_START) || TODO: check if this is even necessary, like does that ever happen?
        println!("Run {run_number} aborted");
        run.is_aborted_run = true;
        run_ended(run, parser_state);
    } 
    else if parser_state.kill_sequence == 3 {
        // 3x BODY_VULNERABLE in one phase means PT dies.
        parser_state.body_kill_time = time_from_line(line);
        prepare_and_submit_phase(line, run, parser_state);
        println!("Run {run_number} completed");
        run_ended(run, parser_state);
    }
}

fn register_shield_changes(line: &str, parser_state: &mut ParserState, run: &mut Run) {
    // register shields
    if line.contains(SHIELD_SWITCH) && !parser_state.shield_phase_ended {
        if parser_state.previous_shield != StatusEffect::NoShield {
            // ignore shield changes before run start
            if run.phases.is_empty() && parser_state.current_phase.shield_changes.is_empty() {
                parser_state.previous_time =
                    run.total_times.total_flight_time + parser_state.start_time;
            }
            let shield = shield_change_from_line(line, parser_state);
            parser_state.current_phase.shield_changes.push(shield);
            println!(
                "New shield change: {:?}: {:.3}",
                parser_state
                    .current_phase
                    .shield_changes
                    .last()
                    .unwrap()
                    .status_effect,
                parser_state
                    .current_phase
                    .shield_changes
                    .last()
                    .unwrap()
                    .shield_time
            );
        } else {
            parser_state.previous_shield = status_from_line(line); //shield switches on run start, need this info for first shield break
            println!("First shield element: {:?}", parser_state.previous_shield);
            if parser_state.current_phase.phase_number != 3 {
                parser_state.previous_time = time_from_line(line);
            }
        }
    } else if line.contains(SHIELD_SWITCH)
        && parser_state.current_phase.phase_number == 3
        && parser_state.shield_phase_ended
    {
        //this is needed to calculate shield time in phase 4, when shield changes during pylons
        parser_state.previous_shield = status_from_line(line);
    } else if line.contains(SHIELD_PHASE_ENDING)
        && !parser_state.current_phase.shield_changes.is_empty()
        && !parser_state.shield_phase_ended
    //this line appears twice, messes up the shield phase end detection
    {
        let shield = shield_change_from_line(line, parser_state);
        parser_state.current_phase.shield_changes.push(shield);
        println!(
            "New shield change: {:?}: {:.3}",
            parser_state
                .current_phase
                .shield_changes
                .last()
                .unwrap()
                .status_effect,
            parser_state
                .current_phase
                .shield_changes
                .last()
                .unwrap()
                .shield_time
        );
        println!(
            "shield phase ends at {}, leg phase starting",
            time_from_line(line)
        );
        println!();
        parser_state.shield_phase_ended = true;
        parser_state.previous_shield = StatusEffect::NoShield;
    }
}
fn prepare_and_submit_phase(line: &str, run: &mut Run, parser_state: &mut ParserState) {
    println!(
        "Phase {} ended at {}\n",
        parser_state.current_phase.phase_number,
        time_from_line(line)
    );
    //total phase time
    parser_state.current_phase.total_time = time_from_line(line) - parser_state.phase_end_timestamp;

    //total shield time
    parser_state.current_phase.total_shield_time = // total shield time is the sum of all shield changes
        if parser_state.current_phase.shield_changes.is_empty() {
            0.0
        } else {
            parser_state
                .current_phase
                .shield_changes
                .iter()
                .map(|x| x.shield_time)
                .sum()
        };

    // total leg time
    parser_state.current_phase.total_leg_time = parser_state //total leg time is the sum of all leg breaks
        .current_phase
        .leg_breaks
        .iter()
        .map(|x| x.leg_break_time)
        .sum();

    // total body time
    parser_state.current_phase.total_body_kill_time =
        parser_state.body_kill_time - parser_state.body_vuln_time;

    // total pylon time
    parser_state.current_phase.total_pylon_time = if parser_state.pylon_launch_time == 0.0 {
        0.0
    } else {
        time_from_line(line) - parser_state.pylon_launch_time
    };

    // phase number, shield_change and leg_breaks are already set at this point
    let phase_nr = parser_state.current_phase.phase_number;
    run.phases.push(parser_state.current_phase.clone());
    parser_state.current_phase = Phase::new(phase_nr + 1);
    if parser_state.current_phase.phase_number < 5 {
        println!("Phase {} started", parser_state.current_phase.phase_number);
    }

    //reset phase variables
    parser_state.body_vuln_time = 0.0;
    parser_state.pylon_launch_time = 0.0;
    parser_state.kill_sequence = 0;
    parser_state.previous_time = time_from_line(line);
    parser_state.phase_end_timestamp = time_from_line(line);
}

fn run_ended(run: &mut Run, parser_state: &mut ParserState) {
    run.time_stamp = chrono::Utc::now().timestamp(); // TODO: implement relative timestamp from the log
    post_process(run);
    //println!("{run:#?}");
    parser_state.run_ended = true;
    parser_state.shield_phase_ended = false;
    pretty_print_run(run);
}
fn post_process(run: &mut Run) {
    run.total_times.total_time =
        run.phases.iter().map(|x| x.total_time).sum::<f64>() + run.total_times.total_flight_time;
    run.total_times.total_shield_time = run.phases.iter().map(|x| x.total_shield_time).sum();
    run.total_times.total_leg_time = run.phases.iter().map(|x| x.total_leg_time).sum();
    run.total_times.total_body_time = run.phases.iter().map(|x| x.total_body_kill_time).sum();
    run.total_times.total_pylon_time = run.phases.iter().map(|x| x.total_pylon_time).sum();
    if run.is_bugged_run { 
        run.phases[2].total_pylon_time = 0.0;
    }
}

fn submit_run(run: &mut Run) {
    //TODO: implement run submission to database
    //TODO: implement submitting to app
}

fn main() -> io::Result<()> {
    println!("Initializing Profit-Taker parser...");
    let run_number = 0;

    let path = format!(
        "{}{}",
        env::var(ENV_PATH).expect("cant find path to log in your OS"),
        LOG_PATH
    );
    let file = File::open(&path).expect("Log file not found"); 
    let mut reader = BufReader::new(file);
    let pos = reader.seek(SeekFrom::Start(0))?; 
    println!("Log file found at: {path}");
    println!("Now listening for Profit-Taker runs...");

    parser_loop(&path, pos, run_number) 
}
