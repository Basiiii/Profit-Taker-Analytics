use lib_profit_taker_core::{LegPosition, StatusEffect};
use lib_profit_taker_database::{connection::initialize_database, queries::{
    delete_favorite::unmark_as_favorite, delete_run::delete_run, edit_run_name::edit_run_name, fetch_earliest_run::fetch_earliest_run_id, fetch_latest_run::fetch_latest_run_id, fetch_next_run::fetch_next_run_id, fetch_previous_run::fetch_previous_run_id, fetch_run_data::fetch_run_from_db, insert_favorite::mark_as_favorite, latest_run::is_latest_run, run_exists::run_exists
}};

#[flutter_rust_bridge::frb]
pub struct RunModel {
    pub run_id: i32,
    pub time_stamp: i64,
    pub run_name: String,
    pub player_name: String,
    pub is_bugged_run: bool,
    pub is_aborted_run: bool,
    pub is_solo_run: bool,
    pub total_times: TotalTimesModel,
    pub phases: Vec<PhaseModel>,
    pub squad_members: Vec<SquadMemberModel>,
}

#[flutter_rust_bridge::frb]
pub struct TotalTimesModel {
    pub total_duration: f64,
    pub total_flight_time: f64,
    pub total_shield_time: f64,
    pub total_leg_time: f64,
    pub total_body_time: f64,
    pub total_pylon_time: f64,
}

#[flutter_rust_bridge::frb]
pub struct PhaseModel {
    pub phase_number: i32,
    pub total_time: f64,
    pub total_shield_time: f64,
    pub total_leg_time: f64,
    pub total_body_kill_time: f64,
    pub total_pylon_time: f64,
    pub shield_changes: Vec<ShieldChangeModel>,
    pub leg_breaks: Vec<LegBreakModel>,
}

#[flutter_rust_bridge::frb]
pub struct ShieldChangeModel {
    pub shield_time: f64,
    pub status_effect: StatusEffectEnum,
}

#[flutter_rust_bridge::frb]
pub enum StatusEffectEnum {
    Impact,
    Puncture,
    Slash,
    Heat,
    Cold,
    Electric,
    Toxin,
    Blast,
    Radiation,
    Gas,
    Magnetic,
    Viral,
    Corrosive,
    NoShield,
}

#[flutter_rust_bridge::frb(name = "LegBreak")]
pub struct LegBreakModel {
    pub leg_break_time: f64,
    pub leg_position: LegPositionEnum,
    pub leg_order: i32,
}

#[flutter_rust_bridge::frb(name = "LegPosition")]
pub enum LegPositionEnum {
    FrontLeft,
    FrontRight,
    BackLeft,
    BackRight,
}

#[flutter_rust_bridge::frb(name = "SquadMember")]
pub struct SquadMemberModel {
    pub member_name: String,
}

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    // Default utilities - feel free to customize
    flutter_rust_bridge::setup_default_user_utils();
}

/// Initializes the database by checking if the database file exists.
/// If it exists, just sets the database path; if not, creates a new database.
///
/// This function wraps the `initialize_database` function and handles errors by returning them
/// in a format suitable for Flutter. The initialization will either set the database path or
/// create the database if it does not exist.
///
/// # Arguments
/// - `path`: The path to the SQLite database file.
///
/// # Returns
/// - `Ok(())` if the database was successfully initialized (path set or created).
/// - `Err(error_message)` if there was an error initializing the database, with an error message describing the issue.
#[flutter_rust_bridge::frb(sync)]
pub fn initialize_db(path: String) -> Result<(), String> {
    let db_path = path.as_str();

    // Try to initialize the database (either create or set the path)
    initialize_database(db_path).map_err(|e| format!("Error initializing database: {}", e))
}

