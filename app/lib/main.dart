import 'package:flutter/material.dart';
import 'package:profit_taker_analyzer/theme/theme_control.dart';
import 'theme/app_theme.dart';
import 'package:profit_taker_analyzer/widgets/navigation_bar.dart'
    as custom_nav;
import 'screens/home/home_screen.dart';
import 'screens/run_storage/runs_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

/// Main function to run the application.
void main() {
  runApp(const MyApp());

  doWhenWindowReady(() {
    const initialSize = Size(1500, 750);
    appWindow.minSize = const Size(870, 600);
    appWindow.maxSize = const Size(1920, 1080);
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.title = "Profit Taker Analytics";
    appWindow.show();
  });
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
class _MyAppState extends State<MyApp> {
  /// Current index of selected tab.
  int _currentIndex = 0;

  /// Future for loading the theme mode.
  Future<void>? _themeModeFuture;

  @override
  void initState() {
    super.initState();
    _themeModeFuture = loadThemeMode();
  }

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
}
