import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

/// A service class for managing language settings in the application.
class SettingsService {
  /// A list of supported locales for the application.
  static List<Locale> get supportedLanguages => const [
        Locale('en', 'US'),
        Locale('pt', 'PT'),
        Locale('zh', 'CN'),
        Locale('ru'),
        Locale('fr'),
        Locale('tr'),
      ];

  /// Retrieves the translated name of the current language based on the provided locale.
  ///
  /// Uses [FlutterI18n] to get the localized language name from the translation keys.
  ///
  /// - [context]: The current [BuildContext] required for localization.
  /// - [currentLocale]: The locale whose language name should be retrieved.
  ///
  /// Returns the translated name of the language as a [String].
  String getCurrentLanguage(BuildContext context, Locale currentLocale) {
    return FlutterI18n.translate(
      context,
      "languages.${currentLocale.languageCode}",
    );
  }
}
