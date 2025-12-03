import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';

import 'app.dart';
import 'screens/login_page.dart';
import 'services/settings_service.dart';
import 'services/notification_service.dart';
import 'app_config.dart';

// Import Collector Screen
import 'screens/collector/collector_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "key.env");

  final settings = SettingsService();
  await settings.loadSettings();
  await NotificationService().init();
  await Firebase.initializeApp();

  // --- CONFIGURATION: COLLECTOR ---
  enableAdminFeatures = false;
  AppConfig().adminScreenBuilder = null;
  // Inject the Collector Dashboard so Login Page can route to it
  AppConfig().collectorScreenBuilder = (context) => const CollectorDashboard();

  final prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  // LOGIC: If logged in, go STRAIGHT to Collector Dashboard, skip HomePage entirely
  Widget initialScreen = isLoggedIn
      ? const CollectorDashboard()
      : const LoginPage();

  runApp(
    GreenMalaysiaApp(
      startScreen: initialScreen,
      settings: settings,
      appTitle: 'GreenMalaysia Driver',
      primaryColor: Colors.blue, // Blue Theme for Drivers
    ),
  );
}
