import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider(SharedPreferences prefs) {
    _loadTheme(prefs);
  }

  // Load theme from SharedPreferences
  Future<void> _loadTheme(SharedPreferences prefs) async {
    String? savedTheme = prefs.getString('themeMode');
    if (savedTheme != null && savedTheme == 'light') {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.dark;
    }
    notifyListeners();
  }

  // Switch the theme mode and save it
  Future<void> switchTheme(SharedPreferences prefs) async {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();

    prefs.setString(
        'themeMode', _themeMode == ThemeMode.light ? 'light' : 'dark');
  }
}
