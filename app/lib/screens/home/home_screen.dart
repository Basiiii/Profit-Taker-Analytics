import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:profit_taker_analyzer/main.dart';
import 'package:profit_taker_analyzer/screens/home/home_widgets.dart';
import 'package:profit_taker_analyzer/widgets/text_widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:super_clipboard/super_clipboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

/// An enumeration of possible statuses for the screenshot operation.
enum ScreenshotStatus {
  success,
  failure,
  unsupportedPlatform,
  directoryDoesNotExist,
  screenshotFailure,
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

/// The HomeScreen widget represents the home screen of the application.
///
/// This widget uses a Scaffold to provide a basic structure for the app,
/// including an AppBar and a Body. The body of the scaffold is a single
/// child scroll view, containing various widgets such as titles, buttons,
/// and cards.
///
/// Example usage:
/// ```dart
/// HomeScreen()
/// ```
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/// The _HomeScreenState class represents the mutable state for the HomeScreen widget.
///
/// This class contains a GlobalKey for the Scaffold, which allows for
/// opening and closing of drawers programmatically.
class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  ScreenshotController screenshotController = ScreenshotController();

  Future<ScreenshotStatus> captureScreenshot() async {
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

  /// Overrides the build method to construct the widget tree.
  ///
  /// This method returns a Scaffold widget, which provides a framework
  /// for major parts of the material design visual layout structure, such as
  /// an AppBar and a Body.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: SingleChildScrollView(
          child: Padding(
              padding: const EdgeInsets.only(left: 60, top: 30),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: [
                        titleText(
                            'Profit Taker Analytics', 32, FontWeight.bold),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                  icon: Icon(MyApp.themeNotifier.value ==
                                          ThemeMode.light
                                      ? Icons.nightlight
                                      : Icons.wb_sunny),
                                  onPressed: () async {
                                    ThemeMode newMode =
                                        MyApp.themeNotifier.value ==
                                                ThemeMode.light
                                            ? ThemeMode.dark
                                            : ThemeMode.light;

                                    MyApp.themeNotifier.value = newMode;

                                    SharedPreferences prefs =
                                        await SharedPreferences.getInstance();
                                    Map<ThemeMode, String> themeModeMap = {
                                      ThemeMode.light: 'light',
                                      ThemeMode.dark: 'dark',
                                    };
                                    prefs.setString(
                                        'themeMode', themeModeMap[newMode]!);
                                  }),
                              Padding(
                                padding: const EdgeInsets.only(right: 15),
                                child: drawerButton(_scaffoldKey),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    titleText('Hello User!', 24, FontWeight.normal),
                    const SizedBox(height: 25),
                    Row(
                      children: [
                        titleText('Your last run', 20, FontWeight.w500),
                        IconButton(
                          icon: const Icon(Icons.share, size: 18),
                          onPressed: () {
                            var scaffoldMessenger =
                                ScaffoldMessenger.of(context);
                            captureScreenshot().then((status) {
                              String message =
                                  messages[status] ?? 'Unknown status';
                              scaffoldMessenger.showSnackBar(
                                SnackBar(content: Text(message)),
                              );
                            });
                          },
                        )
                      ],
                    ),
                    const SizedBox(height: 15),
                    Screenshot(
                        controller: screenshotController,
                        child: Column(
                          children: [
                            Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Wrap(
                                    spacing: 12.0,
                                    runSpacing: 12.0,
                                    children: [
                                      ...List.generate(
                                          6,
                                          (index) => buildOverviewCard(
                                              index, context)),
                                      ...List.generate(
                                          4,
                                          (index) =>
                                              buildPhaseCard(index, context)),
                                    ])),
                          ],
                        )),
                    const SizedBox(height: 12), // Space between elements
                  ]))),
      endDrawer: Drawer(
        //TODO: DATA FROM DRAWER MUST BE FETCHED DYNAMICALLY
        child: Container(
          color: const Color(0xFF070417),
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              ListTile(
                title: Text(
                  'Latest runs',
                  style: TextStyle(
                    fontSize: (MediaQuery.of(context).size.width * 0.02)
                        .clamp(10, 30),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                title: Text(
                  '15/11/2023 @ 15:04',
                  style: TextStyle(
                      fontSize: (MediaQuery.of(context).size.width * 0.01)
                          .clamp(10, 15)),
                ),
                onTap: () {
                  // TODO: BUTTON MUST LOAD DATA FROM SPECIFIC RUN CHOSEN
                  // Update the state of the app
                  // ...
                  // Then close the drawer
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
