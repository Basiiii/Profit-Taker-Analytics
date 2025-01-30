use chrono;
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
    fn new(phase_number: i32) -> Phase {
        Phase {
            phase_number,
            total_time: 0.0,
            total_shield: Some(0.0),
            total_leg: 0.0,
            total_body_kill: 0.0,
            total_pylon: Some(0.0),
            shield_change: Vec::new(),
            leg_breaks: Vec::new(),
        }
    }
}

#[derive(Debug, Clone)]
struct ShieldChange {
    time: f64,
    effect: StatusEffect,
}
impl ShieldChange {
    fn new(time: f64, effect: StatusEffect) -> ShieldChange {
        ShieldChange {
            time,
            effect,
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
    NoShield,
}

struct ParserState {
    phase_nr: i8,
    start_time: f64,
    leg_order: i8,
    current_phase: Phase,
    body_vuln_time: f64,
    pylon_launch_time: f64,
    phase_end_timestamp: f64,
    kill_sequence: i8,
    previous_shield: StatusEffect,
    previous_time: f64,
}

fn parser_loop(path: &str, mut pos: u64, mut run_number:i32) -> io::Result<()> {
    let mut current_run: Option<Run> = None; // current run is an option so that parse_run is only called when a run is found

    let mut parser_state = ParserState {
        phase_nr: 0, // phase number, incremented on phase end, reset when a run is saved / new run found TODO: actually implement this
        start_time: 0.0,
        leg_order: 0, // incremented when a leg is broken, reset when a phase ends
        current_phase: Phase::new(0), // current phase, updated throughout the run and saved and reset on phase ending
        body_vuln_time: 0.0, // time of body kill, reset when a phase ends
        pylon_launch_time: 0.0, // time of pylon launch, reset when a phase ends
        phase_end_timestamp: 0.0, // time of phase end, used to calculate phase 1-3 time, reset when a phase ends
        kill_sequence: 0, // 3x BODY_VULNERABLE in one phase means PT dies.
        previous_shield: StatusEffect::NoShield,
        previous_time: 0.0, // timestamp used to calculate time deltas
    };

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
                parse_run(run, run_number, &line, &mut parser_state);
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

fn parse_run(run: &mut Run, run_number: i32, line: &str, mut parser_state: &mut ParserState, ) {
//(mut run: &mut Run, run_number: i32, line: &str, phase_nr: i8, mut start_time: f64, mut leg_order: i8, mut bodies: i8, mut current_phase: &mut Phase, mut body_vuln_time: f64, mut pylon_launch_time: f64, mut phase_end_timestamp: f64) {
    /// Parses a line of the log file, and updates the current run with the information
    /// absolute times so far, TODO: implement relative times

    if line.contains(NICKNAME) && run.player_name.is_empty() { 
        run.player_name = line.split_whitespace()
            .nth(4)
            .expect("No player name found.")
            .to_string()
            .split('\u{e000}')
            .next()
            .unwrap_or_default()
            .to_string();
        println!("Run host: {:?}", run.player_name);
    }
    if line.contains(SQUAD_MEMBER) { 
        let parts: Vec<&str> = line.split_whitespace().collect();
        if let Some(name_part) = parts.get(3) {
            let clean_name = name_part
                .split('\u{e000}')
                .next()
                .unwrap_or_default()
                .to_string();

            if run.squad_members.len() < 3 && clean_name != run.player_name { //
                run.squad_members.push(Some(SquadMember::new(clean_name)));
            }
        }
        println!("Squad members: {:?}", run.squad_members);
    }

    // run starts
    if line.contains(ELEVATOR_EXIT) {
        parser_state.start_time = time_from_line(line);
        println!("Run started at {}", parser_state.start_time);
    }

    // flight time
    if line.contains(PHASE_1_START) {
        run.total_times.total_flight = time_from_line(line) - parser_state.start_time;
        parser_state.current_phase.phase_number = 1;
        println!("Phase 1 started, flight time: {}", run.total_times.total_flight);
    }

    // register shields
    if line.contains(SHIELD_SWITCH) {
        if run.total_times.total_flight >= 0.1 { // ignore shield changes before run start
            if run.phases.is_empty() && parser_state.current_phase.shield_change.is_empty() {
                parser_state.previous_time = run.total_times.total_flight + parser_state.start_time
            }
            println!("previous time: {}", parser_state.previous_time);
            let shield = Some(shield_change_from_line(line, parser_state));
            parser_state.current_phase.shield_change.push(shield);
            println!("current phase shield changes: {:#?}", parser_state.current_phase.shield_change);
            println!("Shield change registered: {:?}", parser_state.current_phase.shield_change.last());
        } else {
            parser_state.previous_shield = status_from_line(line);
        }
    }
    if line.contains(SHIELD_PHASE_ENDING) {
        let shield = Some(shield_change_from_line(line, parser_state));
        parser_state.current_phase.shield_change.push(shield);
        println!("current phase shield changes: {:#?}", parser_state.current_phase.shield_change);
        println!("Shield change registered: {:?}", parser_state.current_phase.shield_change.last());
    }


    // register leg breaks
    if line.contains(LEG_KILL) {
        parser_state.current_phase.leg_breaks.push(leg_break_from_line(line, parser_state.phase_nr, parser_state.leg_order));
        println!("Leg break registered: {:?}", parser_state.current_phase.leg_breaks);
    }

    // register body
    if line.contains(BODY_VULNERABLE) {
        if parser_state.kill_sequence == 0 {
            parser_state.body_vuln_time = time_from_line(line);
        }
        parser_state.kill_sequence += 1; // 3x BODY_VULNERABLE in one phase means PT dies.
    }

    // register pylon TODO: bugged pylons
    if line.contains(PYLONS_LAUNCHED) {
        parser_state.pylon_launch_time = time_from_line(line);
        println!("Pylons launched at {}", parser_state.pylon_launch_time);
    }

    //current phase
    if line.contains(PHASE_START) { //TODO check bugged runs
        match line {
            _ if line.contains(PHASE_ENDS_1) => {
                prepare_and_submit_phase(line, run, parser_state);
                parser_state.phase_end_timestamp = time_from_line(line);
            },
            _ if line.contains(PHASE_ENDS_2) => {
                prepare_and_submit_phase(line, run, parser_state);
                parser_state.phase_end_timestamp = time_from_line(line);
            },
            _ if line.contains(PHASE_ENDS_3) => {
                prepare_and_submit_phase(line, run, parser_state);
                parser_state.phase_end_timestamp = time_from_line(line);
            },
            _ => {},
        }
        parser_state.leg_order = 0;
    }

    // Check for abort&end conditions
    if line.contains(ABORT_MISSION) || line.contains(BACK_TO_TOWN) { // line.contains(HEIST_START) || TODO: check if this is even necessary, like does that ever happen?
        println!("{:#?}", run);
        run.is_aborted_run = true;
        println!("Run {} aborted", run_number);
        run.time_stamp = chrono::Utc::now(); // Update timestamp
        post_process();
    } 
    else if parser_state.kill_sequence == 3 { // 3x BODY_VULNERABLE in one phase means PT dies.
        // run.aborted_run = false; //already default value
        println!("Run {} completed", run_number);
        run.time_stamp = chrono::Utc::now(); // Update timestamp to end of run
        post_process();
    } 

}

fn prepare_and_submit_phase (line: &str, mut run: &mut Run, mut parser_state: &mut ParserState) {
    println!("Phase {} ended", parser_state.current_phase.phase_number);
    parser_state.current_phase.total_time = 
        if parser_state.phase_nr == 1 {
            time_from_line(line) - parser_state.start_time
        } else {
            time_from_line(line) - parser_state.phase_end_timestamp
        };
    println!("Phase {} time: {}", parser_state.current_phase.phase_number, parser_state.current_phase.total_time);
    parser_state.current_phase.total_shield =
        if parser_state.current_phase.shield_change.is_empty() {
            None
        }
        else {
            Some(parser_state.current_phase.shield_change.
                iter()
                .map(|x| x.as_ref().unwrap().time)
                .sum())
        };
    println!("Phase {} shield time: {}", parser_state.current_phase.phase_number, parser_state.current_phase.total_shield.unwrap_or(0.0));
    parser_state.current_phase.total_leg = parser_state.current_phase.leg_breaks.iter().map(|x| x.time).sum();
    println!("Phase {} leg time: {}", parser_state.current_phase.phase_number, parser_state.current_phase.total_leg);
    parser_state.current_phase.total_body_kill = parser_state.pylon_launch_time - parser_state.body_vuln_time; // if pylon launch, body kill time is the time from body vuln to pylon launch, this is different in phases without pylons
    println!("Phase {} body time: {}", parser_state.current_phase.phase_number, parser_state.current_phase.total_body_kill);
    parser_state.current_phase.total_pylon =
        if parser_state.pylon_launch_time == 0.0 {
            None
        }
        else {
            Some(time_from_line(line) - parser_state.pylon_launch_time)
        };
    println!("Phase {} pylon time: {}", parser_state.current_phase.phase_number, parser_state.current_phase.total_pylon.unwrap_or(0.0));
    // phase number, shield_change and leg_breaks are already set at this point
    let phase_nr = parser_state.current_phase.phase_number;
    run.phases.push(parser_state.current_phase.clone());
    parser_state.current_phase = Phase::new(phase_nr + 1);
    println!("Phase {} started", parser_state.current_phase.phase_number);
    parser_state.body_vuln_time = 0.0;
    parser_state.pylon_launch_time = 0.0;
}

fn time_from_line(line: &str) -> f64 {
    line.split_whitespace().next().unwrap_or_default().parse::<f64>().expect("Time couldn't be extracted from line")
}
fn shield_change_from_line(line: &str, mut parser_state: &mut ParserState) -> ShieldChange {
    /// takes a line with a shield change, and returns a ShieldChange object, containing the time, status effect and current phase
    /// time is in relation to the previous time
    println!("previous time: {:?}", parser_state.previous_time);
    println!("line time: {:?}", time_from_line(line));
    let time = time_from_line(line) - parser_state.previous_time;
    println!("relative time: {:?}", time);
    let shield_change = ShieldChange::new(time, parser_state.previous_shield);
    parser_state.previous_time = time_from_line(line);
    if !line.contains(SHIELD_PHASE_ENDING) {
        parser_state.previous_shield = status_from_line(line);
    }
    shield_change
}
fn status_from_line(line: &str) -> StatusEffect {
    let name :&str = line.split_whitespace().last().expect("couldnt read shield element");
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
    status
}
fn leg_break_from_line (line :&str, phase: i8, mut leg_order: i8) -> LegBreak {
    let time = time_from_line(line);
    let name :&str = line.split_whitespace().last().expect("couldnt read leg ");
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

fn post_process() {
    //TODO Process the completed/aborted run
    //println!("Post-processed Run {}: Nickname: {:?}, Squad: {:?}",
    //         run.id, run.player_name, run.squad_members);
}

fn main() -> io::Result<()> {
    println!("Initiating");
    let run_number = 0;

    let path = format!("{}{}", env::var("LOCALAPPDATA").expect("LOCALAPPDATA not set"), LOG_PATH);
    let file = File::open(&path).expect("Log file not found");
    let mut reader = BufReader::new(file);
    let pos = reader.seek(SeekFrom::Start(0))?; //TODO implement follow log and static log mode

    parser_loop(&path, pos, run_number) //TODO: implement non-follower parser
}
