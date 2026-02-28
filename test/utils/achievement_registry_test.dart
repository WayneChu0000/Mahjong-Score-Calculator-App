import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/models/achievement.dart';
import 'package:flutter_application_1/models/game_mode.dart';
import 'package:flutter_application_1/utils/achievement_registry.dart';

void main() {
  group('AchievementRegistry', () {
    test('all contains at least 40 achievements', () {
      expect(AchievementRegistry.all.length, greaterThanOrEqualTo(40));
    });

    test('totalCount matches all.length', () {
      expect(AchievementRegistry.totalCount, equals(AchievementRegistry.all.length));
    });

    test('all achievements have unique IDs', () {
      final ids = AchievementRegistry.all.map((d) => d.id).toSet();
      expect(ids.length, equals(AchievementRegistry.all.length));
    });

    test('all achievements have non-empty title and description keys', () {
      for (final def in AchievementRegistry.all) {
        expect(def.titleKey, isNotEmpty, reason: '${def.id} has empty titleKey');
        expect(def.descriptionKey, isNotEmpty, reason: '${def.id} has empty descriptionKey');
      }
    });

    test('all achievements have target > 0', () {
      for (final def in AchievementRegistry.all) {
        expect(def.target, greaterThan(0), reason: '${def.id} has target <= 0');
      }
    });

    test('getById returns correct achievement', () {
      final def = AchievementRegistry.getById('gen_first_game');
      expect(def, isNotNull);
      expect(def!.id, equals('gen_first_game'));
      expect(def.category, equals(AchievementCategory.general));
    });

    test('getById returns null for unknown ID', () {
      expect(AchievementRegistry.getById('nonexistent'), isNull);
    });

    test('byCategory returns only achievements of that category', () {
      final hk = AchievementRegistry.byCategory(AchievementCategory.hk);
      expect(hk, isNotEmpty);
      for (final def in hk) {
        expect(def.category, equals(AchievementCategory.hk));
      }
    });

    test('general category count', () {
      final general = AchievementRegistry.byCategory(AchievementCategory.general);
      expect(general.length, greaterThanOrEqualTo(10));
    });

    test('hk category count', () {
      final hk = AchievementRegistry.byCategory(AchievementCategory.hk);
      expect(hk.length, greaterThanOrEqualTo(10));
    });

    test('tw category count', () {
      final tw = AchievementRegistry.byCategory(AchievementCategory.tw);
      expect(tw.length, greaterThanOrEqualTo(10));
    });

    test('milestone category count', () {
      final ms = AchievementRegistry.byCategory(AchievementCategory.milestone);
      expect(ms.length, greaterThanOrEqualTo(4));
    });

    test('hk achievements require hongKong mode', () {
      final hk = AchievementRegistry.byCategory(AchievementCategory.hk);
      for (final def in hk) {
        expect(def.requiredMode, equals(GameMode.hongKong),
            reason: '${def.id} should require HK mode');
      }
    });

    test('tw achievements require taiwan mode', () {
      final tw = AchievementRegistry.byCategory(AchievementCategory.tw);
      for (final def in tw) {
        expect(def.requiredMode, equals(GameMode.taiwan),
            reason: '${def.id} should require TW mode');
      }
    });

    test('general achievements have no required mode', () {
      final general = AchievementRegistry.byCategory(AchievementCategory.general);
      for (final def in general) {
        expect(def.requiredMode, isNull,
            reason: '${def.id} should not require a mode');
      }
    });

    test('tierColor returns different colors for each tier', () {
      final colors = AchievementTier.values
          .map((t) => AchievementRegistry.tierColor(t))
          .toSet();
      expect(colors.length, equals(4));
    });

    test('tierColor returns non-transparent colors', () {
      for (final tier in AchievementTier.values) {
        final c = AchievementRegistry.tierColor(tier);
        expect(c.a, greaterThan(0));
      }
    });

    test('tierKey returns non-empty string for each tier', () {
      for (final tier in AchievementTier.values) {
        expect(AchievementRegistry.tierKey(tier), isNotEmpty);
      }
    });

    test('categories sum up to all', () {
      int sum = 0;
      for (final cat in AchievementCategory.values) {
        sum += AchievementRegistry.byCategory(cat).length;
      }
      expect(sum, equals(AchievementRegistry.all.length));
    });
  });
}
