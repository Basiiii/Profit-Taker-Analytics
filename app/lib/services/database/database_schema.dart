import 'package:sqflite/sqflite.dart';

Future<void> createRunsTable(Database db) async {
  await db.execute('''
    CREATE TABLE runs (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      time_stamp TIMESTAMP NOT NULL,
      name TEXT,
      player_name TEXT,
      bugged_run BOOLEAN,
      aborted_run BOOLEAN,
      solo_run BOOLEAN,
      total_time REAL,
      total_flight REAL,
      total_shield REAL,
      total_leg REAL,
      total_body REAL,
      total_pylon REAL
    )
  ''');
}

Future<void> createPhasesTable(Database db) async {
  await db.execute('''
    CREATE TABLE phases (
      run_id INTEGER,
      phase_number INTEGER,
      total_time REAL,
      total_shield REAL NULL,
      total_leg REAL,
      total_body_kill REAL,
      total_pylon REAL NULL,
      PRIMARY KEY (run_id, phase_number),
      FOREIGN KEY (run_id) REFERENCES runs (id) ON DELETE CASCADE
    )
  ''');
}

Future<void> createSquadMembersTable(Database db) async {
  await db.execute('''
    CREATE TABLE squad_members (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      run_id INTEGER,
      member_name TEXT,
      FOREIGN KEY (run_id) REFERENCES runs (id) ON DELETE CASCADE
    )
  ''');
}

Future<void> createLegBreaksTable(Database db) async {
  await db.execute('''
    CREATE TABLE leg_breaks (
      run_id INTEGER,
      phase_number INTEGER,
      leg_position INTEGER,
      break_time INTEGER,
      break_order INTEGER,
      PRIMARY KEY (run_id, phase_number, leg_position),
      FOREIGN KEY (run_id, phase_number) REFERENCES phases (run_id, phase_number) ON DELETE CASCADE
    )
  ''');
}

Future<void> createStatusEffectsTable(Database db) async {
  await db.execute('''
    CREATE TABLE status_effects (
      id INTEGER PRIMARY KEY,
      name TEXT NOT NULL
    )
  ''');
}

Future<void> insertDefaultStatusEffects(Database db) async {
  const statusEffects = [
    'Impact',
    'Puncture',
    'Slash',
    'Heat',
    'Cold',
    'Electric',
    'Toxin',
    'Blast',
    'Corrosive',
    'Gas',
    'Magnetic',
    'Radiation',
    'Viral',
    'Void',
    'Tau',
    'True'
  ];
  for (int i = 0; i < statusEffects.length; i++) {
    await db.insert('status_effects', {'id': i + 1, 'name': statusEffects[i]});
  }
}

Future<void> createShieldChangesTable(Database db) async {
  await db.execute('''
    CREATE TABLE shield_changes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      shield_time INTEGER,
      status_effect_id INTEGER,
      run_id INTEGER,
      phase_number INTEGER,
      FOREIGN KEY (status_effect_id) REFERENCES status_effects (id) ON DELETE SET NULL,
      FOREIGN KEY (run_id, phase_number) REFERENCES phases (run_id, phase_number) ON DELETE CASCADE
    )
  ''');
}

Future<void> createLegPositionTable(Database db) async {
  await db.execute('''
    CREATE TABLE leg_position (
      id INTEGER PRIMARY KEY,
      name TEXT NOT NULL
    )
  ''');
}

Future<void> insertDefaultLegPositions(Database db) async {
  const legPositions = [
    'FR', // Front Right
    'FL', // Front Left
    'BR', // Back Right
    'BL' // Back Left
  ];
  for (int i = 0; i < legPositions.length; i++) {
    await db.insert('leg_position', {'id': i + 1, 'name': legPositions[i]});
  }
}
