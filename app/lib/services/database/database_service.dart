import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:profit_taker_analyzer/constants/app/app_constants.dart';
import 'package:rust_core/rust_core.dart';
import 'package:path/path.dart' as p;

/// A singleton service that manages database interactions and run navigation.
///
/// This class provides methods to initialize the database, retrieve file paths,
/// and fetch run-related data such as next/previous run IDs.
class DatabaseService {
  /// The singleton instance of [DatabaseService].
  static final DatabaseService _instance = DatabaseService._internal();

  /// Factory constructor returning the singleton instance.
  factory DatabaseService() => _instance;

  /// Private internal constructor for singleton pattern.
  DatabaseService._internal();

  /// Retrieves the directory path where the database is stored.
  ///
  /// Returns the absolute path to the database folder within the executable directory.
  String getDatabaseFolder() {
    // Get the directory of the running executable
    String exeDir = p.dirname(Platform.resolvedExecutable);

    // Define the database folder path
    return p.join(exeDir, AppConstants.databaseFolder);
  }

  /// Retrieves the full file path to the database file.
  ///
  /// Returns the absolute path including the database file name.
  String getDatabaseFilePath() {
    String dbFolderPath = getDatabaseFolder();
    return p.join(dbFolderPath, AppConstants.databaseName);
  }

  /// Initializes the database by ensuring the database folder exists and setting up the database file.
  ///
  /// If the database folder does not exist, it is created. Then, the database is initialized.
  Future<void> initialize() async {
    try {
      // Get batabase path
      String dbFolderPath = getDatabaseFolder();

      // Ensure the database folder exists
      Directory dbFolder = Directory(dbFolderPath);
      if (!dbFolder.existsSync()) {
        dbFolder.createSync(recursive: true);
        if (kDebugMode) {
          print("Database folder created at: $dbFolderPath");
        }
      }

      // Define the database file path
      String dbFilePath = getDatabaseFilePath();

      // Initialize the database with the new path
      initializeDb(path: dbFilePath);
      if (kDebugMode) {
        print("Database initialized successfully at: $dbFilePath");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Failed to initialize database: $e");
      }
    }
  }

  /// Fetches the next run ID relative to the given [currentRunId].
  Future<int?> fetchNextRunId(int currentRunId) async =>
      getNextRunId(currentRunId: currentRunId);

  /// Fetches the previous run ID relative to the given [currentRunId].
  Future<int?> fetchPreviousRunId(int currentRunId) async =>
      getPreviousRunId(currentRunId: currentRunId);

  /// Fetches the latest run ID available in the database.
  Future<int?> fetchLatestRunId() async => getLatestRunId();

  /// Fetches the first run ID available in the database.
  Future<int?> fetchFirstRunId() async => getEarliestRunId();

  /// Checks if the given [currentRunId] is the last run in the database.
  Future<bool> isAtEndOfList(int currentRunId) async =>
      currentRunId == (await fetchLatestRunId());

  /// Checks if the given [currentRunId] is the first run in the database.
  Future<bool> isAtStartOfList(int currentRunId) async =>
      currentRunId == (await fetchFirstRunId());

  /// Checks if a run with the given [runId] exists in the database.
  Future<bool> runExists(int runId) async => checkRunExists(runId: runId);

  /// Fetches the run details for the given [runId].
  ///
  /// Returns a [RunModel] if the run exists, otherwise returns `null`.
  Future<RunModel?> fetchRun(int runId) async {
    try {
      return getRunFromDb(runId: runId);
    } catch (e) {
      if (kDebugMode) print("Error fetching run: $e");
      return null;
    }
  }

  /// Removes the run with the given [runId] from the database.
  ///
  /// Returns `true` if the deletion is successful, otherwise `false`.
  Future<bool> removeRun(int runId) async {
    var result = deleteRunFromDb(runId: runId);
    return result.success;
  }
}
