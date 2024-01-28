import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleModel extends ChangeNotifier {
  Locale? _locale;
  final SharedPreferences _prefs;

  LocaleModel(this._prefs) {
    var selectedLocale = _prefs.getString("selectedLocale");
    if (selectedLocale != null) {
      _locale = Locale(selectedLocale);
    }
  }

  Locale? get locale => _locale;

  void set(Locale locale) {
    _locale = locale;
    _prefs.setString('selectedLocale', locale.toString());

    notifyListeners();
  }
}
