
// Constants
pub const LOG_PATH: &str = "/Warframe/EE.log";
#[cfg(target_os = "windows")]
pub const ENV_PATH: &str = "LOCALAPPDATA";
#[cfg(target_os = "linux")]
pub const ENV_PATH: &str = "/Warframe/EE.log"; // to be updated with whatever the path is on linux

pub const SHIELD_SWITCH: &str = "SwitchShieldVulnerability";
pub const SHIELD_PHASE_ENDING: &str = "GiveItem Queuing resource load for Transmission: ";
pub const SHIELD_PHASE_ENDING_1: &str =
    "Lotus/Sounds/Dialog/FortunaOrbHeist/Business/DBntyFourInterPrTk0920TheBusiness";
pub const SHIELD_PHASE_ENDING_3: &str =
    "/Lotus/Sounds/Dialog/FortunaOrbHeist/Business/DBntyFourInterPrTk0890TheBusiness";
pub const SHIELD_PHASE_ENDING_4: &str =
    "/Lotus/Sounds/Dialog/FortunaOrbHeist/Business/DBntyFourSatelReal0930TheBusiness";
pub const SHIELD_PHASE_ENDINGS: [&str; 3] = [
    SHIELD_PHASE_ENDING_1,
    SHIELD_PHASE_ENDING_3,
    SHIELD_PHASE_ENDING_4,
];
pub const LEG_KILL: &str = "Leg freshly destroyed at part";

pub const BODY_VULNERABLE: &str = "Camper->StartVulnerable() - The Camper can now be damaged!";
pub const STATE_CHANGE: &str = "CamperHeistOrbFight.lua: Landscape - New State: ";
pub const PYLONS_LAUNCHED: &str = "Pylon launch complete";
pub const PHASE_START: &str = "Orb Fight - Starting";
pub const PHASE_1_START: &str = "Orb Fight - Starting first attack Orb phase";
pub const PHASE_ENDS_1: &str = "Orb Fight - Starting second attack Orb phase";
pub const PHASE_ENDS_2: &str = "Orb Fight - Starting third attack Orb phase";
pub const PHASE_ENDS_3: &str = "Orb Fight - Starting final attack Orb phase";

pub const NICKNAME: &str = "Net [Info]: name: ";
pub const SQUAD_MEMBER: &str = "loadout loader finished.";
pub const HEIST_START: &str =
    "jobId=/Lotus/Types/Gameplay/Venus/Jobs/Heists/HeistProfitTakerBountyFour";
pub const HOST_MIGRATION: &str =
    "\"jobId\" : \"/Lotus/Types/Gameplay/Venus/Jobs/Heists/HeistProfitTakerBountyFour";
pub const HEIST_ABORT: &str = "SetReturnToLobbyLevelArgs: ";
pub const ELEVATOR_EXIT: &str = "EidolonMP.lua: EIDOLONMP: Avatar left the zone";
pub const BACK_TO_TOWN: &str = "EidolonMP.lua: EIDOLONMP: TryTownTransition";
pub const ABORT_MISSION: &str = "GameRulesImpl - changing state from SS_STARTED to SS_ENDING";
