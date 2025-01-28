import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

class SettingsService {
  static List<Locale> get supportedLanguages => const [
        Locale('en', 'US'),
        Locale('pt', 'PT'),
        Locale('zh', 'CN'),
        Locale('ru'),
        Locale('fr'),
        Locale('tr'),
      ];

  String getCurrentLanguage(BuildContext context, Locale currentLocale) {
    return FlutterI18n.translate(
      context,
      "languages.${currentLocale.languageCode}",
    );
  }
}
