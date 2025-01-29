import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:profit_taker_analyzer/screens/settings/utils/key_handler.dart';
import 'package:profit_taker_analyzer/utils/action_keys.dart';
import 'package:profit_taker_analyzer/widgets/key_config_tile.dart';

/// Builds a settings section for configuring navigation keys.
///
/// This function creates a section within the settings UI where users can
/// configure their key bindings for navigation actions.
///
/// Parameters:
/// - [context]: The build context.
/// - [upWaiting]: A flag indicating if the application is waiting for the user to set the "Up" key.
/// - [downWaiting]: A flag indicating if the application is waiting for the user to set the "Down" key.
/// - [onKeySet]: A callback function triggered when a new key is set, receiving a boolean (`true` for up key, `false` for down key) and the selected [LogicalKeyboardKey].
/// - [onStartListening]: A callback function triggered when the app starts listening for key input, receiving a boolean (`true` for up key, `false` for down key).
///
/// Returns:
/// A [SettingsSection] containing tiles for configuring the up and down keys.
SettingsSection buildKeyConfigSection(
  BuildContext context,
  bool upWaiting,
  bool downWaiting,
  Function(bool isUpKey, LogicalKeyboardKey key) onKeySet,
  Function(bool isUpKey) onStartListening,
) {
  return SettingsSection(
    title: Text(FlutterI18n.translate(context, "settings.key_config")),
    tiles: [
      KeyConfigTile(
        title: FlutterI18n.translate(context, "settings.config_up_key"),
        keyLabel: ActionKeyManager.upActionKey.keyLabel,
        waitingForKey: upWaiting,
        onStartListening: () {
          onStartListening(true);
          startListeningForKeys((key) => onKeySet(true, key));
        },
      ),
      KeyConfigTile(
        title: FlutterI18n.translate(context, "settings.config_down_key"),
        keyLabel: ActionKeyManager.downActionKey.keyLabel,
        waitingForKey: downWaiting,
        onStartListening: () {
          onStartListening(false);
          startListeningForKeys((key) => onKeySet(false, key));
        },
      ),
    ],
  );
}
