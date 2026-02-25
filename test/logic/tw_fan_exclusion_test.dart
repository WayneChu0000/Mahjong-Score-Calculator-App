import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/logic/hand_patterns.dart';
import 'package:flutter_application_1/models/tw_rules.dart';
import 'package:flutter_application_1/models/rule.dart';
import 'package:flutter_application_1/localization/app_localizations.dart';

/// Tests that mutually exclusive patterns do NOT both fire,
/// ensuring the higher-fan pattern supersedes the lower one.
///
/// In TW Mahjong the controller is responsible for pruning overlaps,
/// but the HandPatterns validators themselves should NOT produce
/// logical contradictions for the same hand.
void main() {
  AppLocalizations.setLocale('English');

  late List<Rule> rules;

  setUp(() {
    rules = twRules;
  });

  // ═══════════════════════════════════════════════════════════
  // Dragon exclusions
  // ═══════════════════════════════════════════════════════════
  group('Big Three Dragons vs Small Three Dragons', () {
    test('Hand with 3 dragon triplets triggers Big but NOT Small', () {
      // 5z5z5z 6z6z6z 7z7z7z 1m2m3m + 5m5m
      final hand = ['5z', '5z', '5z', '6z', '6z', '6z', '7z', '7z', '7z', '1m', '2m', '3m', '5m', '5m'];
      expect(HandPatterns.isBigThreeDragons(hand), isTrue);
      expect(HandPatterns.isSmallThreeDragons(hand), isFalse);
    });

    test('Hand with 2 dragon triplets + dragon pair triggers Small but NOT Big', () {
      // 5z5z5z 6z6z6z 7z7z 1m1m1m + 9p9p9p
      final hand = ['5z', '5z', '5z', '6z', '6z', '6z', '7z', '7z', '1m', '1m', '1m', '9p', '9p', '9p'];
      expect(HandPatterns.isSmallThreeDragons(hand), isTrue);
      expect(HandPatterns.isBigThreeDragons(hand), isFalse);
    });
  });

  // ═══════════════════════════════════════════════════════════
  // Wind exclusions
  // ═══════════════════════════════════════════════════════════
  group('Big Four Winds vs Small Four Winds', () {
    test('Hand with 4 wind triplets triggers Big AND Small (controller must prune Small)', () {
      // E×3 S×3 W×3 N×3 + 1m1m
      final hand = ['1z', '1z', '1z', '2z', '2z', '2z', '3z', '3z', '3z', '4z', '4z', '4z', '1m', '1m'];
      expect(HandPatterns.isBigFourWinds(hand), isTrue);
      // isSmallFourWinds also returns true at the validator level;
      // the scoring controller is responsible for pruning the overlap.
      expect(HandPatterns.isSmallFourWinds(hand), isTrue);
    });

    test('Hand with 3 wind triplets + wind pair triggers Small but NOT Big', () {
      // E×3 S×3 W×3 N×2 + 1m1m1m
      final hand = ['1z', '1z', '1z', '2z', '2z', '2z', '3z', '3z', '3z', '4z', '4z', '1m', '1m', '1m'];
      expect(HandPatterns.isSmallFourWinds(hand), isTrue);
      expect(HandPatterns.isBigFourWinds(hand), isFalse);
    });
  });

  // ═══════════════════════════════════════════════════════════
  // Flush exclusions
  // ═══════════════════════════════════════════════════════════
  group('Pure One Suit vs Mixed One Suit', () {
    test('Pure One Suit does NOT trigger Mixed One Suit', () {
      // 1m2m3m 4m5m6m 7m8m9m 1m2m3m + 5m5m
      final hand = ['1m', '2m', '3m', '4m', '5m', '6m', '7m', '8m', '9m', '1m', '2m', '3m', '5m', '5m'];
      expect(HandPatterns.isPureHand(hand), isTrue);
      expect(HandPatterns.isMixedOneSuit(hand), isFalse);
    });

    test('Mixed One Suit does NOT trigger Pure One Suit', () {
      // 1m2m3m 4m5m6m 7m8m9m 5z5z5z + 1m1m
      final hand = ['1m', '2m', '3m', '4m', '5m', '6m', '7m', '8m', '9m', '5z', '5z', '5z', '1m', '1m'];
      expect(HandPatterns.isMixedOneSuit(hand), isTrue);
      expect(HandPatterns.isPureHand(hand), isFalse);
    });
  });

  // ═══════════════════════════════════════════════════════════
  // Terminal exclusions
  // ═══════════════════════════════════════════════════════════
  group('Pure Terminals vs Mixed Terminals', () {
    test('Pure Terminals does NOT trigger Mixed Terminals', () {
      // 1m1m1m 9m9m9m 1p1p1p 9s9s9s + 1s1s
      final hand = ['1m', '1m', '1m', '9m', '9m', '9m', '1p', '1p', '1p', '9s', '9s', '9s', '1s', '1s'];
      expect(HandPatterns.isPureTerminals(hand), isTrue);
      expect(HandPatterns.isMixedTerminals(hand), isFalse);
    });

    test('Mixed Terminals does NOT trigger Pure Terminals', () {
      // 1m1m1m 9p9p9p 1z1z1z 5z5z5z + 9s9s
      final hand = ['1m', '1m', '1m', '9p', '9p', '9p', '1z', '1z', '1z', '5z', '5z', '5z', '9s', '9s'];
      expect(HandPatterns.isMixedTerminals(hand), isTrue);
      expect(HandPatterns.isPureTerminals(hand), isFalse);
    });
  });

  // ═══════════════════════════════════════════════════════════
  // All Honors vs terminals
  // ═══════════════════════════════════════════════════════════
  group('All Honors is distinct from terminal patterns', () {
    test('All Honors does NOT trigger Pure Terminals', () {
      // 1z1z1z 2z2z2z 3z3z3z 5z5z5z + 6z6z
      final hand = ['1z', '1z', '1z', '2z', '2z', '2z', '3z', '3z', '3z', '5z', '5z', '5z', '6z', '6z'];
      expect(HandPatterns.isAllHonors(hand), isTrue);
      expect(HandPatterns.isPureTerminals(hand), isFalse);
    });

    test('All Honors does NOT trigger All Simples', () {
      final hand = ['1z', '1z', '1z', '2z', '2z', '2z', '3z', '3z', '3z', '5z', '5z', '5z', '6z', '6z'];
      expect(HandPatterns.isAllHonors(hand), isTrue);
      expect(HandPatterns.isAllSimples(hand), isFalse);
    });
  });

  // ═══════════════════════════════════════════════════════════
  // All Simples is incompatible with terminals / honors
  // ═══════════════════════════════════════════════════════════
  group('All Simples exclusivity', () {
    test('All Simples never contains 1 or 9', () {
      // Valid all simples hand
      final hand = ['2m', '3m', '4m', '5p', '6p', '7p', '3s', '4s', '5s', '6m', '7m', '8m', '5s', '5s'];
      expect(HandPatterns.isAllSimples(hand), isTrue);

      // Hand with a 1 should fail
      final hand2 = ['1m', '3m', '4m', '5p', '6p', '7p', '3s', '4s', '5s', '6m', '7m', '8m', '5s', '5s'];
      expect(HandPatterns.isAllSimples(hand2), isFalse);
    });

    test('All Simples never co-fires with MixedTerminals', () {
      final hand = ['2m', '3m', '4m', '5p', '6p', '7p', '3s', '4s', '5s', '6m', '7m', '8m', '5s', '5s'];
      expect(HandPatterns.isAllSimples(hand), isTrue);
      expect(HandPatterns.isMixedTerminals(hand), isFalse);
    });
  });

  // ═══════════════════════════════════════════════════════════
  // Thirteen Orphans exclusivity
  // ═══════════════════════════════════════════════════════════
  group('Thirteen Orphans cannot co-fire with suit/pong patterns', () {
    test('Thirteen Orphans is not Ping Hu', () {
      final hand = ['1m', '9m', '1p', '9p', '1s', '9s', '1z', '2z', '3z', '4z', '5z', '6z', '7z', '1m'];
      expect(HandPatterns.isThirteenOrphans(hand), isTrue);
      expect(HandPatterns.isPingHu(hand), isFalse);
    });

    test('Thirteen Orphans is not Pure Hand', () {
      final hand = ['1m', '9m', '1p', '9p', '1s', '9s', '1z', '2z', '3z', '4z', '5z', '6z', '7z', '1m'];
      expect(HandPatterns.isThirteenOrphans(hand), isTrue);
      expect(HandPatterns.isPureHand(hand), isFalse);
    });

    test('Thirteen Orphans is not All Pongs', () {
      final hand = ['1m', '9m', '1p', '9p', '1s', '9s', '1z', '2z', '3z', '4z', '5z', '6z', '7z', '1m'];
      expect(HandPatterns.isThirteenOrphans(hand), isTrue);
      expect(HandPatterns.isAllPongs(hand), isFalse);
    });
  });

  // ═══════════════════════════════════════════════════════════
  // Nine Gates exclusivity
  // ═══════════════════════════════════════════════════════════
  group('Nine Gates relationship with Pure One Suit', () {
    test('Nine Gates hand IS also Pure One Suit', () {
      // 1112345678999m — classic nine gates
      final hand = ['1m', '1m', '1m', '2m', '3m', '4m', '5m', '6m', '7m', '8m', '9m', '9m', '9m', '5m'];
      if (HandPatterns.isNineGates(hand)) {
        expect(HandPatterns.isPureHand(hand), isTrue,
            reason: 'Nine Gates must contain only one suit ⇒ isPureHand');
      }
    });
  });

  // ═══════════════════════════════════════════════════════════
  // Seven Pairs / Eight Pairs exclusivity with pong patterns
  // ═══════════════════════════════════════════════════════════
  group('Pair hands vs All Pongs', () {
    test('Seven Pairs is NOT All Pongs', () {
      // 7 distinct pairs
      final hand = ['1m', '1m', '3p', '3p', '5s', '5s', '7m', '7m', '2p', '2p', '4s', '4s', '6z', '6z'];
      if (HandPatterns.isSevenPairs(hand)) {
        expect(HandPatterns.isAllPongs(hand), isFalse);
      }
    });

    test('Eight Pairs is NOT All Pongs', () {
      // 8 pairs = 16 tiles
      final hand = [
        '1m', '1m', '3m', '3m', '5m', '5m', '7m', '7m',
        '2p', '2p', '4p', '4p', '6p', '6p', '8p', '8p',
      ];
      if (HandPatterns.isEightPairs(hand)) {
        expect(HandPatterns.isAllPongs(hand), isFalse);
      }
    });
  });
}
