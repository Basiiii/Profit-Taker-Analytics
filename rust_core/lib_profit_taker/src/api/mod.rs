use crate::utils::json_to_db::initialize_json_converter;
use lib_profit_taker_core::{
    LegBreak, LegPosition, Phase, Run, ShieldChange, SquadMember, StatusEffect, TotalTimes,
};
use lib_profit_taker_database::{
    connection::initialize_database,
    queries::{
        check_is_pb::is_pb, delete_favorite::unmark_as_favorite, delete_run::delete_run,
        edit_run_name::edit_run_name, fetch_analytics_data::fetch_analytics_runs,
        fetch_average_times::fetch_average_times_query, fetch_earliest_run::fetch_earliest_run_id,
        fetch_latest_run::fetch_latest_run_id, fetch_next_run::fetch_next_run_id,
        fetch_paginated_runs::fetch_paginated_runs_query, fetch_pb_times::fetch_pb_times,
        fetch_previous_run::fetch_previous_run_id, fetch_run_data::fetch_run_from_db,
        fetch_second_best_times::fetch_second_best_times, insert_favorite::mark_as_favorite,
        is_favorite::is_run_favorite, latest_run::is_latest_run, run_exists::run_exists,
    },
};
use lib_profit_taker_parser::{cli::pretty_print_run, initialize_parser};

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
    pub shield_order: i32,
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
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
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

/// Initializes the JSON converter by setting the storage folder for JSON files.
/// This function wraps the `initialize_json_converter` function and handles errors by returning them
/// in a format suitable for Flutter. The initialization will set the storage folder for JSON files.
///
/// # Arguments
/// - `storage_folder`: The path to the folder where JSON files are stored.
///
/// # Returns
///
/// - `Ok(())` if the JSON converter was successfully initialized.
/// - `Err(error_message)` if there was an error initializing the converter, with an error message describing the issue.
#[flutter_rust_bridge::frb(dart_async)]
pub fn initialize_converter(storage_folder: String) -> Result<(), String> {
    let storage_folder = storage_folder.as_str();
    // Try to initialize the JSON converter
    initialize_json_converter(storage_folder)
        .map_err(|e| format!("Error initializing converter: {}", e))
}

