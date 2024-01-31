import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:profit_taker_analyzer/main.dart';

/// A mapping of [ThemeMode] to string representations.
///
/// This map associates each [ThemeMode] with a corresponding string label
/// for easy conversion between the two representations.
Map<ThemeMode, String> themeModeMap = {
  ThemeMode.light: 'light',
  ThemeMode.dark: 'dark',
};

/// Loads the saved theme mode from shared preferences.
///
/// This method retrieves the saved theme mode from the shared preferences
/// and updates the [themeNotifier] in the [MyApp] class accordingly.
///
/// It uses the `themeModeMap` and its reverse to map between string
/// representations and [ThemeMode] values.
///
/// Note: The [themeNotifier] is a ValueNotifier that manages the current
/// theme mode in the application.
Future<void> loadThemeMode() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? savedThemeMode = prefs.getString('themeMode');

  Map<String, ThemeMode> reverseThemeModeMap =
      themeModeMap.map((k, v) => MapEntry(v, k));

  if (reverseThemeModeMap.containsKey(savedThemeMode)) {
    MyApp.themeNotifier.value = reverseThemeModeMap[savedThemeMode]!;
  }
}
