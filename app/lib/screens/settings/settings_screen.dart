import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';

import 'package:profit_taker_analyzer/constants/constants.dart';
import 'package:profit_taker_analyzer/utils/action_keys.dart';

import 'package:profit_taker_analyzer/main.dart';
import 'package:profit_taker_analyzer/utils/language.dart';

import 'package:profit_taker_analyzer/widgets/dialogs.dart';

import 'package:profit_taker_analyzer/utils/utils.dart';

import 'package:profit_taker_analyzer/theme/custom_icons.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A callback function type for setting a key.
typedef KeySetterCallback = void Function(LogicalKeyboardKey key);

/// The settings screen of the application.
///
/// This screen provides users with various options to customize the app's behavior.
/// It includes sections such as General, Links, Report Bugs, and About.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  /// Indicates whether the system is currently waiting for a key press.
  bool upWaitingForKeyPress = false;
  bool downWaitingForKeyPress = false;

  /// Starts listening for key events and invokes the provided callback when a key is set.
  ///
  /// The [onKeySet] callback is invoked when a key is pressed down. Once a key is set,
  /// the listener is removed to avoid duplication of events.
  ///
  /// Parameters:
  /// - [onKeySet]: A callback function that takes a [LogicalKeyboardKey] as input.
  void startListeningForKeys(KeySetterCallback onKeySet) {
    void keyEventListener(RawKeyEvent event) {
      if (event is RawKeyDownEvent) {
        onKeySet(event.logicalKey);
        RawKeyboard.instance
            .removeListener(keyEventListener); // Remove the current listener
        return; // Exit the function after handling the event
      }
    }

    RawKeyboard.instance.addListener(keyEventListener);
  }

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      print("Opened settings screen");
    }
  }

  /// List of supported languages with corresponding [Locale] objects.
  final List<Locale> supportedLanguages = const [
    Locale('en', 'US'), // English
    Locale('pt', 'PT'), // Portuguese
    Locale('zh', 'CN'), // Chinese
    Locale('ru'), // Russian
    Locale('fr'), // French
  ];

  /// The currently selected locale.
  late Locale _currentLocale;

  /// Returns the localized name of the currently selected language.
  String _currentLanguage() {
    return FlutterI18n.translate(
        context, "languages.${_currentLocale.languageCode}");
  }

  /// Displays a dialog for selecting the app's language.
  ///
  /// Parameters:
  ///   - `context`: The build context providing access to the theme.
  ///   - `changeLanguage`: The localized text for the change language option.
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

  /// Changes the app's language based on the selected locale.
  ///
  /// Parameters:
  ///   - `locale`: The selected locale representing the new language.
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

  /// Overrides the method called when a dependency of this [State] object changes.
  ///
  /// This method is called whenever the dependencies of this [State] object change.
  /// It updates the [_currentLocale] variable with the current locale obtained from
  /// the [BuildContext].
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _currentLocale = Localizations.localeOf(context);
  }

  @override
  Widget build(BuildContext context) {
    /// Localized strings
    String changeLanguageText =
        FlutterI18n.translate(context, "settings.change_language");
    String contactText =
        FlutterI18n.translate(context, "settings.contact_basi");
    String contactContent =
        FlutterI18n.translate(context, "settings.basi_contacts_description");
    String aboutTitle = FlutterI18n.translate(context, "settings.about_app");
    String aboutDescription =
        FlutterI18n.translate(context, "settings.about_app_description");
    String okayText = FlutterI18n.translate(context, "buttons.ok");
    String donateTitle = FlutterI18n.translate(context, "donate.title");
    String donateMainText = FlutterI18n.translate(context, "donate.main");

    return FocusTraversalGroup(
      descendantsAreFocusable: false,
      child: Scaffold(
        body: Center(
          child: SettingsList(
            darkTheme: SettingsThemeData(
                settingsListBackground:
                    Theme.of(context).colorScheme.background),
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
                      },
                    ),
                  ),
                  SettingsTile(
                    title: Text(FlutterI18n.translate(
                        context, "settings.change_language")),
                    leading: const Icon(Icons.language),
                    trailing: Text(_currentLanguage()),
                    onPressed: (BuildContext context) {
                      _selectLanguage(context, changeLanguageText);
                    },
                  ),
                  SettingsTile(
                    title:
                        Text(FlutterI18n.translate(context, "donate.button")),
                    leading: const Icon(Icons.wallet_giftcard_rounded),
                    onPressed: (BuildContext context) {
                      showDonationDialog(context, donateTitle, donateMainText,
                          "PayPal", okayText);
                    },
                  )
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
                    title: Text(
                        FlutterI18n.translate(context, "settings.pt_guide")),
                    leading: const Icon(CustomIcons.book),
                    onPressed: (BuildContext context) {
                      launchURL(
                          'https://docs.google.com/document/d/1DWY-ZNv7cUA6egxDZKYu0e8qz7z-yHT2KncyYAo5NHU/edit?pli=1');
                    },
                  ),
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
                title:
                    Text(FlutterI18n.translate(context, "settings.key_config")),
                tiles: [
                  SettingsTile(
                    title: Text(FlutterI18n.translate(
                        context, "settings.config_up_key")),
                    leading: const Icon(Icons.arrow_forward_rounded),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (upWaitingForKeyPress)
                          Container(
                            width: 30,
                            height: 30,
                            padding: const EdgeInsets.all(5),
                            child: const CircularProgressIndicator(
                              backgroundColor: Color(0xFF86BCFC),
                              color: Colors.grey,
                              strokeWidth: 4,
                            ),
                          ),
                        if (upWaitingForKeyPress) const SizedBox(width: 10),
                        Text(upActionKey.keyLabel),
                      ],
                    ),
                    onPressed: (BuildContext context) {
                      if (!upWaitingForKeyPress) {
                        startListeningForKeys((key) {
                          setState(() {
                            upActionKey = key;
                            saveUpActionKey();
                            upWaitingForKeyPress = false;
                          });
                        });
                        setState(() {
                          upWaitingForKeyPress = true;
                        });
                      }
                    },
                  ),
                  SettingsTile(
                    title: Text(FlutterI18n.translate(
                        context, "settings.config_down_key")),
                    leading: const Icon(Icons.arrow_back_rounded),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (downWaitingForKeyPress)
                          Container(
                            width: 30,
                            height: 30,
                            padding: const EdgeInsets.all(5),
                            child: const CircularProgressIndicator(
                              backgroundColor: Color(0xFF86BCFC),
                              color: Colors.grey,
                              strokeWidth: 4,
                            ),
                          ),
                        if (downWaitingForKeyPress) const SizedBox(width: 10),
                        Text(downActionKey.keyLabel),
                      ],
                    ),
                    onPressed: (BuildContext context) {
                      if (!downWaitingForKeyPress) {
                        startListeningForKeys((key) {
                          setState(() {
                            downActionKey = key;
                            saveDownActionKey();
                            downWaitingForKeyPress = false;
                          });
                        });
                        setState(() {
                          downWaitingForKeyPress = true;
                        });
                      }
                    },
                  ),
                ],
              ),
              SettingsSection(
                title: Text(FlutterI18n.translate(context, "settings.about")),
                tiles: [
                  SettingsTile(
                    title: Text(FlutterI18n.translate(
                        context, "settings.contact_basi")),
                    leading: const Icon(Icons.contact_page),
                    onPressed: (BuildContext context) {
                      showContactsAppDialog(
                          context, contactText, contactContent);
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
                    title: Text(
                        FlutterI18n.translate(context, "settings.version")),
                    trailing: const Text(version),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
