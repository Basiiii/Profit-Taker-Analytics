import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:profit_taker_analyzer/constants/app_constants.dart';
import 'package:rust_core/rust_core.dart';
import 'package:path/path.dart' as p;

// RunService to manage the runs and their navigation
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  String getDatabaseFolder() {
    // Get the directory of the running executable
    String exeDir = p.dirname(Platform.resolvedExecutable);

    // Define the database folder path
    String dbFolderPath = p.join(exeDir, 'database');

    return dbFolderPath;
  }

  String getDatabaseFilePath() {
    String dbFolderPath = getDatabaseFolder();
    String dbFilePath = p.join(dbFolderPath, AppConstants.databaseName);

    return dbFilePath;
  }

  // Initializes the Database
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

  Future<int?> fetchNextRunId(int currentRunId) async =>
      getNextRunId(currentRunId: currentRunId);
  Future<int?> fetchPreviousRunId(int currentRunId) async =>
      getPreviousRunId(currentRunId: currentRunId);
  Future<int?> fetchLatestRunId() async => getLatestRunId();
  Future<int?> fetchFirstRunId() async => getEarliestRunId();
  Future<bool> isAtEndOfList(int currentRunId) async =>
      currentRunId == (await fetchLatestRunId());
  Future<bool> isAtStartOfList(int currentRunId) async =>
      currentRunId == (await fetchFirstRunId());
  Future<bool> runExists(int runId) async => checkRunExists(runId: runId);

  Future<RunModel?> fetchRun(int runId) async {
    try {
      return getRunFromDb(runId: runId);
    } catch (e) {
      if (kDebugMode) print("Error fetching run: $e");
      return null;
    }
  }

  Future<bool> removeRun(int runId) async {
    var result = deleteRunFromDb(runId: runId);
    return result.success;
  }
}
