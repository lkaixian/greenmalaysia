import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';

import 'app.dart';
import 'homepage.dart';
import 'screens/login_page.dart';
import 'services/settings_service.dart';
import 'services/notification_service.dart';
import 'app_config.dart';

// Import Admin Screen
import 'screens/admin/admin_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "key.env");

  final settings = SettingsService();
  await settings.loadSettings();
  await NotificationService().init();
  await Firebase.initializeApp();

  // --- CONFIGURATION: ADMIN ---
  enableAdminFeatures = true; // Show Admin Button in Profile
  AppConfig().adminScreenBuilder = (context) =>
      const AdminDashboard(); // Inject Logic
  AppConfig().collectorScreenBuilder =
      null; // Admin doesn't need Collector view usually

  final prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(
    GreenMalaysiaApp(
      startScreen: isLoggedIn ? const HomePage() : const LoginPage(),
      settings: settings,
      appTitle: 'GreenMalaysia (Admin)',
      primaryColor: Colors.teal, // Teal Theme to distinguish it
    ),
  );
}
