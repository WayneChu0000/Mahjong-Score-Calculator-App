import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/achievement.dart';
import '../utils/achievement_registry.dart';

/// Firebase CRUD service for player achievements within a group.
///
/// Data path: `users/{uid}/player_groups/{groupName}/achievements/{playerId}`
///   - `counters` (Map): raw AchievementCounters
///   - `progress` (Map<achvId, AchievementProgress>): per-achievement progress
class AchievementService {
  AchievementService._();

  static final _db = FirebaseFirestore.instance;

  // ── Path helpers ─────────────────────────────────────────────────

  static DocumentReference? _achievementDoc(String groupName, String playerId) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return _db
        .collection('users')
        .doc(user.uid)
        .collection('player_groups')
        .doc(groupName)
        .collection('achievements')
        .doc(playerId);
  }

  // ── Counters ─────────────────────────────────────────────────────

  /// Load counters for a player in a group.
  static Future<AchievementCounters> loadCounters(
    String groupName,
    String playerId,
  ) async {
    try {
      final doc = _achievementDoc(groupName, playerId);
      if (doc == null) return const AchievementCounters();

      final snap = await doc.get();
      if (!snap.exists) return const AchievementCounters();

      final data = snap.data() as Map<String, dynamic>? ?? {};
      final countersRaw = data['counters'] as Map<String, dynamic>? ?? {};
      return AchievementCounters.fromJson(countersRaw);
    } catch (e) {
      debugPrint('Error loading achievement counters: $e');
      return const AchievementCounters();
    }
  }

  /// Persist updated counters.
  static Future<void> saveCounters(
    String groupName,
    String playerId,
    AchievementCounters counters,
  ) async {
    try {
      final doc = _achievementDoc(groupName, playerId);
      if (doc == null) return;

      await doc.set({'counters': counters.toJson()}, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error saving achievement counters: $e');
    }
  }

  // ── Progress ─────────────────────────────────────────────────────

  /// Load all achievement progress entries for a player.
  static Future<Map<String, AchievementProgress>> loadProgress(
    String groupName,
    String playerId,
  ) async {
    try {
      final doc = _achievementDoc(groupName, playerId);
      if (doc == null) return {};

      final snap = await doc.get();
      if (!snap.exists) return {};

      final data = snap.data() as Map<String, dynamic>? ?? {};
      final progressRaw = data['progress'] as Map<String, dynamic>? ?? {};

      return progressRaw.map(
        (key, value) => MapEntry(
          key,
          AchievementProgress.fromJson(
            value is Map<String, dynamic> ? value : {},
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error loading achievement progress: $e');
      return {};
    }
  }

  /// Persist the full progress map.
  static Future<void> saveProgress(
    String groupName,
    String playerId,
    Map<String, AchievementProgress> progress,
  ) async {
    try {
      final doc = _achievementDoc(groupName, playerId);
      if (doc == null) return;

      await doc.set({
        'progress': progress.map((key, value) => MapEntry(key, value.toJson())),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error saving achievement progress: $e');
    }
  }

  // ── Convenience ──────────────────────────────────────────────────

  /// Load everything needed for the achievement screen.
  static Future<
    ({AchievementCounters counters, Map<String, AchievementProgress> progress})
  >
  loadAll(String groupName, String playerId) async {
    final counters = await loadCounters(groupName, playerId);
    final progress = await loadProgress(groupName, playerId);
    return (counters: counters, progress: progress);
  }

  /// Persist both counters and progress in one call.
  static Future<void> saveAll(
    String groupName,
    String playerId, {
    required AchievementCounters counters,
    required Map<String, AchievementProgress> progress,
  }) async {
    try {
      final doc = _achievementDoc(groupName, playerId);
      if (doc == null) return;

      await doc.set({
        'counters': counters.toJson(),
        'progress': progress.map((key, value) => MapEntry(key, value.toJson())),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error saving achievement data: $e');
    }
  }

  /// Get unlock summary: total unlocked / total achievements.
  static Future<({int unlocked, int total})> getUnlockSummary(
    String groupName,
    String playerId,
  ) async {
    final progress = await loadProgress(groupName, playerId);
    final unlocked = progress.values.where((p) => p.isUnlocked).length;
    return (unlocked: unlocked, total: AchievementRegistry.totalCount);
  }
}