/// Fetches a run from the database based on the provided `run_id` and ensures it adheres to the expected structure.
///
/// This function retrieves a run from the database and converts it into a structured `RunModel`. It ensures that:
/// - There are always exactly 4 phases, filling in missing phases with default values if necessary.
/// - Each phase contains the required fields based on its position:
///   - **Phase 1**: Shields, legs, body, and pylon times.
///   - **Phase 2**: Legs and body times only.
///   - **Phase 3**: Shields, legs, body, and pylon times.
///   - **Phase 4**: Shields, legs, and body times.
/// - Missing shield changes are filled with a default shield (0.0s time, `NoShield` status).
/// - Missing leg positions are filled with all four positions (FrontLeft, FrontRight, BackLeft, BackRight) with 0.0s time.
///
/// # Arguments
/// - `run_id`: The ID of the run to fetch from the database.
///
/// # Returns
/// - `Ok(RunModel)` if the run was successfully retrieved and converted into a structured model.
/// - `Err(String)` if there was an error fetching or converting the run, with an error message describing the issue.
///
/// # Example
/// ```
/// let run = get_run_from_db(123);
/// match run {
///     Ok(run_model) => println!("Run fetched successfully: {:?}", run_model),
///     Err(e) => println!("Error fetching run: {}", e),
/// }
/// ```
///
/// # Data Structure
/// The returned `RunModel` contains:
/// - General run information (ID, timestamp, name, etc.).
/// - Total times for the run (duration, flight time, shield time, etc.).
/// - A vector of exactly 4 `PhaseModel` instances, each containing:
///   - Phase-specific times (total time, shield time, leg time, etc.).
///   - Shield changes (if applicable for the phase).
///   - Leg breaks (all four positions, even if missing in the database).
/// - A list of squad members.
///
/// # Error Handling
/// - If the database fetch fails, an error message is returned.
/// - If the run exists but has invalid data (e.g., phases outside the 1-4 range), those phases are ignored and replaced with defaults.
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

            // Process phases to ensure exactly 4 with required fields
            let existing_phases: std::collections::HashMap<_, _> = run
                .phases
                .into_iter()
                .filter(|p| (1..=4).contains(&p.phase_number))
                .map(|p| (p.phase_number, p))
                .collect();

            let phases = (1..=4)
                .map(|phase_number| {
                    let mut phase = if let Some(db_phase) = existing_phases.get(&phase_number) {
                        // Convert shield changes
                        let shield_changes = db_phase
                            .shield_changes
                            .iter()
                            .map(|sc| {
                                let status_effect = match sc.status_effect {
                                    StatusEffect::Impact => StatusEffectEnum::Impact,
                                    StatusEffect::Puncture => StatusEffectEnum::Puncture,
                                    StatusEffect::Slash => StatusEffectEnum::Slash,
                                    StatusEffect::Heat => StatusEffectEnum::Heat,
                                    StatusEffect::Cold => StatusEffectEnum::Cold,
                                    StatusEffect::Electric => StatusEffectEnum::Electric,
                                    StatusEffect::Toxin => StatusEffectEnum::Toxin,
                                    StatusEffect::Blast => StatusEffectEnum::Blast,
                                    StatusEffect::Radiation => StatusEffectEnum::Radiation,
                                    StatusEffect::Gas => StatusEffectEnum::Gas,
                                    StatusEffect::Magnetic => StatusEffectEnum::Magnetic,
                                    StatusEffect::Viral => StatusEffectEnum::Viral,
                                    StatusEffect::Corrosive => StatusEffectEnum::Corrosive,
                                    StatusEffect::NoShield => StatusEffectEnum::NoShield,
                                };
                                ShieldChangeModel {
                                    shield_time: sc.shield_time,
                                    status_effect,
                                    shield_order: sc.shield_order,
                                }
                            })
                            .collect::<Vec<_>>();

                        // Convert leg breaks
                        let leg_breaks = db_phase
                            .leg_breaks
                            .iter()
                            .map(|lb| {
                                let leg_position = match lb.leg_position {
                                    LegPosition::FrontLeft => LegPositionEnum::FrontLeft,
                                    LegPosition::FrontRight => LegPositionEnum::FrontRight,
                                    LegPosition::BackLeft => LegPositionEnum::BackLeft,
                                    LegPosition::BackRight => LegPositionEnum::BackRight,
                                };
                                LegBreakModel {
                                    leg_break_time: lb.leg_break_time,
                                    leg_position,
                                    leg_order: lb.leg_order,
                                }
                            })
                            .collect::<Vec<_>>();

                        PhaseModel {
                            phase_number: db_phase.phase_number,
                            total_time: db_phase.total_time,
                            total_shield_time: db_phase.total_shield_time,
                            total_leg_time: db_phase.total_leg_time,
                            total_body_kill_time: db_phase.total_body_kill_time,
                            total_pylon_time: db_phase.total_pylon_time,
                            shield_changes,
                            leg_breaks,
                        }
                    } else {
                        // Create default phase based on phase number
                        let (has_shields, has_pylon) = match phase_number {
                            1 => (true, true),
                            2 => (false, false),
                            3 => (true, true),
                            4 => (true, false),
                            _ => unreachable!(),
                        };

                        let shield_changes = if has_shields {
                            vec![ShieldChangeModel {
                                shield_time: 0.0,
                                status_effect: StatusEffectEnum::NoShield,
                                shield_order: 0,
                            }]
                        } else {
                            Vec::new()
                        };

                        let leg_breaks = vec![
                            LegPositionEnum::FrontLeft,
                            LegPositionEnum::FrontRight,
                            LegPositionEnum::BackLeft,
                            LegPositionEnum::BackRight,
                        ]
                        .iter()
                        .map(|&leg_pos| LegBreakModel {
                            leg_break_time: 0.0,
                            leg_position: leg_pos,
                            leg_order: 0,
                        })
                        .collect();

                        PhaseModel {
                            phase_number,
                            total_time: 0.0,
                            total_shield_time: 0.0,
                            total_leg_time: 0.0,
                            total_body_kill_time: 0.0,
                            total_pylon_time: 0.0,
                            shield_changes,
                            leg_breaks,
                        }
                    };

                    // Ensure required shield changes for phases 1, 3, 4
                    if [1, 3, 4].contains(&phase_number) && phase.shield_changes.is_empty() {
                        phase.shield_changes.push(ShieldChangeModel {
                            shield_time: 0.0,
                            status_effect: StatusEffectEnum::NoShield,
                            shield_order: 0,
                        });
                    }

                    // Ensure all leg positions are present
                    let existing_positions: std::collections::HashSet<_> =
                        phase.leg_breaks.iter().map(|lb| lb.leg_position).collect();

                    for &required_pos in &[
                        LegPositionEnum::FrontLeft,
                        LegPositionEnum::FrontRight,
                        LegPositionEnum::BackLeft,
                        LegPositionEnum::BackRight,
                    ] {
                        if !existing_positions.contains(&required_pos) {
                            phase.leg_breaks.push(LegBreakModel {
                                leg_break_time: 0.0,
                                leg_position: required_pos,
                                leg_order: 0,
                            });
                        }
                    }

                    phase
                })
                .collect();

            // Convert SquadMembers
            let squad_members = run
                .squad_members
                .into_iter()
                .map(|s| SquadMemberModel {
                    member_name: s.member_name,
                })
                .collect();

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
    fetch_next_run_id(current_run_id).map_err(|e| format!("Error fetching next run ID: {}", e))
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

