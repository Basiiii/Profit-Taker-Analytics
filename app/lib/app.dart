import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:profit_taker_analyzer/app_layout.dart';
import 'package:profit_taker_analyzer/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:profit_taker_analyzer/theme/app_theme.dart';
import 'package:profit_taker_analyzer/utils/language.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

/// The root widget of the application.
///
/// This widget is responsible for setting up the app's core properties such as:
/// - Dynamic locale (language) handling using `LocaleModel`.
/// - Theme handling using `ThemeProvider` to switch between light and dark themes.
/// - Localization support through `flutter_localizations` and `FlutterI18n`.
/// - Setting the initial screen to `AppLayout` (the main layout of the app).
///
/// It listens to the `ThemeProvider` and `LocaleModel` to update the theme and locale
/// whenever changes occur and applies those settings to the app globally.
class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

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
          // TODO: move locales into another file (because also used in settings_service.dart)
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
                // TODO: consider moving these into constants? instead of magic strings
                fallbackFile: 'en', // Fallback language if not available
                basePath: 'assets/i18n', // Path to the i18n files
              ),
            ),
          ],
          home: AppLayout(
            key: AppLayout.globalKey,
          ),
        );
      },
    );
  }
}
