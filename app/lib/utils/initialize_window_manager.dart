import 'dart:ui';

import 'package:profit_taker_analyzer/constants/layout_constants.dart';
import 'package:window_manager/window_manager.dart';

Future<void> initializeWindowManager() async {
  await windowManager.ensureInitialized();
  WindowOptions windowOptions = const WindowOptions(
    size: Size(LayoutConstants.startingWidth, LayoutConstants.startingHeight),
    minimumSize:
        Size(LayoutConstants.minimumWidth, LayoutConstants.minimumHeight),
    center: true,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
}
