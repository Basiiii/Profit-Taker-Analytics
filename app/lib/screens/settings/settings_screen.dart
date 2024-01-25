import 'package:flutter/material.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:profit_taker_analyzer/main.dart';
import 'package:profit_taker_analyzer/utils/utils.dart';
import 'package:profit_taker_analyzer/theme/custom_icons.dart';

/// The main settings screen of the application.
///
/// This screen provides users with various options to customize the app's behavior.
/// It includes sections such as General, Links, Report Bugs, and About.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SettingsList(
          darkTheme: SettingsThemeData(
              settingsListBackground: Theme.of(context).colorScheme.background),
          sections: [
            SettingsSection(
              title: const Text('General'),
              tiles: [
                SettingsTile(
                    title: const Text('Theme'),
                    leading: const Icon(Icons.contrast),
                    trailing: ValueListenableBuilder(
                        valueListenable: MyApp.themeNotifier,
                        builder: (context, ThemeMode mode, _) {
                          return IconButton(
                            icon: Icon(mode == ThemeMode.light
                                ? Icons.nightlight
                                : Icons.wb_sunny),
                            onPressed: switchTheme,
                          );
                        })),
              ],
            ),
            SettingsSection(
              title: const Text('Links'),
              tiles: [
                SettingsTile(
                  title: const Text('Official PT Discord'),
                  leading: const Icon(CustomIcons.discord),
                  onPressed: (BuildContext context) {
                    launchURL('https://discord.gg/WVpfZFMeUs');
                  },
                ),
                SettingsTile(
                  title: const Text('Github Repository'),
                  leading: const Icon(CustomIcons.github),
                  onPressed: (BuildContext context) {
                    launchURL(
                        'https://github.com/Basiiii/Profit-Taker-Analytics');
                  },
                ),
                SettingsTile(
                  title: const Text('Profit Taker Guide'),
                  leading: const Icon(CustomIcons.book),
                  onPressed: (BuildContext context) {
                    launchURL(
                        'https://docs.google.com/document/d/1DWY-ZNv7cUA6egxDZKYu0e8qz7z-yHT2KncyYAo5NHU/edit?pli=1');
                  },
                )
              ],
            ),
            SettingsSection(
              title: const Text('Report Bugs'),
              tiles: [
                SettingsTile(
                  title: const Text('Report a Bug'),
                  leading: const Icon(Icons.bug_report),
                  onPressed: (BuildContext context) {
                    launchURL(
                        'https://github.com/Basiiii/Profit-Taker-Analytics/issues/new/choose');
                  },
                ),
              ],
            ),
            SettingsSection(
              title: const Text('About'),
              tiles: [
                SettingsTile(
                  title: const Text('About'),
                  leading: const Icon(Icons.info),
                  onPressed: (BuildContext context) {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('About'),
                            content: const Text(
                                'Made with love by Basi.\nIf you found this, send me a DM\nof a mango on discord.'),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('OK'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              )
                            ],
                          );
                        });
                  },
                ),
                SettingsTile(
                  title: const Text('Version'),
                  trailing: const Text('ALPHA 0.1.0'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
