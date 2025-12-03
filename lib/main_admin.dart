import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:greenmalaysia/l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'homepage.dart';
import 'screens/login_page.dart';
import 'services/settings_service.dart';
import 'services/notification_service.dart';

// --- ADMIN SPECIFIC IMPORTS ---
import 'package:greenmalaysia/app_config.dart'; // To inject the builder
import 'package:greenmalaysia/screens/admin/admin_dashboard.dart'; // The Admin Page

void main() async {
  print("--- [ADMIN MODE] STEP 1: App Starting ---");
  WidgetsFlutterBinding.ensureInitialized();

  print("--- [ADMIN MODE] STEP 2: Loading DotEnv ---");
  await dotenv.load(fileName: "key.env");

  print("--- [ADMIN MODE] STEP 3: Initializing Settings & Services ---");
  final settings = SettingsService();
  await settings.loadSettings();
  await NotificationService().init();

  print("--- [ADMIN MODE] STEP 4: Initializing Firebase ---");
  await Firebase.initializeApp();

  // --- CRITICAL STEP: ENABLE ADMIN FEATURES ---
  print("--- [ADMIN MODE] Injecting Admin Dashboard ---");
  enableAdminFeatures = true; // Turn on the flag
  AppConfig().adminScreenBuilder = (context) =>
      const AdminDashboard(); // Inject the page
  // -------------------------------------------

  print("--- [ADMIN MODE] STEP 5: Checking Login Status ---");
  final prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  print("--- [ADMIN MODE] STEP 6: Running App ---");
  runApp(
    MyApp(
      startScreen: isLoggedIn ? const HomePage() : const LoginPage(),
      settings: settings,
    ),
  );
}

// We can reuse the exact same MyApp class.
// Ideally, you should move MyApp to a separate file (e.g., app.dart) to avoid code duplication.
// But for now, pasting it here works perfectly fine for a separate entry point.
class MyApp extends StatelessWidget {
  final Widget startScreen;
  final SettingsService settings;

  const MyApp({super.key, required this.startScreen, required this.settings});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settings,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title:
              'GreenMalaysia (Admin)', // Changed Title to indicate Admin mode
          // Use settings here
          themeMode: settings.themeMode,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor:
                  Colors.teal, // Differentiate Admin app with Teal color?
              brightness: Brightness.light,
            ),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.teal,
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