/// Fetches a run from the database based on the provided `run_id`.
///
/// This function wraps the `fetch_run_from_db` function and converts the data into a structured model
/// that can be returned to Flutter. The conversion process includes transforming nested structures such as
/// `TotalTimes`, `Phases`, `ShieldChanges`, `LegBreaks`, and `SquadMembers` into their corresponding models.
///
/// # Arguments
/// - `run_id`: The ID of the run to fetch from the database.
///
/// # Returns
/// - `Ok(RunModel)` if the run was successfully retrieved and converted into a structured model.
/// - `Err(error_message)` if there was an error fetching or converting the run, with an error message describing the issue.
#[flutter_rust_bridge::frb(sync)]
pub fn get_run_from_db(run_id: i32) -> Result<RunModel, String> {
    match fetch_run_from_db(run_id) {
        Ok(run) => {
            // Convert TotalTimes
            let total_times = TotalTimesModel {
                total_duration: run.total_times.total_time,
                total_flight_time: run.total_times.total_flight_time,
                total_shield_time: run.total_times.total_shield_time,
                total_leg_time: run.total_times.total_leg_time,
                total_body_time: run.total_times.total_body_time,
                total_pylon_time: run.total_times.total_pylon_time,
            };

            // Convert Phases
            let phases = run.phases.into_iter().map(|p| {
                // Convert ShieldChanges for each phase
                let shield_changes = p.shield_changes.into_iter().map(|sc| {
                    let status_effect = match sc.status_effect {
                        StatusEffect::Impact      => StatusEffectEnum::Impact,
                        StatusEffect::Puncture    => StatusEffectEnum::Puncture,
                        StatusEffect::Slash       => StatusEffectEnum::Slash,
                        StatusEffect::Heat        => StatusEffectEnum::Heat,
                        StatusEffect::Cold        => StatusEffectEnum::Cold,
                        StatusEffect::Electric    => StatusEffectEnum::Electric,
                        StatusEffect::Toxin       => StatusEffectEnum::Toxin,
                        StatusEffect::Blast       => StatusEffectEnum::Blast,
                        StatusEffect::Radiation   => StatusEffectEnum::Radiation,
                        StatusEffect::Gas         => StatusEffectEnum::Gas,
                        StatusEffect::Magnetic    => StatusEffectEnum::Magnetic,
                        StatusEffect::Viral       => StatusEffectEnum::Viral,
                        StatusEffect::Corrosive   => StatusEffectEnum::Corrosive,
                        StatusEffect::NoShield    => StatusEffectEnum::NoShield,
                    };

                    ShieldChangeModel {
                        shield_time: sc.shield_time,
                        status_effect,
                    }
                }).collect();

                // Convert LegBreaks for each phase
                let leg_breaks = p.leg_breaks.into_iter().map(|lb| {
                    let leg_position = match lb.leg_position {
                        LegPosition::FrontLeft  => LegPositionEnum::FrontLeft,
                        LegPosition::FrontRight => LegPositionEnum::FrontRight,
                        LegPosition::BackLeft   => LegPositionEnum::BackLeft,
                        LegPosition::BackRight  => LegPositionEnum::BackRight,
                    };

                    LegBreakModel {
                        leg_break_time: lb.leg_break_time,
                        leg_position,
                        leg_order: lb.leg_order,
                    }
                }).collect();

                PhaseModel {
                    phase_number: p.phase_number,
                    total_time: p.total_time,
                    total_shield_time: p.total_shield_time,
                    total_leg_time: p.total_leg_time,
                    total_body_kill_time: p.total_body_kill_time,
                    total_pylon_time: p.total_pylon_time,
                    shield_changes,
                    leg_breaks,
                }
            }).collect();

            // Convert SquadMembers
            let squad_members = run.squad_members.into_iter().map(|s| {
                SquadMemberModel {
                    member_name: s.member_name,
                }
            }).collect();

            Ok(RunModel {
                run_id: run.run_id,
                time_stamp: run.time_stamp,
                run_name: run.run_name,
                player_name: run.player_name,
                is_bugged_run: run.is_bugged_run,
                is_aborted_run: run.is_aborted_run,
                is_solo_run: run.is_solo_run,
                total_times,
                phases,
                squad_members,
            })
        }
        Err(e) => Err(format!("Error fetching run: {}", e)),
    }
}

