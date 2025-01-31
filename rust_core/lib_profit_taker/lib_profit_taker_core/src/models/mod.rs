/// This module contains the core data models for the application.
///
/// The models define the various entities and their relationships used in the application. 
/// Each model corresponds to a distinct concept, and together they form the structure 
/// that will be used throughout the system.
///
/// The models include:
/// - `Run`: Represents a specific run in the system, with data such as run time, player name, and phases.
/// - `Phase`: Represents a phase within a run, including data on shields, leg breaks, and status effects.
/// - `SquadMember`: Represents a member of a squad participating in the run.
/// - `TotalTimes`: Stores cumulative times for a run, including time spent on fight, shield, body, and pylon.
/// - `ShieldChange`: Represents a change in shield status during a phase of the run.
/// - `LegBreak`: Represents a leg break during a phase, including the leg's position and break order.
/// - `StatusEffect`: Enum representing various status effects that can apply to a shield or player during a phase.
/// - `LegPosition`: Enum representing possible positions of a leg that can be broken during the run.
///
/// This module serves as a convenient entry point for working with the data models by re-exporting all the core 
/// structures and enums to provide a clean and flat API. You can import the necessary models directly from this module 
/// without needing to refer to individual files.
///
/// Example usage:
/// ```rust
/// use lib_profit_taker_core::models::{Run, Phase, SquadMember};
/// let run = Run::new(1);
/// let phase = Phase::new(1);
/// ```
pub mod run;
pub mod phase;
pub mod squad_member;
pub mod total_times;
pub mod shield_change;
pub mod leg_break;
pub mod status_effect;
pub mod leg_position;

pub use run::Run;
pub use phase::Phase;
pub use squad_member::SquadMember;
pub use total_times::TotalTimes;
pub use shield_change::ShieldChange;
pub use leg_break::LegBreak;
pub use status_effect::StatusEffect;
pub use leg_position::LegPosition;
