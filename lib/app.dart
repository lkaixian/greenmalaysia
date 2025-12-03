import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:greenmalaysia/l10n/app_localizations.dart';
import 'services/settings_service.dart';

class GreenMalaysiaApp extends StatelessWidget {
  final Widget startScreen;
  final SettingsService settings;
  final String appTitle;
  final Color primaryColor;

  const GreenMalaysiaApp({
    super.key,
    required this.startScreen,
    required this.settings,
    required this.appTitle,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settings,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: appTitle,

          // --- THEME CONFIGURATION ---
          themeMode: settings.themeMode,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: primaryColor,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: primaryColor,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),

          // --- LOCALIZATION ---
          locale: settings.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en', 'GB'), Locale('ms', '')],

          home: startScreen,
        );
      },
    );
  }
}
