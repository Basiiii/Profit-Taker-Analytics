import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:profit_taker_analyzer/screens/settings/utils/language_utils.dart';
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
        ActionKeyManager.upActionKey = newKey;
        ActionKeyManager.saveUpActionKey();
        _upWaitingForKeyPress = false;
      } else {
        ActionKeyManager.downActionKey = newKey;
        ActionKeyManager.saveDownActionKey();
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

  void _showLanguageDialog(BuildContext context) {
    showLanguageDialog(context, (locale) {
      setState(() => _currentLocale = locale);
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
}
