import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';
import 'package:profit_taker_analyzer/services/settings_service.dart';
import 'package:profit_taker_analyzer/utils/language.dart';

/// Displays a dialog allowing the user to select a new language for the application.
///
/// This dialog presents a list of supported languages, and when a language is selected,
/// the app's locale is updated and the change is reflected in the UI.
///
/// Parameters:
/// - [context]: The build context used to display the dialog and manage localization.
/// - [onLanguageChanged]: A callback function triggered when the language is changed.
///   This function receives the newly selected locale as an argument.
///
/// Returns:
/// A dialog widget containing options to change the app's language.
void showLanguageDialog(
    BuildContext context, Function(Locale) onLanguageChanged) {
  showDialog(
    context: context,
    builder: (context) => SimpleDialog(
      title: Text(FlutterI18n.translate(context, "settings.change_language")),
      children: SettingsService.supportedLanguages.map((locale) {
        return SimpleDialogOption(
          onPressed: () => _changeLanguage(context, locale, onLanguageChanged),
          child: Text(
            FlutterI18n.translate(context, "languages.${locale.languageCode}"),
          ),
        );
      }).toList(),
    ),
  );
}

/// Updates the app's language to the selected locale and refreshes the UI state.
///
/// This method updates the app's locale and triggers the provided callback function
/// to inform the caller of the language change. It also dismisses the language change dialog.
///
/// Parameters:
/// - [context]: The build context used to update the app's locale.
/// - [locale]: The new locale to be set for the application.
/// - [onLanguageChanged]: A callback function triggered after the language change,
///   which provides the updated locale as an argument.
///
/// Returns:
/// None. This method only updates the app's state and dismisses the dialog.
void _changeLanguage(
    BuildContext context, Locale locale, Function(Locale) onLanguageChanged) {
  Provider.of<LocaleModel>(context, listen: false).setLocale(locale);
  onLanguageChanged(locale);
  Navigator.pop(context);
}