/// Checks if a `Run` is marked as a favorite and exposes it to Flutter via flutter_rust_bridge.
///
/// This function wraps the `is_run_favorite` function to make it accessible to Flutter.
///
/// # Arguments
/// - `run_id`: The ID of the run to check.
///
/// # Returns
/// - `true` if the run is marked as a favorite.
/// - `false` if an error occurs during the check.
#[flutter_rust_bridge::frb(sync)]
pub fn check_run_favorite(run_id: i32) -> bool {
    match is_run_favorite(run_id) {
        Ok(is_favorite) => is_favorite,
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

/// Enum representing the possible outcomes of parser initialization.
/// This enum includes a success case and specific error cases, without error messages.
#[flutter_rust_bridge::frb]
pub enum InitializeParserOutcome {
    /// Success variant, indicating successful parser initialization.
    Success,

    /// Error variant for issues with the environment variable.
    EnvironmentVariableError,

    /// Error variant for issues with opening the log file.
    FileOpenError,

    /// Error variant for issues with seeking the file.
    FileSeekError,

    /// Error variant for issues with spawning the thread.
    ThreadSpawnError,

    /// Generic error variant for unknown issues.
    UnknownError,
}

/// Wrapper function for calling `initialize_parser` and returning a result to Dart.
/// This function handles errors from `initialize_parser` and maps them to a specific error type.
/// It returns `InitializeParserOutcome`, which includes both success and error outcomes.
///
/// # Returns:
/// - `Success`: Indicates that the parser was initialized successfully.
/// - `Error`: Represents different types of errors during initialization, without error messages.
#[flutter_rust_bridge::frb(sync)]
pub fn initialize_profit_taker_parser() -> InitializeParserOutcome {
    match initialize_parser() {
        // If the parser is initialized successfully, return the success variant.
        Ok(_) => InitializeParserOutcome::Success,

        // If there is an error, map it to a specific error variant.
        Err(e) => {
            let error_message = e.to_string();

            // Check the error message and map to the appropriate error variant.
            if error_message.contains("can't find path to log") {
                InitializeParserOutcome::EnvironmentVariableError
            } else if error_message.contains("No such file or directory") {
                InitializeParserOutcome::FileOpenError
            } else if error_message.contains("Error seeking to start of file") {
                InitializeParserOutcome::FileSeekError
            } else if error_message.contains("Error starting the parser") {
                InitializeParserOutcome::ThreadSpawnError
            } else {
                // For any unexpected error, return the generic unknown error.
                InitializeParserOutcome::UnknownError
            }
        }
    }
}

/// Retrieves and pretty-prints the details of a Profit-Taker run.
///
/// This function wraps the `pretty_print_run` function to make it accessible to Flutter.
/// It converts a `RunModel` instance into a `Run` and returns a formatted string.
///
/// # Arguments
/// - `run_model`: The `RunModel` instance to convert and format.
///
/// # Returns
/// - A `String` containing the formatted Profit-Taker run details.
#[flutter_rust_bridge::frb(sync)]
pub fn get_pretty_printed_run(run_model: RunModel) -> String {
    let run = Run {
        run_id: run_model.run_id,
        time_stamp: run_model.time_stamp,
        run_name: run_model.run_name,
        player_name: run_model.player_name,
        is_bugged_run: run_model.is_bugged_run,
        is_aborted_run: run_model.is_aborted_run,
        is_solo_run: run_model.is_solo_run,
        total_times: TotalTimes {
            total_time: run_model.total_times.total_duration,
            total_flight_time: run_model.total_times.total_flight_time,
            total_shield_time: run_model.total_times.total_shield_time,
            total_leg_time: run_model.total_times.total_leg_time,
            total_body_time: run_model.total_times.total_body_time,
            total_pylon_time: run_model.total_times.total_pylon_time,
        },
        phases: run_model
            .phases
            .into_iter()
            .map(|phase| Phase {
                phase_number: phase.phase_number,
                total_time: phase.total_time,
                total_shield_time: phase.total_shield_time,
                total_leg_time: phase.total_leg_time,
                total_body_kill_time: phase.total_body_kill_time,
                total_pylon_time: phase.total_pylon_time,
                shield_changes: phase
                    .shield_changes
                    .into_iter()
                    .map(|shield| ShieldChange {
                        shield_time: shield.shield_time,
                        status_effect: match shield.status_effect {
                            StatusEffectEnum::Impact => StatusEffect::Impact,
                            StatusEffectEnum::Puncture => StatusEffect::Puncture,
                            StatusEffectEnum::Slash => StatusEffect::Slash,
                            StatusEffectEnum::Heat => StatusEffect::Heat,
                            StatusEffectEnum::Cold => StatusEffect::Cold,
                            StatusEffectEnum::Electric => StatusEffect::Electric,
                            StatusEffectEnum::Toxin => StatusEffect::Toxin,
                            StatusEffectEnum::Blast => StatusEffect::Blast,
                            StatusEffectEnum::Radiation => StatusEffect::Radiation,
                            StatusEffectEnum::Gas => StatusEffect::Gas,
                            StatusEffectEnum::Magnetic => StatusEffect::Magnetic,
                            StatusEffectEnum::Viral => StatusEffect::Viral,
                            StatusEffectEnum::Corrosive => StatusEffect::Corrosive,
                            StatusEffectEnum::NoShield => StatusEffect::NoShield,
                        },
                        shield_order: shield.shield_order,
                    })
                    .collect(),
                leg_breaks: phase
                    .leg_breaks
                    .into_iter()
                    .map(|leg| LegBreak {
                        leg_break_time: leg.leg_break_time,
                        leg_position: match leg.leg_position {
                            LegPositionEnum::FrontLeft => LegPosition::FrontLeft,
                            LegPositionEnum::FrontRight => LegPosition::FrontRight,
                            LegPositionEnum::BackLeft => LegPosition::BackLeft,
                            LegPositionEnum::BackRight => LegPosition::BackRight,
                        },
                        leg_order: leg.leg_order,
                    })
                    .collect(),
            })
            .collect(),
        squad_members: run_model
            .squad_members
            .into_iter()
            .map(|member| SquadMember {
                member_name: member.member_name,
            })
            .collect(),
    };

    pretty_print_run(&run)
}

/// Checks whether a run is the Personal Best (PB).
///
/// # Arguments
/// - `run_id`: The ID of the run to check.
///
/// # Returns
/// - `true` if the run is the PB.
/// - `false` if the run is not the PB or if an error occurs.
#[flutter_rust_bridge::frb(sync)]
pub fn is_run_pb(run_id: i32) -> bool {
    match is_pb(run_id) {
        Ok(is_pb) => is_pb,
        Err(_) => false, // Default to `false` on error
    }
}
/// Represents the times of a run for FFI compatibility.
#[flutter_rust_bridge::frb]
pub struct RunTimesResponse {
    pub run_id: i32,
    pub total_time: f64,
    pub total_flight_time: f64,
    pub total_shield_time: f64,
    pub total_leg_time: f64,
    pub total_body_time: f64,
    pub total_pylon_time: f64,
}

/// Fetches the times of the PB run.
///
/// # Returns
/// - `Some(RunTimesResponse)` if the PB run exists.
/// - `None` if no PB run is found.
#[flutter_rust_bridge::frb]
pub fn get_pb_times() -> Option<RunTimesResponse> {
    match fetch_pb_times() {
        Ok(Some(pb_times)) => Some(RunTimesResponse {
            run_id: pb_times.run_id,
            total_time: pb_times.total_time,
            total_flight_time: pb_times.total_flight_time,
            total_shield_time: pb_times.total_shield_time,
            total_leg_time: pb_times.total_leg_time,
            total_body_time: pb_times.total_body_time,
            total_pylon_time: pb_times.total_pylon_time,
        }),
        _ => None, // Return `None` on error or if no PB run exists
    }
}

/// Fetches the times of the second-best run.
///
/// # Returns
/// - `Some(RunTimesResponse)` if the second-best run exists.
/// - `None` if no second-best run is found.
#[flutter_rust_bridge::frb]
pub fn get_second_best_times() -> Option<RunTimesResponse> {
    match fetch_second_best_times() {
        Ok(Some(second_best_times)) => Some(RunTimesResponse {
            run_id: second_best_times.run_id,
            total_time: second_best_times.total_time,
            total_flight_time: second_best_times.total_flight_time,
            total_shield_time: second_best_times.total_shield_time,
            total_leg_time: second_best_times.total_leg_time,
            total_body_time: second_best_times.total_body_time,
            total_pylon_time: second_best_times.total_pylon_time,
        }),
        _ => None, // Return `None` on error or if no second-best run exists
    }
}

#[flutter_rust_bridge::frb]
pub struct RunListItemModel {
    pub id: i32,
    pub name: String,
    pub date: i64,
    pub duration: f64,
    pub is_bugged: bool,
    pub is_aborted: bool,
    pub is_favorite: bool,
}

#[flutter_rust_bridge::frb]
pub struct PaginationRequest {
    pub page: i32,
    pub page_size: i32,
    pub sort_column: String,
    pub sort_ascending: bool,
}

#[flutter_rust_bridge::frb]
pub struct PaginatedRunsResponse {
    pub runs: Vec<RunListItemModel>,
    pub total_count: i32,
}

#[flutter_rust_bridge::frb]
pub fn get_paginated_runs(
    page: i32,
    page_size: i32,
    sort_column: String,
    sort_ascending: bool,
) -> Result<PaginatedRunsResponse, String> {
    // Call the query function to get paginated runs, handling errors and converting them to String
    let (runs, total_count) =
        fetch_paginated_runs_query(page, page_size, &sort_column, sort_ascending)
            .map_err(|e| e.to_string())?; // Convert the rusqlite error to String

    // Convert each `Run` to `RunListItemModel`
    let runs_model: Vec<RunListItemModel> = runs
        .into_iter()
        .map(|run| RunListItemModel {
            id: run.run_id,
            name: run.run_name,
            date: run.time_stamp,
            duration: run.total_times.total_time,
            is_bugged: run.is_bugged_run,
            is_aborted: run.is_aborted_run,
            is_favorite: false,
        })
        .collect();

    // Construct the response with the fetched runs and total count
    let response = PaginatedRunsResponse {
        runs: runs_model,
        total_count,
    };

    Ok(response)
}

// Struct representing the different time types, redefined for Flutter FFI compatibility
#[flutter_rust_bridge::frb]
pub struct TimeTypeModel {
    pub total_time: f64,
    pub flight_time: f64,
    pub shield_time: f64,
    pub leg_time: f64,
    pub body_time: f64,
    pub pylon_time: f64,
}

// This function fetches the average times and returns them as TimeTypeModel
#[flutter_rust_bridge::frb(sync)]
pub fn get_average_times() -> Option<TimeTypeModel> {
    match fetch_average_times_query() {
        Ok((
            avg_total_time,
            avg_flight_time,
            avg_shield_time,
            avg_leg_time,
            avg_body_time,
            avg_pylon_time,
        )) => Some(TimeTypeModel {
            total_time: avg_total_time,
            flight_time: avg_flight_time,
            shield_time: avg_shield_time,
            leg_time: avg_leg_time,
            body_time: avg_body_time,
            pylon_time: avg_pylon_time,
        }),
        Err(_) => None, // Return None if there's an error fetching the averages
    }
}

// Struct representing the different time types, redefined for Flutter FFI compatibility
#[flutter_rust_bridge::frb]
pub struct AnalyticsRunTotalTimesModel {
    pub id: i32,
    pub run_name: String,
    pub total_time: f64,
    pub total_flight_time: f64,
    pub total_shield_time: f64,
    pub total_leg_time: f64,
    pub total_body_time: f64,
    pub total_pylon_time: f64,
}

// This function fetches the analytics runs and returns them as a list of AnalyticsRunTotalTimesModel
#[flutter_rust_bridge::frb(sync)]
pub fn get_analytics_runs(limit: i32) -> Vec<AnalyticsRunTotalTimesModel> {
    match fetch_analytics_runs(limit) {
        Ok(runs) => runs
            .into_iter()
            .map(|run| AnalyticsRunTotalTimesModel {
                id: run.id,
                run_name: run.run_name,
                total_time: run.total_time,
                total_flight_time: run.total_flight_time,
                total_shield_time: run.total_shield_time,
                total_leg_time: run.total_leg_time,
                total_body_time: run.total_body_time,
                total_pylon_time: run.total_pylon_time,
            })
            .collect(),
        Err(_) => Vec::new(), // Return an empty list if there's an error
    }
}
