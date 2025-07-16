import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  // 單例模式
  static final SettingsService instance = SettingsService._internal();
  
  factory SettingsService() {
    return instance;
  }
  
  SettingsService._internal();
  
  // 設定鍵
  static const String _keyNotifications = 'notifications_enabled';
  static const String _keySound = 'sound_enabled';
  static const String _keyLanguage = 'language';
  static const String _keyTheme = 'theme';
  
  // 預設值
  static const bool _defaultNotifications = true;
  static const bool _defaultSound = false;
  static const String _defaultLanguage = '繁體中文';
  static const String _defaultTheme = '淺色模式';
  
  // 緩存當前設定，避免頻繁讀取 SharedPreferences
  bool _isNotificationsEnabled = _defaultNotifications;
  bool _isSoundEnabled = _defaultSound;
  String _language = _defaultLanguage;
  String _theme = _defaultTheme;
  
  // 是否已初始化
  bool _isInitialized = false;
  
  // 初始化並加載設定
  Future<void> init() async {
    if (_isInitialized) return;
    
    final prefs = await SharedPreferences.getInstance();
    
    _isNotificationsEnabled = prefs.getBool(_keyNotifications) ?? _defaultNotifications;
    _isSoundEnabled = prefs.getBool(_keySound) ?? _defaultSound;
    _language = prefs.getString(_keyLanguage) ?? _defaultLanguage;
    _theme = prefs.getString(_keyTheme) ?? _defaultTheme;
    
    _isInitialized = true;
  }
  
  // 通知設定
  bool get isNotificationsEnabled {
    return _isNotificationsEnabled;
  }
  
  Future<void> setNotificationsEnabled(bool value) async {
    _isNotificationsEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotifications, value);
  }
  
  // 音效設定
  bool get isSoundEnabled {
    return _isSoundEnabled;
  }
  
  Future<void> setSoundEnabled(bool value) async {
    _isSoundEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySound, value);
  }
  
  // 語言設定
  String get language {
    return _language;
  }
  
  Future<void> setLanguage(String value) async {
    _language = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLanguage, value);
  }
  
  // 主題設定
  String get theme {
    return _theme;
  }
  
  Future<void> setTheme(String value) async {
    _theme = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyTheme, value);
  }
  
  // 重置所有設定為預設值
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
  
  // 清除所有數據
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    // 重置內存中的設定
    await resetToDefaults();
  }
}