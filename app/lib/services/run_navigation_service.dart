// services/run_navigation_service.dart
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:profit_taker_analyzer/models/run_data.dart';
import 'package:profit_taker_analyzer/services/database/database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RunNavigationService extends ChangeNotifier {
  final DatabaseService _databaseService;
  Run? _currentRun;
  int? _currentRunId;
  bool _isLoading = false;
  bool _hasError = false;
  Timer? _updateTimer;

  RunNavigationService({required DatabaseService databaseService})
      : _databaseService = databaseService;

  Run? get currentRun => _currentRun;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  int? get currentRunId => _currentRunId;

  Future<void> initialize({int? initialRunId}) async {
    _isLoading = true;
    _hasError = false;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      // First, try to get the ID from SharedPreferences
      _currentRunId = initialRunId ?? prefs.getInt('currentRunId');

      // Check if the run ID exists in the database
      if (_currentRunId != null) {
        final db = await _databaseService.getDatabase();
        final runExists = await _databaseService.runExists(db, _currentRunId!);
        if (runExists) {
          // If the run exists, use it
          await _loadRunData(_currentRunId!);
        } else {
          // If the run does not exist, fall back to the latest run ID
          _currentRunId = await _databaseService.getLatestRunId();
          if (_currentRunId != null) {
            // If the run is not null, load it
            await _loadRunData(_currentRunId!);
          }
        }
      } else {
        // If no ID is stored, use the latest run ID
        _currentRunId = await _databaseService.getLatestRunId();
        if (_currentRunId != null) {
          // If the run is not null, load it
          await _loadRunData(_currentRunId!);
        }
      }
    } catch (e) {
      _handleError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> navigateToNextRun() async {
    if (_currentRunId == null || _isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      final nextRunId = await _databaseService.getNextRunId(_currentRunId!);
      if (nextRunId != null) {
        _currentRunId = nextRunId;
        await _loadRunData(_currentRunId!);
      }
    } catch (e) {
      _handleError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> navigateToPreviousRun() async {
    if (_currentRunId == null || _isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      final previousRunId =
          await _databaseService.getPreviousRunId(_currentRunId!);
      if (previousRunId != null) {
        _currentRunId = previousRunId;
        await _loadRunData(_currentRunId!);
      }
    } catch (e) {
      _handleError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> maybeNavigateToRun(int runId) async {
    if (runId == _currentRunId) return;

    _currentRunId = runId;
    await _loadRunData(runId);
  }

  Future<void> _loadRunData(int runId) async {
    _hasError = false;
    notifyListeners();

    try {
      final db = await _databaseService.getDatabase();
      final prefs = await SharedPreferences.getInstance();

      _currentRun = await _databaseService.fetchRun(db, runId);
      await prefs.setInt('currentRunId', runId);
    } catch (e) {
      _handleError(e);
    }

    notifyListeners();
  }

  Future<void> _handleError(dynamic error) async {
    _hasError = true;

    final prefs = await SharedPreferences.getInstance();
    int? latestId = await _databaseService.getLatestRunId();
    if (latestId != null) {
      prefs.setInt('currentRunId', latestId);
    } else {
      // No runs exist, clear currentRunId to indicate no valid data
      prefs.remove('currentRunId');
    }

    if (kDebugMode) {
      print('RunNavigationService Error: $error');
    }
  }

  Future<bool> isAtStartOfList() async {
    if (_currentRunId == null) return true;
    final firstRunId = await _databaseService.getFirstRunId();
    return _currentRunId == firstRunId;
  }

  Future<bool> isAtEndOfList() async {
    if (_currentRunId == null) return true;
    final latestRunId = await _databaseService.getLatestRunId();
    return _currentRunId == latestRunId;
  }

  /// Check and update to the most recent run
  Future<void> checkAndUpdateToMostRecentRun() async {
    if (_isLoading) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final latestStoredRunId =
          prefs.getInt('latestRunId'); // Get the stored latest run ID
      final latestRunId = await _databaseService
          .getLatestRunId(); // Get the latest run ID from the database

      // If the latest run ID is different from the stored one, update
      if (latestRunId != null && latestRunId != latestStoredRunId) {
        // Update the stored latest run ID
        await prefs.setInt('latestRunId', latestRunId);

        // Load the new most recent run
        await _loadRunData(latestRunId);
      }
    } catch (e) {
      _handleError(e);
    }
  }

  /// Start periodic updates
  void startPeriodicUpdate({Duration interval = const Duration(seconds: 1)}) {
    _updateTimer?.cancel(); // Cancel any existing timer
    _updateTimer = Timer.periodic(interval, (_) async {
      await checkAndUpdateToMostRecentRun();
    });
  }

  /// Stop periodic updates
  void stopPeriodicUpdate() {
    _updateTimer?.cancel();
    _updateTimer = null;
  }
}
