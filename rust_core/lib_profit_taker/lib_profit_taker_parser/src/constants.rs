
//! # Parser Constants
//!
//! This module defines a collection of constants used for parsing EE.log. The constants
//! include OS-specific configurations for locating log files, as well as various log
//! line patterns used to identify key events and transitions during gameplay.
//!
//! ## OS-Specific Path Configurations
//! - For Windows: The log folder path is determined via the `LOCALAPPDATA` environment 
//!   variable and is stored under the defined `LOG_PATH`.
//! - For Linux: The path is determined using the `HOME` environment variable, with a 
//!   different folder structure.
//!
//! ## Log Line Patterns
//! These constants are used to search the logs for specific events such as:
//! - Game state changes (e.g., starting phases, ending phases).
//! - Key game events (e.g., shield vulnerability switches, leg breaks).
//! - Player information (e.g., player nicknames, squad member details).
//! - Run-related events (e.g., start, abort, host migration).

/// The OS-dependent environment variable that holds the path to the warframe log folder
#[cfg(target_os = "windows")]
pub const ENV_PATH: &str = "LOCALAPPDATA";

/// The OS-dependent path to where the warframe log folder is stored
#[cfg(target_os = "windows")]
pub const LOG_PATH: &str = "/Warframe/EE.log";

/// The OS-dependent environment variable that holds the path to the warframe log folder
#[cfg(target_os = "linux")]
pub const ENV_PATH: &str = "HOME";

/// The OS-dependent path to where the warframe log folder is stored
#[cfg(target_os = "linux")]
pub const LOG_PATH: &str = "/.local/share/Steam/steamapps/compatdata/230410/pfx/drive_c/users/steamuser/AppData/Local/Warframe/EE.log";

/// Line containing information on when the log was generated
pub const LOG_START_TIME: &str = "Sys [Diag]: Current time:";
/// Line indicating shield vulnerability was changed
pub const SHIELD_SWITCH: &str = "SwitchShieldVulnerability";
/// Line indicating a shield phase has ended
pub const SHIELD_PHASE_ENDING: &str = "ResourceLoader";
// this line no longer exists:
// pub const SHIELD_PHASE_ENDING: &str = "GiveItem Queuing resource load for Transmission: ";
/// Line indicating the first shield phase has ended
pub const SHIELD_PHASE_ENDING_1: &str =
    "Lotus/Sounds/Dialog/FortunaOrbHeist/Business/DBntyFourInterPrTk0920TheBusiness";
/// Line indicating the third shield phase has ended
pub const SHIELD_PHASE_ENDING_3: &str =
    "/Lotus/Sounds/Dialog/FortunaOrbHeist/Business/DBntyFourInterPrTk0890TheBusiness";
/// Line indicating the fourth shield phase has ended
pub const SHIELD_PHASE_ENDING_4: &str =
    "/Lotus/Sounds/Dialog/FortunaOrbHeist/Business/DBntyFourSatelReal0930TheBusiness";
/// All shield phase ending lines
pub const SHIELD_PHASE_ENDINGS: [&str; 3] = [
    SHIELD_PHASE_ENDING_1,
    SHIELD_PHASE_ENDING_3,
    SHIELD_PHASE_ENDING_4,
];
/// Line indicating a leg was destroyed
pub const LEG_KILL: &str = "Leg freshly destroyed at part";
/// Line indicating Profit-Taker's body is vulnerable to damage
pub const BODY_VULNERABLE: &str = "Camper->StartVulnerable() - The Camper can now be damaged!";
/// Line indicating the body was killed
pub const STATE_CHANGE: &str = "CamperHeistOrbFight.lua: Landscape - New State: ";
/// Line indicating pylons have been launched
pub const PYLONS_LAUNCHED: &str = "Pylon launch complete";
/// Line indicating the start of a phase
pub const PHASE_START: &str = "Orb Fight - Starting";
/// Line indicating the start of the first phase
pub const PHASE_1_START: &str = "Orb Fight - Starting first attack Orb phase";
/// Line indicating the end of the first phase and start of the second
pub const PHASE_ENDS_1: &str = "Orb Fight - Starting second attack Orb phase";
/// Line indicating the end of the second phase and start of the third phase
pub const PHASE_ENDS_2: &str = "Orb Fight - Starting third attack Orb phase";
/// Line indicating the end of the third phase and start of the final phase
pub const PHASE_ENDS_3: &str = "Orb Fight - Starting final attack Orb phase";
/// Line containing the username of the host of the run
pub const NICKNAME: &str = "Net [Info]: name: ";
/// Line containing information on players participating in the run
pub const SQUAD_MEMBER: &str = "loadout loader finished.";
/// Line indicating the bounty has started
pub const HEIST_START: &str =
    "jobId=/Lotus/Types/Gameplay/Venus/Jobs/Heists/HeistProfitTakerBountyFour";
/// Line indicating a host migration
pub const HOST_MIGRATION: &str =
    "\"jobId\" : \"/Lotus/Types/Gameplay/Venus/Jobs/Heists/HeistProfitTakerBountyFour";
/// Line indicating that the run was aborted
pub const HEIST_ABORT: &str = "SetReturnToLobbyLevelArgs: ";
/// Line indicating that the player has exited the elevator
pub const ELEVATOR_EXIT: &str = "EidolonMP.lua: EIDOLONMP: Avatar left the zone";
/// Line indicating that the player has entered fortuna
pub const BACK_TO_TOWN: &str = "EidolonMP.lua: EIDOLONMP: TryTownTransition";
/// Line indicating a run was aborted
pub const ABORT_MISSION: &str = "GameRulesImpl - changing state from SS_STARTED to SS_ENDING";
