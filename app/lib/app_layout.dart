import 'package:flutter/material.dart';
import 'package:profit_taker_analyzer/screens/analytics/analytics_screen.dart';
import 'package:profit_taker_analyzer/screens/home/home_screen.dart';
import 'package:profit_taker_analyzer/screens/settings/settings_screen.dart';
import 'package:profit_taker_analyzer/widgets/navigation_bar.dart'
    as custom_nav;

/// The main layout widget that handles the app's navigation.
///
/// This widget displays a navigation bar on the left and dynamically loads the screen
/// on the right side based on the selected tab. It is responsible for managing navigation
/// between different screens in the app.
///
/// The layout uses a `Row` to place the `NavigationBar` and the active screen side by side.
/// The active screen changes when a tab is selected from the navigation bar.
class AppLayout extends StatefulWidget {
  const AppLayout({super.key});

  @override
  AppLayoutState createState() => AppLayoutState();
}

class AppLayoutState extends State<AppLayout> {
  int _currentIndex = 0;
  Widget? _activeScreen;

  @override
  void initState() {
    super.initState();
    _activeScreen = const HomeScreen(); // Default screen to show
  }

  /// Changes the active screen based on the selected tab in the navigation bar.
  ///
  /// The [navIndex] corresponds to the index of the selected tab. This method updates
  /// the `_currentIndex` and sets the `_activeScreen` to the screen corresponding to the
  /// selected tab.
  void _selectTab(int navIndex) {
    setState(() {
      _currentIndex = navIndex;
      _activeScreen = _getScreenByIndex(navIndex);
    });
  }

  /// Returns the screen widget corresponding to the given index.
  ///
  /// This method maps the provided index to the appropriate screen widget.
  ///
  /// If the index doesn't match any of the specified cases, the default screen is HomeScreen.
  Widget _getScreenByIndex(int index) {
    switch (index) {
      case 0:
        return const HomeScreen();
      case 3:
        return const AnalyticsScreen();
      case 4:
        return const SettingsScreen();
      default:
        return const HomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The layout consists of a Row with the NavigationBar on the left
      // and the currently active screen on the right.
      body: Row(
        children: <Widget>[
          custom_nav.NavigationBar(
            currentIndex: _currentIndex,
            onTabSelected: _selectTab,
          ),
          Expanded(child: _activeScreen!),
        ],
      ),
    );
  }
}
