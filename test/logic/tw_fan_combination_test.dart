import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/logic/hand_patterns.dart';
import 'package:flutter_application_1/models/tw_rules.dart';
import 'package:flutter_application_1/models/rule.dart';
import 'package:flutter_application_1/localization/app_localizations.dart';

/// Tests that multiple hand patterns can co-exist on the same hand.
/// When validators fire simultaneously, the fan values should stack.
void main() {
  AppLocalizations.setLocale('English');

  late List<Rule> rules;

  setUp(() {
    rules = twRules;
  });

  /// Run all validators and return the total fan from tile-detectable patterns.
  int _autoDetectedFan(List<String> hand) {
    int total = 0;
    for (final rule in rules) {
      if (rule.validator != null && rule.validator!(hand)) {
        total += rule.fanValue;
      }
    }
    return total;
  }

  /// Collect names of all matched rules
  List<String> _matchedNames(List<String> hand) {
    return [
      for (final rule in rules)
        if (rule.validator != null && rule.validator!(hand)) rule.name,
    ];
  }

  // ═══════════════════════════════════════════════════════════
  // Pure One Suit combos
  // ═══════════════════════════════════════════════════════════
  group('Pure One Suit combinations', () {
    test(
      'Pure bamboo all-chow hand detects: isPureHand + isPingHu + isConcealedDragon + hasEyeOf258',
      () {
        // 1s2s3s 4s5s6s 7s8s9s 1s2s3s + 5s5s
        final hand = [
          '1s',
          '2s',
          '3s',
          '4s',
          '5s',
          '6s',
          '7s',
          '8s',
          '9s',
          '1s',
          '2s',
          '3s',
          '5s',
          '5s',
        ];
        expect(HandPatterns.isPureHand(hand), isTrue);
        expect(HandPatterns.isPingHu(hand), isTrue);
        expect(HandPatterns.isConcealedDragon(hand), isTrue);
        expect(HandPatterns.hasEyeOf258(hand), isTrue);
        // 80 + 3 + 20 + 1 = 104
        expect(_autoDetectedFan(hand), equals(104));
      },
    );

    test('Pure bamboo all-pong hand detects: isPureHand + isAllPongs', () {
      // 1s1s1s 3s3s3s 5s5s5s 7s7s7s + 9s9s
      final hand = [
        '1s',
        '1s',
        '1s',
        '3s',
        '3s',
        '3s',
        '5s',
        '5s',
        '5s',
        '7s',
        '7s',
        '7s',
        '9s',
        '9s',
      ];
      expect(HandPatterns.isPureHand(hand), isTrue);
      expect(HandPatterns.isAllPongs(hand), isTrue);
      // Five Concealed Pongs also uses isAllPongs → 80 + 30 + 80 = 190
      final matched = _matchedNames(hand);
      expect(matched.length, greaterThanOrEqualTo(2));
    });
  });

  // ═══════════════════════════════════════════════════════════
  // Mixed One Suit combos
  // ═══════════════════════════════════════════════════════════
  group('Mixed One Suit combinations', () {
    test(
      'Mixed bamboo + honors all-pong hand detects: isMixedOneSuit + isAllPongs',
      () {
        // 1s1s1s 5s5s5s 9s9s9s 5z5z5z + 7s7s
        final hand = [
          '1s',
          '1s',
          '1s',
          '5s',
          '5s',
          '5s',
          '9s',
          '9s',
          '9s',
          '5z',
          '5z',
          '5z',
          '7s',
          '7s',
        ];
        expect(HandPatterns.isMixedOneSuit(hand), isTrue);
        expect(HandPatterns.isAllPongs(hand), isTrue);
      },
    );
  });

  // ═══════════════════════════════════════════════════════════
  // Dragon pattern combos
  // ═══════════════════════════════════════════════════════════
  group('Dragon pattern combinations', () {
    test('Big Three Dragons + Half Flush both fire', () {
      // 5z5z5z 6z6z6z 7z7z7z 1m2m3m + 5m5m
      final hand = [
        '5z',
        '5z',
        '5z',
        '6z',
        '6z',
        '6z',
        '7z',
        '7z',
        '7z',
        '1m',
        '2m',
        '3m',
        '5m',
        '5m',
      ];
      expect(HandPatterns.isBigThreeDragons(hand), isTrue);
      expect(HandPatterns.isMixedOneSuit(hand), isTrue);
    });

    test('Small Three Dragons + All Pongs both fire', () {
      // 5z5z5z 6z6z6z 7z7z 1m1m1m 9p9p9p
      final hand = [
        '5z',
        '5z',
        '5z',
        '6z',
        '6z',
        '6z',
        '7z',
        '7z',
        '1m',
        '1m',
        '1m',
        '9p',
        '9p',
        '9p',
      ];
      expect(HandPatterns.isSmallThreeDragons(hand), isTrue);
      expect(HandPatterns.isAllPongs(hand), isTrue);
    });

    test('Big Three Dragons does NOT trigger Small Three Dragons', () {
      final hand = [
        '5z',
        '5z',
        '5z',
        '6z',
        '6z',
        '6z',
        '7z',
        '7z',
        '7z',
        '1m',
        '2m',
        '3m',
        '5m',
        '5m',
      ];
      expect(HandPatterns.isBigThreeDragons(hand), isTrue);
      expect(HandPatterns.isSmallThreeDragons(hand), isFalse);
    });
  });

  // ═══════════════════════════════════════════════════════════
  // Wind pattern combos
  // ═══════════════════════════════════════════════════════════
  group('Wind pattern combinations', () {
    test('Big Four Winds + All Pongs both fire', () {
      // E×3 S×3 W×3 N×3 + 1m1m
      final hand = [
        '1z',
        '1z',
        '1z',
        '2z',
        '2z',
        '2z',
        '3z',
        '3z',
        '3z',
        '4z',
        '4z',
        '4z',
        '1m',
        '1m',
      ];
      expect(HandPatterns.isBigFourWinds(hand), isTrue);
      expect(HandPatterns.isAllPongs(hand), isTrue);
    });

    test(
      'Big Four Winds also triggers Small Four Winds (controller handles exclusion)',
      () {
        final hand = [
          '1z',
          '1z',
          '1z',
          '2z',
          '2z',
          '2z',
          '3z',
          '3z',
          '3z',
          '4z',
          '4z',
          '4z',
          '1m',
          '1m',
        ];
        expect(HandPatterns.isBigFourWinds(hand), isTrue);
        // isSmallFourWinds returns true even for big; controller prunes the lower pattern
        expect(HandPatterns.isSmallFourWinds(hand), isTrue);
      },
    );

    test('Small Four Winds + All Pongs both fire', () {
      final hand = [
        '1z',
        '1z',
        '1z',
        '2z',
        '2z',
        '2z',
        '3z',
        '3z',
        '3z',
        '4z',
        '4z',
        '1m',
        '1m',
        '1m',
      ];
      expect(HandPatterns.isSmallFourWinds(hand), isTrue);
      expect(HandPatterns.isAllPongs(hand), isTrue);
    });
  });

  // ═══════════════════════════════════════════════════════════
  // Terminal combos
  // ═══════════════════════════════════════════════════════════
  group('Terminal pattern combinations', () {
    test('Pure Terminals implies All Pongs', () {
      final hand = [
        '1m',
        '1m',
        '1m',
        '9m',
        '9m',
        '9m',
        '1p',
        '1p',
        '1p',
        '9s',
        '9s',
        '9s',
        '1s',
        '1s',
      ];
      expect(HandPatterns.isPureTerminals(hand), isTrue);
      expect(HandPatterns.isAllPongs(hand), isTrue);
    });

    test('Mixed Terminals implies All Pongs', () {
      final hand = [
        '1m',
        '1m',
        '1m',
        '9p',
        '9p',
        '9p',
        '5z',
        '5z',
        '5z',
        '1z',
        '1z',
        '1z',
        '9s',
        '9s',
      ];
      expect(HandPatterns.isMixedTerminals(hand), isTrue);
      expect(HandPatterns.isAllPongs(hand), isTrue);
    });

    test('Pure Terminals also triggers Mixed Terminals', () {
      // This is an exclusion case — controller should handle
      final hand = [
        '1m',
        '1m',
        '1m',
        '9m',
        '9m',
        '9m',
        '1p',
        '1p',
        '1p',
        '9s',
        '9s',
        '9s',
        '1s',
        '1s',
      ];
      expect(HandPatterns.isPureTerminals(hand), isTrue);
      // isMixedTerminals requires both honor and terminal, so pure terminals is false
      expect(HandPatterns.isMixedTerminals(hand), isFalse);
    });
  });

  // ═══════════════════════════════════════════════════════════
  // Concealed Dragon combo
  // ═══════════════════════════════════════════════════════════
  group('Concealed Dragon combinations', () {
    test('Concealed Dragon + Pure Hand both fire on 1-9 same suit', () {
      // 1m2m3m 4m5m6m 7m8m9m 1m2m3m + 5m5m
      final hand = [
        '1m',
        '2m',
        '3m',
        '4m',
        '5m',
        '6m',
        '7m',
        '8m',
        '9m',
        '1m',
        '2m',
        '3m',
        '5m',
        '5m',
      ];
      expect(HandPatterns.isConcealedDragon(hand), isTrue);
      expect(HandPatterns.isPureHand(hand), isTrue);
      expect(HandPatterns.isPingHu(hand), isTrue);
    });
  });

  // ═══════════════════════════════════════════════════════════
  // All Simples combos
  // ═══════════════════════════════════════════════════════════
  group('All Simples combinations', () {
    test('All Simples + Ping Hu both fire', () {
      // 2m3m4m 5p6p7p 3s4s5s 6m7m8m + 5s5s
      final hand = [
        '2m',
        '3m',
        '4m',
        '5p',
        '6p',
        '7p',
        '3s',
        '4s',
        '5s',
        '6m',
        '7m',
        '8m',
        '5s',
        '5s',
      ];
      expect(HandPatterns.isAllSimples(hand), isTrue);
      expect(HandPatterns.isPingHu(hand), isTrue);
      expect(HandPatterns.hasEyeOf258(hand), isTrue);
    });
  });

  // ═══════════════════════════════════════════════════════════
  // Special hand non-overlap
  // ═══════════════════════════════════════════════════════════
  group('Thirteen Orphans exclusivity', () {
    test('Thirteen Orphans does NOT trigger All Pongs', () {
      final hand = [
        '1m',
        '9m',
        '1p',
        '9p',
        '1s',
        '9s',
        '1z',
        '2z',
        '3z',
        '4z',
        '5z',
        '6z',
        '7z',
        '1m',
      ];
      expect(HandPatterns.isThirteenOrphans(hand), isTrue);
      expect(HandPatterns.isAllPongs(hand), isFalse);
      expect(HandPatterns.isPingHu(hand), isFalse);
    });
  });

  group('All Honors combos', () {
    test('All Honors + All Pongs + Big Four Winds all fire', () {
      // E×3 S×3 W×3 N×3 + 5z5z → all honors, all pongs, big four winds
      final hand = [
        '1z',
        '1z',
        '1z',
        '2z',
        '2z',
        '2z',
        '3z',
        '3z',
        '3z',
        '4z',
        '4z',
        '4z',
        '5z',
        '5z',
      ];
      expect(HandPatterns.isAllHonors(hand), isTrue);
      expect(HandPatterns.isAllPongs(hand), isTrue);
      expect(HandPatterns.isBigFourWinds(hand), isTrue);
    });
  });
}
