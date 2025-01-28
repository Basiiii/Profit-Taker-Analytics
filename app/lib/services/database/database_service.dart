import 'package:flutter/foundation.dart';
import 'package:profit_taker_analyzer/models/phases.dart';
import 'package:profit_taker_analyzer/models/run_data.dart';
import 'package:profit_taker_analyzer/services/database/database_schema.dart';
import 'package:profit_taker_analyzer/services/database/utils/fetch_data/fetch_phases.dart';
import 'package:profit_taker_analyzer/services/database/utils/fetch_data/fetch_run_details.dart';
import 'package:profit_taker_analyzer/services/database/utils/fetch_data/fetch_squad_members.dart';
import 'package:profit_taker_analyzer/services/database/utils/parsing/total_times_parser.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// RunService to manage the runs and their navigation
class DatabaseService {
  // Database instance
  late Database _database;

  // Singleton pattern for the DatabaseService
  static final DatabaseService _instance = DatabaseService._internal();

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  // Initializes the Database
  Future<void> initialize() async {
    final databasePath = await getDatabasesPath();
    if (kDebugMode) {
      print(databasePath);
    }
    final path = join(databasePath, 'runs.db');
    _database = await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  // Returns the database instance after ensuring it's initialized
  Future<Database> getDatabase() async {
    return _database;
  }

  /// Creates the necessary tables in the database.
  Future<void> _onCreate(Database db, int version) async {
    await createRunsTable(db);
    await createPhasesTable(db);
    await createSquadMembersTable(db);
    await createLegBreaksTable(db);
    await createStatusEffectsTable(db);
    await insertDefaultStatusEffects(db);
    await createShieldChangesTable(db);
    await createLegPositionTable(db);
    await insertDefaultLegPositions(db);
  }

  /// Fetches the next run ID.
  ///
  /// Retrieves the ID of the next run in the database relative
  /// to the current run ID.
  ///
  /// [currentRunId] - The ID of the current run.
  ///
  /// Returns:
  /// - An [int] representing the ID of the next run, or null if no next run exists.
  Future<int?> getNextRunId(int currentRunId) async {
    final result = await _database.query(
      'runs',
      columns: ['id'],
      where: 'id > ?',
      whereArgs: [currentRunId],
      orderBy: 'id ASC',
      limit: 1,
    );

    return result.isEmpty ? null : result.first['id'] as int;
  }

  /// Fetches the previous run ID.
  ///
  /// Retrieves the ID of the previous run in the database relative
  /// to the current run ID.
  ///
  /// [currentRunId] - The ID of the current run.
  ///
  /// Returns:
  /// - An [int] representing the ID of the previous run, or null if no previous run exists.
  Future<int?> getPreviousRunId(int currentRunId) async {
    final result = await _database.query(
      'runs',
      columns: ['id'],
      where: 'id < ?',
      whereArgs: [currentRunId],
      orderBy: 'id DESC',
      limit: 1,
    );

    return result.isEmpty ? null : result.first['id'] as int;
  }

  /// Fetches the latest run ID.
  ///
  /// Retrieves the ID of the most recent run in the database,
  /// ordered by the highest ID.
  ///
  /// Returns:
  /// - An [int] representing the ID of the latest run, or null if no runs exist.
  Future<int?> getLatestRunId() async {
    final result = await _database.query(
      'runs',
      columns: ['id'],
      orderBy: 'id DESC',
      limit: 1,
    );

    return result.isEmpty ? null : result.first['id'] as int;
  }

  /// Determines if the current run is the latest run in the list.
  ///
  /// Compares the `currentRunId` with the latest run ID fetched
  /// from the database. If both IDs match, it indicates we're at the end of the list.
  ///
  /// [currentRunId] - The ID of the current run.
  ///
  /// Returns true if we're at the end of the list, otherwise false.
  Future<bool> isAtEndOfList(int currentRunId) async {
    final latestRunId = await getLatestRunId();
    return currentRunId == latestRunId;
  }

  /// Fetches the first run ID.
  ///
  /// Retrieves the ID of the oldest run in the database,
  /// ordered by the lowest ID.
  ///
  /// Returns:
  /// - An [int] representing the ID of the first run, or null if no runs exist.
  Future<int?> getFirstRunId() async {
    final result = await _database.query(
      'runs',
      columns: ['id'],
      orderBy: 'id ASC',
      limit: 1,
    );

    return result.isEmpty ? null : result.first['id'] as int;
  }

  /// Determines if the current run is the first run in the list.
  ///
  /// Compares the `currentRunId` with the oldest run ID fetched
  /// from the database. If both IDs match, it indicates we're at the start of the list.
  ///
  /// [currentRunId] - The ID of the current run.
  ///
  /// Returns true if we're at the start of the list, otherwise false.
  Future<bool> isAtStartOfList(int currentRunId) async {
    final firstRunId = await getFirstRunId();
    return currentRunId == firstRunId;
  }

  /// Deletes a run from the database.
  ///
  /// Deletes a run from the 'runs' table by its ID.
  /// Related data in the 'phases', 'squad_members', 'leg_breaks',
  /// and 'shield_changes' tables will also be deleted due to ON DELETE CASCADE.
  ///
  /// [runId] - The ID of the run to delete.
  ///
  /// Returns:
  /// - A [Future<int>] representing the number of rows affected by the delete operation.
  Future<int> deleteRun(int runId) async {
    final result = await _database.delete(
      'runs',
      where: 'id = ?',
      whereArgs: [runId],
    );
    return result;
  }

  Future<Run> fetchRun(Database db, int runId) async {
    try {
      // Fetch the basic run details and squad members
      final runDetails = await fetchRunDetails(db, runId);
      final squadMembers = await fetchSquadMembers(db, runId);

      if (runDetails == null) {
        throw Exception('Run with id $runId not found');
      }

      // Fetch the phases for this run and parse them
      final phasesList = await fetchPhases(db, runId);

      // Parse the total times (simplified to just get from the first row)
      final totalTimes = TotalTimesParser.parse(runDetails);

      return Run(
        runId: runDetails['run_id'],
        timeStamp: DateTime.parse(runDetails['time_stamp']),
        runName: runDetails['run_name'],
        playerName: runDetails['player_name'],
        isBuggedRun: runDetails['bugged_run'] == 1,
        isAbortedRun: runDetails['aborted_run'] == 1,
        issoloRun: runDetails['solo_run'] == 1,
        totalTimes: totalTimes,
        phases: Phases(phases: phasesList),
        squadMembers: squadMembers,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> runExists(Database db, int runId) async {
    final result = await db.query(
      'runs',
      where: 'id = ?',
      whereArgs: [runId],
    );
    return result.isNotEmpty;
  }
}
