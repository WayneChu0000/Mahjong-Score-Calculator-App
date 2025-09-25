import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/player_group.dart';

class PlayerGroupService {
  static const String _key = 'saved_player_groups';
  
  // 獲取所有已儲存的玩家群組
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
      print('讀取玩家群組時發生錯誤: $e');
      return [];
    }
  }
  
  // 儲存玩家群組
  static Future<bool> saveGroup(PlayerGroup group) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<PlayerGroup> currentGroups = await getSavedGroups();
      
      // 檢查是否已存在相同名稱的群組
      final existingIndex = currentGroups.indexWhere(
        (g) => g.name == group.name
      );
      
      if (existingIndex != -1) {
        // 更新現有群組
        currentGroups[existingIndex] = group;
      } else {
        // 新增群組
        currentGroups.add(group);
      }
      
      // 轉換為 JSON 並儲存
      final String jsonString = json.encode(
        currentGroups.map((g) => g.toJson()).toList()
      );
      
      await prefs.setString(_key, jsonString);
      return true;
    } catch (e) {
      print('儲存玩家群組時發生錯誤: $e');
      return false;
    }
  }
  
  // 刪除玩家群組
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
      print('刪除玩家群組時發生錯誤: $e');
      return false;
    }
  }
  
  // 載入特定群組
  static Future<PlayerGroup?> loadGroup(String groupName) async {
    final List<PlayerGroup> groups = await getSavedGroups();
    try {
      return groups.firstWhere((group) => group.name == groupName);
    } catch (e) {
      return null;
    }
  }
}