import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:profit_taker_analyzer/constants/features/screenshot_constants.dart';
import 'package:screenshot/screenshot.dart';
import 'package:super_clipboard/super_clipboard.dart';

/// An enumeration that represents the status of a screenshot operation.
enum ScreenshotStatus {
  /// Indicates that the screenshot was successfully captured and copied to the clipboard.
  success,

  /// Indicates that an unknown error occurred during the screenshot operation.
  failure,

  /// Indicates that the screenshot capture failed.
  screenshotFailure,

  /// Indicates that the Clipboard API is not supported on the current platform.
  unsupportedPlatform,

  /// Indicates that the temporary directory where screenshots should be saved does not exist.
  directoryDoesNotExist
}

/// A map that associates each [ScreenshotStatus] with a corresponding message.
const Map<ScreenshotStatus, String> messages = {
  ScreenshotStatus.success: 'Image copied to clipboard',
  ScreenshotStatus.failure: 'An unknown error occurred',
  ScreenshotStatus.unsupportedPlatform:
      'Clipboard API is not supported on this platform',
  ScreenshotStatus.directoryDoesNotExist: 'Temporary directory does not exist',
  ScreenshotStatus.screenshotFailure: 'Failed to capture screenshot',
};

/// Captures a screenshot using the provided [ScreenshotController].
///
/// This function captures a screenshot using the provided [ScreenshotController], saves it as a `.png`
/// to the temporary directory of the system and then saves that `.png` to the clipboard.
///
/// At the end returns the status of the operation.
///
/// Parameters:
/// * `screenshotController`: The controller for capturing screenshots.
///
/// Returns a [Future] that completes with a [ScreenshotStatus] value indicating the outcome of the operation.
Future<ScreenshotStatus> captureScreenshot(
    ScreenshotController screenshotController) async {
  try {
    Uint8List? image = await screenshotController.capture();
    if (image == null) {
      return ScreenshotStatus.screenshotFailure;
    }

    final directory = await getTemporaryDirectory();
    if (!(await directory.exists())) {
      return ScreenshotStatus.directoryDoesNotExist;
    }

    final path = directory.path;
    final file = File('$path/${ScreenshotConstants.screenshotFileName}');
    await file.writeAsBytes(image);

    final clipboard = SystemClipboard.instance;
    if (clipboard == null) {
      return ScreenshotStatus.unsupportedPlatform;
    }

    final item = DataWriterItem();
    item.add(Formats.png(image));
    await clipboard.write([item]);

    return ScreenshotStatus.success;
  } catch (_) {
    return ScreenshotStatus.failure;
  }
}
