import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:profit_taker_analyzer/constants/app_locales.dart';

/// A service class for managing language settings in the application.
///
/// This class provides functionality for retrieving supported languages and translating
/// language names based on the current locale. It uses [FlutterI18n] for localization.
///
/// Methods:
/// - [supportedLanguages]: A getter that returns the list of supported locales for the app.
/// - [getCurrentLanguage]: Retrieves the translated name of the language for a given locale.
class SettingsService {
  /// A getter that returns a list of supported locales for the application.
  ///
  /// Returns:
  /// A [List<Locale>] containing the supported locales for the app.
  static List<Locale> get supportedLanguages => AppLocales.supportedLanguages;

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
