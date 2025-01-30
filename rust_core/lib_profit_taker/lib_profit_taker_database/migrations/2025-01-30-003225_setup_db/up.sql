-- Create runs table
CREATE TABLE runs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    time_stamp TIMESTAMP NOT NULL,
    run_name TEXT,
    player_name TEXT,
    bugged_run BOOLEAN,
    aborted_run BOOLEAN,
    solo_run BOOLEAN,
    total_time REAL,
    total_flight_time REAL,
    total_shield_time REAL,
    total_leg_time REAL,
    total_body_time REAL,
    total_pylon_time REAL
);

-- Create phases table
CREATE TABLE phases (
    run_id INTEGER,
    phase_number INTEGER,
    phase_time REAL,
    shield_time REAL NULL,
    leg_time REAL,
    body_kill_time REAL,
    pylon_time REAL NULL,
    PRIMARY KEY (run_id, phase_number),
    FOREIGN KEY (run_id) REFERENCES runs (id) ON DELETE CASCADE
);

-- Create squad_members table
CREATE TABLE squad_members (
    run_id INTEGER,
    member_name TEXT,
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
    run_id INTEGER,
    phase_number INTEGER,
    break_time INTEGER,
    break_order INTEGER,
    leg_position_id INTEGER,
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
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    shield_time INTEGER,
    status_effect_id INTEGER,
    run_id INTEGER,
    phase_number INTEGER,
    FOREIGN KEY (status_effect_id) REFERENCES status_effects (id) ON DELETE SET NULL,
    FOREIGN KEY (run_id, phase_number) REFERENCES phases (run_id, phase_number) ON DELETE CASCADE
);

-- Create player_pb table
CREATE TABLE player_pb (
    pb_run_id INTEGER PRIMARY KEY,
    pb_total_time REAL,
    pb_total_flight_time REAL,
    pb_total_shield_time REAL,
    pb_total_leg_time REAL,
    pb_total_body_time REAL,
    pb_total_pylon_time REAL,
    FOREIGN KEY (pb_run_id) REFERENCES runs (id) ON DELETE CASCADE
);
