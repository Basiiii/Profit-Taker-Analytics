mod cli;
use cli::pretty_print_run;

use lib_profit_taker_core::{
    LegBreak, LegPosition, Phase, Run, ShieldChange, SquadMember, StatusEffect,
};
use std::fs::File;
use std::io::{self, BufRead, BufReader, Seek, SeekFrom};
use std::time::Duration;
use std::{env, thread};

#[cfg(target_os = "windows")]
const LOG_PATH: &str = "/Warframe/EE.log";
#[cfg(target_os = "linux")]
const LOG_PATH: &str = "/Warframe/EE.log"; // to be updated with whatever the path is on linux

// Constants
const SHIELD_SWITCH: &str = "SwitchShieldVulnerability";
const SHIELD_PHASE_ENDING: &str = "GiveItem Queuing resource load for Transmission: ";
const SHIELD_PHASE_ENDING_1: &str =
    "Lotus/Sounds/Dialog/FortunaOrbHeist/Business/DBntyFourInterPrTk0920TheBusiness";
const SHIELD_PHASE_ENDING_3: &str =
    "/Lotus/Sounds/Dialog/FortunaOrbHeist/Business/DBntyFourInterPrTk0890TheBusiness";
const SHIELD_PHASE_ENDING_4: &str =
    "/Lotus/Sounds/Dialog/FortunaOrbHeist/Business/DBntyFourSatelReal0930TheBusiness";
const LEG_KILL: &str = "Leg freshly destroyed at part";

const BODY_VULNERABLE: &str = "Camper->StartVulnerable() - The Camper can now be damaged!";
const STATE_CHANGE: &str = "CamperHeistOrbFight.lua: Landscape - New State: ";
const PYLONS_LAUNCHED: &str = "Pylon launch complete";
const PHASE_START: &str = "Orb Fight - Starting";
const PHASE_1_START: &str = "Orb Fight - Starting first attack Orb phase";
const PHASE_ENDS_1: &str = "Orb Fight - Starting second attack Orb phase";
const PHASE_ENDS_2: &str = "Orb Fight - Starting third attack Orb phase";
const PHASE_ENDS_3: &str = "Orb Fight - Starting final attack Orb phase";

const NICKNAME: &str = "Net [Info]: name: ";
const SQUAD_MEMBER: &str = "loadout loader finished.";
const HEIST_START: &str =
    "jobId=/Lotus/Types/Gameplay/Venus/Jobs/Heists/HeistProfitTakerBountyFour";
const HOST_MIGRATION: &str =
    "\"jobId\" : \"/Lotus/Types/Gameplay/Venus/Jobs/Heists/HeistProfitTakerBountyFour";
const HEIST_ABORT: &str = "SetReturnToLobbyLevelArgs: ";
const ELEVATOR_EXIT: &str = "EidolonMP.lua: EIDOLONMP: Avatar left the zone";
const BACK_TO_TOWN: &str = "EidolonMP.lua: EIDOLONMP: TryTownTransition";
const ABORT_MISSION: &str = "GameRulesImpl - changing state from SS_STARTED to SS_ENDING";

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
}

