import 'package:flutter/material.dart';
import 'package:profit_taker_analyzer/constants/preferences/shared_prefs_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:profit_taker_analyzer/app_layout.dart';

Future<void> viewRun(BuildContext context, int runId) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt(SharedPrefsKeys.currentRunId, runId);

  // Attempt to switch tabs
  AppLayout.globalKey.currentState?.selectTab(0);
}
