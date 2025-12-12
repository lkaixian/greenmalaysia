import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService extends ChangeNotifier {
  // 1. Static final instance
  static final SettingsService _instance = SettingsService._internal();

  // 2. Factory constructor
  factory SettingsService() {
    return _instance;
  }

  // 3. Private internal constructor
  SettingsService._internal();

  // --- STATE VARIABLES ---
  Locale _locale = const Locale('en', 'GB');
  ThemeMode _themeMode = ThemeMode.system;
  bool _isAiLiveMode = false;
  bool _useHighPrecision = false;

  // NEW: Navigation Radius (Default 5000 meters)
  int _navRadius = 5000;

  // --- GETTERS ---
  Locale get locale => _locale;
  ThemeMode get themeMode => _themeMode;
  bool get isAiLiveMode => _isAiLiveMode;
  int get navRadius => _navRadius;
  bool get useHighPrecision => _useHighPrecision;

  // --- INITIALIZATION ---
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // Load Language
    String? langCode = prefs.getString('language_code');
    if (langCode != null) {
      _locale = Locale(langCode, '');
    }

    // Load Theme
    String? themeName = prefs.getString('theme_mode');
    if (themeName == 'light') {
      _themeMode = ThemeMode.light;
    } else if (themeName == 'dark') {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.system;
    }

    // Load AI Mode
    _isAiLiveMode = prefs.getBool('ai_live_mode') ?? false;

    // Load AI Precision (if needed in future)
    _useHighPrecision = prefs.getBool('ai_high_precision') ?? false;

    // NEW: Load Radius
    _navRadius = prefs.getInt('nav_radius') ?? 5000;

    notifyListeners();
  }

  // --- SETTERS ---
  Future<void> updateLocale(Locale newLocale) async {
    if (_locale == newLocale) return;
    _locale = newLocale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', newLocale.languageCode);
  }

  Future<void> updateThemeMode(ThemeMode newTheme) async {
    if (_themeMode == newTheme) return;
    _themeMode = newTheme;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    String themeName = 'system';
    if (newTheme == ThemeMode.light) themeName = 'light';
    if (newTheme == ThemeMode.dark) themeName = 'dark';
    await prefs.setString('theme_mode', themeName);
  }

  Future<void> updateAiMode(bool isLive) async {
    if (_isAiLiveMode == isLive) return;
    _isAiLiveMode = isLive;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('ai_live_mode', isLive);
  }

  // NEW: Update Radius
  Future<void> updateNavRadius(int newRadius) async {
    if (_navRadius == newRadius) return;
    _navRadius = newRadius;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('nav_radius', newRadius);
  }

  Future<void> updateHighPrecision(bool useHighPrecision) async {
    if (_useHighPrecision == useHighPrecision) return;
    _useHighPrecision = useHighPrecision;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('ai_high_precision', useHighPrecision);
  }
}
