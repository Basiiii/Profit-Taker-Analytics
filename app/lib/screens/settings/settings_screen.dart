import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:profit_taker_analyzer/screens/settings/utils/language_utils.dart';
import 'package:profit_taker_analyzer/screens/settings/utils/select_folder.dart';
import 'package:profit_taker_analyzer/services/input/action_keys.dart';
import 'package:profit_taker_analyzer/widgets/dialogs/show_onboarding_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'ui/general_section.dart';
import 'ui/links_section.dart';
import 'ui/about_section.dart';
import 'ui/key_config_section.dart';
import 'ui/account_section.dart';
import 'ui/donate_section.dart';

/// A StatefulWidget that displays the settings screen of the application.
///
/// The settings screen allows users to configure various app preferences, such as the
/// language and key bindings for action keys. It manages the state for the current locale
/// and key press status.
///
/// Returns:
/// A [SettingsScreen] widget.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

/// The state for [SettingsScreen], responsible for managing the settings UI.
///
/// This class tracks the current locale and the state of the "up" and "down" action key presses.
/// It listens for changes in the locale and provides logic for updating the settings.
///
/// Instance variables:
/// - [_currentLocale]: The current locale of the app, used for localization.
/// - [_upWaitingForKeyPress]: A flag indicating whether the app is waiting for a key press for the "up" action key.
/// - [_downWaitingForKeyPress]: A flag indicating whether the app is waiting for a key press for the "down" action key.
/// - [_user]: The current user object.
/// - [_username]: The username of the current user.
///
/// Methods:
/// - [didChangeDependencies]: A lifecycle method that updates the current locale when dependencies change.
/// - [refreshUser]: A method to refresh the user information.
/// - [onLogout]: A method to handle user logout.
class _SettingsScreenState extends State<SettingsScreen> {
  late Locale _currentLocale;
  bool _upWaitingForKeyPress = false;
  bool _downWaitingForKeyPress = false;
  User? _user;
  String? _username;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _currentLocale = Localizations.localeOf(context);
    _refreshUser();
  }

  void _refreshUser() {
    final user = Supabase.instance.client.auth.currentUser;
    setState(() {
      _user = user;
      _username = user?.userMetadata?['username'] ??
          user?.userMetadata?['full_name'] ??
          user?.email;
    });
  }

  void _onLogout() async {
    await Supabase.instance.client.auth.signOut();
    setState(() {
      _user = null;
      _username = null;
    });
  }

  /// Handles the key press events for configuring action keys.
  ///
  /// When a key is pressed, this method updates the appropriate action key (up or down)
  /// in the `ActionKeyManager` and saves the changes. It also manages the state to indicate
  /// that the key press was processed.
  ///
  /// Parameters:
  /// - [isUpKey]: A boolean indicating whether the key is for the "up" action (true) or the "down" action (false).
  /// - [newKey]: The new key that was pressed, represented as a `LogicalKeyboardKey`.
  ///
  /// Returns:
  /// None. This method updates the state and saves the new action key.
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

  /// Starts listening for a key press to configure either the "up" or "down" action key.
  ///
  /// This method sets the waiting state to true for the appropriate action key, indicating
  /// that the user needs to press a key to assign it.
  ///
  /// Parameters:
  /// - [isUpKey]: A boolean indicating whether to listen for the "up" action key (true) or the "down" action key (false).
  ///
  /// Returns:
  /// None. This method updates the state to signal that a key press is awaited.
  void _startListening(bool isUpKey) {
    setState(() {
      if (isUpKey) {
        _upWaitingForKeyPress = true;
      } else {
        _downWaitingForKeyPress = true;
      }
    });
  }

  /// Displays a dialog allowing the user to change the app's language.
  ///
  /// This method shows the language selection dialog and updates the app's locale
  /// based on the user's selection.
  ///
  /// Parameters:
  /// - [context]: The build context used to display the dialog.
  ///
  /// Returns:
  /// None. This method triggers a callback to update the app's locale once a language is selected.
  void _showLanguageDialog(BuildContext context) {
    showLanguageDialog(context, (locale) {
      setState(() => _currentLocale = locale);
    });
  }

  void _onSignUp(BuildContext context) async {
    final url = Uri.parse('https://stats.profit-taker.com/auth/sign-up');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _onSignIn(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => SignInDialog(),
    );
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
                () => showOnboardingDialog(context, true),
                () => selectFolder(context),
              ),
              buildAccountSection(
                context,
                _user,
                _username,
                () => _onSignIn(context),
                () => _onSignUp(context),
                () => _onLogout(),
              ),
              buildDonateSection(context),
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
