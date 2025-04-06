import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// A helper class for managing local preferences using Hive.
///
/// This class provides methods for storing and retrieving user preferences,
/// such as onboarding visibility and theme settings.
class Pref {
  static late Box _box;
  static const String _themeKey = 'theme_mode';
  static const String _tokenKey = 'auth_token';

  /// Initializes Hive and opens the preferences box.
  ///
  /// This method **must be called** before using any preference-related functions.
  static Future<void> initialize() async {
    await Hive.initFlutter();
    _box = await Hive.openBox('app_preferences');
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
    final value = _box.get(_themeKey, defaultValue: 'system');
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  static set defaultTheme(ThemeMode mode) {
    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    _box.put(_themeKey, value);
  }

  static String? get token => _box.get(_tokenKey);

  static set token(String? value) {
    if (value != null) {
      _box.put(_tokenKey, value);
    } else {
      _box.delete(_tokenKey);
    }
  }
}
