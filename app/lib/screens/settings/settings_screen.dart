import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:profit_taker_analyzer/services/settings_service.dart';
import 'package:provider/provider.dart';
import 'package:profit_taker_analyzer/utils/language.dart';
import 'package:profit_taker_analyzer/utils/action_keys.dart';

import 'ui/general_section.dart';
import 'ui/links_section.dart';
import 'ui/about_section.dart';
import 'ui/key_config_section.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Locale _currentLocale;
  bool _upWaitingForKeyPress = false;
  bool _downWaitingForKeyPress = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _currentLocale = Localizations.localeOf(context);
  }

  void _handleKeyPress(bool isUpKey, LogicalKeyboardKey newKey) {
    setState(() {
      if (isUpKey) {
        upActionKey = newKey;
        saveUpActionKey();
        _upWaitingForKeyPress = false;
      } else {
        downActionKey = newKey;
        saveDownActionKey();
        _downWaitingForKeyPress = false;
      }
    });
  }

  void _startListening(bool isUpKey) {
    setState(() {
      if (isUpKey) {
        _upWaitingForKeyPress = true;
      } else {
        _downWaitingForKeyPress = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FocusTraversalGroup(
      descendantsAreFocusable: false,
      child: Scaffold(
        body: Center(
          child: SettingsList(
            darkTheme: SettingsThemeData(
              settingsListBackground: Theme.of(context).colorScheme.surface,
            ),
            sections: [
              buildGeneralSection(
                context,
                _currentLocale,
                () => _showLanguageDialog(context),
              ),
              buildLinksSection(context),
              buildKeyConfigSection(
                context,
                _upWaitingForKeyPress,
                _downWaitingForKeyPress,
                _handleKeyPress,
                _startListening,
              ),
              buildAboutSection(context),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(FlutterI18n.translate(context, "settings.change_language")),
        children: SettingsService.supportedLanguages.map((locale) {
          return SimpleDialogOption(
            onPressed: () => _changeLanguage(context, locale),
            child: Text(
              FlutterI18n.translate(
                  context, "languages.${locale.languageCode}"),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _changeLanguage(BuildContext context, Locale locale) {
    Provider.of<LocaleModel>(context, listen: false).setLocale(locale);
    setState(() => _currentLocale = locale);

    Navigator.pop(context);
  }
}
