import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';

/// A service class for managing screenshots using [ScreenshotController].
///
/// This class provides a [ScreenshotController] instance and a method
/// to notify listeners when an update is needed.
class ScreenshotService extends ChangeNotifier {
  /// The controller responsible for capturing screenshots.
  final ScreenshotController controller = ScreenshotController();

  /// Notifies listeners to update any dependencies on the screenshot controller.
  void updateController() {
    notifyListeners();
  }
}
