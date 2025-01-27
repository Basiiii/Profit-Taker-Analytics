import 'package:flutter/material.dart';
import 'package:profit_taker_analyzer/screens/analytics/analytics_screen.dart';
import 'package:profit_taker_analyzer/screens/favorite/favorite_screen.dart';
import 'package:profit_taker_analyzer/screens/home/home_screen.dart';
import 'package:profit_taker_analyzer/screens/settings/settings_screen.dart';
import 'package:profit_taker_analyzer/screens/storage/storage_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case '/settings':
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case '/analytics':
        return MaterialPageRoute(builder: (_) => const AnalyticsScreen());
      // case '/favorites':
      //   return MaterialPageRoute(builder: (_) => const FavoriteScreen());
      // case '/storage':
      //   return MaterialPageRoute(builder: (_) => const StorageScreen());
      default:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
    }
  }
}
