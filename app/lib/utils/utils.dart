import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:profit_taker_analyzer/main.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_clipboard/super_clipboard.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:window_manager/window_manager.dart';

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
    final file = File('$path/screenshot.png');
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

/// Displays an error dialog to the user.
///
/// This method creates an AlertDialog with a title indicating that there was an error closing the parser.
/// The content of the dialog tells the user to try again. The dialog has two action buttons: 'FORCE QUIT' and 'Okay'.
///
/// Clicking the 'FORCE QUIT' button closes the dialog and forces the destruction of the window.
/// Clicking the 'Okay' button simply closes the dialog.
///
/// The method uses the `showDialog` function to display the AlertDialog. The `showDialog` function
/// requires a context and a builder function.
/// The builder function returns the AlertDialog to be displayed.
void showErrorDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) {
      return AlertDialog(
          title: const Text('There was an error closing parser.'),
          content: const Text('Please try again.'),
          actions: [
            TextButton(
                child: Text('FORCE QUIT',
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error)),
                onPressed: () async {
                  Navigator.of(context).pop();
                  await windowManager.destroy();
                }),
            TextButton(
                child: const Text('Okay'),
                onPressed: () {
                  Navigator.of(context).pop();
                })
          ]);
    },
  );
}

/// Displays an about dialog with information about the app.
///
/// This function shows a dialog with a title of "About", and content describing
/// the author of the app and instructions for reaching out via Discord. The user
/// can close the dialog by pressing the "OK" button.
void showAboutAppDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('About'),
        content: const Text(
            'Made with love by Basi.\nIf you found this, send me a DM\nof a mango on discord.'),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        ],
      );
    },
  );
}

/// Switches the current theme.
///
/// Checks the current theme mode and switches it to the other mode.
/// Then, it saves the new theme mode to the shared preferences.
Future<void> switchTheme() async {
  ThemeMode newMode = MyApp.themeNotifier.value == ThemeMode.light
      ? ThemeMode.dark
      : ThemeMode.light;

  MyApp.themeNotifier.value = newMode;

  SharedPreferences prefs = await SharedPreferences.getInstance();
  Map<ThemeMode, String> themeModeMap = {
    ThemeMode.light: 'light',
    ThemeMode.dark: 'dark',
  };
  prefs.setString('themeMode', themeModeMap[newMode]!);
}

/// Launches a URL.
///
/// Parses the provided URL and checks if it can be launched.
/// If it can be launched, it does so. Otherwise, it throws an error.
void launchURL(String url) async {
  final Uri parsedUrl = Uri.parse(url);
  if (await canLaunchUrl(parsedUrl)) {
    await launchUrl(parsedUrl);
  } else {
    throw 'Could not launch $url';
  }
}

/// Displays a connection error dialog when the app fails to connect to the parser.
///
/// This function shows a dialog with a title of "Error!" and content advising the user
/// to restart the program. If the problem persists, they are instructed to contact Basi.
/// The user can close the dialog by pressing the "OK" button.
void showParserConnectionErrorDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Error!'),
        content: const Text(
            'The app cannot establish a connection to the parser.\nPlease restart the program.\n\nIf you continue with issues please contact Basi.'),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        ],
      );
    },
  );
}