use lib_profit_taker_core::{LegBreak, LegPosition, Run, ShieldChange, SquadMember, StatusEffect};
use chrono::{DateTime, Local, NaiveDateTime, TimeZone};
use lib_profit_taker_database::queries::insert_run::insert_run;
use serde::{Deserialize, Serialize};
use std::{fs, io};
use std::fs::File;
use lib_profit_taker_database::queries::fetch_latest_run::fetch_latest_run_id;

/// Phase struct to hold the data from the json file, in the same format as the json file
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

/// RunData struct to hold the data from the json file, in the same format as the json file
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

/// Function to initialize the converter, which reads all files in the storage folder and converts them to the database
///
/// # Example
///
/// ```
/// use lib_profit_taker_core::utils::json_to_db::initialize_converter;
/// initialize_converter("./storage/".to_string());
/// ```
///
/// This will read all files in the storage folder and convert them to the database
///
/// # Panics
///
/// This function will panic if it can't read the storage folder
pub fn initialize_json_converter(path: &str) -> Result<(), io::Error> {
    let entries = fs::read_dir(&path)?;
    for entry in entries {
        deserialize_json(entry)?;
    }
    Ok(())
}

/// Function to deserialize the json file and insert it into the database
///
/// # Arguments
///
/// * `entry` - A Result of a DirEntry, which is the file to be deserialized
///
/// # Panics
///
/// This function will panic if it
/// * can't find the path
/// * can't open the file
/// * can't parse the json
///
/// # Example
///
/// ```
/// use std::fs;
/// use lib_profit_taker_core::utils::json_to_db::deserialize_json;
/// let path = fs::read_dir("./src/storage").expect("read_dir call failed").next().unwrap();
/// deserialize_json(path);
/// ```
fn deserialize_json(entry: Result<fs::DirEntry, io::Error>) -> Result<(), io::Error> {
    let mut run = Run::new();
    let path = entry?.path();
    let file = File::open(&path)?;
    let run_json: RunData = serde_json::from_reader(file)?;
    sort_run_data(&mut run, &run_json);

    // Fetch the latest run ID from the database
    let latest_run_id = match fetch_latest_run_id() {
        Ok(Some(run_id)) => run_id,
        Ok(None) => 0,
        Err(e) => {
            eprintln!("Failed to fetch latest run: {e}");
            0
        }
    };
    
    // Set the run name based on the latest run ID
    run.run_name = format!("Run #{}", latest_run_id + 1);
    
    //println!("done parsing run: {run:#?}");
    if let Err(e) = insert_run(&run) {
        eprintln!("Error inserting run: {e}");
    }
    Ok(())
}

