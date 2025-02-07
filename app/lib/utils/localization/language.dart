import 'package:flutter/material.dart';
import 'package:profit_taker_analyzer/constants/localization/localization_constants.dart';
import 'package:profit_taker_analyzer/constants/preferences/shared_prefs_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A model class for managing the application's locale.
///
/// The `LocaleModel` class extends [ChangeNotifier] and provides functionality
/// to set and retrieve the currently selected locale. It utilizes shared preferences
/// to persist the selected locale across app sessions.
class LocaleModel extends ChangeNotifier {
  Locale? _locale;
  final SharedPreferences _prefs;

  /// Constructs a [LocaleModel] instance.
  ///
  /// Parameters:
  ///   - `_prefs`: An instance of [SharedPreferences] for managing app preferences.
  LocaleModel(this._prefs) {
    _initializeLocale();
  }

  /// Initializes the locale from SharedPreferences.
  void _initializeLocale() {
    final selectedLocale = _prefs.getString(SharedPrefsKeys.selectedLocale);
    if (selectedLocale != null) {
      final parts = selectedLocale.split('_');
      if (parts.length == 1) {
        // Only language code is saved
        _locale = Locale(parts[0]);
      } else if (parts.length == 2) {
        // Both language and country code are saved
        _locale = Locale(parts[0], parts[1]);
      }
    } else {
      // Default locale (English)
      _locale = const Locale(LocalizationConstants.fallbackLanguage);
    }
  }

  /// Gets the currently selected locale.
  Locale? get locale => _locale;

  /// Sets the selected locale and notifies listeners.
  ///
  /// Parameters:
  ///   - `locale`: The locale to be set as the currently selected locale.
  void setLocale(Locale locale) {
    _locale = locale;
    _prefs.setString(SharedPrefsKeys.selectedLocale, _locale.toString());
    notifyListeners();
  }
}
