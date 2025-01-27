import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';
import 'package:profit_taker_analyzer/utils/action_keys.dart';

class AppInitializer {
  static Future<void> initialize() async {
    // TODO: update function, create one to fetch version from remote server and another to check if current is latest
    // Check for latest version
    // bool isMostRecentVersion = await checkVersion();

    // Load key mappings
    upActionKey = await loadUpActionKey() ?? LogicalKeyboardKey.arrowUp;
    downActionKey = await loadDownActionKey() ?? LogicalKeyboardKey.arrowDown;
  }
}
