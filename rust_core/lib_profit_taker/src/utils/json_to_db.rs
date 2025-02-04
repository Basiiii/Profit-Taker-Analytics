use lib_profit_taker_core::{LegBreak, LegPosition, Run, ShieldChange, SquadMember, StatusEffect};
//use lib_profit_taker_database::queries::insert_run::insert_run;
use serde::{Deserialize, Serialize};
use std::fs;
use std::fs::File;
use lib_profit_taker_database::queries::insert_run::insert_run;

#[derive(Serialize, Deserialize, Debug, Clone)]
struct Phase {
    phase_time: f64,
    total_shield: Option<f64>,
    total_leg: f64,
    shield_change_times: Option<Vec<f64>>,
    shield_change_types: Option<Vec<String>>,
    leg_break_times: Vec<f64>,
    leg_break_order: Vec<String>,
    body_kill_time: f64,
    pylon_time: Option<f64>,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
struct RunData {
    total_duration: f64,
    total_shield: f64,
    total_leg: f64,
    total_body: f64,
    total_pylon: f64,
    time_stamp: String,
    pretty_name: String,
    file_name: String,
    status: String,
    flight_duration: f64,
    bugged_run: bool,
    aborted_run: bool,
    best_run: bool,
    squad_members: Vec<String>,
    nickname: String,
    phase_1: Phase,
    phase_2: Phase,
    phase_3: Phase,
    phase_4: Phase,
}

pub fn initialize_converter() {
    let path = String::from("./src/storage");
    let entries = fs::read_dir(&path).expect("read_dir call failed");
    for entry in entries {
        deserialize_json(entry);
    }
}

fn deserialize_json(entry: Result<fs::DirEntry, std::io::Error>) {
    let mut run = Run::new();
    let path = entry.expect("couldnt find path").path();
    let file = File::open(&path).expect("file open failed");
    let run_json: RunData = serde_json::from_reader(file).expect("json parse failed");
    sort_run_data(&mut run, &run_json);
    //println!("done parsing run: {run:#?}");
    if let Err(e) = insert_run(&run) {
        eprintln!("Error inserting run: {e}");
    }
}

fn sort_run_data(run: &mut Run, run_json: &RunData) {
    // insert basic run metadata
    //TODO run.time_stamp = run_json.time_stamp;
    run.is_bugged_run = run_json.bugged_run;
    run.is_aborted_run = run_json.aborted_run;
    run.player_name = run_json.nickname.clone();
    for member in run_json.squad_members.clone() {
        if member != run.player_name {
            run.squad_members.push(SquadMember::new(member));
        }
    }

    if run.squad_members.len() > 0 {
        run.is_solo_run = false;
    }

    // insert total times
    sort_total_times(run, run_json);

    // insert phases
    for phase in 1..=4 {
        match phase {
            1 => sort_phase(run, run_json.phase_1.clone(), 1),
            2 => sort_phase(run, run_json.phase_2.clone(), 2),
            3 => sort_phase(run, run_json.phase_3.clone(), 3),
            4 => sort_phase(run, run_json.phase_4.clone(), 4),
            _ => println!("invalid phase number"),
        }
    }
}

fn sort_total_times(run: &mut Run, run_json: &RunData) {
    run.total_times.total_flight_time = run_json.flight_duration;
    run.total_times.total_time = run_json.total_duration;
    run.total_times.total_shield_time = run_json.total_shield;
    run.total_times.total_leg_time = run_json.total_leg;
    run.total_times.total_body_time = run_json.total_body;
    run.total_times.total_pylon_time = run_json.total_pylon;
}

fn sort_phase(run: &mut Run, phase: Phase, phase_nr: i32) {
    let mut current_phase = lib_profit_taker_core::Phase::new(phase_nr);
    current_phase.total_shield_time = phase.total_shield.unwrap_or_default();
    current_phase.total_leg_time = phase.total_leg;
    current_phase.total_body_kill_time = phase.body_kill_time;
    current_phase.total_pylon_time = phase.pylon_time.unwrap_or_default();

    sort_shields(&mut current_phase, phase.clone());

    sort_legs(&mut current_phase, phase.clone());

    match phase_nr {
        1 => current_phase.total_time = phase.phase_time - run.total_times.total_flight_time,
        2 => {
            current_phase.total_time =
                phase.phase_time - run.total_times.total_flight_time - run.phases[0].total_time;
        }
        3 => {
            current_phase.total_time = phase.phase_time
                - run.total_times.total_flight_time
                - run.phases[0].total_time
                - run.phases[1].total_time;
        }
        4 => {
            current_phase.total_time = phase.phase_time
                - run.total_times.total_flight_time
                - run.phases[0].total_time
                - run.phases[1].total_time
                - run.phases[2].total_time;
        }
        _ => println!("invalid phase number"),
    }

    run.phases.push(current_phase);
}

fn sort_shields(current_phase: &mut lib_profit_taker_core::Phase, json_phase: Phase) {
    let shield_change_times = json_phase.shield_change_times.unwrap_or_default();
    let shield_change_types = json_phase.shield_change_types.unwrap_or_default();
    let shield_change_length = shield_change_times.len();
    //TODO: add shield order
    for entry in 0..shield_change_length {
        current_phase.shield_changes.push(ShieldChange::new(
            shield_change_times[entry],
            status_from_json(&shield_change_types[entry]),
        ));
    }
}
fn status_from_json(name: &str) -> StatusEffect {
    match name {
        "Impact" => StatusEffect::Impact,
        "Puncture" => StatusEffect::Puncture,
        "Slash" => StatusEffect::Slash,
        "Cold" => StatusEffect::Cold,
        "Heat" => StatusEffect::Heat,
        "Toxin" => StatusEffect::Toxin,
        "Electricity" => StatusEffect::Electric,
        "Gas" => StatusEffect::Gas,
        "Viral" => StatusEffect::Viral,
        "Magnetic" => StatusEffect::Magnetic,
        "Radiation" => StatusEffect::Radiation,
        "Corrosive" => StatusEffect::Corrosive,
        "Blast" => StatusEffect::Blast,
        _ => panic!("Unknown status effect: {}", name),
    }
}
fn sort_legs(current_phase: &mut lib_profit_taker_core::Phase, json_phase: Phase) {
    let leg_break_times = json_phase.leg_break_times;
    let leg_break_order = json_phase.leg_break_order;
    if leg_break_order.len() == 4 {
        for entry in 0..4 {
            current_phase.leg_breaks.push(LegBreak::new(
                leg_break_times[entry],
                leg_position_from_json(&leg_break_order[entry]),
                entry as i32 + 1,
            ));
        }
    }
}

fn leg_position_from_json(name: &str) -> LegPosition {
    match name {
        "FR" => LegPosition::FrontLeft,
        "BL" => LegPosition::BackRight,
        "BR" => LegPosition::BackLeft,
        "FL" => LegPosition::FrontRight,
        _ => panic!("Unknown leg position: {name}"),
    }
}
