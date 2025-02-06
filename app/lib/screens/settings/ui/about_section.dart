import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:profit_taker_analyzer/constants/app_constants.dart';
import 'package:profit_taker_analyzer/widgets/dialogs/about_app_dialog.dart';
import 'package:profit_taker_analyzer/widgets/dialogs/contacts_dialog.dart';

/// Builds the "About" section of the settings page in the app.
///
/// This section includes tiles for contacting the app developer, viewing
/// information about the app, and displaying the current app version.
///
/// Parameters:
/// - [context]: The build context used for localization and dialog rendering.
///
/// Returns:
/// A [SettingsSection] containing tiles for contact info, about the app,
/// and app version.
SettingsSection buildAboutSection(BuildContext context) {
  return SettingsSection(
    title: Text(FlutterI18n.translate(context, "settings.about.title")),
    tiles: [
      SettingsTile(
        title: Text(FlutterI18n.translate(context, "settings.contact.title")),
        leading: const Icon(Icons.contact_page),
        onPressed: (_) => showContactsDialog(
            context,
            FlutterI18n.translate(context, "settings.contact.title"),
            FlutterI18n.translate(
                context, "settings.contact.basi_contacts_description"),
            FlutterI18n.translate(context, "common.ok")),
      ),
      SettingsTile(
        title: Text(FlutterI18n.translate(context, "settings.about.about_app")),
        leading: const Icon(Icons.info),
        onPressed: (_) => showAboutAppDialog(
            context,
            FlutterI18n.translate(context, "settings.about.about_app"),
            FlutterI18n.translate(context, "settings.about.description"),
            FlutterI18n.translate(context, "common.ok")),
      ),
      SettingsTile(
          title: Text(FlutterI18n.translate(context, "settings.about.version")),
          trailing: const Text(AppConstants.version)),
    ],
  );
}