/// Fetches the latest run ID.
///
/// This function wraps the `fetch_latest_run_id` function to make it accessible to Flutter.
/// It retrieves the most recent run ID from the database.
///
/// # Returns
/// - `Ok(Some(run_id))` if the latest run ID is successfully retrieved.
/// - `Ok(None)` if there are no runs in the database.
/// - `Err(error_message)` if there is an error fetching the latest run ID, with an error message describing the issue.
#[flutter_rust_bridge::frb(sync)]
pub fn get_latest_run_id() -> Result<Option<i32>, String> {
    fetch_latest_run_id().map_err(|e| format!("Error fetching latest run ID: {}", e))
}

/// Fetches the earliest run ID.
///
/// This function wraps the `fetch_earliest_run_id` function to make it accessible to Flutter.
/// It retrieves the first run ID from the database.
///
/// # Returns
/// - `Ok(Some(run_id))` if the earliest run ID is successfully retrieved.
/// - `Ok(None)` if there are no runs in the database.
/// - `Err(error_message)` if there is an error fetching the earliest run ID, with an error message describing the issue.
#[flutter_rust_bridge::frb(sync)]
pub fn get_earliest_run_id() -> Result<Option<i32>, String> {
    fetch_earliest_run_id().map_err(|e| format!("Error fetching first run ID: {}", e))
}

/// Fetches the previous run ID relative to a given run ID.
///
/// This function wraps the `fetch_previous_run_id` function to make it accessible to Flutter.
/// It retrieves the previous run ID based on the provided `current_run_id`.
///
/// # Arguments
/// - `current_run_id`: The ID of the current run to find the previous one.
///
/// # Returns
/// - `Ok(Some(run_id))` if the previous run ID is successfully retrieved.
/// - `Ok(None)` if there is no previous run for the given `current_run_id`.
/// - `Err(error_message)` if there is an error fetching the previous run ID, with an error message describing the issue.
#[flutter_rust_bridge::frb(sync)]
pub fn get_previous_run_id(current_run_id: i32) -> Result<Option<i32>, String> {
    fetch_previous_run_id(current_run_id)
        .map_err(|e| format!("Error fetching previous run ID: {}", e))
}

/// Fetches the next run ID relative to a given run ID.
///
/// This function wraps the `fetch_next_run_id` function to make it accessible to Flutter.
/// It retrieves the next run ID based on the provided `current_run_id`.
///
/// # Arguments
/// - `current_run_id`: The ID of the current run to find the next one.
///
/// # Returns
/// - `Ok(Some(run_id))` if the next run ID is successfully retrieved.
/// - `Ok(None)` if there is no next run for the given `current_run_id`.
/// - `Err(error_message)` if there is an error fetching the next run ID, with an error message describing the issue.
#[flutter_rust_bridge::frb(sync)]
pub fn get_next_run_id(current_run_id: i32) -> Result<Option<i32>, String> {
    fetch_next_run_id(current_run_id)
        .map_err(|e| format!("Error fetching next run ID: {}", e))
}

/// Checks whether a run exists with the given run ID.
///
/// This function wraps the `run_exists` function to make it accessible to Flutter.
/// It checks if a run exists in the database with the specified `run_id`.
///
/// # Arguments
/// - `run_id`: The ID of the run to check for existence.
///
/// # Returns
/// - `true` if the run exists in the database.
/// - `false` if the run does not exist or there was an error during the check.
#[flutter_rust_bridge::frb(sync)]
pub fn check_run_exists(run_id: i32) -> bool {
    match run_exists(run_id) {
        Ok(exists) => exists,
        Err(_) => false, // On error, default to `false`
    }
}

/// Represents the result of a delete operation.
#[flutter_rust_bridge::frb]
pub struct DeleteRunResult {
    pub success: bool,
    pub error: Option<String>, // Optional error message
}

