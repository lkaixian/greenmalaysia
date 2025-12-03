import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';

// Shared
import 'app.dart';
import 'homepage.dart';
import 'screens/login_page.dart';
import 'services/settings_service.dart';
import 'services/notification_service.dart';
import 'app_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "key.env");

  // Init Services
  final settings = SettingsService();
  await settings.loadSettings();
  await NotificationService().init();
  await Firebase.initializeApp();

  // --- CONFIGURATION: PUBLIC USER ---
  // We explicitly set these to NULL.
  // The Flutter Compiler is smart enough to remove (tree-shake) the
  // Admin/Collector code because it sees we never use it here.
  enableAdminFeatures = false;
  AppConfig().adminScreenBuilder = null;
  AppConfig().collectorScreenBuilder = null;

  // Check Login
  final prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(
    GreenMalaysiaApp(
      startScreen: isLoggedIn ? const HomePage() : const LoginPage(),
      settings: settings,
      appTitle: 'GreenMalaysia',
      primaryColor: Colors.green, // Standard Green Theme
    ),
  );
}
