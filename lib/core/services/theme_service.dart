// lib/core/services/theme_service.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  static const String themeModeKey = 'themeMode';

  late SharedPreferences _prefs;
  late ThemeMode _themeMode;

  ThemeService() {
    _themeMode = ThemeMode.light; // Default to light theme
    _loadSavedTheme();
  }

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Future<void> _loadSavedTheme() async {
    _prefs = await SharedPreferences.getInstance();
    final isDark = _prefs.getBool(themeModeKey) ?? false;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await _prefs.setBool(themeModeKey, _themeMode == ThemeMode.dark);
    notifyListeners();
  }

  Future<void> setDarkMode(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    await _prefs.setBool(themeModeKey, isDark);
    notifyListeners();
  }
}
