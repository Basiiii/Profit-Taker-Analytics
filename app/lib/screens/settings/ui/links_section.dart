import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:profit_taker_analyzer/constants/app_links.dart';
import 'package:profit_taker_analyzer/theme/custom_icons.dart';
import 'package:profit_taker_analyzer/utils/utils.dart';

/// Builds the "Links" settings section in the app.
///
/// This section provides links to external resources related to the app,
/// such as the Discord server, GitHub repository, user guide, and bug reporting page.
///
/// Parameters:
/// - [context]: The build context used for localization and UI rendering.
///
/// Returns:
/// A [SettingsSection] containing tiles that open external URLs for the provided links.
SettingsSection buildLinksSection(BuildContext context) {
  return SettingsSection(
    title: Text(FlutterI18n.translate(context, "settings.links.title")),
    tiles: [
      SettingsTile(
        title:
            Text(FlutterI18n.translate(context, "settings.links.pt_discord")),
        leading: const Icon(CustomIcons.discord),
        onPressed: (_) => launchURL(AppLinks.discord),
      ),
      SettingsTile(
        title:
            Text(FlutterI18n.translate(context, "settings.links.github_repo")),
        leading: const Icon(CustomIcons.github),
        onPressed: (_) => launchURL(AppLinks.githubRepo),
      ),
      SettingsTile(
        title: Text(FlutterI18n.translate(context, "settings.links.pt_guide")),
        leading: const Icon(CustomIcons.book),
        onPressed: (_) => launchURL(AppLinks.profitTakerGuide),
      ),
      SettingsTile(
        title:
            Text(FlutterI18n.translate(context, "settings.links.report_bug")),
        leading: const Icon(Icons.bug_report),
        onPressed: (_) => launchURL(AppLinks.reportBug),
      ),
    ],
  );
}
