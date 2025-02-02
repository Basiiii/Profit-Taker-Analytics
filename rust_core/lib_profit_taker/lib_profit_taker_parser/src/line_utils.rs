//! Utility functions for extracting data from log lines.

use crate::constants::{NICKNAME, SHIELD_PHASE_ENDING, SQUAD_MEMBER};
use crate::ParserState;
use lib_profit_taker_core::{LegBreak, LegPosition, Run, ShieldChange, SquadMember, StatusEffect};

pub fn handle_names(line: &str, run: &mut Run) {
    /// takes a line with a nickname or squad member, and updates the run object with the player name or squad members
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
pub fn time_from_line(line: &str) -> f64 {
    /// takes a line with a timestamp, and returns the time as a f64
    line.split_whitespace()
        .next()
        .unwrap_or_default()
        .parse::<f64>()
        .expect("Time couldn't be extracted from line")
}
pub fn shield_change_from_line(line: &str, parser_state: &mut ParserState) -> ShieldChange {
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
pub fn status_from_line(line: &str) -> StatusEffect {
    /// takes a line with a shield change, and returns the status effect
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
pub fn leg_break_from_line(line: &str, parser_state: &mut ParserState) -> LegBreak {
    /// takes a line with a leg break, and returns a LegBreak object, containing the time, leg position and current phase
    let time = time_from_line(line) - parser_state.previous_time;
    let name: &str = line.split_whitespace().last().expect("couldnt read leg ");
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
