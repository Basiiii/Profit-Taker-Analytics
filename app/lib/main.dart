import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:profit_taker_analyzer/app.dart';
import 'package:profit_taker_analyzer/screens/home/widgets/layout_preferences.dart';
import 'package:profit_taker_analyzer/services/database/database_service.dart';
import 'package:profit_taker_analyzer/services/run_navigation_service.dart';
import 'package:profit_taker_analyzer/services/screenshot_service.dart';
import 'package:profit_taker_analyzer/utils/action_keys.dart';
import 'package:profit_taker_analyzer/utils/initialize_window_manager.dart';
import 'package:profit_taker_analyzer/utils/language.dart';
import 'package:provider/provider.dart';
import 'package:profit_taker_analyzer/theme/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:rust_core/rust_core.dart';

/// The entry point of the application.
///
/// This method ensures the app is properly initialized, sets up key resources (such as database,
/// preferences, and window configuration), and then runs the app using `runApp`.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Rust Core library
  await RustLib.init();

  // Initialize window manager
  initializeWindowManager();

  // Initialize the database factory for ffi
  databaseFactory = databaseFactoryFfi;

  // Load key mappings for Home controls
  ActionKeyManager.upActionKey =
      await ActionKeyManager.loadUpActionKey() ?? LogicalKeyboardKey.arrowUp;
  ActionKeyManager.downActionKey = await ActionKeyManager.loadDownActionKey() ??
      LogicalKeyboardKey.arrowDown;

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Initialize the database
  final databaseService = DatabaseService();
  await databaseService.initialize();

  // Run the app with ThemeProvider and LocaleModel
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LayoutPreferences()),
        Provider<DatabaseService>(create: (_) => databaseService),
        ChangeNotifierProvider(
          create: (context) => RunNavigationService(
            databaseService: context.read<DatabaseService>(),
          ),
        ),
        ChangeNotifierProvider<ThemeProvider>(
          create: (context) => ThemeProvider(prefs),
        ),
        ChangeNotifierProvider<LocaleModel>(
          create: (context) => LocaleModel(prefs),
        ),
        ChangeNotifierProvider(create: (_) => ScreenshotService()),
      ],
      child: const AppRoot(),
    ),
  );
}
