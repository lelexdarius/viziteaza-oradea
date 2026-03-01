import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState extends ChangeNotifier {
  AppState._internal();
  static final AppState _instance = AppState._internal();
  static AppState get instance => _instance;

  static const String _kLanguage = 'app_language';
  static const String _kDarkMode = 'app_dark_mode';

  String _language = 'ro';
  bool _isDarkMode = false;

  String get language => _language;
  bool get isDarkMode => _isDarkMode;

  Future<void> loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _language = prefs.getString(_kLanguage) ?? 'ro';
      _isDarkMode = prefs.getBool(_kDarkMode) ?? false;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> setLanguage(String lang) async {
    if (_language == lang) return;
    _language = lang;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kLanguage, lang);
    } catch (_) {}
  }

  Future<void> setDarkMode(bool value) async {
    if (_isDarkMode == value) return;
    _isDarkMode = value;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kDarkMode, value);
    } catch (_) {}
  }

  void toggleLanguage() {
    setLanguage(_language == 'ro' ? 'en' : 'ro');
  }
}
