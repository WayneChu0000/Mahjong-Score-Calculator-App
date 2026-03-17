import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/logic/tw_pattern_evaluator.dart';
import 'package:flutter_application_1/models/tw_hand.dart';

void main() {
  // Helper to build a fully concealed hand
  TwHand concealed(List<String> tiles, String winTile) {
    return TwHand(concealedTiles: tiles, winningTile: winTile);
  }

  group('暗刻: winning tile completing pong — self-draw vs discard', () {
    // Hand: 1s×3(full pong), 3s×2(+win=pong), 6s×2(eye)
    // If self-draw: 1s pong + 3s pong = 二暗刻
    // If discard: only 1s pong = no X暗刻 pattern (need ≥2)
    test('1s1s1s 3s3s 6s6s + win 3s: self-draw → 二暗刻', () {
      final hand = concealed([
        '1s', '1s', '1s',
        '3s', '3s',
        '6s', '6s',
        '2m', '3m', '4m',
        '5p', '6p', '7p',
        '8m', '9m',
      ], '7m'); // Use a chow-completing tile for realistic hand

      // Actually use the exact example from user:
      // 1s1s1s 3s3s 6s6s winning 3s (need 17 tiles for TW)
      final hand2 = concealed([
        '1s', '1s', '1s',
        '3s', '3s',
        '6s', '6s',
        '2m', '3m', '4m',
        '5p', '6p', '7p',
        '8m', '8m', '8m',
      ], '3s');

      final selfDraw = TwPatternEvaluator.evaluate(
        hand: hand2,
        isSelfDraw: true,
        flowerCount: 1,
        wrongFlowerCount: 1,
      );
      // 1s×3 = 1 concealed pong, 3s×2 + win 3s = 1 concealed pong, 8m×3 = 1 concealed pong → 三暗刻
      expect(
        selfDraw.finalMatches.any((m) => m.id == 'threeConcealedPongs'),
        true,
        reason: 'self-draw: 1s, 8m full pongs + 3s completed by winning tile = 三暗刻',
      );
    });

    test('1s1s1s 3s3s 6s6s winning 3s: discard → 二暗刻 (3s pong not counted)', () {
      final hand = concealed([
        '1s', '1s', '1s',
        '3s', '3s',
        '6s', '6s',
        '2m', '3m', '4m',
        '5p', '6p', '7p',
        '8m', '8m', '8m',
      ], '3s');

      final discard = TwPatternEvaluator.evaluate(
        hand: hand,
        isSelfDraw: false,
        flowerCount: 1,
        wrongFlowerCount: 1,
      );
      // 1s×3 + 8m×3 = 2 concealed pongs, 3s from discard → NOT counted as concealed pong
      expect(
        discard.finalMatches.any((m) => m.id == 'twoConcealedPongs'),
        true,
        reason: 'discard: only 1s×3 and 8m×3 are concealed pongs = 二暗刻',
      );
      expect(
        discard.finalMatches.any((m) => m.id == 'threeConcealedPongs'),
        false,
        reason: '3s completed by discard is NOT a concealed pong',
      );
    });

    test('two concealed + winning completing third: self-draw → 三暗刻', () {
      // 2p×3(concealed), 5s×3(concealed), 9m×2 + win 9m, 7m×2 pair
      final hand = concealed([
        '2p', '2p', '2p',
        '5s', '5s', '5s',
        '9m', '9m',
        '1m', '2m', '3m',
        '4p', '5p', '6p',
        '7m', '7m',
      ], '9m');

      final result = TwPatternEvaluator.evaluate(
        hand: hand,
        isSelfDraw: true,
        flowerCount: 1,
        wrongFlowerCount: 1,
      );
      expect(
        result.finalMatches.any((m) => m.id == 'threeConcealedPongs'),
        true,
        reason: '2p + 5s full pongs + 9m (self-draw) = 三暗刻',
      );
    });

    test('two concealed + winning completing third: discard → 二暗刻', () {
      final hand = concealed([
        '2p', '2p', '2p',
        '5s', '5s', '5s',
        '9m', '9m',
        '1m', '2m', '3m',
        '4p', '5p', '6p',
        '7m', '7m',
      ], '9m');

      final result = TwPatternEvaluator.evaluate(
        hand: hand,
        isSelfDraw: false,
        flowerCount: 1,
        wrongFlowerCount: 1,
      );
      expect(
        result.finalMatches.any((m) => m.id == 'twoConcealedPongs'),
        true,
        reason: 'discard: only 2p, 5s are concealed pongs = 二暗刻',
      );
      expect(
        result.finalMatches.any((m) => m.id == 'threeConcealedPongs'),
        false,
      );
    });

    test('winning tile completing only concealed pong: self-draw → counts, discard → zero', () {
      // Only 1 concealed pong from winning tile: 4s×2 + win 4s
      // No other concealed pongs
      final hand = concealed([
        '4s', '4s',
        '1m', '2m', '3m',
        '4p', '5p', '6p',
        '7m', '8m', '9m',
        '1s', '2s', '3s',
        '8p',
      ], '4s');

      final selfDraw = TwPatternEvaluator.evaluate(
        hand: hand,
        isSelfDraw: true,
        flowerCount: 1,
        wrongFlowerCount: 1,
      );
      // Only 1 concealed pong from winning tile — no X暗刻 pattern (need ≥2)
      expect(
        selfDraw.finalMatches.any((m) =>
            m.id == 'twoConcealedPongs' ||
            m.id == 'threeConcealedPongs' ||
            m.id == 'fourConcealedPongs' ||
            m.id == 'fiveConcealedPongs'),
        false,
        reason: '1 concealed pong does not trigger any concealed pong pattern',
      );

      final discard = TwPatternEvaluator.evaluate(
        hand: hand,
        isSelfDraw: false,
        flowerCount: 1,
        wrongFlowerCount: 1,
      );
      expect(
        discard.finalMatches.any((m) =>
            m.id == 'twoConcealedPongs' ||
            m.id == 'threeConcealedPongs' ||
            m.id == 'fourConcealedPongs' ||
            m.id == 'fiveConcealedPongs'),
        false,
        reason: 'discard: 0 concealed pongs',
      );
    });

    test('full concealed pongs (≥3 in concealedTiles) always count regardless of self-draw', () {
      // 1m×3, 2m×3 in concealed — these are full pongs, not dependent on winning tile
      final hand = concealed([
        '1m', '1m', '1m',
        '2m', '2m', '2m',
        '3p', '4p', '5p',
        '6s', '7s', '8s',
        '1s', '2s', '3s',
        '9p',
      ], '9p');

      for (final isSelfDraw in [true, false]) {
        final result = TwPatternEvaluator.evaluate(
          hand: hand,
          isSelfDraw: isSelfDraw,
          flowerCount: 1,
          wrongFlowerCount: 1,
        );
        expect(
          result.finalMatches.any((m) => m.id == 'twoConcealedPongs'),
          true,
          reason: 'isSelfDraw=$isSelfDraw: 1m×3, 2m×3 full concealed pongs = 二暗刻',
        );
      }
    });

    test('kongs always count as concealed pongs regardless of self-draw', () {
      final hand = TwHand(
        exposedMelds: [
          const Meld(type: MeldType.kong, tiles: ['1m', '1m', '1m', '1m']),
          const Meld(type: MeldType.concealedKong, tiles: ['2m', '2m', '2m', '2m']),
          const Meld(type: MeldType.chow, tiles: ['3p', '4p', '5p']),
          const Meld(type: MeldType.chow, tiles: ['6s', '7s', '8s']),
          const Meld(type: MeldType.chow, tiles: ['1s', '2s', '3s']),
        ],
        concealedTiles: ['9p'],
        winningTile: '9p',
      );

      for (final isSelfDraw in [true, false]) {
        final result = TwPatternEvaluator.evaluate(
          hand: hand,
          isSelfDraw: isSelfDraw,
          flowerCount: 1,
          wrongFlowerCount: 1,
        );
        expect(
          result.finalMatches.any((m) => m.id == 'twoConcealedPongs'),
          true,
          reason: 'isSelfDraw=$isSelfDraw: 2 kongs = 二暗刻',
        );
      }
    });

    test('五暗刻 with self-draw: winning tile can complete 5th pong', () {
      // 4 full concealed pongs + winning tile completes 5th + pair
      final hand = concealed([
        '1m', '1m', '1m',
        '2m', '2m', '2m',
        '3m', '3m', '3m',
        '4p', '4p', '4p',
        '5p', '5p',
        '6s', '6s',
      ], '5p');

      final selfDraw = TwPatternEvaluator.evaluate(
        hand: hand,
        isSelfDraw: true,
        flowerCount: 0,
      );
      expect(
        selfDraw.finalMatches.any((m) => m.id == 'jianJianHu'),
        true,
        reason: 'self-draw: 5 concealed pongs + all pongs + concealed = 間間胡',
      );
    });

    test('五暗刻 with discard: winning tile does NOT complete 5th pong → 四暗刻', () {
      // Same hand but discard — only 4 concealed pongs
      final hand = concealed([
        '1m', '1m', '1m',
        '2m', '2m', '2m',
        '3m', '3m', '3m',
        '4p', '4p', '4p',
        '5p', '5p',
        '6s', '6s',
      ], '5p');

      final discard = TwPatternEvaluator.evaluate(
        hand: hand,
        isSelfDraw: false,
        flowerCount: 0,
      );
      expect(
        discard.finalMatches.any((m) => m.id == 'fourConcealedPongs'),
        true,
        reason: 'discard: 4 concealed pongs (5p not counted) = 四暗刻',
      );
      expect(
        discard.finalMatches.any((m) => m.id == 'fiveConcealedPongs'),
        false,
        reason: 'discard: winning tile does not form concealed pong',
      );
    });
  });
}
