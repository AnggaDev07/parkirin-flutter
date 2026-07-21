// lib/core/services/localization_service.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Language {
  final String name;
  final String code;
  final String flag;

  const Language({
    required this.name,
    required this.code,
    required this.flag,
  });
}

class LocalizationService extends ChangeNotifier {
  static const String languageCodeKey = 'languageCode';

  static const List<Language> supportedLanguages = [
    Language(
      name: 'English',
      code: 'en',
      flag: '🇺🇸',
    ),
    Language(
      name: 'Indonesian',
      code: 'id',
      flag: '🇮🇩',
    ),
  ];

  late SharedPreferences _prefs;
  late Locale _currentLocale;

  LocalizationService() {
    _currentLocale = const Locale('id'); // Default to Indonesian
    _loadSavedLanguage();
  }

  Locale get currentLocale => _currentLocale;

  Language getCurrentLanguage() {
    return supportedLanguages.firstWhere(
      (lang) => lang.code == _currentLocale.languageCode,
      orElse: () => supportedLanguages.first,
    );
  }

  Future<void> _loadSavedLanguage() async {
    _prefs = await SharedPreferences.getInstance();
    final savedLanguageCode = _prefs.getString(languageCodeKey);
    if (savedLanguageCode != null) {
      _currentLocale = Locale(savedLanguageCode);
      notifyListeners();
    }
  }

  Future<void> changeLocale(String languageCode) async {
    if (_currentLocale.languageCode != languageCode) {
      _currentLocale = Locale(languageCode);
      await _prefs.setString(languageCodeKey, languageCode);
      notifyListeners();
    }
  }

  String getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'id':
        return 'Indonesian';
      default:
        return 'Unknown';
    }
  }
}
