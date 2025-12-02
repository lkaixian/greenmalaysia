import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:greenmalaysia/l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'homepage.dart';
import 'screens/login_page.dart';
import 'services/settings_service.dart'; // Import the service

void main() async {
  print("--- STEP 1: App Starting ---");
  WidgetsFlutterBinding.ensureInitialized();
  print("--- STEP 2: Loading DotEnv ---");
  await dotenv.load(fileName: "key.env");

  print("--- STEP 3: Initializing Settings ---");
  final settings = SettingsService();
  await settings.loadSettings(); // Load saved preferences

  print("--- STEP 4: Initializing Firebase ---");
  await Firebase.initializeApp();
  print("--- STEP 5: Checking Login Status ---");
  final prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  // 2. Pass the 'settings' variable to MyApp
  print("--- STEP 6: Running App ---");
  runApp(
    MyApp(
      startScreen: isLoggedIn ? const HomePage() : const LoginPage(),
      settings: settings,
    ),
  );
}

class MyApp extends StatelessWidget {
  final Widget startScreen;
  final SettingsService settings; // Receive the service

  const MyApp({super.key, required this.startScreen, required this.settings});

  @override
  Widget build(BuildContext context) {
    // 3. Listen to the passed 'settings' object
    return ListenableBuilder(
      listenable: settings,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'GreenMalaysia',

          // Use settings here
          themeMode: settings.themeMode,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.green,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.green,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),

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
