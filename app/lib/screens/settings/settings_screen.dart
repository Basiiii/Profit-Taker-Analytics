import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';

import 'package:profit_taker_analyzer/constants/constants.dart';

import 'package:profit_taker_analyzer/main.dart';
import 'package:profit_taker_analyzer/utils/language.dart';

import 'package:profit_taker_analyzer/widgets/dialogs.dart';

import 'package:profit_taker_analyzer/utils/utils.dart';

import 'package:profit_taker_analyzer/theme/custom_icons.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final List<Locale> supportedLanguages = const [
    Locale('en', 'US'), // English
    Locale('pt', 'PT'), // Portuguese
    Locale('zh', 'CN'), // Chinese
    Locale('ru'), // Russian
  ];

  late Locale _currentLocale;

  String _currentLanguage() {
    return FlutterI18n.translate(
        context, "languages.${_currentLocale.languageCode}");
  }

  void _selectLanguage(BuildContext context, String changeLanguage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(changeLanguage),
          children: supportedLanguages.map((Locale locale) {
            return SimpleDialogOption(
              child: Text(FlutterI18n.translate(
                  context, "languages.${locale.languageCode}")),
              onPressed: () {
                Navigator.pop(context);
                _changeLanguage(locale);
              },
            );
          }).toList(),
        );
      },
    );
  }

  void _changeLanguage(Locale locale) async {
    await FlutterI18n.refresh(context, locale);
    _currentLocale = locale;
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('language', locale.languageCode);
    });
    if (mounted) {
      Provider.of<LocaleModel>(context, listen: false).set(locale);
    }
    setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _currentLocale = Localizations.localeOf(context);
  }

  @override
  Widget build(BuildContext context) {
    String changeLanguageText =
        FlutterI18n.translate(context, "settings.change_language");
    String contactText =
        FlutterI18n.translate(context, "settings.contact_basi");
    String aboutTitle = FlutterI18n.translate(context, "settings.about_app");
    String aboutDescription =
        FlutterI18n.translate(context, "settings.about_app_description");

    return Scaffold(
      body: Center(
        child: SettingsList(
          darkTheme: SettingsThemeData(
              settingsListBackground: Theme.of(context).colorScheme.background),
          sections: [
            SettingsSection(
              title: Text(FlutterI18n.translate(context, "settings.general")),
              tiles: [
                SettingsTile(
                    title:
                        Text(FlutterI18n.translate(context, "settings.theme")),
                    leading: const Icon(Icons.contrast),
                    trailing: ValueListenableBuilder(
                        valueListenable: MyApp.themeNotifier,
                        builder: (context, ThemeMode mode, _) {
                          return IconButton(
                            icon: Icon(mode == ThemeMode.light
                                ? Icons.nightlight
                                : Icons.wb_sunny),
                            onPressed: () => switchTheme(),
                          );
                        })),
              ],
            ),
            SettingsSection(
              title: Text(FlutterI18n.translate(context, "settings.links")),
              tiles: [
                SettingsTile(
                  title: Text(
                      FlutterI18n.translate(context, "settings.pt_discord")),
                  leading: const Icon(CustomIcons.discord),
                  onPressed: (BuildContext context) {
                    launchURL('https://discord.gg/WVpfZFMeUs');
                  },
                ),
                SettingsTile(
                  title: Text(
                      FlutterI18n.translate(context, "settings.github_repo")),
                  leading: const Icon(CustomIcons.github),
                  onPressed: (BuildContext context) {
                    launchURL(
                        'https://github.com/Basiiii/Profit-Taker-Analytics');
                  },
                ),
                SettingsTile(
                  title:
                      Text(FlutterI18n.translate(context, "settings.pt_guide")),
                  leading: const Icon(CustomIcons.book),
                  onPressed: (BuildContext context) {
                    launchURL(
                        'https://docs.google.com/document/d/1DWY-ZNv7cUA6egxDZKYu0e8qz7z-yHT2KncyYAo5NHU/edit?pli=1');
                  },
                )
              ],
            ),
            SettingsSection(
                title:
                    Text(FlutterI18n.translate(context, "settings.language")),
                tiles: [
                  SettingsTile(
                    title: Text(FlutterI18n.translate(
                        context, "settings.change_language")),
                    leading: const Icon(Icons.language),
                    trailing: Text(_currentLanguage()),
                    onPressed: (BuildContext context) {
                      _selectLanguage(context, changeLanguageText);
                    },
                  )
                ]),
            SettingsSection(
              title:
                  Text(FlutterI18n.translate(context, "settings.report_bugs")),
              tiles: [
                SettingsTile(
                  title: Text(
                      FlutterI18n.translate(context, "settings.report_bug")),
                  leading: const Icon(Icons.bug_report),
                  onPressed: (BuildContext context) {
                    launchURL(
                        'https://github.com/Basiiii/Profit-Taker-Analytics/issues/new/choose');
                  },
                ),
              ],
            ),
            SettingsSection(
              title: Text(FlutterI18n.translate(context, "settings.about")),
              tiles: [
                SettingsTile(
                  title: Text(
                      FlutterI18n.translate(context, "settings.contact_basi")),
                  leading: const Icon(Icons.contact_page),
                  onPressed: (BuildContext context) {
                    showContactsAppDialog(context, contactText);
                  },
                ),
                SettingsTile(
                  title: Text(
                      FlutterI18n.translate(context, "settings.about_app")),
                  leading: const Icon(Icons.info),
                  onPressed: (BuildContext context) {
                    showAboutAppDialog(context, aboutTitle, aboutDescription);
                  },
                ),
                SettingsTile(
                  title:
                      Text(FlutterI18n.translate(context, "settings.version")),
                  trailing: const Text(version),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
