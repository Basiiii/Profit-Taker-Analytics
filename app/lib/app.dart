import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:profit_taker_analyzer/screens/analytics/analytics_screen.dart';
import 'package:profit_taker_analyzer/screens/home/home_screen.dart';
import 'package:profit_taker_analyzer/screens/settings/settings_screen.dart';
import 'package:profit_taker_analyzer/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:profit_taker_analyzer/theme/app_theme.dart';
import 'package:profit_taker_analyzer/utils/language.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:profit_taker_analyzer/widgets/navigation_bar.dart'
    as custom_nav;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LocaleModel>(
      builder: (context, themeProvider, localeModel, child) {
        return MaterialApp(
          locale: localeModel.locale, // Set locale dynamically
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeProvider.themeMode, // Use ThemeProvider's themeMode
          debugShowCheckedModeBanner: false,
          supportedLocales: const [
            Locale('en', 'US'), // English
            Locale('pt', 'PT'), // Portuguese
            Locale('zh', 'CN'), // Chinese
            Locale('ru'), // Russian
            Locale('fr'), // French
            Locale('tr'), // Turkish
          ],
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            FlutterI18nDelegate(
              translationLoader: FileTranslationLoader(
                useCountryCode: false,
                fallbackFile: 'en', // Fallback language if not available
                basePath: 'assets/i18n', // Path to the i18n files
              ),
            ),
          ],
          home: const _MyHomePage(), // Set the home screen
        );
      },
    );
  }
}

class _MyHomePage extends StatefulWidget {
  const _MyHomePage();

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<_MyHomePage> {
  int _currentIndex = 0;
  Widget? _activeScreen;

  @override
  void initState() {
    super.initState();
    _activeScreen = const HomeScreen(); // Default screen to show
  }

  void _selectTab(int navIndex) {
    setState(() {
      _currentIndex = navIndex;
      _activeScreen = _getScreenByIndex(navIndex);
    });
  }

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
      body: Row(
        children: <Widget>[
          custom_nav.NavigationBar(
            currentIndex: _currentIndex,
            onTabSelected:
                _selectTab, // Pass the method for handling navigation
          ),
          Expanded(child: _activeScreen!), // Show the active screen
        ],
      ),
    );
  }
}
