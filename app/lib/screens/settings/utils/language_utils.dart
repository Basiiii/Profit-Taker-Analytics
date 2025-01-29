import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';
import 'package:profit_taker_analyzer/services/settings_service.dart';
import 'package:profit_taker_analyzer/utils/language.dart';

/// Shows a dialog allowing the user to change the application language.
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

/// Changes the app's language and updates the state.
void _changeLanguage(
    BuildContext context, Locale locale, Function(Locale) onLanguageChanged) {
  Provider.of<LocaleModel>(context, listen: false).setLocale(locale);
  onLanguageChanged(locale);
  Navigator.pop(context);
}
