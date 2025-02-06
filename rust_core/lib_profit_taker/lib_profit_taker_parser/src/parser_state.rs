use lib_profit_taker_core::{Phase, StatusEffect};

/// Holds all the different temporary variables needed for calculating and sorting the run data
///
/// The `ParserState` struct is used during log parsing to store intermediate parsing results,
/// track the current phase, and manage event timing and order. These values are reset or updated
/// as the parsing progresses and are used to build the final run data.

pub(crate) struct ParserState {
    /// The time the run started, for reference
    pub(crate) start_time: f64,
    
    /// The order of the legs, incremented by 1 for each leg, reset on phase end
    pub(crate) leg_order: i32,
    
    /// The order of the shields, incremented by 1 for each shield, reset on phase end
    pub(crate) shield_order: i32,
    
    /// The current phase, edited while parsing, added to the run data when the phase ends and reset
    pub(crate) current_phase: Phase,
    
    /// The time the body is vulnerable, after legs, for reference
    pub(crate) body_vuln_time: f64,
    
    /// The time pylons are launched, for reference
    pub(crate) pylon_launch_time: f64,
    
    /// The time the current phase ends, for reference
    pub(crate) phase_end_timestamp: f64,
    
    /// incremented with every `BODY_VULNERABLE` line in a phase (reset on phase end), used to determine if the run is over
    pub(crate) kill_sequence: i32,
    
    /// The previous shield status, used to determine the element of a shield break using the next shield change line
    pub(crate) previous_shield: StatusEffect,
    
    /// whatever the previous time was, used to determine the time between events where others arent applicable
    pub(crate) previous_time: f64,
    
    /// whether the shield phase has ended, used to determine shield phase endings
    pub(crate) shield_phase_ended: bool,
    
    /// The time the body was killed, for reference
    pub(crate) body_kill_time: f64,
    
    /// Whether the run has ended, used to determine if the run is over and a new one can be parsed
    pub(crate) run_ended: bool,
    
    /// Set to true when pylons launch in phase 3, used to determine if the run is bugged 
    /// by checking if more than one shield change happens while this is true
    pub(crate) pylon_check: bool, // needed to parse phase 4 in bugged runs
    
    /// The number of shields that have been broken, used to determine if the run is bugged, see above
    pub(crate) shield_count: i8, // needed to parse phase 4 in bugged runs
    
    /// The time the log started, for reference
    pub(crate) log_start_time: i64,
}
impl ParserState {
    pub(crate) const fn new() -> Self {
        Self {
            start_time: 0.0,
            leg_order: 0,
            shield_order: 0,
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
            log_start_time: 0,
        }
    }
    pub(crate) fn with_log_start_time(log_start_time: i64) -> Self {
        Self {
            log_start_time,
            ..Self::new()
        }
    }
}