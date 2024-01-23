import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'package:profit_taker_analyzer/widgets/navigation_bar.dart'
    as custom_nav;
import 'screens/home/home_screen.dart';
import 'screens/advanced_screen.dart';
import 'screens/settings_screen.dart';
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
}

/// The mutable state for the MyApp widget.
class _MyAppState extends State<MyApp> {
  /// Current index of selected tab.
  int _currentIndex = 0;

  /// Builds the widget tree.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: lightTheme,
      darkTheme: darkTheme,

      /// Use dark theme by default
      themeMode: ThemeMode.dark,
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
                  AdvancedScreen(),

                  /// Settings screen widget.
                  SettingsScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
