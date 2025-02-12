import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:profit_taker_analyzer/services/settings_service.dart';
import 'package:profit_taker_analyzer/widgets/ui/theme_switcher.dart';

/// Builds the "General" settings section in the app.
///
/// This section allows users to configure the theme and change the app's language.
/// It includes a tile for toggling the theme and another for selecting a new language.
///
/// Parameters:
/// - [context]: The build context used for localization and dialog rendering.
/// - [currentLocale]: The current locale of the app to display the correct language.
/// - [onLanguagePressed]: A callback function triggered when the user presses to change the language.
///
/// Returns:
/// A [SettingsSection] containing tiles for changing the theme and language.
SettingsSection buildGeneralSection(
  BuildContext context,
  Locale currentLocale,
  VoidCallback onLanguagePressed,
  VoidCallback onViewOnboarding,
  VoidCallback onImportOldJson,
) {
  final settingsService = SettingsService();

  return SettingsSection(
    title: Text(FlutterI18n.translate(context, "settings.general.title")),
    tiles: [
      SettingsTile(
        title: Text(FlutterI18n.translate(context, "settings.general.theme")),
        leading: const Icon(Icons.contrast),
        trailing: const ThemeSwitcher(),
      ),
      SettingsTile(
        title: Text(
            FlutterI18n.translate(context, "settings.general.change_language")),
        leading: const Icon(Icons.language),
        trailing:
            Text(settingsService.getCurrentLanguage(context, currentLocale)),
        onPressed: (_) => onLanguagePressed(),
      ),
      SettingsTile(
        title: Text(
            FlutterI18n.translate(context, "settings.general.view_onboarding")),
        leading: const Icon(Icons.info_outline_rounded),
        onPressed: (_) => onViewOnboarding(),
      ),
      SettingsTile(
        title: Text(
            FlutterI18n.translate(context, "settings.general.import_old_json")),
        leading: const Icon(MdiIcons.database),
        onPressed: (_) => onImportOldJson(),
      ),
    ],
  );
}
