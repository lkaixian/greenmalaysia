import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:greenmalaysia/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'homepage.dart';
import 'screens/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //Init
  await dotenv.load(fileName: "key.env");
  await Firebase.initializeApp();
  
  // Check if user is already logged in or completed setup
  final prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(MyApp(startScreen: isLoggedIn ? const HomePage() : const LoginPage()));
}

class MyApp extends StatelessWidget {
  final Widget startScreen;
  
  const MyApp({super.key, required this.startScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GreenMalaysia',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green), // Changed to Green for theme
        useMaterial3: true,
      ),
      // L10n Setup
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'GB'),
        Locale('ms', ''),
      ],
      // Dynamic Home
      home: startScreen,
    );
  }
}