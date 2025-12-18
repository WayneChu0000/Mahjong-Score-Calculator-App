import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  // Singleton pattern
  static final SettingsService instance = SettingsService._internal();
  
  factory SettingsService() {
    return instance;
  }
  
  SettingsService._internal();
  
  // Settings keys
  static const String _keyNotifications = 'notifications_enabled';
  static const String _keySound = 'sound_enabled';
  static const String _keyLanguage = 'language';
  static const String _keyTheme = 'theme';
  
  // Default values
  static const bool _defaultNotifications = true;
  static const bool _defaultSound = false;
  static const String _defaultLanguage = 'Traditional Chinese';
  static const String _defaultTheme = 'Light Mode';
  
  // Cache current settings to avoid frequent SharedPreferences reads
  bool _isNotificationsEnabled = _defaultNotifications;
  bool _isSoundEnabled = _defaultSound;
  String _language = _defaultLanguage;
  String _theme = _defaultTheme;
  
  // Whether initialized
  bool _isInitialized = false;
  
  // Initialize and load settings
  Future<void> init() async {
    if (_isInitialized) return;
    
    final prefs = await SharedPreferences.getInstance();
    
    _isNotificationsEnabled = prefs.getBool(_keyNotifications) ?? _defaultNotifications;
    _isSoundEnabled = prefs.getBool(_keySound) ?? _defaultSound;
    _language = prefs.getString(_keyLanguage) ?? _defaultLanguage;
    _theme = prefs.getString(_keyTheme) ?? _defaultTheme;
    
    _isInitialized = true;
  }
  
  // Notification settings
  bool get isNotificationsEnabled {
    return _isNotificationsEnabled;
  }
  
  Future<void> setNotificationsEnabled(bool value) async {
    _isNotificationsEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotifications, value);
  }
  
  // Sound settings
  bool get isSoundEnabled {
    return _isSoundEnabled;
  }
  
  Future<void> setSoundEnabled(bool value) async {
    _isSoundEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySound, value);
  }
  
  // Language settings
  String get language {
    return _language;
  }
  
  Future<void> setLanguage(String value) async {
    _language = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLanguage, value);
  }
  
  // Theme settings
  String get theme {
    return _theme;
  }
  
  Future<void> setTheme(String value) async {
    _theme = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyTheme, value);
  }
  
  // Reset all settings to default values
  Future<void> resetToDefaults() async {
    _isNotificationsEnabled = _defaultNotifications;
    _isSoundEnabled = _defaultSound;
    _language = _defaultLanguage;
    _theme = _defaultTheme;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotifications, _defaultNotifications);
    await prefs.setBool(_keySound, _defaultSound);
    await prefs.setString(_keyLanguage, _defaultLanguage);
    await prefs.setString(_keyTheme, _defaultTheme);
  }
  
  // Clear all data
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    // Reset settings in memory
    await resetToDefaults();
  }
}