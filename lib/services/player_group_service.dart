import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/player_group.dart';

class PlayerGroupService {
  // Helper to get the collection for the current user
  static CollectionReference? _getUserGroupCollection() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('player_groups');
  }
  
  // Get all saved player groups
  static Future<List<PlayerGroup>> getSavedGroups() async {
    try {
      final collection = _getUserGroupCollection();
      if (collection == null) return [];

      final querySnapshot = await collection.get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return PlayerGroup.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error reading player groups from Firebase: $e');
      return [];
    }
  }
  
  // Save player group
  static Future<bool> saveGroup(PlayerGroup group) async {
    try {
      final collection = _getUserGroupCollection();
      if (collection == null) return false;

      // Use name as document ID
      await collection.doc(group.name).set(group.toJson());
      return true;
    } catch (e) {
      print('Error saving player group to Firebase: $e');
      return false;
    }
  }
  
  // Delete player group
  static Future<bool> deleteGroup(String groupName) async {
    try {
      final collection = _getUserGroupCollection();
      if (collection == null) return false;

      await collection.doc(groupName).delete();
      return true;
    } catch (e) {
      print('Error deleting player group from Firebase: $e');
      return false;
    }
  }
  
  // Load specific group
  static Future<PlayerGroup?> loadGroup(String groupName) async {
    try {
      final collection = _getUserGroupCollection();
      if (collection == null) return null;

      final doc = await collection.doc(groupName).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return PlayerGroup.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error loading player group from Firebase: $e');
      return null;
    }
  }
}