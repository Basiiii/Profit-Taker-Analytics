import 'package:flutter/foundation.dart';
import 'package:profit_taker_analyzer/services/database/database_service.dart';
import 'package:rust_core/rust_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RunNavigator {
  final DatabaseService _databaseService = DatabaseService();
  int? _currentRunId;
  RunModel? _runData; // Store the current run data here

  // Initializes the navigation with the current run ID
  Future<void> initialize(int initialRunId) async {
    _currentRunId = initialRunId;
    await _loadRunData(_currentRunId!); // Load the data for the initial run
  }

  // Get the current run ID
  int? getCurrentRunId() => _currentRunId;

  // Fetch the current run data
  RunModel? getCurrentRunData() => _runData;

  // Navigate to the next run (if possible)
  Future<void> navigateToNextRun() async {
    if (_currentRunId == null) return;

    final nextRunId = await _databaseService.fetchNextRunId(_currentRunId!);
    if (nextRunId != null) {
      _currentRunId = nextRunId;
      await _loadRunData(_currentRunId!); // Load data for the new run
    }
  }

  // Navigate to the previous run (if possible)
  Future<void> navigateToPreviousRun() async {
    if (_currentRunId == null) return;

    final previousRunId =
        await _databaseService.fetchPreviousRunId(_currentRunId!);
    if (previousRunId != null) {
      _currentRunId = previousRunId;
      await _loadRunData(_currentRunId!); // Load data for the new run
    }
  }

  // Fetch and load the current run data (using the current run ID)
  Future<void> _loadRunData(int runId) async {
    final prefs = await SharedPreferences.getInstance();

    try {
      // Fetch run data
      _runData = await _databaseService.fetchRun(runId);

      // Save the current runId to shared preferences
      await prefs.setInt('currentRunId', runId);
    } catch (e) {
      // Log the exception
      if (kDebugMode) {
        print('Error fetching run data: $e');
      }

      // Set _runData to null
      _runData = null;

      // Reset the currentRunId to 1 if there's an issue
      await prefs.setInt('currentRunId', 1);
    }
  }

  // Check if we're at the end (most recent run)
  Future<bool> isAtEndOfList() async {
    final latestRunId = await _databaseService.fetchLatestRunId();
    return _currentRunId == latestRunId;
  }

  // Check if we're at the start (oldest run)
  Future<bool> isAtStartOfList() async {
    final firstRunId = await _databaseService.fetchFirstRunId();
    return _currentRunId == firstRunId;
  }
}
