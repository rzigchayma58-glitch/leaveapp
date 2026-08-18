import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  static const String _themeKey = 'isDarkMode';
  bool _isDarkMode = false;
  
  bool get isDarkMode => _isDarkMode;
  
  ThemeService() {
    _loadThemeFromPrefs();
  }
  
  /// Charge le thème sauvegardé depuis les SharedPreferences
  Future<void> _loadThemeFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool(_themeKey) ?? false;
      notifyListeners();
    } catch (e) {
      print('Erreur lors du chargement du thème: $e');
    }
  }
  
  /// Bascule entre le mode clair et sombre
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _saveThemeToPrefs();
    notifyListeners();
  }
  
  /// Définit le mode sombre
  Future<void> setDarkMode(bool isDark) async {
    if (_isDarkMode != isDark) {
      _isDarkMode = isDark;
      await _saveThemeToPrefs();
      notifyListeners();
    }
  }
  
  /// Sauvegarde le thème dans les SharedPreferences
  Future<void> _saveThemeToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, _isDarkMode);
    } catch (e) {
      print('Erreur lors de la sauvegarde du thème: $e');
    }
  }
  
  /// Retourne le thème approprié
  ThemeMode get themeMode {
    return _isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }
}