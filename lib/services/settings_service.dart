import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../localization/app_localizations.dart';

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
  static const String _keyCustomHkFan = 'customHkFan';
  static const String _keyCustomTwTai = 'customTwTai';
  static const String _keyHkMinFan = 'hkMinFan';
  static const String _keyHkMaxFan = 'hkMaxFan';
  static const String _keyTwBaseTai = 'twBaseTai';
  static const String _keyTwTaiValue = 'twTaiValue';
  static const String _keyCustomHkRules = 'customHkRules';
  static const String _keyCustomTwRules = 'customTwRules';
  static const String _keyDeletedHkRules = 'deletedHkRules';
  static const String _keyDeletedTwRules = 'deletedTwRules';
  static const String _keyTwPayments = 'twPayments';
  static const String _keyTwBuiltInPayValues = 'twBuiltInPayValues';

  // Default values
  static const String _defaultLanguage = 'English';
  static const String _defaultTheme = 'Light Mode';

  // Cache current settings to avoid frequent SharedPreferences reads
  String _language = _defaultLanguage;
  String _theme = _defaultTheme;
  Map<String, int> _customHkFan = {};
  Map<String, int> _customTwTai = {};

  // HK game settings
  int _hkMinFan = 3;
  int _hkMaxFan = 13;

  // TW game settings
  int _twBaseTai = 10;
  int _twTaiValue = 5;

  // Custom user-added rules [{"name": "...", "fanValue": 3}, ...]
  List<Map<String, dynamic>> _customHkRules = [];
  List<Map<String, dynamic>> _customTwRules = [];

  // Deleted built-in rule indices
  Set<int> _deletedHkRules = {};
  Set<int> _deletedTwRules = {};

  // TW real-time payment items [{"name": "...", "value": 10}, ...]
  List<Map<String, dynamic>> _twPayments = [];

  // Built-in payment value overrides  { ruleKey: value }
  Map<String, int> _twBuiltInPayValues = {};

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

    // Load custom fan/tai overrides
    final hkJson = prefs.getString(_keyCustomHkFan);
    if (hkJson != null) {
      _customHkFan = Map<String, int>.from(json.decode(hkJson));
    }
    final twJson = prefs.getString(_keyCustomTwTai);
    if (twJson != null) {
      _customTwTai = Map<String, int>.from(json.decode(twJson));
    }

    // Load HK game settings
    _hkMinFan = prefs.getInt(_keyHkMinFan) ?? 3;
    _hkMaxFan = prefs.getInt(_keyHkMaxFan) ?? 13;

    // Load TW game settings
    _twBaseTai = prefs.getInt(_keyTwBaseTai) ?? 10;
    _twTaiValue = prefs.getInt(_keyTwTaiValue) ?? 5;

    // Load custom rules
    final customHkJson = prefs.getString(_keyCustomHkRules);
    if (customHkJson != null) {
      _customHkRules = List<Map<String, dynamic>>.from(
        (json.decode(customHkJson) as List).map(
          (e) => Map<String, dynamic>.from(e),
        ),
      );
    }
    final customTwJson = prefs.getString(_keyCustomTwRules);
    if (customTwJson != null) {
      _customTwRules = List<Map<String, dynamic>>.from(
        (json.decode(customTwJson) as List).map(
          (e) => Map<String, dynamic>.from(e),
        ),
      );
    }

    // Load deleted built-in rule indices
    final deletedHkJson = prefs.getString(_keyDeletedHkRules);
    if (deletedHkJson != null) {
      _deletedHkRules = Set<int>.from(json.decode(deletedHkJson));
    }
    final deletedTwJson = prefs.getString(_keyDeletedTwRules);
    if (deletedTwJson != null) {
      _deletedTwRules = Set<int>.from(json.decode(deletedTwJson));
    }

    // Load TW real-time payment items
    final paymentsJson = prefs.getString(_keyTwPayments);
    if (paymentsJson != null) {
      _twPayments = List<Map<String, dynamic>>.from(
        (json.decode(paymentsJson) as List).map(
          (e) => Map<String, dynamic>.from(e),
        ),
      );
    }

    // Load built-in payment value overrides
    final builtInPayJson = prefs.getString(_keyTwBuiltInPayValues);
    if (builtInPayJson != null) {
      _twBuiltInPayValues = Map<String, int>.from(json.decode(builtInPayJson));
    }

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
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        if (data.containsKey('language')) {
          final String cloudLanguage = data['language'];
          if (cloudLanguage != _language) {
            await setLanguage(cloudLanguage);
          }
        }
      } else {
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

  // ── Language settings ──────────────────────────────────────────
  String get language => _language;

  Future<void> setLanguage(String value) async {
    _language = value;
    AppLocalizations.setLocale(value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLanguage, value);
    notifyListeners();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _saveSettingsToFirestore(user.uid);
    }
  }

  // ── Theme settings ─────────────────────────────────────────────
  String get theme => _theme;

  Future<void> setTheme(String value) async {
    _theme = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyTheme, value);
    notifyListeners();
  }

  // ── HK Game Settings ──────────────────────────────────────────
  int get hkMinFan => _hkMinFan;
  int get hkMaxFan => _hkMaxFan;

  Future<void> setHkMinFan(int value) async {
    _hkMinFan = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyHkMinFan, value);
    notifyListeners();
  }

  Future<void> setHkMaxFan(int value) async {
    _hkMaxFan = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyHkMaxFan, value);
    notifyListeners();
  }

  // ── TW Game Settings ──────────────────────────────────────────
  int get twBaseTai => _twBaseTai;
  int get twTaiValue => _twTaiValue;

  Future<void> setTwBaseTai(int value) async {
    _twBaseTai = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyTwBaseTai, value);
    notifyListeners();
  }

  Future<void> setTwTaiValue(int value) async {
    _twTaiValue = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyTwTaiValue, value);
    notifyListeners();
  }

  // ── TW Built-in Payment Value Overrides ───────────────────────
  Map<String, int> get twBuiltInPayValues =>
      Map.unmodifiable(_twBuiltInPayValues);

  int getTwBuiltInPayValue(String ruleKey, int defaultValue) {
    return _twBuiltInPayValues[ruleKey] ?? defaultValue;
  }

  Future<void> setTwBuiltInPayValue(String ruleKey, int value) async {
    _twBuiltInPayValues[ruleKey] = value;
    await _saveTwBuiltInPayValues();
    notifyListeners();
  }

  Future<void> _saveTwBuiltInPayValues() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _keyTwBuiltInPayValues,
      json.encode(_twBuiltInPayValues),
    );
  }

  // ── TW Real-time Payment Items ────────────────────────────────
  List<Map<String, dynamic>> get twPayments => List.unmodifiable(_twPayments);

  Future<void> addTwPayment(String name, int value) async {
    _twPayments.add({'name': name, 'value': value});
    await _saveTwPayments();
    notifyListeners();
  }

  Future<void> updateTwPayment(int index, String name, int value) async {
    if (index >= 0 && index < _twPayments.length) {
      _twPayments[index] = {'name': name, 'value': value};
      await _saveTwPayments();
      notifyListeners();
    }
  }

  Future<void> removeTwPayment(int index) async {
    if (index >= 0 && index < _twPayments.length) {
      _twPayments.removeAt(index);
      await _saveTwPayments();
      notifyListeners();
    }
  }

  Future<void> _saveTwPayments() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyTwPayments, json.encode(_twPayments));
  }

  // ── Custom fan/tai override settings ──────────────────────────
  Map<String, int> get customHkFan => Map.unmodifiable(_customHkFan);
  Map<String, int> get customTwTai => Map.unmodifiable(_customTwTai);

  int? getCustomHkFan(int ruleIndex) => _customHkFan[ruleIndex.toString()];
  int? getCustomTwTai(int ruleIndex) => _customTwTai[ruleIndex.toString()];

  Future<void> setCustomHkFan(int ruleIndex, int? fanValue) async {
    if (fanValue == null) {
      _customHkFan.remove(ruleIndex.toString());
    } else {
      _customHkFan[ruleIndex.toString()] = fanValue;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCustomHkFan, json.encode(_customHkFan));
    notifyListeners();
  }

  Future<void> setCustomTwTai(int ruleIndex, int? taiValue) async {
    if (taiValue == null) {
      _customTwTai.remove(ruleIndex.toString());
    } else {
      _customTwTai[ruleIndex.toString()] = taiValue;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCustomTwTai, json.encode(_customTwTai));
    notifyListeners();
  }

  Future<void> resetCustomHkFan() async {
    _customHkFan.clear();
    _customHkRules.clear();
    _deletedHkRules.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyCustomHkFan);
    await prefs.remove(_keyCustomHkRules);
    await prefs.remove(_keyDeletedHkRules);
    notifyListeners();
  }

  Future<void> resetCustomTwTai() async {
    _customTwTai.clear();
    _customTwRules.clear();
    _deletedTwRules.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyCustomTwTai);
    await prefs.remove(_keyCustomTwRules);
    await prefs.remove(_keyDeletedTwRules);
    notifyListeners();
  }

  bool get hasCustomHkFan =>
      _customHkFan.isNotEmpty ||
      _customHkRules.isNotEmpty ||
      _deletedHkRules.isNotEmpty;
  bool get hasCustomTwTai =>
      _customTwTai.isNotEmpty ||
      _customTwRules.isNotEmpty ||
      _deletedTwRules.isNotEmpty;

  // ── Custom user-added rules ───────────────────────────────────
  List<Map<String, dynamic>> get customHkRules =>
      List.unmodifiable(_customHkRules);
  List<Map<String, dynamic>> get customTwRules =>
      List.unmodifiable(_customTwRules);

  Future<void> addCustomHkRule(String name, int fanValue) async {
    _customHkRules.add({'name': name, 'fanValue': fanValue});
    await _saveCustomRules(isHk: true);
    notifyListeners();
  }

  Future<void> removeCustomHkRule(int index) async {
    if (index >= 0 && index < _customHkRules.length) {
      _customHkRules.removeAt(index);
      await _saveCustomRules(isHk: true);
      notifyListeners();
    }
  }

  Future<void> addCustomTwRule(String name, int taiValue) async {
    _customTwRules.add({'name': name, 'taiValue': taiValue});
    await _saveCustomRules(isHk: false);
    notifyListeners();
  }

  Future<void> removeCustomTwRule(int index) async {
    if (index >= 0 && index < _customTwRules.length) {
      _customTwRules.removeAt(index);
      await _saveCustomRules(isHk: false);
      notifyListeners();
    }
  }

  Future<void> _saveCustomRules({required bool isHk}) async {
    final prefs = await SharedPreferences.getInstance();
    if (isHk) {
      await prefs.setString(_keyCustomHkRules, json.encode(_customHkRules));
    } else {
      await prefs.setString(_keyCustomTwRules, json.encode(_customTwRules));
    }
  }

  // ── Deleted built-in rules ────────────────────────────────────
  Set<int> get deletedHkRules => Set.unmodifiable(_deletedHkRules);
  Set<int> get deletedTwRules => Set.unmodifiable(_deletedTwRules);

  Future<void> deleteBuiltInHkRule(int ruleIndex) async {
    _deletedHkRules.add(ruleIndex);
    _customHkFan.remove(ruleIndex.toString());
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _keyDeletedHkRules,
      json.encode(_deletedHkRules.toList()),
    );
    await prefs.setString(_keyCustomHkFan, json.encode(_customHkFan));
    notifyListeners();
  }

  Future<void> restoreBuiltInHkRule(int ruleIndex) async {
    _deletedHkRules.remove(ruleIndex);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _keyDeletedHkRules,
      json.encode(_deletedHkRules.toList()),
    );
    notifyListeners();
  }

  Future<void> deleteBuiltInTwRule(int ruleIndex) async {
    _deletedTwRules.add(ruleIndex);
    _customTwTai.remove(ruleIndex.toString());
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _keyDeletedTwRules,
      json.encode(_deletedTwRules.toList()),
    );
    await prefs.setString(_keyCustomTwTai, json.encode(_customTwTai));
    notifyListeners();
  }

  Future<void> restoreBuiltInTwRule(int ruleIndex) async {
    _deletedTwRules.remove(ruleIndex);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _keyDeletedTwRules,
      json.encode(_deletedTwRules.toList()),
    );
    notifyListeners();
  }

  bool isHkRuleDeleted(int ruleIndex) => _deletedHkRules.contains(ruleIndex);
  bool isTwRuleDeleted(int ruleIndex) => _deletedTwRules.contains(ruleIndex);

  // ── Reset all settings to default values ──────────────────────
  Future<void> resetToDefaults() async {
    _language = _defaultLanguage;
    _theme = _defaultTheme;
    _customHkFan.clear();
    _customTwTai.clear();
    _hkMinFan = 3;
    _hkMaxFan = 13;
    _twBaseTai = 10;
    _twTaiValue = 5;
    _customHkRules.clear();
    _customTwRules.clear();
    _deletedHkRules.clear();
    _deletedTwRules.clear();
    _twPayments.clear();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLanguage, _defaultLanguage);
    await prefs.setString(_keyTheme, _defaultTheme);
    await prefs.remove(_keyCustomHkFan);
    await prefs.remove(_keyCustomTwTai);
    await prefs.remove(_keyHkMinFan);
    await prefs.remove(_keyHkMaxFan);
    await prefs.remove(_keyTwBaseTai);
    await prefs.remove(_keyTwTaiValue);
    await prefs.remove(_keyCustomHkRules);
    await prefs.remove(_keyCustomTwRules);
    await prefs.remove(_keyDeletedHkRules);
    await prefs.remove(_keyDeletedTwRules);
    await prefs.remove(_keyTwPayments);

    notifyListeners();
  }

  // Clear all data
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await resetToDefaults();
  }
}
