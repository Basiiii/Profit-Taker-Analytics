import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:profit_taker_analyzer/services/settings_service.dart';
import 'package:profit_taker_analyzer/widgets/theme_switcher.dart';

SettingsSection buildGeneralSection(
  BuildContext context,
  Locale currentLocale,
  VoidCallback onLanguagePressed,
) {
  final settingsService = SettingsService();

  return SettingsSection(
    title: Text(FlutterI18n.translate(context, "settings.general")),
    tiles: [
      SettingsTile(
        title: Text(FlutterI18n.translate(context, "settings.theme")),
        leading: const Icon(Icons.contrast),
        trailing: const ThemeSwitcher(),
      ),
      SettingsTile(
        title: Text(FlutterI18n.translate(context, "settings.change_language")),
        leading: const Icon(Icons.language),
        trailing:
            Text(settingsService.getCurrentLanguage(context, currentLocale)),
        onPressed: (_) => onLanguagePressed(),
      ),
    ],
  );
}
