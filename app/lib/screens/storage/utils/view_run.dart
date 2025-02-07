import 'package:flutter/material.dart';
import 'package:profit_taker_analyzer/constants/preferences/shared_prefs_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:profit_taker_analyzer/app_layout.dart';
import 'package:profit_taker_analyzer/screens/storage/model/run_list_model.dart';

Future<void> viewRun(BuildContext context, RunListItemCustom run) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt(SharedPrefsKeys.currentRunId, run.id);

  // Attempt to switch tabs
  AppLayout.globalKey.currentState?.selectTab(0);
}
