import 'package:flutter/material.dart';
import 'package:profit_taker_analyzer/app.dart';
import 'package:profit_taker_analyzer/constants/layout_constants.dart';
import 'package:profit_taker_analyzer/services/database/database_service.dart';
import 'package:profit_taker_analyzer/utils/app_initializer.dart';
import 'package:profit_taker_analyzer/utils/language.dart';
import 'package:provider/provider.dart';
import 'package:profit_taker_analyzer/theme/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize window manager
  await windowManager.ensureInitialized();
  WindowOptions windowOptions = const WindowOptions(
    size: Size(LayoutConstants.startingWidth, LayoutConstants.startingHeight),
    minimumSize:
        Size(LayoutConstants.minimumWidth, LayoutConstants.minimumHeight),
    center: true,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  // Initialize the database factory for ffi
  databaseFactory = databaseFactoryFfi;

  // Initialize other app resources
  await AppInitializer.initialize();

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Initialize language settings
  String language = prefs.getString('language') ?? "en";

  // Initialize the database
  await DatabaseService().initialize();

  // Run the app with ThemeProvider and LocaleModel
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(
          create: (context) => ThemeProvider(prefs),
        ),
        ChangeNotifierProvider<LocaleModel>(
          create: (context) => LocaleModel(prefs), // Provide LocaleModel
        ),
      ],
      child: const MyApp(),
    ),
  );
}
