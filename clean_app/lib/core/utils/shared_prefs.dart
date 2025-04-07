import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static late SharedPreferences _prefs;

  // Initialize shared preferences
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Show onboarding screen preference
  static bool get showOnboarding => _prefs.getBool('show_onboarding') ?? true;
  static Future<void> setShowOnboarding(bool value) async {
    await _prefs.setBool('show_onboarding', value);
  }

  // User authentication token
  static String? get authToken => _prefs.getString('auth_token');
  static Future<void> setAuthToken(String? token) async {
    if (token != null) {
      await _prefs.setString('auth_token', token);
    } else {
      await _prefs.remove('auth_token');
    }
  }

  // User ID
  static String? get userId => _prefs.getString('user_id');
  static Future<void> setUserId(String? id) async {
    if (id != null) {
      await _prefs.setString('user_id', id);
    } else {
      await _prefs.remove('user_id');
    }
  }

  // Theme mode
  static bool get isDarkMode => _prefs.getBool('isDarkMode') ?? false;
  static Future<void> setDarkMode(bool value) async {
    await _prefs.setBool('isDarkMode', value);
  }

  // Generic getter and setter for boolean values
  static bool getBool(String key, {bool defaultValue = false}) {
    return _prefs.getBool(key) ?? defaultValue;
  }

  static Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  // Clear all preferences
  static Future<void> clear() async {
    await _prefs.clear();
  }
}
