import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:profit_taker_analyzer/theme/custom_icons.dart';
import 'package:profit_taker_analyzer/utils/utils.dart';

SettingsSection buildLinksSection(BuildContext context) {
  return SettingsSection(
    title: Text(FlutterI18n.translate(context, "settings.links")),
    tiles: [
      SettingsTile(
        title: Text(FlutterI18n.translate(context, "settings.pt_discord")),
        leading: const Icon(CustomIcons.discord),
        onPressed: (_) => launchURL('https://discord.gg/WVpfZFMeUs'),
      ),
      SettingsTile(
        title: Text(FlutterI18n.translate(context, "settings.github_repo")),
        leading: const Icon(CustomIcons.github),
        onPressed: (_) =>
            launchURL('https://github.com/Basiiii/Profit-Taker-Analytics'),
      ),
      SettingsTile(
        title: Text(FlutterI18n.translate(context, "settings.pt_guide")),
        leading: const Icon(CustomIcons.book),
        onPressed: (_) => launchURL(
            'https://docs.google.com/document/d/1DWY-ZNv7cUA6egxDZKYu0e8qz7z-yHT2KncyYAo5NHU/edit?pli=1'),
      ),
      SettingsTile(
        title: Text(FlutterI18n.translate(context, "settings.report_bug")),
        leading: const Icon(Icons.bug_report),
        onPressed: (_) => launchURL(
            'https://github.com/Basiiii/Profit-Taker-Analytics/issues/new/choose'),
      ),
    ],
  );
}
