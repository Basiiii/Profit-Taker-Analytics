//! This module provides utility functions for parsing log lines in a structured way.
//!
//! The primary goal of the functions in this module is to extract meaningful
//! gameplay-related data from textual log lines and format them into structured,
//! reusable data types for further processing.
//!
//! Main functionalities include:
//! - Extracting and converting timestamps from log lines into a consistent format (`get_log_time`).
//! - Identifying and updating player-related information, such as the player's nickname
//!   and squad members (`handle_names`).
//! - Parsing and processing shield change events to track time and status effects (`shield_change_from_line`).
//! - Identifying and handling specific events like leg breaks and converting them to structured types (`leg_break_from_line`).
//!
//! This is used in conjunction with the `ParserState` that keeps track of prior state changes
//! and supports generating structured events like `Run`, `ShieldChange`, and `LegBreak`.

use crate::constants::{NICKNAME, SHIELD_PHASE_ENDING, SQUAD_MEMBER};
use crate::parser_state::ParserState;
use chrono::prelude::{DateTime, Local};
use chrono::{NaiveDateTime, TimeZone};
use lib_profit_taker_core::{LegBreak, LegPosition, Run, ShieldChange, SquadMember, StatusEffect};
use regex::Regex;


/// Parses a timestamp from a log line and converts it to a Unix timestamp in seconds.
///
/// # Arguments
///
/// - `line`: A string slice that represents the log line containing a timestamp.
///   Expected format is: `Mon Jan  2 15:04:05 2006`, such as `Mon Jan  1 12:34:56 2021`.
///
/// # Returns
///
/// A 64-bit integer representing the Unix timestamp (number of seconds since 
/// January 1, 1970, UTC).
///
/// # Panics
///
/// This function will panic if:
/// - The given log line does not match the expected regex format.
/// - The date-time string extracted from the log line cannot be parsed successfully.
/// - Time conversion to the local time zone fails.
pub(crate) fn get_log_time(line: &str) -> i64 {
    // Regex to capture the timestamp in the log line
    let re = Regex::new(r"(\w{3}) (\w{3})\s+(\d+) (\d{2}:\d{2}:\d{2}) (\d{4})").unwrap();
    let caps = re.captures(line).expect("Failed to match regex");

    // Build a datetime string in the format "YYYY MMM DD HH:MM:SS"
    let datetime_str = format!("{} {} {} {}", &caps[5], &caps[2], &caps[3], &caps[4]);

    // Parse the datetime string into NaiveDateTime (no time zone)
    let naive_dt = NaiveDateTime::parse_from_str(&datetime_str, "%Y %b %d %H:%M:%S")
        .expect("Failed to parse datetime");

    // Convert to DateTime<Local> (local timezone)
    let local_time: DateTime<Local> = Local.from_local_datetime(&naive_dt).unwrap();

    // Return the Unix timestamp for the local time
    local_time.timestamp()
}

/// Handles the extraction and processing of player and squad member names
/// from a log line, updating the given `Run` object accordingly.
///
/// # Arguments
///
/// - `line`: A string slice representing a single log line to be parsed.
/// - `run`: A mutable reference to the `Run` object that holds the 
///          gameplay-related player and squad information.
///
/// # Behavior
///
/// This function performs the following actions:
/// 1. Extracts the player's nickname from the log line if the line contains
///    the `NICKNAME` identifier and the `Run` does not already have a player name.
/// 2. Extracts squad member names if the log line contains the `SQUAD_MEMBER`
///    identifier, ensuring that names are cleaned and added only if the max squad
///    size (3 members) has not been reached and the name is not the player's nickname.
///
/// # Panics
///
/// This function will panic if:
/// - The expected player or squad member name cannot be extracted from the log line.
pub(crate) fn handle_names(line: &str, run: &mut Run) {
    if line.contains(NICKNAME) && run.player_name.is_empty() {
        run.player_name = line
            .split_whitespace()
            .nth(4)
            .expect("No player name found.")
            .split('\u{e000}')
            .next()
            .expect("No player name found.")
            .to_string();
        //println!("Run host: {:?}", run.player_name);
    } else if line.contains(SQUAD_MEMBER) {
        let parts: Vec<&str> = line.split_whitespace().collect();
        if let Some(name_part) = parts.get(3) {
            let clean_name = name_part
                .split('\u{e000}')
                .next()
                .unwrap_or_default()
                .to_string();
            if run.squad_members.len() < 3 && clean_name != run.player_name {
                //
                run.squad_members.push(SquadMember::new(clean_name));
                run.is_solo_run = false;
            }
        }
        //println!("Squad members: {:?}", run.squad_members);
    }
}

