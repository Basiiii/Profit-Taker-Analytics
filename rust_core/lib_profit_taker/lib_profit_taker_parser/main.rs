use std::{env, thread};
use std::collections::{HashMap, HashSet};
use chrono;
use flutter_rust_bridge;
use diesel;
use std::fs::File;
use std::io::{self, BufRead, Read, Seek, SeekFrom, BufReader, Lines};
use std::time::Duration;
use chrono::format::parse;

#[cfg(target_os = "windows")]
const LOG_PATH: &str = "/Warframe/EE.log";
#[cfg(target_os = "linux")]
const LOG_PATH: &str = "/Warframe/EE.log"; // to be updated with whatever the path is on linux

// Constants
const SHIELD_SWITCH: &str = "SwitchShieldVulnerability";
const SHIELD_PHASE_ENDING :&str = "GiveItem Queuing resource load for Transmission: ";
const SHIELD_PHASE_ENDING_1 :&str = "Lotus/Sounds/Dialog/FortunaOrbHeist/Business/DBntyFourInterPrTk0920TheBusiness";
const SHIELD_PHASE_ENDING_3 :&str = "/Lotus/Sounds/Dialog/FortunaOrbHeist/Business/DBntyFourInterPrTk0890TheBusiness";
const SHIELD_PHASE_ENDING_4 :&str = "/Lotus/Sounds/Dialog/FortunaOrbHeist/Business/DBntyFourSatelReal0930TheBusiness";
const LEG_KILL :&str = "Leg freshly destroyed at part";

const BODY_VULNERABLE :&str = "Camper->StartVulnerable() - The Camper can now be damaged!";
const STATE_CHANGE :&str = "CamperHeistOrbFight.lua: Landscape - New State: ";
const PYLONS_LAUNCHED :&str = "Pylon launch complete";
const PHASE_START :&str = "Orb Fight - Starting";
const PHASE_1_START :&str = "Orb Fight - Starting first attack Orb phase";
const PHASE_ENDS_1 :&str = "Orb Fight - Starting second attack Orb phase";
const PHASE_ENDS_2 :&str = "Orb Fight - Starting third attack Orb phase";
const PHASE_ENDS_3 :&str = "Orb Fight - Starting final attack Orb phase";
const PHASE_ENDS_4 :&str = "";
const FINAL_PHASE :i8 = 4;

const NICKNAME :&str = "Net [Info]: name: ";
const SQUAD_MEMBER :&str = "loadout loader finished.";
const HEIST_START :&str = "jobId=/Lotus/Types/Gameplay/Venus/Jobs/Heists/HeistProfitTakerBountyFour";
const HOST_MIGRATION :&str = "\"jobId\" : \"/Lotus/Types/Gameplay/Venus/Jobs/Heists/HeistProfitTakerBountyFour";
const HEIST_ABORT :&str = "SetReturnToLobbyLevelArgs: ";
const ELEVATOR_EXIT :&str = "EidolonMP.lua: EIDOLONMP: Avatar left the zone";
const BACK_TO_TOWN :&str = "EidolonMP.lua: EIDOLONMP: TryTownTransition";
const ABORT_MISSION :&str = "GameRulesImpl - changing state from SS_STARTED to SS_ENDING";

enum Placeholder {}

#[derive(Debug, Clone)]
struct Run {
    id: i32,
    time_stamp: chrono::DateTime<chrono::Utc>,
    run_name: String,
    player_name: String,
    is_bugged_run: bool,
    is_aborted_run: bool,
    is_solo_run: bool,
    total_times: TotalTimes,
    phases: Vec<Phase>,
    squad_members: Vec<Option<SquadMember>>, // TODO: check if this works and if the option is needed
}
impl Run {
    fn new(id: i32) -> Run {
        Run {
            id,
            time_stamp: chrono::Utc::now(), //TODO: Implement timestamp
            run_name: String::new(),
            player_name: String::new(),
            is_bugged_run: false,
            is_aborted_run: false,
            is_solo_run: true,
            total_times: TotalTimes::new(),
            phases: Vec::new(),
            squad_members: Vec::new(),
        }
    }
}

#[derive(Debug, Clone)]
struct TotalTimes {
    total_time: f64,
    total_flight: f64,
    total_shield: f64,
    total_leg: f64,
    total_body: f64,
    total_pylon: f64,
}
impl TotalTimes {
    fn new() -> TotalTimes {
        TotalTimes {
            total_time: 0.0,
            total_flight: 0.0,
            total_shield: 0.0,
            total_leg: 0.0,
            total_body: 0.0,
            total_pylon: 0.0,
        }
    }
}

#[derive(Debug, Clone)]
struct SquadMember {
    player_name: String,
}
impl SquadMember {
    fn new(player_name: String) -> SquadMember {
        SquadMember {
            player_name,
        }
    }
}

