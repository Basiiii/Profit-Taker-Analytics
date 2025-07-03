import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:profit_taker_analyzer/app.dart';
import 'package:profit_taker_analyzer/screens/home/widgets/layout_preferences.dart';
import 'package:profit_taker_analyzer/services/database/database_service.dart';
import 'package:profit_taker_analyzer/services/run_navigation_service.dart';
import 'package:profit_taker_analyzer/services/screenshot_service.dart';
import 'package:profit_taker_analyzer/services/input/action_keys.dart';
import 'package:profit_taker_analyzer/utils/initialization/initialize_parser.dart';
import 'package:profit_taker_analyzer/utils/initialization/initialize_window_manager.dart';
import 'package:profit_taker_analyzer/utils/localization/language.dart';
import 'package:provider/provider.dart';
import 'package:profit_taker_analyzer/theme/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rust_core/rust_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'dart:convert';

/// The entry point of the application.
///
/// This method ensures the app is properly initialized, sets up key resources (such as database,
/// preferences, and window configuration), and then runs the app using `runApp`.
void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  String? deepLinkCode;
  if (args.isNotEmpty && args[0].startsWith('pta://')) {
    final uri = Uri.parse(args[0]);
    deepLinkCode = uri.queryParameters['code'];
    if (deepLinkCode != null) {
      // Exchange code for session
      final supabaseUrl = dotenv.env['SUPABASE_URL']!;
      final authUrl = '$supabaseUrl/auth/v1/token?grant_type=pkce';
      final client = HttpClient();
      final request = await client.postUrl(Uri.parse(authUrl));
      request.headers.contentType = ContentType('application', 'json');
      request.write(
          '{"code": "$deepLinkCode", "redirect_uri": "pta://auth-callback", "grant_type": "pkce"}');
      final httpResponse = await request.close();
      final responseBody =
          await httpResponse.transform(SystemEncoding().decoder).join();
      try {
        final Map<String, dynamic> json = jsonDecode(responseBody);
        final accessToken = json['access_token'];
        final refreshToken = json['refresh_token'];
        if (accessToken != null && refreshToken != null) {
          await Supabase.instance.client.auth.setSession(refreshToken);
          print('Login successful!');
        } else {
          print('Login failed: Invalid session.');
        }
      } catch (e) {
        print('Login failed: ${e.toString()}');
      }
    }
  }

  // Initialize Rust Core library
  await RustLib.init();

  // Initialize window manager
  initializeWindowManager();

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

  // Initialize parser
  initializeParser();

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
