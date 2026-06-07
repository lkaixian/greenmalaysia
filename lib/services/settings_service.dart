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
  bool _isVerboseMode = false;
  String _forcedModel = 'auto';
  bool _forceGpu = false;
  bool _showHud = false;
  int _aiThreadCount = 0; // 0 = auto

  // NEW: Navigation Radius (Default 5000 meters)
  int _navRadius = 5000;

  // --- GETTERS ---
  Locale get locale => _locale;
  ThemeMode get themeMode => _themeMode;
  bool get isAiLiveMode => _isAiLiveMode;
  int get navRadius => _navRadius;
  bool get useHighPrecision => _useHighPrecision;
  bool get isVerboseMode => _isVerboseMode;
  String get forcedModel => _forcedModel;
  bool get forceGpu => _forceGpu;
  bool get showHud => _showHud;
  int get aiThreadCount => _aiThreadCount;

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

    // Load Verbose Mode
    _isVerboseMode = prefs.getBool('verbose_mode') ?? false;

    // Load Forced Model
    _forcedModel = prefs.getString('forced_model') ?? 'auto';

    // Load Force GPU
    _forceGpu = prefs.getBool('force_gpu') ?? false;

    // Load Show HUD
    _showHud = prefs.getBool('show_hud') ?? false;

    // Load AI Thread Count
    _aiThreadCount = prefs.getInt('ai_thread_count') ?? 0;

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

  Future<void> updateVerboseMode(bool isVerbose) async {
    if (_isVerboseMode == isVerbose) return;
    _isVerboseMode = isVerbose;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('verbose_mode', isVerbose);
  }

  Future<void> updateForcedModel(String model) async {
    if (_forcedModel == model) return;
    _forcedModel = model;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('forced_model', model);
  }

  Future<void> updateForceGpu(bool isForced) async {
    if (_forceGpu == isForced) return;
    _forceGpu = isForced;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('force_gpu', isForced);
  }

  Future<void> updateShowHud(bool show) async {
    if (_showHud == show) return;
    _showHud = show;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_hud', show);
  }

  Future<void> updateAiThreadCount(int count) async {
    if (_aiThreadCount == count) return;
    _aiThreadCount = count;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('ai_thread_count', count);
  }
}
