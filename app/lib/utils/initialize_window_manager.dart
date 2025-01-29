import 'dart:ui';

import 'package:profit_taker_analyzer/constants/layout_constants.dart';
import 'package:window_manager/window_manager.dart';

/// Initializes the window manager for the application.
///
/// This function ensures that the window manager is properly initialized and sets up the window
/// with specified options such as size, minimum size, and centering. It then waits for the window to be ready
/// and displays and focuses the window once it is ready.
///
/// Returns:
/// A [Future<void>] that completes once the window manager is initialized and the window is shown and focused.
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
