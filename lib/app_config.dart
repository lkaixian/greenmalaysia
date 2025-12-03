import 'package:flutter/material.dart';

// 1. Global flag: Is this the Admin APK?
// By default, it is false. Only 'main_admin.dart' will set this to true.
bool enableAdminFeatures = false;

// 2. Singleton Class: Holds the navigation logic
class AppConfig {
  static final AppConfig _instance = AppConfig._internal();

  factory AppConfig() {
    return _instance;
  }

  AppConfig._internal();

  // The Builder Function.
  // If this is null, the Admin Dashboard code is NOT loaded.
  // We inject the real Admin Dashboard here only when running main_admin.dart
  Widget Function(BuildContext)? adminScreenBuilder;
}
