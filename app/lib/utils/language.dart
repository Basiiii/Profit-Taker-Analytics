import 'package:flutter/material.dart';
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
    var selectedLocale = _prefs.getString("selectedLocale");
    if (selectedLocale != null) {
      _locale = Locale(selectedLocale);
    }
  }

  /// Gets the currently selected locale.
  ///
  /// Returns:
  ///   The currently selected locale or `null` if not set.
  Locale? get locale => _locale;

  /// Sets the selected locale and notifies listeners.
  ///
  /// Parameters:
  ///   - `locale`: The locale to be set as the currently selected locale.
  void set(Locale locale) {
    _locale = locale;
    _prefs.setString('selectedLocale', locale.toString());

    notifyListeners();
  }
}