#[derive(Debug, Clone)]
struct Phase {
    phase_number: i32,
    total_time: f64,
    total_shield: Option<f64>,
    total_leg: f64,
    total_body_kill: f64,
    total_pylon: Option<f64>,
    shield_change: Vec<Option<ShieldChange>>,
    leg_breaks: Vec<LegBreak>,
}
impl Phase {
    fn new(number: i8) -> Phase {
        Phase {
            phase_number,
            total_time: 0.0,
            total_shield: 0.0,
            total_leg: 0.0,
            total_body_kill: 0.0,
            total_pylon: 0.0,
            shield_change: Vec::new(),
            leg_breaks: Vec::new(),
        }
    }
}

#[derive(Debug, Clone)]
struct ShieldChange {
    time: f64,
    effect: StatusEffect,
    phase: i8,
}
impl ShieldChange {
    fn new(time: f64, effect: StatusEffect, phase: i8) -> ShieldChange {
        ShieldChange {
            time,
            effect,
            phase,
        }
    }
}

#[derive(Debug, Clone)]
struct LegBreak {
    phase: i8,
    position: LegPosition,
    time: f64,
    order: i8,
}
impl LegBreak {
    fn new(time: f64, position: LegPosition, phase: i8, order: i8) -> LegBreak {
        LegBreak {
            phase,
            position,
            time,
            order,
        }
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
enum LegPosition {
    FrontLeft,
    FrontRight,
    BackLeft,
    BackRight,
}

//#[derive(Debug, Clone)]
//struct PylonBreak {
//    phase: i8,
//    time: f64,
//}
//
//#[derive(Debug, Clone)]
//struct BodyDamage {
//    phase: i8,
//    time: f64,
//}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
enum StatusEffect {
    Impact,
    Puncture,
    Slash,
    Cold,
    Heat,
    Toxin,
    Electricity,
    Gas,
    Viral,
    Magnetic,
    Radiation,
    Corrosive,
    Blast,
}

fn parser_loop(path: &str, mut pos: u64, mut run_number:i32) -> io::Result<()> {
    let mut current_run: Option<Run> = None; // current run is an option so that parse_run is only called when a run is found
    let mut phase_nr :i8 = 0; // phase number, incremented on phase end, reset when a run is saved / new run found TODO: actually implement this
    let mut start_time :f64 = 0.0;
    let mut leg_order :i8 = 0; // incremented when a leg is broken, reset when a phase ends
    let mut bodies :i8 = 0; // incremented on body kill, reset when a run ends TODO: implement resetting

    loop {
        let mut file = File::open(path)?;
        file.seek(SeekFrom::Start(pos))?;
        let mut reader = BufReader::new(file);
        let mut line = String::new();

        while reader.read_line(&mut line)? > 0 {
            /// Main loop, reads the log file line by line, and processes the lines
            /// calls parse_run when a run is found, and updates the current run with the information

            if line.contains(HEIST_START) && current_run.is_none() {
                run_number += 1; //TODO remove this when done because it's just for testing
                let new_run = Run::new(run_number);
                current_run = Some(new_run);
                println!("Run #{} found, analysing...", run_number);
            }

            // Process line if inside a run
            if let Some(ref mut run) = current_run {
                parse_run(run, run_number, &line, phase_nr, start_time, leg_order, bodies);
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

fn parse_run(mut run: &mut Run, run_number: i32, line: &str, mut phase_nr: i8, mut start_time: f64, mut leg_order: i8, mut bodies: i8) {
    /// Parses a line of the log file, and updates the current run with the information
    /// absolute times so far, TODO: implement relative times

    if line.contains(NICKNAME) && run.player_name.is_empty() {
        run.player_name = line.split_whitespace().nth(2).unwrap_or_default().to_string();
        println!("Run host: {:?}", run.player_name);
    }
    if line.contains(SQUAD_MEMBER) { //TODO: check if this works
        let parts: Vec<&str> = line.splitn(4, ' ').collect(); //TODO: i dont think this is correct actually, check
        if parts.len() > 3 {
            let member = parts[3].split_whitespace().next().unwrap_or_default().to_string();
            if run.squad_members.len() < 3 { //
                run.squad_members.push(Some(SquadMember::new(member)));
            }
        }
        println!("Squad members: {:?}", run.squad_members);
    }

    // run starts
    if line.contains(ELEVATOR_EXIT) {
        start_time = time_from_line(line);
        println!("Run started at {}", start_time);
    }

    // flight time
    if line.contains(PHASE_1_START) {
        phase_nr = 1;
        run.total_times.total_flight = time_from_line(line) - start_time;
        println!("Phase 1 started, flight time: {}", run.total_times.total_flight);
    }

    //current phase
    if line.contains(PHASE_START) { //TODO check bugged runs
        match line {
            _ if line.contains(PHASE_ENDS_1) => {
                let time = time_from_line(line) - start_time;
                let shield_time = Some(run.shield_changes.iter().filter(|&x| x.phase == 1).map(|x| x.time).sum());
                let leg_time = run.leg_breaks.iter().filter(|&x| x.phase == 1).map(|x| x.time).sum();
                let body_time = 0.0; //TODO: implement body time
                let pylon_time = Some(0.0); //TODO: implement pylon time
                let current_phase = Phase::new(phase_nr, time, shield_time, leg_time, body_time, pylon_time);
                run.phases.insert(phase_nr, current_phase);
                phase_nr = 2;
            },
            _ if line.contains(PHASE_ENDS_2) => phase_nr = 3, //TODO: implement phase 2 construction
            _ if line.contains(PHASE_ENDS_3) => phase_nr = 4, //TODO: implement phase 3 construction
            _ => {},
        }
        leg_order = 0;
    }
    // register shields
    if line.contains(SHIELD_SWITCH) {
        run.phases[phase_nr as usize].shield_change.push(shield_change_from_line(line, phase_nr));
        println!("Shield change registered: {:?}", run.phases[phase_nr as usize].shield_change);
    }
    // register leg breaks
    if line.contains(LEG_KILL) {
        run.phases[phase_nr as usize].leg_breaks.push(leg_break_from_line(line, phase_nr, leg_order));
        println!("Leg break registered: {:?}", run.phases[phase_nr as usize].leg_breaks);
    }
    // register body
    if line.contains(BODY_VULNERABLE) {
        let time = time_from_line(line);
        bodies += 1;
        if bodies == 4 { // 4 body kills means all phases are done = pt killed
            //TODO final phase construction
        }
    }
    // register pylon TODO: bugged pylons
    if line.contains(PYLONS_LAUNCHED) {
        let time = time_from_line(line);
    }

    // TODO: Finish event checks (pylon, body, etc)

    // Check for abort&end conditions
    if line.contains(HEIST_START) || line.contains(ABORT_MISSION) || line.contains(BACK_TO_TOWN) {
        run.aborted_run = true;
        println!("Run {} aborted", run_number);
        run.time_stamp = chrono::Utc::now(); // Update timestamp
        post_process(run);
    } else if bodies == 4 {
        run.aborted_run = false;
        println!("Run {} completed", run_number);
        run.time_stamp = chrono::Utc::now(); // Update timestamp
        post_process(run);
    }

}

fn time_from_line(line: &str) -> f64 {
    line.split_whitespace().next().unwrap_or_default().parse::<f64>().expect("Time couldn't be extracted from line")
}
fn shield_change_from_line(line: &str, phase: i8) -> ShieldChange {
    /// takes a line with a shield change, and returns a ShieldChange object, containing the time, status effect and current phase
    let time = time_from_line(line);
    let name :&str = line.split_whitespace().last().unwrap_or_default().parse().unwrap_or_default();
    let status = match name {
        "DT_IMPACT" => StatusEffect::Impact,
        "DT_PUNCTURE" => StatusEffect::Puncture,
        "DT_SLASH" => StatusEffect::Slash,
        "DT_FREEZE" => StatusEffect::Cold,
        "DT_FIRE" => StatusEffect::Heat,
        "DT_POISON" => StatusEffect::Toxin,
        "DT_ELECTRICITY" => StatusEffect::Electricity,
        "DT_GAS" => StatusEffect::Gas,
        "DT_VIRAL" => StatusEffect::Viral,
        "DT_MAGNETIC" => StatusEffect::Magnetic,
        "DT_RADIATION" => StatusEffect::Radiation,
        "DT_CORROSIVE" => StatusEffect::Corrosive,
        "DT_EXPLOSION" => StatusEffect::Blast,
        _ => panic!("Unknown status effect: {}", name),
    };
    ShieldChange::new(time, status, phase)
}
fn leg_break_from_line (line :&str, phase: i8, mut leg_order: i8) -> LegBreak {
    let time = time_from_line(line);
    let name :&str = line.split_whitespace().last().unwrap_or_default().parse().unwrap_or_default();
    let leg = match name {
        "ARM_RIGHT" => LegPosition::FrontLeft,
        "ARM_LEFT" => LegPosition::FrontRight,
        "LEG_RIGHT" => LegPosition::BackLeft,
        "LEG_LEFT" => LegPosition::BackRight,
        _ => panic!("Unknown leg position: {}", name),
    };
    leg_order += 1;
    LegBreak::new(time, leg, phase, leg_order)
}

fn post_process(run: &mut Run) {
    //TODO Process the completed/aborted run
    println!("Post-processed Run {}: Nickname: {:?}, Squad: {:?}",
             run.id, run.player_name, run.squad_members);
}

fn main() -> io::Result<()> {
    println!("Initiating");
    let mut run_number = 0;

    let path = format!("{}{}", env::var("LOCALAPPDATA").expect("LOCALAPPDATA not set"), LOG_PATH);
    let file = File::open(&path).expect("Log file not found");
    let mut reader = io::BufReader::new(file);
    let pos = reader.seek(SeekFrom::Start(0))?; //TODO change to End later

    parser_loop(&path, pos, run_number) //TODO: implement non-follower parser
}