/// Extracts the timestamp as a floating-point value in seconds from a log line.
///
/// # Arguments
///
/// - `line`: A string slice representing a log line that starts with a timestamp.
///
/// # Returns
///
/// A `f64` value representing the extracted time in seconds as a floating-point number.
///
/// # Example
///
/// Given a log line in the following format:
///
/// ```text
/// 123.456 Sys [Diag]: Current time: ...
/// ```
///
/// The function will extract and return the time as `123.456`.
///
/// # Panics
///
/// This function will panic if:
/// - The log line is empty or improperly formatted such that the timestamp cannot be 
///   extracted.
/// - The extracted timestamp cannot be parsed as a `f64`.
pub(crate) fn time_from_line(line: &str) -> f64 {
    line.split_whitespace()
        .next()
        .unwrap_or_default()
        .parse::<f64>()
        .expect("Time couldn't be extracted from line")
}

/// Parses a log line indicating a shield change event and computes the related information.
///
/// # Arguments
///
/// - `line`: A string slice representing a log line containing information about a shield change.
/// - `parser_state`: A mutable reference to the `ParserState` struct which tracks the state of the parser,
///   including the reference timestamp and the previous shield element.
///
/// # Returns
///
/// A `ShieldChange` object that contains:
/// - The time since the last shield change event, calculated as the difference between the current log
///   timestamp and the `previous_time` stored in `parser_state`.
/// - The status effect of the previous shield.
/// - The current phase time.
///
/// # Behavior
///
/// This function extracts the time of the shield change, calculates the time delta relative to the previous
/// event, and determines the shield type from the log line unless the line indicates the end of a shield phase.
///
/// - The `previous_time` in `parser_state` is updated with the current log timestamp.
/// - If the line does not indicate the end of a shield phase (via the `SHIELD_PHASE_ENDING` string),
///   the `previous_shield` in `parser_state` is updated with the shield type extracted from the log line.
pub(crate) fn shield_change_from_line(line: &str, parser_state: &mut ParserState) -> ShieldChange {
    
    // calculate the time since the last shield change / other event if start of shield phase
    let time = time_from_line(line) - parser_state.previous_time;
    parser_state.shield_order += 1;
    let shield_change = ShieldChange::new(time, parser_state.previous_shield, parser_state.shield_order);
    parser_state.previous_time = time_from_line(line);
    if !line.contains(SHIELD_PHASE_ENDING) {
        parser_state.previous_shield = status_from_line(line);
    }
    shield_change
}


/// Extracts the appropriate `StatusEffect` from the given log line.
///
/// # Arguments
///
/// - `line`: A string slice containing the log line with a shield change event.
///
/// # Returns
///
/// A `StatusEffect` object parsed from the log line.
///
/// # Behavior
///
/// This function examines the last segment of the log line, extracts the shield damage 
/// vulnerability type, and maps it to the corresponding `StatusEffect` variant.
///
/// # Panics
///
/// This function will panic if:
/// - The input line does not contain a valid format to extract a shield damage type.
/// - The extracted type is not recognized as a valid `StatusEffect`.
///
/// # Example
///
/// Given a log line like the following:
///
/// ```text
/// 87.707 AI [Info]: Camper->SwitchShieldVulnerability() - Switching shield damage vulnerability 
/// to DT_VIRAL
/// ```
///
/// This function will return `StatusEffect::Viral`.
pub(crate) fn status_from_line(line: &str) -> StatusEffect {
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

/// Parses a log line indicating a leg break event and creates a `LegBreak` object.
///
/// # Arguments
///
/// - `line`: A string slice representing a log line containing information about a leg break
///   event.
/// - `parser_state`: A mutable reference to the `ParserState` object which stores the reference
///   timestamp and keeps track of the parsing state.
///
/// # Returns
///
/// A `LegBreak` object that includes the time since the previous event, the leg position relative
/// to the player's perspective, and an incrementing leg order number.
///
/// # Panics
///
/// This function will panic if:
/// - The input `line` is not formatted properly to extract the leg position.
/// - The extracted leg position is not recognized as a valid variant of `LegPosition`.
///
/// # Example
///
/// Given the following log line:
///
/// ```text
/// 102.241 AI [Info]: Camper->DestroyLeg() - Leg freshly destroyed at part: LEG_LEFT
/// ```
/// The function will return a `LegBreak` object with the time since the last event, the leg
/// position as `LegPosition::BackRight` (from the player's perspective), and the leg order number
/// incremented.
pub(crate) fn leg_break_from_line(line: &str, parser_state: &mut ParserState) -> LegBreak {
    let time = time_from_line(line) - parser_state.previous_time;
    let name: &str = line
        .split_whitespace()
        .last()
        .expect("couldnt read leg from line");
    // the leg directions are reversed because the log writes them from the perspective of the orb,
    // but we assume the perspective of the player shooting the legs
    let leg = match name {
        "ARM_RIGHT" => LegPosition::FrontLeft,
        "ARM_LEFT" => LegPosition::FrontRight,
        "LEG_RIGHT" => LegPosition::BackLeft,
        "LEG_LEFT" => LegPosition::BackRight,
        _ => panic!("Unknown leg position: {name}"),
    };
    parser_state.previous_time = time_from_line(line);
    parser_state.leg_order += 1;
    LegBreak::new(time, leg, parser_state.leg_order)
}