/// Function to sort the run data from the json file into the Run struct
///
/// # Arguments
///
/// * `run` - A mutable reference to the Run struct to be filled
/// * `run_json` - A reference to the RunData struct to be used to fill the Run struct
///
/// # Example
///
/// ```
/// use lib_profit_taker_core::{Run, SquadMember};
/// use lib_profit_taker_core::utils::json_to_db::sort_run_data;
/// use lib_profit_taker_core::utils::json_to_db::RunData;
/// let mut run = Run::new();
/// let run_json = RunData::new(); // deserialize into this, RunData doesn't actually have a `new` function for obvious reasons
/// sort_run_data(&mut run, &run_json);
/// ```
///
/// This will fill the Run struct with the data from the RunData struct
fn sort_run_data(run: &mut Run, run_json: &RunData) {
    // insert basic run metadata
    run.time_stamp = get_run_timestamp(run_json);
    run.is_bugged_run = run_json.bugged_run;
    run.is_aborted_run = run_json.aborted_run;
    run.player_name = run_json.nickname.clone();
    for member in run_json.squad_members.clone() {
        // old parser added the player name to the squad members
        if member != run.player_name {
            run.squad_members.push(SquadMember::new(member));
        }
    }

    if !run.squad_members.is_empty() {
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

/// Function to get the run's UNIX timestamp from the json file.
/// 
/// The timestamp is in python's ``datetime.isoformat()`` format and therefore a naive iso timestamp, assumed to be in local time
///
/// # Arguments
///
/// * `run_json` - A reference to the RunData struct deserialized from the json file to be used to get the timestamp
///
/// # Returns
///
/// * `i64` - The timestamp of the run in UNIX format
fn get_run_timestamp(run_json: &RunData) -> i64 {
    // parse iso timestamp to NaiveDateTime object
    let chrono_timestamp =
        NaiveDateTime::parse_from_str(&run_json.time_stamp, "%Y-%m-%dT%H:%M:%S%.f")
            .expect("Failed to parse timestamp");

    // Interpret the naive datetime as local time
    let local_dt: DateTime<Local> = Local
        .from_local_datetime(&chrono_timestamp)
        .single()
        .expect("Ambiguous or invalid local datetime");

    // return timestamp as UNIX timestamp
    local_dt.timestamp()
}

/// Function to sort the total times from the json file into the Run struct
///
/// # Arguments
///
/// * `run` - A mutable reference to the Run struct to be filled
/// * `run_json` - A reference to the RunData struct to be used to fill the Run struct
fn sort_total_times(run: &mut Run, run_json: &RunData) {
    run.total_times.total_flight_time = run_json.flight_duration;
    run.total_times.total_time = run_json.total_duration;
    run.total_times.total_shield_time = run_json.total_shield;
    run.total_times.total_leg_time = run_json.total_leg;
    run.total_times.total_body_time = run_json.total_body;
    run.total_times.total_pylon_time = run_json.total_pylon;
}

/// Function to sort the phase data from the json file into the Run struct
///
/// # Arguments
///
/// * `run` - A mutable reference to the Run struct to be filled
/// * `phase` - A reference to the Phase struct to be used to fill the Run struct
/// * `phase_nr` - An i32 representing the phase number
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

/// Function to sort the shield changes from the json file into the Phase struct
///
/// # Arguments
///
/// * `current_phase` - A mutable reference to the Phase struct to be filled
/// * `json_phase` - A reference to the Phase struct to be used to fill the Phase struct
fn sort_shields(current_phase: &mut lib_profit_taker_core::Phase, json_phase: Phase) {
    let shield_change_times = json_phase.shield_change_times.unwrap_or_default();
    let shield_change_types = json_phase.shield_change_types.unwrap_or_default();
    let shield_change_length = shield_change_times.len();
    for entry in 0..shield_change_length {
        current_phase.shield_changes.push(ShieldChange::new(
            shield_change_times[entry],
            status_from_json(&shield_change_types[entry]),
            entry as i32 + 1,
        ));
    }
}

/// Function to convert the status effect from the json file to the StatusEffect enum
///
/// # Arguments
///
/// * `name` - A string representing the status effect to be converted
///
/// # Returns
///
/// * `StatusEffect` - The converted status effect
///
/// # Example
///
/// ```
/// use lib_profit_taker_core::utils::json_to_db::status_from_json;
/// let status = status_from_json("Impact");
///
/// assert_eq!(status, lib_profit_taker_core::StatusEffect::Impact);
/// ```
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

/// Function to sort the leg breaks from the json file into the Phase struct
///
/// # Arguments
///
/// * `current_phase` - A mutable reference to the Phase struct to be filled
/// * `json_phase` - A reference to the Phase struct to be used to fill the Phase struct
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

/// Function to convert the leg position from the json file to the LegPosition enum.
/// Flips the leg position to reflect the correct position from the player's perspective
///
/// # Arguments
///
/// * `name` - A string representing the leg position to be converted
///
/// # Returns
///
/// * `LegPosition` - The converted leg position to the LegPosition enum
///
/// # Example
///
/// ```
/// use lib_profit_taker_core::utils::json_to_db::leg_position_from_json;
/// let leg_position = leg_position_from_json("FR");
///
/// assert_eq!(leg_position, lib_profit_taker_core::LegPosition::FrontLeft);
/// ```
fn leg_position_from_json(name: &str) -> LegPosition {
    match name {
        "FR" => LegPosition::FrontLeft,
        "BL" => LegPosition::BackRight,
        "BR" => LegPosition::BackLeft,
        "FL" => LegPosition::FrontRight,
        _ => panic!("Unknown leg position: {name}"),
    }
}
