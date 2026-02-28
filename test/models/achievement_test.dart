import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/models/achievement.dart';
import 'package:flutter_application_1/models/game_mode.dart';

void main() {
  group('AchievementTier', () {
    test('has all four values', () {
      expect(AchievementTier.values.length, equals(4));
      expect(AchievementTier.values, contains(AchievementTier.bronze));
      expect(AchievementTier.values, contains(AchievementTier.silver));
      expect(AchievementTier.values, contains(AchievementTier.gold));
      expect(AchievementTier.values, contains(AchievementTier.diamond));
    });
  });

  group('AchievementCategory', () {
    test('has all four values', () {
      expect(AchievementCategory.values.length, equals(4));
      expect(AchievementCategory.values, contains(AchievementCategory.general));
      expect(AchievementCategory.values, contains(AchievementCategory.hk));
      expect(AchievementCategory.values, contains(AchievementCategory.tw));
      expect(AchievementCategory.values, contains(AchievementCategory.milestone));
    });
  });

  group('AchievementDef', () {
    test('stores all fields', () {
      const def = AchievementDef(
        id: 'test_id',
        titleKey: 'testTitle',
        descriptionKey: 'testDesc',
        category: AchievementCategory.general,
        tier: AchievementTier.gold,
        iconCodePoint: 0xe87c,
        target: 10,
      );

      expect(def.id, equals('test_id'));
      expect(def.titleKey, equals('testTitle'));
      expect(def.descriptionKey, equals('testDesc'));
      expect(def.category, equals(AchievementCategory.general));
      expect(def.tier, equals(AchievementTier.gold));
      expect(def.iconCodePoint, equals(0xe87c));
      expect(def.target, equals(10));
      expect(def.requiredMode, isNull);
    });

    test('supports requiredMode', () {
      const def = AchievementDef(
        id: 'hk_test',
        titleKey: 't',
        descriptionKey: 'd',
        category: AchievementCategory.hk,
        tier: AchievementTier.bronze,
        iconCodePoint: 0xe87c,
        target: 1,
        requiredMode: GameMode.hongKong,
      );

      expect(def.requiredMode, equals(GameMode.hongKong));
    });
  });

  group('AchievementProgress', () {
    test('default constructor', () {
      final p = AchievementProgress(
        achievementId: 'gen_first_game',
        isUnlocked: false,
        progress: 0,
      );

      expect(p.achievementId, equals('gen_first_game'));
      expect(p.isUnlocked, isFalse);
      expect(p.unlockedAt, isNull);
      expect(p.progress, equals(0));
    });

    test('toJson roundtrip', () {
      final now = DateTime(2025, 1, 15, 12, 0, 0);
      final p = AchievementProgress(
        achievementId: 'gen_first_win',
        isUnlocked: true,
        unlockedAt: now,
        progress: 5,
      );

      final json = p.toJson();
      expect(json['achievementId'], equals('gen_first_win'));
      expect(json['isUnlocked'], isTrue);
      expect(json['progress'], equals(5));
      expect(json['unlockedAt'], isNotNull);

      final restored = AchievementProgress.fromJson(json);
      expect(restored.achievementId, equals('gen_first_win'));
      expect(restored.isUnlocked, isTrue);
      expect(restored.progress, equals(5));
      expect(restored.unlockedAt, isNotNull);
    });

    test('fromJson with empty map gives defaults', () {
      final p = AchievementProgress.fromJson({});
      expect(p.achievementId, equals(''));
      expect(p.isUnlocked, isFalse);
      expect(p.progress, equals(0));
    });

    test('copyWith overrides fields', () {
      final p = AchievementProgress(
        achievementId: 'test',
        isUnlocked: false,
        progress: 3,
      );

      final p2 = p.copyWith(isUnlocked: true, progress: 10);
      expect(p2.achievementId, equals('test'));
      expect(p2.isUnlocked, isTrue);
      expect(p2.progress, equals(10));

      // Original unchanged
      expect(p.isUnlocked, isFalse);
      expect(p.progress, equals(3));
    });
  });

  group('AchievementCounters', () {
    test('default constructor has zero values', () {
      const c = AchievementCounters();
      expect(c.totalGames, equals(0));
      expect(c.totalWins, equals(0));
      expect(c.totalSelfDrawn, equals(0));
      expect(c.maxConsecutiveWins, equals(0));
      expect(c.hkGames, equals(0));
      expect(c.hkMaxFan, equals(0));
      expect(c.twGames, equals(0));
      expect(c.twMaxTai, equals(0));
      expect(c.totalScore, equals(0));
    });

    test('toJson produces expected keys', () {
      const c = AchievementCounters(
        totalGames: 5,
        totalWins: 3,
        hkMaxFan: 8,
        totalScore: 1000,
      );

      final json = c.toJson();
      expect(json['totalGames'], equals(5));
      expect(json['totalWins'], equals(3));
      expect(json['hkMaxFan'], equals(8));
      expect(json['totalScore'], equals(1000));
    });

    test('fromJson roundtrip', () {
      const c = AchievementCounters(
        totalGames: 10,
        totalWins: 7,
        totalSelfDrawn: 3,
        maxConsecutiveWins: 5,
        currentConsecutiveWins: 2,
        hkGames: 4,
        hkWins: 3,
        hkMaxFan: 10,
        hkConcealedHand: 1,
        hkAllOneSuit: 1,
        twGames: 6,
        twWins: 4,
        twMaxTai: 15,
        totalScore: 5000,
      );

      final json = c.toJson();
      final restored = AchievementCounters.fromJson(json);

      expect(restored.totalGames, equals(10));
      expect(restored.totalWins, equals(7));
      expect(restored.totalSelfDrawn, equals(3));
      expect(restored.maxConsecutiveWins, equals(5));
      expect(restored.currentConsecutiveWins, equals(2));
      expect(restored.hkGames, equals(4));
      expect(restored.hkWins, equals(3));
      expect(restored.hkMaxFan, equals(10));
      expect(restored.hkConcealedHand, equals(1));
      expect(restored.hkAllOneSuit, equals(1));
      expect(restored.twGames, equals(6));
      expect(restored.twWins, equals(4));
      expect(restored.twMaxTai, equals(15));
      expect(restored.totalScore, equals(5000));
    });

    test('fromJson with empty map returns defaults', () {
      final c = AchievementCounters.fromJson({});
      expect(c.totalGames, equals(0));
      expect(c.totalWins, equals(0));
      expect(c.totalScore, equals(0));
    });

    test('copyWith overrides specific fields', () {
      const c = AchievementCounters(totalGames: 1, totalWins: 1);
      final c2 = c.copyWith(totalGames: 10, hkMaxFan: 13);
      expect(c2.totalGames, equals(10));
      expect(c2.totalWins, equals(1)); // unchanged
      expect(c2.hkMaxFan, equals(13));
    });
  });
}
