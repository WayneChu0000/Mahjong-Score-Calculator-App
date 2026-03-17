import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/achievement.dart';
import '../utils/achievement_registry.dart';

/// Firebase CRUD service for player achievements within a group.
///
/// Data path: `users/{uid}/player_groups/{groupName}/achievements/{playerId}`
///   - `counters` (Map): raw AchievementCounters
///   - `progress` (Map<achvId, AchievementProgress>): per-achievement progress
///
/// A **local SharedPreferences cache** mirrors every write so that
/// achievement state survives even when Firebase is unreachable
/// (e.g. gRPC "Failed to resolve name" errors). On load, data is read
/// from BOTH sources and the one with more progress wins, keeping
/// achievements from re-triggering after an app restart.
class AchievementService {
  AchievementService._();

  static final _db = FirebaseFirestore.instance;

  // ── Local cache key helpers ──────────────────────────────────────

  static String _localKey(String groupName, String playerId) =>
      'achv_${groupName}_$playerId';

  /// Save counters + progress to SharedPreferences.
  static Future<void> _saveLocal(
    String groupName,
    String playerId, {
    required AchievementCounters counters,
    required Map<String, AchievementProgress> progress,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final payload = jsonEncode({
        'counters': counters.toJson(),
        'progress':
            progress.map((key, value) => MapEntry(key, value.toJson())),
      });
      await prefs.setString(_localKey(groupName, playerId), payload);
    } catch (e) {
      debugPrint('Error saving achievement data locally: $e');
    }
  }

  /// Load counters + progress from SharedPreferences.
  static Future<
    ({AchievementCounters counters, Map<String, AchievementProgress> progress})?
  > _loadLocal(String groupName, String playerId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_localKey(groupName, playerId));
      if (raw == null) return null;

      final data = jsonDecode(raw) as Map<String, dynamic>;
      final countersRaw = data['counters'] as Map<String, dynamic>? ?? {};
      final progressRaw = data['progress'] as Map<String, dynamic>? ?? {};

      return (
        counters: AchievementCounters.fromJson(countersRaw),
        progress: progressRaw.map(
          (key, value) => MapEntry(
            key,
            AchievementProgress.fromJson(
              value is Map<String, dynamic> ? value : {},
            ),
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error loading achievement data locally: $e');
      return null;
    }
  }

  /// Merge two datasets, keeping the one with more unlocked achievements
  /// (or higher totalGames if tied).  This prevents regression when one
  /// source is stale.
  static ({
    AchievementCounters counters,
    Map<String, AchievementProgress> progress,
  }) _merge(
    AchievementCounters cA,
    Map<String, AchievementProgress> pA,
    AchievementCounters cB,
    Map<String, AchievementProgress> pB,
  ) {
    final unlockedA = pA.values.where((p) => p.isUnlocked).length;
    final unlockedB = pB.values.where((p) => p.isUnlocked).length;

    if (unlockedA > unlockedB) return (counters: cA, progress: pA);
    if (unlockedB > unlockedA) return (counters: cB, progress: pB);

    // Same unlock count → prefer higher totalGames
    if (cA.totalGames >= cB.totalGames) {
      return (counters: cA, progress: pA);
    }
    return (counters: cB, progress: pB);
  }

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
  ///
  /// Reads from BOTH Firebase and local cache, then merges so that
  /// the most up-to-date data wins. This prevents achievements from
  /// re-triggering when Firebase was unreachable during a previous save.
  static Future<
    ({AchievementCounters counters, Map<String, AchievementProgress> progress})
  >
  loadAll(String groupName, String playerId) async {
    // Load Firebase and local in parallel
    final fbFuture = Future(() async {
      final counters = await loadCounters(groupName, playerId);
      final progress = await loadProgress(groupName, playerId);
      return (counters: counters, progress: progress);
    });
    final localFuture = _loadLocal(groupName, playerId);

    final fbData = await fbFuture;
    final localData = await localFuture;

    if (localData == null) {
      // No local cache — use Firebase data and seed local cache
      _saveLocal(groupName, playerId,
          counters: fbData.counters, progress: fbData.progress);
      return fbData;
    }

    // Merge: keep whichever source has more progress
    final merged = _merge(
      fbData.counters, fbData.progress,
      localData.counters, localData.progress,
    );

    // Update local cache with the merged result
    _saveLocal(groupName, playerId,
        counters: merged.counters, progress: merged.progress);

    return merged;
  }

  /// Persist both counters and progress in one call.
  ///
  /// Writes to local cache first (fast & reliable), then to Firebase
  /// (async, may fail silently if offline).
  static Future<void> saveAll(
    String groupName,
    String playerId, {
    required AchievementCounters counters,
    required Map<String, AchievementProgress> progress,
  }) async {
    // Always write locally first — this is the safety net
    await _saveLocal(groupName, playerId,
        counters: counters, progress: progress);

    // Then write to Firebase
    try {
      final doc = _achievementDoc(groupName, playerId);
      if (doc == null) return;

      await doc.set({
        'counters': counters.toJson(),
        'progress': progress.map((key, value) => MapEntry(key, value.toJson())),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error saving achievement data to Firebase: $e');
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
