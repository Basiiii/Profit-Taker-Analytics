import 'dart:io';

import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:profit_taker_analyzer/utils/utils.dart';
import 'package:profit_taker_analyzer/theme/theme_control.dart';

import 'package:profit_taker_analyzer/widgets/navigation_bar.dart'
    as custom_nav;
import 'package:window_manager/window_manager.dart';

import 'screens/home/home_screen.dart';
import 'screens/run_storage/runs_screen.dart';
import 'screens/settings/settings_screen.dart';

import 'theme/app_theme.dart';

class ProcessHolder {
  static final ProcessHolder _singleton = ProcessHolder._internal();

  factory ProcessHolder() {
    return _singleton;
  }

  Future<Process?>? parserProcess;

  ProcessHolder._internal();
}

/// Main function to run the application.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Must add this line.
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(1500, 750),
    minimumSize: Size(870, 600),
    center: true,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  windowManager.show();

  runApp(
    MaterialApp(
      home: FlutterSplashScreen.fadeIn(
        backgroundColor: const Color(0xFF121212),
        childWidget: SizedBox(
          height: 75,
          width: 75,
          child: Image.asset("assets/AppIcon.png"),
        ),
        onAnimationEnd: () => debugPrint("On Fade In End"),
        nextScreen: const MyApp(),
        duration: const Duration(milliseconds: 3500),
        onInit: () async {
          // debugPrint("onInit");
          ProcessHolder().parserProcess = startParser();
        },
        onEnd: () async {
          // debugPrint("onEnd 1");
        },
      ),
    ),
  );
}

/// Main widget of the application.
class MyApp extends StatefulWidget {
  /// Constructor for MyApp.
  const MyApp({super.key});

  /// Creates the mutable state for this widget at a given location in the tree.
  @override
  State<MyApp> createState() => _MyAppState();

  static final ValueNotifier<ThemeMode> themeNotifier =
      ValueNotifier(ThemeMode.dark);
}

/// The mutable state for the MyApp widget.
class _MyAppState extends State<MyApp> with WindowListener {
  /// Current index of selected tab.
  int _currentIndex = 0;

  /// Future for loading the theme mode.
  Future<void>? _themeModeFuture;

  /// Initializes the state of this widget.
  ///
  /// This method is called once when creating the state of this widget.
  /// It initializes the [_themeModeFuture] by calling the [loadThemeMode] method,
  /// adds the current instance as a listener to the [windowManager],
  /// and finally calls the [_init] method.
  @override
  void initState() {
    super.initState();
    _themeModeFuture = loadThemeMode();
    windowManager.addListener(this);
    _init();
  }

  /// Cleans up the resources used by this widget.
  ///
  /// This method is called when the framework is done using this widget.
  /// It removes the current instance as a listener to the [windowManager]
  /// and then calls the [dispose] method of the superclass.
  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  /// Prevents the window from closing.
  ///
  /// This method sets the prevent close flag of the [windowManager] to true,
  /// ensuring that the window cannot be closed by the user until this flag is set to false again.
  /// After setting the prevent close flag, it triggers a rebuild of the widget tree
  /// by calling [setState].
  void _init() async {
    await windowManager.setPreventClose(true);
    setState(() {});
  }

  /// Builds the widget tree.
  ///
  /// This method is responsible for building the widget tree of this widget.
  /// It uses a [FutureBuilder] to wait for the [_themeModeFuture] to complete.
  /// Once the future completes, it builds the UI with a [MaterialApp] widget,
  /// which uses a [ValueListenableBuilder] to listen for changes to the theme mode.
  /// The body of the scaffold contains a navigation bar and a stack of screens.
  /// While waiting for the [_themeModeFuture] to complete, it displays a circular progress indicator.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _themeModeFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return ValueListenableBuilder<ThemeMode>(
              valueListenable: MyApp.themeNotifier,
              builder: (_, ThemeMode currentMode, __) {
                return MaterialApp(
                  theme: lightTheme,
                  darkTheme: darkTheme,
                  themeMode: currentMode,
                  home: Scaffold(
                    body: Row(
                      children: <Widget>[
                        /// Navigation bar widget.
                        custom_nav.NavigationBar(
                          /// Callback function when a tab is selected.
                          onTabSelected: (index) {
                            setState(() {
                              _currentIndex = index;
                            });
                          },
                        ),
                        Expanded(
                          child: IndexedStack(
                            index: _currentIndex,
                            children: const <Widget>[
                              /// Home screen widget.
                              HomeScreen(),

                              /// Advanced screen widget.
                              RunStorage(),

                              /// Settings screen widget.
                              SettingsScreen(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              });
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }

  /// Handles the event when the window is being closed.
  ///
  /// When the window is being closed, this method attempts to kill the Parser process.
  /// If the window should not be closed (`isPreventClose` is true), and the Parser process could not be killed successfully,
  /// it shows an error dialog. Otherwise, it destroys the window.
  ///
  /// The method is asynchronous because it involves waiting for the Parser process to be killed, and possibly showing a dialog.
  ///
  /// The `@override` annotation indicates that this method overrides a method from a superclass.
  /// In this case, it's overriding the `onWindowClose` method from the `WindowListener` mixin.
  ///
  /// See also:
  /// * [windowManager.isPreventClose](https://pub.dev/documentation/window_manager/latest/)
  /// * [windowManager.destroy](https://pub.dev/documentation/window_manager/latest/)
  /// * [ProcessHolder](https://api.dart.dev/stable/2.14.4/dart-io/Process-class.html)
  /// * [WindowListener](https://pub.dev/documentation/window_manager/latest/)
  @override
  void onWindowClose() async {
    bool isPreventClose = await windowManager.isPreventClose();

    /// Attempt to kill Parser process
    ProcessHolder().parserProcess?.then((process) async {
      /// `process` will be null if it failed to start the parser executable in the beginning
      if (process != null) {
        bool success = process.kill();

        /// If there was an error killing process, display error
        if (isPreventClose && !success && mounted) {
          showErrorDialog(context);
        } else {
          await windowManager.destroy();
        }
      } else {
        await windowManager.destroy();
      }
    });
  }
}
