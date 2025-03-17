import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// A helper class for managing local preferences using Hive.
///
/// This class provides methods for storing and retrieving user preferences,
/// such as onboarding visibility and theme settings.
class Pref {
  static late Box _box;

  /// Initializes Hive and opens the preferences box.
  ///
  /// This method **must be called** before using any preference-related functions.
  static Future<void> initialize() async {
    await Hive.initFlutter();
    _box = await Hive.openBox('myData');
  }

  /// Whether to show the onboarding screen.
  ///
  /// Defaults to `true` if not previously set.
  static bool get showOnboarding =>
      _box.get('showOnboarding', defaultValue: true);
  static set showOnboarding(bool value) => _box.put('showOnboarding', value);

  /// Determines whether dark mode is enabled.
  ///
  /// Defaults to `false` if not previously set.
  static bool get isDarkMode => _box.get('isDarkMode') ?? false;
  static set isDarkMode(bool value) => _box.put('isDarkMode', value);

  /// Retrieves the default theme mode based on stored preferences.
  ///
  /// - If no preference is set, it returns **ThemeMode.system**.
  /// - If dark mode is enabled, it returns **ThemeMode.dark**.
  /// - Otherwise, it returns **ThemeMode.light**.
  static ThemeMode get defaultTheme {
    final data = _box.get('isDarkMode');
    log('Theme mode preference: $data');
    return (data == true)
        ? ThemeMode.dark
        : (data == false)
            ? ThemeMode.light
            : ThemeMode.system;
  }
}
