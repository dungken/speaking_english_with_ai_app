import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<bool> {
  final SharedPreferences _prefs;
  static const String _themeKey = 'isDarkMode';

  ThemeCubit(this._prefs) : super(_prefs.getBool(_themeKey) ?? false);

  void toggleTheme() {
    final newValue = !state;
    _prefs.setBool(_themeKey, newValue);
    emit(newValue);
  }

  bool get isDarkMode => state;
}
