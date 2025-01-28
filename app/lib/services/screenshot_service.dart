import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';

class ScreenshotService extends ChangeNotifier {
  final ScreenshotController controller = ScreenshotController();

  void updateController() {
    notifyListeners();
  }
}
