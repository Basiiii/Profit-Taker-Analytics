//! Utility functions for extracting data from log lines.

use crate::constants::{NICKNAME, SHIELD_PHASE_ENDING, SQUAD_MEMBER};
use crate::parser_state::ParserState;
use chrono::prelude::{DateTime, Local};
use chrono::{NaiveDateTime, TimeZone};
use lib_profit_taker_core::{LegBreak, LegPosition, Run, ShieldChange, SquadMember, StatusEffect};
use regex::Regex;

/// Takes the log's start time line, like
///
/// `0.087 Sys [Diag]: Current time: Wed Jan 29 15:28:56 2025 [UTC: Wed Jan 29 14:28:56 2025]`
///
/// and returns a consistent Unix timestamp to base run timestamps in that session on, 
/// so that runs are unique even if rerunning the parser on the same log, avoiding duplicates
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

/// Takes a line containing a nickname or squad member, like
///
/// `43.851 Net [Info]: name: [PlayerName], id=0`
/// 
/// or
/// 
/// `198.913 Game [Info]: [PlayerName] loadout loader finished.`
///
/// and updates the run object with the player name or squad members
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
        println!("Run host: {:?}", run.player_name);
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
        println!("Squad members: {:?}", run.squad_members);
    }
}

/// takes a line with a timestamp, like 
/// 
/// `123.456 Sys [Diag]: Current time: ...`
/// 
/// and returns the timestamp as an f64 in seconds: `123.456`
pub(crate) fn time_from_line(line: &str) -> f64 {
    line.split_whitespace()
        .next()
        .unwrap_or_default()
        .parse::<f64>()
        .expect("Time couldn't be extracted from line")
}

/// takes a line with a shield change, like
///
///`87.707 AI [Info]: Camper->SwitchShieldVulnerability() - Switching shield damage vulnerability type to DT_VIRAL`
///
/// and the `ParserState` object containing
/// the last shield element and reference timestamp, and returns a ``ShieldChange`` object,
/// containing the time, status effect and current phase time in relation to the previous time
pub(crate) fn shield_change_from_line(line: &str, parser_state: &mut ParserState) -> ShieldChange {
    
    // calculate the time since the last shield change / other event if start of shield phase
    let time = time_from_line(line) - parser_state.previous_time;
    let shield_change = ShieldChange::new(time, parser_state.previous_shield);
    parser_state.previous_time = time_from_line(line);
    if !line.contains(SHIELD_PHASE_ENDING) {
        parser_state.previous_shield = status_from_line(line);
    }
    shield_change
}

/// takes a line with a shield change, like
///
/// `87.707 AI [Info]: Camper->SwitchShieldVulnerability() - Switching shield damage vulnerability type to DT_VIRAL`
///
/// and returns the corresponding ``StatusEffect`` object:
/// 
/// `DT_VIRAL` -> `StatusEffect::Viral`
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

/// takes a line with a leg break, like
///
/// `102.241 AI [Info]: Camper->DestroyLeg() - Leg freshly destroyed at part: LEG_LEFT`
///
/// and the parser state object containing a reference timestamp,
/// and returns a LegBreak object, containing the leg order number, leg position and time in relation to the previous time.
/// 
/// Leg break directions are reversed to assume player perspective.
/// 
/// `LEG_LEFT` -> `LegPosition::BackRight`
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
