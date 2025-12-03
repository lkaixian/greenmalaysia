import 'package:flutter/material.dart';

// Global flag
bool enableAdminFeatures = false;

class AppConfig {
  static final AppConfig _instance = AppConfig._internal();
  factory AppConfig() => _instance;
  AppConfig._internal();

  // 1. Admin Builder (Already added)
  Widget Function(BuildContext)? adminScreenBuilder;

  // 2. Collector Builder (NEW)
  // This allows us to navigate to Collector Dashboard without importing the file
  Widget Function(BuildContext)? collectorScreenBuilder;
}
