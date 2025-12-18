import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/player_group.dart';

class PlayerGroupService {
  static const String _key = 'saved_player_groups';
  
  // Get all saved player groups
  static Future<List<PlayerGroup>> getSavedGroups() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_key);
    
    if (jsonString == null) {
      return [];
    }
    
    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => PlayerGroup.fromJson(json)).toList();
    } catch (e) {
      print('Error reading player groups: $e');
      return [];
    }
  }
  
  // Save player group
  static Future<bool> saveGroup(PlayerGroup group) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<PlayerGroup> currentGroups = await getSavedGroups();
      
      // Check if group with same name already exists
      final existingIndex = currentGroups.indexWhere(
        (g) => g.name == group.name
      );
      
      if (existingIndex != -1) {
        // Update existing group
        currentGroups[existingIndex] = group;
      } else {
        // Add new group
        currentGroups.add(group);
      }
      
      // Convert to JSON and save
      final String jsonString = json.encode(
        currentGroups.map((g) => g.toJson()).toList()
      );
      
      await prefs.setString(_key, jsonString);
      return true;
    } catch (e) {
      print('Error saving player group: $e');
      return false;
    }
  }
  
  // Delete player group
  static Future<bool> deleteGroup(String groupName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<PlayerGroup> currentGroups = await getSavedGroups();
      
      currentGroups.removeWhere((group) => group.name == groupName);
      
      final String jsonString = json.encode(
        currentGroups.map((g) => g.toJson()).toList()
      );
      
      await prefs.setString(_key, jsonString);
      return true;
    } catch (e) {
      print('Error deleting player group: $e');
      return false;
    }
  }
  
  // Load specific group
  static Future<PlayerGroup?> loadGroup(String groupName) async {
    final List<PlayerGroup> groups = await getSavedGroups();
    try {
      return groups.firstWhere((group) => group.name == groupName);
    } catch (e) {
      return null;
    }
  }
}