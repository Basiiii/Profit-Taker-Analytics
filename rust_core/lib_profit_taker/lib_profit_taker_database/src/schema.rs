//! This module contains the SQL schema used to set up the `SQLite` database for the application.
//!
//! It includes SQL statements for creating and initializing the necessary database tables, 
//! along with inserting default values for specific tables like `leg_position` and `status_effects`.
//!
//! The schema defines several tables related to a "run" in the application, including:
//! - `runs`: Stores information about each run, including timestamps, player details, and run statuses.
//! - `phases`: Stores details about each phase within a run, including phase times and related data.
//! - `squad_members`: Stores information about squad members involved in each run.
//! - `leg_position`: Contains the possible leg positions in a run, such as front-left and back-right.
//! - `leg_breaks`: Stores data about leg breaks occurring during a run's phases.
//! - `status_effects`: Contains predefined status effects that can be applied during runs.
//! - `shield_changes`: Tracks the shield time changes during a run, linked to status effects and phases.
//!
//! The SQL statements in this module are stored as a constant string (`SCHEMA_SQL`), which is later 
//! executed to initialize the database schema.

pub const SCHEMA_SQL: &str = "
-- Create runs table
CREATE TABLE runs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    time_stamp INTEGER NOT NULL UNIQUE,  -- Store as Unix timestamp
    run_name TEXT NOT NULL,
    player_name TEXT NOT NULL,
    bugged_run BOOLEAN NOT NULL,
    aborted_run BOOLEAN NOT NULL,
    solo_run BOOLEAN NOT NULL,
    total_time REAL NOT NULL,
    total_flight_time REAL NOT NULL,
    total_shield_time REAL NOT NULL,
    total_leg_time REAL NOT NULL,
    total_body_time REAL NOT NULL,
    total_pylon_time REAL NOT NULL
);

-- Create phases table
CREATE TABLE phases (
    run_id INTEGER NOT NULL,
    phase_number INTEGER NOT NULL,
    phase_time REAL NOT NULL,
    shield_time REAL,
    leg_time REAL NOT NULL,
    body_kill_time REAL NOT NULL,
    pylon_time REAL,
    PRIMARY KEY (run_id, phase_number),
    FOREIGN KEY (run_id) REFERENCES runs (id) ON DELETE CASCADE
);

-- Create squad_members table
CREATE TABLE squad_members (
    run_id INTEGER NOT NULL,
    member_name TEXT NOT NULL,
    PRIMARY KEY (run_id, member_name),
    FOREIGN KEY (run_id) REFERENCES runs (id) ON DELETE CASCADE
);

-- Create leg_position table
CREATE TABLE leg_position (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL
);

-- Insert default leg positions
INSERT INTO leg_position (id, name) VALUES
(1, 'FL'), -- Front Left
(2, 'FR'), -- Front Right
(3, 'BL'), -- Back Left
(4, 'BR'); -- Back Right

-- Create leg_breaks table
CREATE TABLE leg_breaks (
    run_id INTEGER NOT NULL,
    phase_number INTEGER NOT NULL,
    break_time INTEGER NOT NULL,
    break_order INTEGER NOT NULL,
    leg_position_id INTEGER NOT NULL,
    PRIMARY KEY (run_id, phase_number, leg_position_id),
    FOREIGN KEY (run_id, phase_number) REFERENCES phases (run_id, phase_number) ON DELETE CASCADE,
    FOREIGN KEY (leg_position_id) REFERENCES leg_position (id) ON DELETE CASCADE
);

-- Create status_effects table
CREATE TABLE status_effects (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL
);

-- Insert default status effects
INSERT INTO status_effects (id, name) VALUES
(1, 'Impact'),
(2, 'Puncture'),
(3, 'Slash'),
(4, 'Heat'),
(5, 'Cold'),
(6, 'Electric'),
(7, 'Toxin'),
(8, 'Blast'),
(9, 'Radiation'),
(10, 'Gas'),
(11, 'Magnetic'),
(12, 'Viral'),
(13, 'Corrosive');

-- Create shield_changes table
CREATE TABLE shield_changes (
    run_id INTEGER NOT NULL,
    phase_number INTEGER NOT NULL,
    shield_time INTEGER NOT NULL,
    shield_order INTEGER NOT NULL,
    status_effect_id INTEGER NOT NULL,
    FOREIGN KEY (status_effect_id) REFERENCES status_effects (id) ON DELETE CASCADE,
    FOREIGN KEY (run_id, phase_number) REFERENCES phases (run_id, phase_number) ON DELETE CASCADE
);

-- Create favorites table
CREATE TABLE favorites (
    run_id INTEGER PRIMARY KEY,
    favorited_at INTEGER NOT NULL,  -- Store as Unix timestamp
    FOREIGN KEY (run_id) REFERENCES runs (id) ON DELETE CASCADE
);

-- Index for sorting
CREATE INDEX idx_runs_name ON runs(run_name);
CREATE INDEX idx_runs_time ON runs(time_stamp);
CREATE INDEX idx_runs_total_time ON runs(total_time);

-- Index for joins
CREATE INDEX idx_favorites_run_id ON favorites(run_id);

-- Composite index for sorting and filtering
CREATE INDEX idx_runs_sorting ON runs(time_stamp DESC, total_time DESC, run_name);

-- Index to optimize filtering of solo, non-bugged, non-aborted runs
CREATE INDEX idx_runs_solo_bugged_aborted ON runs (solo_run, bugged_run, aborted_run);
";
