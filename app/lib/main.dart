/// main.dart - Entry point for Profit Taker Analytics.
///
/// **Author**: [Basi] - Enrique Rodrigues
///
/// **Date**: January 26, 2024
///
/// **Description**:
/// The Profit Taker Analytics project is designed to enhance the experience for
/// Profit Taker speedrunners in Warframe by providing an advanced analyzer with
/// a user-friendly Graphical User Interface (GUI). This project builds upon an
/// existing simple command line application, transforming it into a sophisticated
/// tool that bridges the gap between textual data and intuitive visual representation.
///
library;

import 'dart:io';

import 'package:flutter/material.dart';

import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:profit_taker_analyzer/utils/language.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

import 'package:profit_taker_analyzer/constants/constants.dart';

import 'package:profit_taker_analyzer/services/parser.dart';

import 'package:profit_taker_analyzer/widgets/loading_overlay.dart';
import 'package:profit_taker_analyzer/widgets/navigation_bar.dart'
    as custom_nav;

import 'package:profit_taker_analyzer/screens/home/home_screen.dart';
import 'package:profit_taker_analyzer/screens/storage/runs_screen.dart';
import 'package:profit_taker_analyzer/screens/settings/settings_screen.dart';

import 'package:profit_taker_analyzer/theme/theme_control.dart';
import 'package:profit_taker_analyzer/theme/app_theme.dart';

/// The main function that runs the application.
///
/// This function is responsible for initializing the application environment.
/// It ensures that Widget bindings have been initialized, retrieves the user's
/// preferred language from shared preferences, initializes the window manager,
/// sets up the window options, and finally runs the application with specific
/// localization delegates and supported locales.
void main() async {
  // Ensures that widget binding has been initialized.
  WidgetsFlutterBinding.ensureInitialized();

  // Retrieves the user's preferred language from shared preferences.
  final prefs = await SharedPreferences.getInstance();
  String language = prefs.getString('language') ?? "en";

  // Initializes the window manager.
  await windowManager.ensureInitialized();

  // Sets up the window options.
  WindowOptions windowOptions = const WindowOptions(
    size: Size(startingWidth, startingHeight),
    minimumSize: Size(minimumWidth, minimumHeight),
    center: true,
  );

  // Waits until the window is ready to be shown, then shows the window and focuses it.
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  // Creates a FlutterI18nDelegate with a FileTranslationLoader.
  final FlutterI18nDelegate flutterI18nDelegate = FlutterI18nDelegate(
    translationLoader: FileTranslationLoader(
      useCountryCode: false,
      fallbackFile: 'en',
      basePath: 'assets/i18n',
    ),
  );

  // Runs the application with the specified localization delegates and supported locales.
  runApp(ChangeNotifierProvider(
      create: (context) => LocaleModel(prefs),
      child: MaterialApp(
          localizationsDelegates: [
            flutterI18nDelegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', 'US'), // English
            Locale('pt', 'PT'), // Portuguese
            Locale('zh', 'CN'), // Chinese
            Locale('ru'), // Russian
          ],
          home: FlutterSplashScreen.fadeIn(
              backgroundColor: const Color(0xFF121212),
              childWidget: SizedBox(
                height: 75,
                width: 75,
                child: Image.asset("assets/AppIcon.png"),
              ),
              onAnimationEnd: () => debugPrint("On Fade In End"),
              nextScreen: MyApp(
                language: language,
              ),
              duration: const Duration(milliseconds: 3500),
              onInit: () async {
                /// Delete port text file if it exists
                await deletePortFileIfExists(); // done to ensure fresh port every time

                /// Kill old existing parser instances
                await killParserInstances(); // kill old instances if they exist

                /// Run the parser
                debugPrint("Starting parser");
                startParser();

                /// Prepare app language
                debugPrint("Preparing language");
                // Get the user's preferred language from shared preferences
                final prefs = await SharedPreferences.getInstance();
                var languageCode = prefs.getString('language');

                // If there's no language set in shared preferences, use the device's locale
                if (languageCode == null) {
                  // Get device locale
                  languageCode = Platform.localeName.split("_")[0];
                  String countryCode = Platform.localeName.split("_")[1];

                  // Create a Locale object from the language and country codes
                  Locale locale = Locale(languageCode, countryCode);
                  await prefs.setString('language', locale.toString());
                }
              },
              onEnd: () async {
                /// Set the port number
                debugPrint("Setting port number");
                var result = await setPortNumber();
                if (result == errorSettingPort) {
                  debugPrint("Error setting the port number");
                }
              }))));
}

/// The main widget of the application.
///
/// This class extends `StatefulWidget`, which allows the widget to maintain state
/// that can change over time.
///
/// The [language] parameter is passed into the constructor and is used to determine
/// the language settings for the app.
class MyApp extends StatefulWidget {
  final String language;

  const MyApp({super.key, required this.language});

  @override
  State<MyApp> createState() => _MyAppState();

  static final ValueNotifier<ThemeMode> themeNotifier =
      ValueNotifier(ThemeMode.dark);
}

/// The mutable state for the MyApp widget.
///
/// This class manages the state of the MyApp widget. It includes methods for
/// initialization and disposal, as well as handling changes in the language and theme.
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
    _loadLanguage();
    _init();
  }

  /// Loads the saved language from shared preferences and sets the locale.
  ///
  /// This method is asynchronous because it needs to wait for the shared preferences to load.
  /// It retrieves the saved language using the 'language' key. If a language is found,
  /// it sets the locale to the retrieved language.
  /// Note that this only happens if the widget is still mounted, i.e., not disposed of.
  void _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    var language = prefs.getString('language');
    if (language != null) {
      if (mounted) {
        Provider.of<LocaleModel>(context, listen: false).set(Locale(language));
      }
    }
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
                return Consumer<LocaleModel>(
                    builder: (context, localeModel, child) => LoadingOverlay(
                          child: MaterialApp(
                            locale: localeModel.locale,
                            theme: lightTheme,
                            darkTheme: darkTheme,
                            themeMode: currentMode,
                            localizationsDelegates: [
                              FlutterI18nDelegate(
                                translationLoader: FileTranslationLoader(
                                  useCountryCode: false,
                                  fallbackFile: 'en',
                                  basePath: 'assets/i18n',
                                ),
                              ),
                              GlobalMaterialLocalizations.delegate,
                              GlobalWidgetsLocalizations.delegate,
                              GlobalCupertinoLocalizations.delegate,
                            ],
                            supportedLocales: const [
                              Locale('en', 'US'), // English
                              Locale('pt', 'PT'), // Portuguese
                              Locale('zh', 'CN'), // Chinese
                              Locale('ru'), // Russian
                            ],
                            home: Scaffold(
                              body: Row(
                                children: <Widget>[
                                  /// Navigation bar widget.
                                  custom_nav.NavigationBar(
                                    currentIndex: _currentIndex,
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
                                        StorageScreen(),

                                        /// Settings screen widget.
                                        SettingsScreen(),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ));
              });
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }

  /// Handles the window close event.
  ///
  /// When the window close event occurs, this method is called. It first attempts to
  /// kill parser instances and then destroys the window. This ensures that any
  /// ongoing processes are properly terminated before the window closes.
  @override
  void onWindowClose() async {
    /// Attempt to kill Parser process
    await killParserInstances().whenComplete(() async {
      /// Close app window
      await windowManager.destroy();

      // /// Delay for a short period
      // await Future.delayed(const Duration(seconds: 1));

      // /// Force kill app
      // await Shell().run('taskkill /F /IM profit_taker_analyzer.exe');
    });
  }
}
