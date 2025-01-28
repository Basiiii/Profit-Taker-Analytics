import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:profit_taker_analyzer/screens/settings/utils/key_handler.dart';
import 'package:profit_taker_analyzer/utils/action_keys.dart';
import 'package:profit_taker_analyzer/widgets/key_config_tile.dart';

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
        keyLabel: upActionKey.keyLabel,
        waitingForKey: upWaiting,
        onStartListening: () {
          onStartListening(true);
          startListeningForKeys((key) => onKeySet(true, key));
        },
      ),
      KeyConfigTile(
        title: FlutterI18n.translate(context, "settings.config_down_key"),
        keyLabel: downActionKey.keyLabel,
        waitingForKey: downWaiting,
        onStartListening: () {
          onStartListening(false);
          startListeningForKeys((key) => onKeySet(false, key));
        },
      ),
    ],
  );
}
