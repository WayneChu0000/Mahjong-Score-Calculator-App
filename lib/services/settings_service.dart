import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    
    String defaultLang = _defaultLanguage;
    try {
      final String systemLocale = Platform.localeName;
      // Simple check for Chinese locale
      if (systemLocale.startsWith('zh')) {
        defaultLang = 'Traditional Chinese';
      }
    } catch (e) {
      // Ignore platform errors
    }
    
    _language = prefs.getString(_keyLanguage) ?? defaultLang;
    _theme = prefs.getString(_keyTheme) ?? _defaultTheme;
    
    _isInitialized = true;
    
    // Listen to auth state changes to sync settings
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        _syncSettingsFromFirestore(user.uid);
      }
    });

    notifyListeners();
  }
  
  Future<void> _syncSettingsFromFirestore(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        if (data.containsKey('language')) {
          final String cloudLanguage = data['language'];
          if (cloudLanguage != _language) {
             await setLanguage(cloudLanguage); // This will also update local prefs
          }
        }
      } else {
        // If no settings exist in cloud, save current local settings
        await _saveSettingsToFirestore(uid);
      }
    } catch (e) {
      debugPrint('Error syncing settings: $e');
    }
  }

  Future<void> _saveSettingsToFirestore(String uid) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'language': _language,
        'theme': _theme,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error saving settings: $e');
    }
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
    
    // Sync to cloud if logged in
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _saveSettingsToFirestore(user.uid);
    }
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