import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService extends ChangeNotifier {
  // Singleton pattern
  static final SettingsService instance = SettingsService._internal();
  
  factory SettingsService() {
    return instance;
  }
  
  SettingsService._internal();
  
  // Settings keys
  static const String _keyLanguage = 'language';
  static const String _keyTheme = 'theme';
  
  // Default values
  static const String _defaultLanguage = 'English';
  static const String _defaultTheme = 'Light Mode';
  
  // Cache current settings to avoid frequent SharedPreferences reads
  String _language = _defaultLanguage;
  String _theme = _defaultTheme;
  
  // Whether initialized
  bool _isInitialized = false;
  
  // Initialize and load settings
  Future<void> init() async {
    if (_isInitialized) return;
    
    final prefs = await SharedPreferences.getInstance();
    
    _language = prefs.getString(_keyLanguage) ?? _defaultLanguage;
    _theme = prefs.getString(_keyTheme) ?? _defaultTheme;
    
    _isInitialized = true;
    notifyListeners();
  }
  
  // Language settings
  String get language {
    return _language;
  }
  
  Future<void> setLanguage(String value) async {
    _language = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLanguage, value);
    notifyListeners();
  }
  
  // Theme settings
  String get theme {
    return _theme;
  }
  
  Future<void> setTheme(String value) async {
    _theme = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyTheme, value);
    notifyListeners();
  }
  
  // Reset all settings to default values
  Future<void> resetToDefaults() async {
    _language = _defaultLanguage;
    _theme = _defaultTheme;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLanguage, _defaultLanguage);
    await prefs.setString(_keyTheme, _defaultTheme);
    
    notifyListeners();
  }
  
  // Clear all data (mock implementation for now)
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    // Re-initialize defaults
    await resetToDefaults();
  }
}