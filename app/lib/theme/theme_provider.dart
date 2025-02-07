import 'package:flutter/material.dart';
import 'package:profit_taker_analyzer/constants/layout/theme_constants.dart';
import 'package:profit_taker_analyzer/constants/preferences/shared_prefs_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A provider class for managing the app's theme settings.
///
/// This class handles the loading and switching of the theme mode (light or dark) and uses
/// [SharedPreferences] to persist the selected theme across app sessions.
///
/// Instance variables:
/// - [_themeMode]: The current theme mode (either [ThemeMode.light] or [ThemeMode.dark]).
///
/// Methods:
/// - [themeMode]: A getter that returns the current theme mode.
/// - [ThemeProvider]: Constructor that initializes the theme provider and loads the saved theme from [SharedPreferences].
/// - [_loadTheme]: A private method that loads the saved theme from [SharedPreferences].
/// - [switchTheme]: A method to toggle between light and dark modes, updating both the state and [SharedPreferences].
class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider(SharedPreferences prefs) {
    _loadTheme(prefs);
  }

  /// Loads the theme from [SharedPreferences] and updates the [ThemeMode] accordingly.
  ///
  /// This method checks for a saved theme mode in [SharedPreferences] and sets the theme accordingly.
  /// If no theme is found, it defaults to [ThemeMode.dark].
  ///
  /// Parameters:
  /// - [prefs]: The [SharedPreferences] instance used to retrieve the saved theme.
  ///
  /// Returns:
  /// A [Future<void>] that completes when the theme is loaded and listeners are notified.
  Future<void> _loadTheme(SharedPreferences prefs) async {
    String? savedTheme = prefs.getString(SharedPrefsKeys.themeMode);
    if (savedTheme != null && savedTheme == ThemeConstants.light) {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.dark;
    }
    notifyListeners();
  }

  /// Switches between light and dark theme modes and updates the saved preference.
  ///
  /// This method toggles the theme mode and saves the new value to [SharedPreferences], allowing
  /// the theme to persist across app sessions.
  ///
  /// Parameters:
  /// - [prefs]: The [SharedPreferences] instance used to store the current theme.
  ///
  /// Returns:
  /// A [Future<void>] that completes when the theme is switched and saved.
  Future<void> switchTheme(SharedPreferences prefs) async {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();

    prefs.setString(
        SharedPrefsKeys.themeMode,
        _themeMode == ThemeMode.light
            ? ThemeConstants.light
            : ThemeConstants.dark);
  }
}
