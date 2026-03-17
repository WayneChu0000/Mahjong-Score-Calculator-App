import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/logic/tw_pattern_evaluator.dart';
import 'package:flutter_application_1/logic/hand_validator.dart';
import 'package:flutter_application_1/models/tw_hand.dart';
import 'package:flutter_application_1/models/game_mode.dart';
import 'package:flutter_application_1/localization/app_localizations.dart';

void main() {
  AppLocalizations.setLocale('English');

  // ═══════════════════════════════════════════════════════════
  //  十三么 (TW Thirteen Orphans) — 80 Tai
  //  13 orphan tiles + 1 pair + 3-tile concealed meld (chow or pong)
  // ═══════════════════════════════════════════════════════════
  group('TW Thirteen Orphans (十三么)', () {
    test('valid: 13 orphans + pair 1m + pong 2s2s2s → true', () {
      // 1m,9m,1p,9p,1s,9s,1z,2z,3z,4z,5z,6z,7z + 1m(pair) + 2s,2s,2s(pong)
      final hand = TwHand(
        concealedTiles: [
          '1m', '9m', '1p', '9p', '1s', '9s',
          '1z', '2z', '3z', '4z', '5z', '6z', '7z',
          '1m', // pair
          '2s', '2s', // part of pong
        ],
        winningTile: '2s', // completes pong
      );
      expect(TwPatternEvaluator.isTwThirteenOrphans(hand), isTrue);
    });

    test('valid: 13 orphans + pair 7z + chow 2m3m4m → true', () {
      final hand = TwHand(
        concealedTiles: [
          '1m', '9m', '1p', '9p', '1s', '9s',
          '1z', '2z', '3z', '4z', '5z', '6z', '7z',
          '7z', // pair
          '2m', '3m', // part of chow
        ],
        winningTile: '4m', // completes chow
      );
      expect(TwPatternEvaluator.isTwThirteenOrphans(hand), isTrue);
    });

    test('valid: 13 orphans + pair 9s + chow 3p4p5p → true', () {
      final hand = TwHand(
        concealedTiles: [
          '1m', '9m', '1p', '9p', '1s', '9s',
          '1z', '2z', '3z', '4z', '5z', '6z', '7z',
          '9s', // pair
          '3p', '4p', // part of chow
        ],
        winningTile: '5p', // completes chow
      );
      expect(TwPatternEvaluator.isTwThirteenOrphans(hand), isTrue);
    });

    test('invalid: missing one orphan tile → false', () {
      // Missing 7z, replaced with extra 1z
      final hand = TwHand(
        concealedTiles: [
          '1m', '9m', '1p', '9p', '1s', '9s',
          '1z', '2z', '3z', '4z', '5z', '6z', '1z',
          '1z', // pair
          '2m', '3m',
        ],
        winningTile: '4m',
      );
      expect(TwPatternEvaluator.isTwThirteenOrphans(hand), isFalse);
    });

    test('invalid: extra tiles don\'t form valid meld → false', () {
      // 3 tiles that don't form chow or pong: 2m, 5p, 8s
      final hand = TwHand(
        concealedTiles: [
          '1m', '9m', '1p', '9p', '1s', '9s',
          '1z', '2z', '3z', '4z', '5z', '6z', '7z',
          '1m', // pair
          '2m', '5p',
        ],
        winningTile: '8s',
      );
      expect(TwPatternEvaluator.isTwThirteenOrphans(hand), isFalse);
    });

    test('invalid: has exposed melds → false', () {
      final hand = TwHand(
        exposedMelds: [
          const Meld(type: MeldType.pong, tiles: ['2s', '2s', '2s']),
        ],
        concealedTiles: [
          '1m', '9m', '1p', '9p', '1s', '9s',
          '1z', '2z', '3z', '4z', '5z', '6z', '7z',
          '1m',
        ],
        winningTile: '2s',
      );
      expect(TwPatternEvaluator.isTwThirteenOrphans(hand), isFalse);
    });

    test('invalid: wrong tile count (14 tiles) → false', () {
      final hand = TwHand(
        concealedTiles: [
          '1m', '9m', '1p', '9p', '1s', '9s',
          '1z', '2z', '3z', '4z', '5z', '6z', '7z',
        ],
        winningTile: '1m',
      );
      expect(TwPatternEvaluator.isTwThirteenOrphans(hand), isFalse);
    });

    test('scoring: TW 十三么 gives 80 tai', () {
      final hand = TwHand(
        concealedTiles: [
          '1m', '9m', '1p', '9p', '1s', '9s',
          '1z', '2z', '3z', '4z', '5z', '6z', '7z',
          '1m', '2s', '2s',
        ],
        winningTile: '2s',
      );
      final result = TwPatternEvaluator.evaluate(hand: hand, isSelfDraw: false);
      final orphan = result.finalMatches.where((m) => m.id == 'thirteenOrphans');
      expect(orphan.length, equals(1));
      expect(orphan.first.tai, equals(80));
    });

    test('hand validator: valid TW 十三么 → valid', () {
      final tiles = [
        '1m', '9m', '1p', '9p', '1s', '9s',
        '1z', '2z', '3z', '4z', '5z', '6z', '7z',
        '1m', // pair
        '2s', '2s', '2s', // pong
      ];
      final result = HandValidator.checkWinningHand(
        tiles,
        gameMode: GameMode.taiwan,
      );
      expect(result['valid'], isTrue);
    });

    test('hand validator: valid TW 十三么 with chow → valid', () {
      final tiles = [
        '1m', '9m', '1p', '9p', '1s', '9s',
        '1z', '2z', '3z', '4z', '5z', '6z', '7z',
        '7z', // pair
        '2m', '3m', '4m', // chow
      ];
      final result = HandValidator.checkWinningHand(
        tiles,
        gameMode: GameMode.taiwan,
      );
      expect(result['valid'], isTrue);
    });
  });

  // ═══════════════════════════════════════════════════════════
  //  十六不搭 (Sixteen Non-Matching) — 50 Tai
  //  7 honors + 3 tiles/suit (non-adjacent) + 1 pair = 17 tiles
  // ═══════════════════════════════════════════════════════════
  group('Sixteen Non-Matching (十六不搭)', () {
    test('valid: 7 honors + 1,4,7m + 2,5,8p + 3,6,9s + pair 1z → true', () {
      final tiles = [
        '1z', '2z', '3z', '4z', '5z', '6z', '7z', // 7 honors
        '1m', '4m', '7m', // bamboo: 147
        '2p', '5p', '8p', // characters: 258
        '3s', '6s', '9s', // dots: 369
        '1z', // pair (duplicate honor)
      ];
      expect(TwPatternEvaluator.isSixteenNonMatching(tiles), isTrue);
    });

    test('valid: pair in numbered tile suit → true', () {
      final tiles = [
        '1z', '2z', '3z', '4z', '5z', '6z', '7z',
        '1m', '4m', '7m', '1m', // pair in m suit (1m duplicated)
        '2p', '5p', '8p',
        '3s', '6s', '9s',
      ];
      expect(TwPatternEvaluator.isSixteenNonMatching(tiles), isTrue);
    });

    test('valid: 147s + 258p + 369m + pair 5z → true', () {
      final tiles = [
        '1z', '2z', '3z', '4z', '5z', '6z', '7z',
        '1s', '4s', '7s',
        '2p', '5p', '8p',
        '3m', '6m', '9m',
        '5z', // pair honor
      ];
      expect(TwPatternEvaluator.isSixteenNonMatching(tiles), isTrue);
    });

    test('invalid: adjacent tiles 1m, 2m in same suit → false', () {
      final tiles = [
        '1z', '2z', '3z', '4z', '5z', '6z', '7z',
        '1m', '2m', '7m', // 1 and 2 are adjacent!
        '2p', '5p', '8p',
        '3s', '6s', '9s',
        '1z',
      ];
      expect(TwPatternEvaluator.isSixteenNonMatching(tiles), isFalse);
    });

    test('invalid: adjacent tiles 2s, 4s (gap=2 OK) but 4s,5s adjacent → false', () {
      final tiles = [
        '1z', '2z', '3z', '4z', '5z', '6z', '7z',
        '1m', '4m', '7m',
        '2p', '5p', '8p',
        '4s', '5s', '9s', // 4 and 5 adjacent!
        '1z',
      ];
      expect(TwPatternEvaluator.isSixteenNonMatching(tiles), isFalse);
    });

    test('invalid: missing honor tile → false', () {
      final tiles = [
        '1z', '2z', '3z', '4z', '5z', '6z', // missing 7z
        '1m', '4m', '7m',
        '2p', '5p', '8p',
        '3s', '6s', '9s',
        '1z', '1z', // extra honors to maintain 17 count
      ];
      expect(TwPatternEvaluator.isSixteenNonMatching(tiles), isFalse);
    });

    test('invalid: wrong tile count (16) → false', () {
      final tiles = [
        '1z', '2z', '3z', '4z', '5z', '6z', '7z',
        '1m', '4m', '7m',
        '2p', '5p', '8p',
        '3s', '6s', '9s',
      ];
      expect(TwPatternEvaluator.isSixteenNonMatching(tiles), isFalse);
    });

    test('invalid: same tile 3 times in suit → false', () {
      final tiles = [
        '1z', '2z', '3z', '4z', '5z', '6z', '7z',
        '1m', '1m', '1m', '7m', // 3x 1m
        '2p', '5p', '8p',
        '3s', '6s', '9s',
      ];
      // 18 tiles — wrong count
      expect(TwPatternEvaluator.isSixteenNonMatching(tiles), isFalse);
    });

    test('scoring: 十六不搭 gives 50 tai', () {
      final hand = TwHand(
        concealedTiles: [
          '1z', '2z', '3z', '4z', '5z', '6z', '7z',
          '1z', // pair
          '1m', '4m', '7m',
          '2p', '5p', '8p',
          '3s', '6s',
        ],
        winningTile: '9s',
      );
      final result = TwPatternEvaluator.evaluate(hand: hand, isSelfDraw: false);
      final match = result.finalMatches.where((m) => m.id == 'sixteenNonMatching');
      expect(match.length, equals(1));
      expect(match.first.tai, equals(50));
    });

    test('scoring: 十六不搭 with numbered pair gives 50 tai', () {
      final hand = TwHand(
        concealedTiles: [
          '1z', '2z', '3z', '4z', '5z', '6z', '7z',
          '1m', '4m', '7m', '1m', // pair in m suit
          '2p', '5p', '8p',
          '3s', '6s',
        ],
        winningTile: '9s',
      );
      final result = TwPatternEvaluator.evaluate(hand: hand, isSelfDraw: false);
      final match = result.finalMatches.where((m) => m.id == 'sixteenNonMatching');
      expect(match.length, equals(1));
      expect(match.first.tai, equals(50));
    });

    test('hand validator: valid 十六不搭 → valid', () {
      final tiles = [
        '1z', '2z', '3z', '4z', '5z', '6z', '7z',
        '1m', '4m', '7m',
        '2p', '5p', '8p',
        '3s', '6s', '9s',
        '1z', // pair
      ];
      final result = HandValidator.checkWinningHand(
        tiles,
        gameMode: GameMode.taiwan,
      );
      expect(result['valid'], isTrue);
    });

    test('hand validator: invalid adjacent → invalid in structural check', () {
      final tiles = [
        '1z', '2z', '3z', '4z', '5z', '6z', '7z',
        '1m', '2m', '7m', // adjacent!
        '2p', '5p', '8p',
        '3s', '6s', '9s',
        '1z',
      ];
      final result = HandValidator.checkWinningHand(
        tiles,
        gameMode: GameMode.taiwan,
      );
      // Should NOT be valid as 十六不搭 (adjacent tiles),
      // and it can't form normal melds either
      expect(result['valid'], isFalse);
    });
  });

  // ═══════════════════════════════════════════════════════════
  //  Edge cases and interaction tests
  // ═══════════════════════════════════════════════════════════
  group('Edge cases', () {
    test('user example: 1z1z2z3z4z5z6z7z1p5p9p2s5s8s1m6m9m is 十六不搭', () {
      final tiles = [
        '1z', '1z', '2z', '3z', '4z', '5z', '6z', '7z',
        '1p', '5p', '9p',
        '2s', '5s', '8s',
        '1m', '6m', '9m',
      ];
      expect(TwPatternEvaluator.isSixteenNonMatching(tiles), isTrue);
    });

    test('十六不搭: 159 pattern per suit is valid', () {
      final tiles = [
        '1z', '2z', '3z', '4z', '5z', '6z', '7z',
        '1m', '5m', '9m',
        '1p', '5p', '9p',
        '1s', '5s', '9s',
        '3z', // pair
      ];
      expect(TwPatternEvaluator.isSixteenNonMatching(tiles), isTrue);
    });

    test('十六不搭: 1,3 in same suit (gap=2) is valid', () {
      final tiles = [
        '1z', '2z', '3z', '4z', '5z', '6z', '7z',
        '1m', '3m', '7m', // 1 and 3 differ by 2 (not adjacent)
        '2p', '5p', '8p',
        '3s', '6s', '9s',
        '1z',
      ];
      expect(TwPatternEvaluator.isSixteenNonMatching(tiles), isTrue);
    });
  });
}