/// Deletes a run by its ID from the database.
///
/// This function attempts to delete a run identified by its `run_id` from the database.
/// It returns a result that indicates whether the deletion was successful, 
/// and if not, provides a descriptive error message.
///
/// # Arguments
/// - `run_id`: The ID of the run to delete. This ID should correspond to an existing record in the database.
///
/// # Returns
/// - `DeleteRunResult { success: true, error: None }` if the run was successfully deleted.
/// - `DeleteRunResult { success: false, error: Some(error_message) }` if there was an error, including:
///     - `Run not found`: if no run with the given `run_id` exists in the database.
///     - A detailed error message describing the failure if an exception occurred during the deletion process.
/// 
/// # Errors
/// This function will return `DeleteRunResult` with an error message if:
/// - The database query fails (e.g., a connection issue).
/// - The specified `run_id` does not exist in the database, meaning no rows were deleted.
#[flutter_rust_bridge::frb(sync)]
pub fn delete_run_from_db(run_id: i32) -> DeleteRunResult {
    match delete_run(run_id) {
        Ok(true) => DeleteRunResult {
            success: true,
            error: None,
        },
        Ok(false) => DeleteRunResult {
            success: false,
            error: Some("Run not found".to_string()),
        },
        Err(e) => DeleteRunResult {
            success: false,
            error: Some(format!("Failed to delete run: {}", e)),
        },
    }
}

/// Checks whether the given run is the latest in the database.
///
/// This function wraps the `is_latest_run` function to make it accessible to Flutter.
/// It checks if the run with the given `run_id` is the latest run in the database.
///
/// # Arguments
/// - `run_id`: The ID of the run to check.
///
/// # Returns
/// - `true` if the run is the latest in the database.
/// - `false` if the run is not the latest or an error occurs during the check.
#[flutter_rust_bridge::frb(sync)]
pub fn check_if_latest_run(run_id: i32) -> bool {
    match is_latest_run(run_id) {
        Ok(is_latest) => is_latest,
        Err(_) => false, // On error, default to `false`
    }
}

/// Marks the given run as a favorite in the database.
///
/// This function wraps the `mark_as_favorite` function to make it accessible to Flutter.
/// It attempts to mark the run with the given `run_id` as a favorite. 
///
/// # Arguments
/// - `run_id`: The ID of the run to be marked as favorite.
///
/// # Returns
/// - `true` if the run was successfully marked as a favorite.
/// - `false` if an error occurs during the insertion.
#[flutter_rust_bridge::frb(sync)]
pub fn mark_run_as_favorite(run_id: i32) -> bool {
    match mark_as_favorite(run_id) {
        Ok(_) => true,
        Err(_) => false, // On error, default to `false`
    }
}

/// Removes the given run from the favorites list in the database.
///
/// This function wraps the `unmark_as_favorite` function to make it accessible to Flutter.
/// It attempts to remove the run with the given `run_id` from the favorites list.
///
/// # Arguments
/// - `run_id`: The ID of the run to be removed from favorites.
///
/// # Returns
/// - `true` if the run was successfully removed from favorites.
/// - `false` if an error occurs during the removal.
#[flutter_rust_bridge::frb(sync)]
pub fn remove_run_from_favorites(run_id: i32) -> bool {
    match unmark_as_favorite(run_id) {
        Ok(_) => true,
        Err(_) => false, // On error, default to `false`
    }
}

/// Updates the name of the given run in the database.
///
/// This function wraps the `edit_run_name` function to make it accessible to Flutter.
/// It attempts to update the `run_name` for the run with the given `run_id`.
///
/// # Arguments
/// - `run_id`: The ID of the run to update.
/// - `new_name`: The new name to set for the run.
///
/// # Returns
/// - `true` if the run name was successfully updated.
/// - `false` if an error occurs during the update.
#[flutter_rust_bridge::frb(sync)]
pub fn update_run_name(run_id: i32, new_name: String) -> bool {
    match edit_run_name(run_id, &new_name) {
        Ok(_) => true,
        Err(_) => false, // On error, default to `false`
    }
}
