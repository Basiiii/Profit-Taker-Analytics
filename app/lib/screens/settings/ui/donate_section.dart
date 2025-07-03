import 'package:flutter/material.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:profit_taker_analyzer/widgets/dialogs/donation_dialog.dart';

/// Builds the "Donate" settings section in the app.
///
/// This section provides a way for users to donate to support the development
/// of the Profit Taker Analytics application.
///
/// Parameters:
/// - [context]: The build context used for localization and UI rendering.
///
/// Returns:
/// A [SettingsSection] containing the donation tile.
SettingsSection buildDonateSection(BuildContext context) {
  return SettingsSection(
    title: Text(FlutterI18n.translate(context, "donate.title")),
    tiles: [
      SettingsTile(
        title: Text(FlutterI18n.translate(context, "donate.button")),
        leading: const Icon(Icons.favorite),
        onPressed: (_) => showDonationDialog(
          context,
          FlutterI18n.translate(context, "donate.title"),
          FlutterI18n.translate(context, "donate.main"),
          FlutterI18n.translate(context, "donate.button"),
          FlutterI18n.translate(context, "common.ok"),
        ),
      ),
    ],
  );
}