fn parser_loop(path: &str, mut pos: u64, mut run_number: i32) -> io::Result<()> {
    let mut current_run: Option<Run> = None; // current run is an option so that parse_run is only called when a run is found

    // This struct holds all the different temporary variables needed for calculating and sorting the run data
    let mut parser_state = ParserState {
        phase_nr: 0, // phase number, incremented on phase end, reset when a run is saved / new run found TODO: actually implement this
        start_time: 0.0,
        leg_order: 0, // incremented when a leg is broken, reset when a phase ends
        current_phase: Phase::new(0), // current phase, updated throughout the run and saved and reset on phase ending
        body_vuln_time: 0.0,          // time of body kill, reset when a phase ends
        pylon_launch_time: 0.0,       // time of pylon launch, reset when a phase ends
        phase_end_timestamp: 0.0, // time of phase end, used to calculate phase 1-3 time, reset when a phase ends
        kill_sequence: 0,         // 3x BODY_VULNERABLE in one phase means PT dies.
        previous_shield: StatusEffect::NoShield, // previous shield status, used to calculate shield change time, Impact is a placeholder
        previous_time: 0.0,                      // timestamp used to calculate time deltas
        shield_phase_ended: false,               // used to check if a shield phase has ended
        body_kill_time: 0.0,
        run_ended: false,
    };

    /// Main loop, reads the log file line by line, and processes the lines
    /// calls parse_run when a run is found, and updates the current run with the information
    loop {
        let mut file = File::open(path)?;
        file.seek(SeekFrom::Start(pos))?;
        let mut reader = BufReader::new(file);
        let mut line = String::new();


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
                println!("Run #{} found, analysing...", run_number);
                parser_state.run_ended = false;
            }

            // Process line if inside a run
            if let Some(ref mut run) = current_run {
                parse_run(run, run_number, &line, &mut parser_state);
                if parser_state.run_ended {
                    current_run = None;
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
    if line.contains(NICKNAME) && run.player_name.is_empty() {
        run.player_name = line
            .split_whitespace()
            .nth(4)
            .expect("No player name found.")
            .split('\u{e000}')
            .next()
            .expect("No player name found.")
            .to_string();
        println!("Run host: {:?}", run.player_name);
    }
    else if line.contains(SQUAD_MEMBER) {
        let parts: Vec<&str> = line.split_whitespace().collect();
        if let Some(name_part) = parts.get(3) {
            let clean_name = name_part
                .split('\u{e000}')
                .next()
                .unwrap_or_default()
                .to_string();

            if run.squad_members.len() < 3 && clean_name != run.player_name {
                //
                run.squad_members.push(SquadMember::new(clean_name)); //TODO option maybe?
            }
        }
        println!("Squad members: {:?}", run.squad_members);
    }
    // run starts
    else if line.contains(ELEVATOR_EXIT) {
        parser_state.start_time = time_from_line(line);
        println!("Run started at {}", parser_state.start_time);
    }
    // flight time
    else if line.contains(PHASE_1_START) {
        run.total_times.total_flight_time = time_from_line(line) - parser_state.start_time;
        parser_state.current_phase.phase_number = 1;
        parser_state.phase_end_timestamp = time_from_line(line); // this is needed to calculate phase 1 time
        println!(
            "Phase 1 started, flight time: {}",
            run.total_times.total_flight_time,
        );
    }
    // register shields
    else if line.contains(SHIELD_SWITCH) && !parser_state.shield_phase_ended{
        if parser_state.previous_shield != StatusEffect::NoShield {
            // ignore shield changes before run start
            if run.phases.is_empty() && parser_state.current_phase.shield_changes.is_empty() {
                parser_state.previous_time =
                    run.total_times.total_flight_time + parser_state.start_time
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
        }  else {
            parser_state.previous_shield = status_from_line(line); //shield switches on run start, need this info for first shield break
            println!("First shield element: {:?}", parser_state.previous_shield);
            if parser_state.current_phase.phase_number != 3 {
                parser_state.previous_time = time_from_line(line);
            }
        }
    } else if line.contains(SHIELD_SWITCH) && parser_state.current_phase.phase_number == 3 && parser_state.shield_phase_ended {
        //this is needed to calculate shield time in phase 4, when shield changes during pylons
        parser_state.previous_shield = status_from_line(line);
    }
    else if line.contains(SHIELD_PHASE_ENDING)
        && !parser_state.current_phase.shield_changes.is_empty()
        && !parser_state.shield_phase_ended //this line appears twice, messes up the shield phase end detection
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
    // register leg breaks
    else if line.contains(LEG_KILL) {
        let leg = leg_break_from_line(line, parser_state);
        parser_state.current_phase.leg_breaks.push(leg);
        println!(
            "New leg break: {:?}: {:.3}",
            parser_state
                .current_phase
                .leg_breaks
                .last()
                .unwrap()
                .leg_position,
            parser_state
                .current_phase
                .leg_breaks
                .last()
                .unwrap()
                .leg_break_time
        );
    }
    // register body
    else if line.contains(BODY_VULNERABLE) {
        if parser_state.kill_sequence == 0 {
            parser_state.body_vuln_time = time_from_line(line);
            println!("Body vulnerable at {}", time_from_line(line));
        }
        parser_state.kill_sequence += 1; // 3x BODY_VULNERABLE in one phase means PT dies.
    }
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
    }
    //current phase
    else if line.contains(PHASE_START) {
        //TODO check bugged runs
        match line {
            _ if line.contains(PHASE_ENDS_1) => {
                prepare_and_submit_phase(line, run, parser_state);
                parser_state.phase_end_timestamp = time_from_line(line);
            }
            _ if line.contains(PHASE_ENDS_2) => {
                parser_state.shield_phase_ended = false;
                prepare_and_submit_phase(line, run, parser_state);
                parser_state.phase_end_timestamp = time_from_line(line);
            }
            _ if line.contains(PHASE_ENDS_3) => {
                parser_state.shield_phase_ended = false;
                prepare_and_submit_phase(line, run, parser_state);

                parser_state.phase_end_timestamp = time_from_line(line);
            }
            _ => {}
        }
        parser_state.leg_order = 0;
    }

    // Check for abort&end conditions
    if line.contains(ABORT_MISSION) || line.contains(BACK_TO_TOWN) {
        // line.contains(HEIST_START) || TODO: check if this is even necessary, like does that ever happen?
        // TODO check abort behaviour
        println!("{:#?}", run);
        run.is_aborted_run = true;
        println!("Run {} aborted", run_number);
        run.time_stamp = chrono::Local::now().timestamp(); // Update timestamp
        post_process(run);
        parser_state.run_ended = true;
        parser_state.shield_phase_ended = false;
    } else if parser_state.kill_sequence == 3 { // 3x BODY_VULNERABLE in one phase means PT dies.
        parser_state.body_kill_time = time_from_line(line);
        prepare_and_submit_phase(line, run, parser_state);
        println!("Run {} completed", run_number);
        println!("{:#?}", run);
        run.time_stamp = chrono::Utc::now().timestamp(); // Update timestamp to end of run
        pretty_print_run(run);
        post_process(run);
        parser_state.run_ended = true;
        parser_state.shield_phase_ended = false;
    }
    //TODO: implement run post processing (actually filling out the run struct completely)
}

fn prepare_and_submit_phase(line: &str, run: &mut Run, parser_state: &mut ParserState) {
    println!(
        "Phase {} ended at {}",
        parser_state.current_phase.phase_number,
        time_from_line(line)
    );
    parser_state.current_phase.total_time = time_from_line(line) - parser_state.phase_end_timestamp;
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
    parser_state.current_phase.total_leg_time = parser_state //total leg time is the sum of all leg breaks
        .current_phase
        .leg_breaks
        .iter()
        .map(|x| x.leg_break_time)
        .sum();
    parser_state.current_phase.total_body_kill_time =
        parser_state.body_kill_time - parser_state.body_vuln_time;
    parser_state.current_phase.total_pylon_time = if parser_state.pylon_launch_time == 0.0 {
        0.0
    } else {
        time_from_line(line) - parser_state.pylon_launch_time
    };
    // phase number, shield_change and leg_breaks are already set at this point
    let phase_nr = parser_state.current_phase.phase_number;
    //println!("Phase {} submitted: {:#?}",parser_state.current_phase.phase_number, parser_state.current_phase);
    run.phases.push(parser_state.current_phase.clone());
    parser_state.current_phase = Phase::new(phase_nr + 1);
    if parser_state.current_phase.phase_number < 5 {
        println!("Phase {} started", parser_state.current_phase.phase_number);
    }
    parser_state.body_vuln_time = 0.0;
    parser_state.pylon_launch_time = 0.0;
    parser_state.kill_sequence = 0;
    parser_state.previous_time = time_from_line(line);
}
fn time_from_line(line: &str) -> f64 {
    line.split_whitespace()
        .next()
        .unwrap_or_default()
        .parse::<f64>()
        .expect("Time couldn't be extracted from line")
}
fn shield_change_from_line(line: &str, parser_state: &mut ParserState) -> ShieldChange {
    /// takes a line with a shield change, and returns a ShieldChange object, containing the time, status effect and current phase
    /// time is in relation to the previous time
    let time = time_from_line(line) - parser_state.previous_time;
    //println!("previous time: {:?}, line time: {:?}, relative: {:?}", parser_state.previous_time, time_from_line(line), time);
    let shield_change = ShieldChange::new(time, parser_state.previous_shield);
    parser_state.previous_time = time_from_line(line);
    if !line.contains(SHIELD_PHASE_ENDING) {
        parser_state.previous_shield = status_from_line(line);
    }
    shield_change
}
fn status_from_line(line: &str) -> StatusEffect {
    let name: &str = line
        .split_whitespace()
        .last()
        .expect("couldnt read shield element");
    let status = match name {
        "DT_IMPACT" => StatusEffect::Impact,
        "DT_PUNCTURE" => StatusEffect::Puncture,
        "DT_SLASH" => StatusEffect::Slash,
        "DT_FREEZE" => StatusEffect::Cold,
        "DT_FIRE" => StatusEffect::Heat,
        "DT_POISON" => StatusEffect::Toxin,
        "DT_ELECTRICITY" => StatusEffect::Electric,
        "DT_GAS" => StatusEffect::Gas,
        "DT_VIRAL" => StatusEffect::Viral,
        "DT_MAGNETIC" => StatusEffect::Magnetic,
        "DT_RADIATION" => StatusEffect::Radiation,
        "DT_CORROSIVE" => StatusEffect::Corrosive,
        "DT_EXPLOSION" => StatusEffect::Blast,
        _ => panic!("Unknown status effect: {}", name),
    };
    status
}
fn leg_break_from_line(line: &str, parser_state: &mut ParserState) -> LegBreak {
    let time = time_from_line(line) - parser_state.previous_time;
    let name: &str = line.split_whitespace().last().expect("couldnt read leg ");
    let leg = match name {
        "ARM_RIGHT" => LegPosition::FrontLeft,
        "ARM_LEFT" => LegPosition::FrontRight,
        "LEG_RIGHT" => LegPosition::BackLeft,
        "LEG_LEFT" => LegPosition::BackRight,
        _ => panic!("Unknown leg position: {}", name),
    };
    parser_state.previous_time = time_from_line(line);
    parser_state.leg_order += 1;
    LegBreak::new(time, leg, parser_state.leg_order)
}

fn post_process(run: &mut Run) {
    //TODO Process the completed/aborted run, calculate total times, etc.
    run
}



fn main() -> io::Result<()> {
    println!("Initiating");
    let run_number = 0;

    let path = format!(
        "{}{}",
        env::var("LOCALAPPDATA").expect("LOCALAPPDATA not set"),
        LOG_PATH
    );
    let file = File::open(&path).expect("Log file not found"); //TODO: handle file reset
    let mut reader = BufReader::new(file);
    let pos = reader.seek(SeekFrom::Start(0))?; //TODO implement follow log and static log mode

    parser_loop(&path, pos, run_number) //TODO: implement non-follower parser
}
