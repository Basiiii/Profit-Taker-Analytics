import 'package:flutter/material.dart';
import 'package:profit_taker_analyzer/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

Map<ThemeMode, String> themeModeMap = {
  ThemeMode.light: 'light',
  ThemeMode.dark: 'dark',
};

Future<void> loadThemeMode() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? savedThemeMode = prefs.getString('themeMode');

  Map<String, ThemeMode> reverseThemeModeMap =
      themeModeMap.map((k, v) => MapEntry(v, k));

  if (reverseThemeModeMap.containsKey(savedThemeMode)) {
    MyApp.themeNotifier.value = reverseThemeModeMap[savedThemeMode]!;
  }
}
