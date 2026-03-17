import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/logic/tw_pattern_evaluator.dart';
import 'package:flutter_application_1/models/tw_hand.dart';

void main() {
  // ── Helper to build a fully concealed hand ──────────────────
  TwHand concealed(List<String> tiles, String winTile) {
    return TwHand(
      concealedTiles: tiles,
      winningTile: winTile,
    );
  }

  // All-pong concealed hand: 5 pongs + 1 pair = 17 tiles
  // 1m×3, 2m×3, 3m×3, 4m×3, 5m×3, 6m×2
  TwHand allPongConcealedHand() {
    return concealed([
      '1m', '1m', '1m',
      '2m', '2m', '2m',
      '3m', '3m', '3m',
      '4m', '4m', '4m',
      '5m', '5m', '5m',
      '6m',
    ], '6m');
  }

  group('間間胡 (Concealed All Pongs Self-Draw) — 100 Tai', () {
    test('valid: concealed + self-draw + all pongs → has jianJianHu (100 tai)', () {
      final hand = allPongConcealedHand();
      final result = TwPatternEvaluator.evaluate(
        hand: hand,
        isSelfDraw: true,
        flowerCount: 0,
      );
      expect(
        result.finalMatches.any((m) => m.id == 'jianJianHu'),
        true,
      );
      final jjh = result.finalMatches.firstWhere((m) => m.id == 'jianJianHu');
      expect(jjh.tai, 100);
    });

    test('invalid: concealed + all pongs but NOT self-draw → no jianJianHu', () {
      final hand = allPongConcealedHand();
      final result = TwPatternEvaluator.evaluate(
        hand: hand,
        isSelfDraw: false,
        flowerCount: 0,
      );
      expect(
        result.finalMatches.any((m) => m.id == 'jianJianHu'),
        false,
      );
      // Should still have fiveConcealedPongs
      expect(
        result.finalMatches.any((m) => m.id == 'fiveConcealedPongs'),
        true,
      );
    });

    test('invalid: self-draw + all pongs but NOT concealed → no jianJianHu', () {
      // Has an exposed pong → not fully concealed
      final hand = TwHand(
        exposedMelds: [
          const Meld(type: MeldType.pong, tiles: ['1m', '1m', '1m']),
        ],
        concealedTiles: [
          '2m', '2m', '2m',
          '3m', '3m', '3m',
          '4m', '4m', '4m',
          '5m', '5m', '5m',
          '6m',
        ],
        winningTile: '6m',
      );
      final result = TwPatternEvaluator.evaluate(
        hand: hand,
        isSelfDraw: true,
        flowerCount: 0,
      );
      expect(
        result.finalMatches.any((m) => m.id == 'jianJianHu'),
        false,
      );
    });

    test('invalid: self-draw + concealed but NOT all pongs → no jianJianHu', () {
      // Has chows → not all pongs
      final hand = concealed([
        '1m', '2m', '3m', // chow
        '4m', '5m', '6m', // chow
        '7m', '8m', '9m', // chow
        '1p', '2p', '3p', // chow
        '1z', '1z', '1z', // pong
        '2z',
      ], '2z');
      final result = TwPatternEvaluator.evaluate(
        hand: hand,
        isSelfDraw: true,
        flowerCount: 0,
      );
      expect(
        result.finalMatches.any((m) => m.id == 'jianJianHu'),
        false,
      );
    });
  });

  group('間間胡 exclusion rules', () {
    test('間間胡 excludes 自摸 (selfDraw)', () {
      final hand = allPongConcealedHand();
      final result = TwPatternEvaluator.evaluate(
        hand: hand,
        isSelfDraw: true,
        flowerCount: 0,
      );
      expect(
        result.finalMatches.any((m) => m.id == 'selfDraw'),
        false,
        reason: '間間胡 should exclude selfDraw',
      );
    });

    test('間間胡 excludes 門清 (concealedHand)', () {
      final hand = allPongConcealedHand();
      final result = TwPatternEvaluator.evaluate(
        hand: hand,
        isSelfDraw: true,
        flowerCount: 0,
      );
      expect(
        result.finalMatches.any((m) => m.id == 'concealedHand'),
        false,
        reason: '間間胡 should exclude concealedHand',
      );
    });

    test('間間胡 excludes 門清自摸 (concealedSelfDraw)', () {
      final hand = allPongConcealedHand();
      final result = TwPatternEvaluator.evaluate(
        hand: hand,
        isSelfDraw: true,
        flowerCount: 0,
      );
      expect(
        result.finalMatches.any((m) => m.id == 'concealedSelfDraw'),
        false,
        reason: '間間胡 should exclude concealedSelfDraw',
      );
    });

    test('間間胡 excludes 對對胡 (allPongs)', () {
      final hand = allPongConcealedHand();
      final result = TwPatternEvaluator.evaluate(
        hand: hand,
        isSelfDraw: true,
        flowerCount: 0,
      );
      expect(
        result.finalMatches.any((m) => m.id == 'allPongs'),
        false,
        reason: '間間胡 should exclude allPongs',
      );
    });

    test('間間胡 excludes 五暗刻 (fiveConcealedPongs)', () {
      final hand = allPongConcealedHand();
      final result = TwPatternEvaluator.evaluate(
        hand: hand,
        isSelfDraw: true,
        flowerCount: 0,
      );
      expect(
        result.finalMatches.any((m) => m.id == 'fiveConcealedPongs'),
        false,
        reason: '間間胡 should exclude fiveConcealedPongs',
      );
    });

    test('間間胡 does NOT exclude other patterns (e.g. noHonors)', () {
      // All-pong hand with number tiles only → noHonors should still count
      final hand = allPongConcealedHand();
      final result = TwPatternEvaluator.evaluate(
        hand: hand,
        isSelfDraw: true,
        flowerCount: 0,
      );
      // noHonors (1 tai) should still appear
      expect(
        result.rawMatches.any((m) => m.id == 'noHonors'),
        true,
        reason: 'noHonors should still be detected',
      );
    });
  });

  group('五暗刻 excludes 對對胡', () {
    test('五暗刻 without self-draw: has fiveConcealedPongs, NOT allPongs', () {
      final hand = allPongConcealedHand();
      final result = TwPatternEvaluator.evaluate(
        hand: hand,
        isSelfDraw: false,
        flowerCount: 0,
      );
      expect(
        result.finalMatches.any((m) => m.id == 'fiveConcealedPongs'),
        true,
      );
      expect(
        result.finalMatches.any((m) => m.id == 'allPongs'),
        false,
        reason: '五暗刻 should exclude 對對胡',
      );
    });

    test('五暗刻 raw matches still contain allPongs', () {
      final hand = allPongConcealedHand();
      final result = TwPatternEvaluator.evaluate(
        hand: hand,
        isSelfDraw: false,
        flowerCount: 0,
      );
      // allPongs detected in raw matches...
      expect(
        result.rawMatches.any((m) => m.id == 'allPongs'),
        true,
      );
      // ...but excluded from final matches
      expect(
        result.finalMatches.any((m) => m.id == 'allPongs'),
        false,
      );
    });
  });

  group('間間胡 vs 五暗刻 difference', () {
    test('self-draw makes the difference: with self-draw → 間間胡, without → 五暗刻', () {
      final hand = allPongConcealedHand();

      // With self-draw → 間間胡
      final withSelfDraw = TwPatternEvaluator.evaluate(
        hand: hand,
        isSelfDraw: true,
        flowerCount: 0,
      );
      expect(withSelfDraw.finalMatches.any((m) => m.id == 'jianJianHu'), true);
      expect(withSelfDraw.finalMatches.any((m) => m.id == 'fiveConcealedPongs'), false);

      // Without self-draw → 五暗刻 (no 間間胡)
      final withoutSelfDraw = TwPatternEvaluator.evaluate(
        hand: hand,
        isSelfDraw: false,
        flowerCount: 0,
      );
      expect(withoutSelfDraw.finalMatches.any((m) => m.id == 'jianJianHu'), false);
      expect(withoutSelfDraw.finalMatches.any((m) => m.id == 'fiveConcealedPongs'), true);
    });
  });

  group('間間胡 with honor tiles', () {
    test('concealed all pongs with honors + self-draw → jianJianHu', () {
      // 1z×3, 2z×3, 3z×3, 4z×3, 5z×3, 6z×2 = 17
      final hand = concealed([
        '1z', '1z', '1z',
        '2z', '2z', '2z',
        '3z', '3z', '3z',
        '4z', '4z', '4z',
        '5z', '5z', '5z',
        '6z',
      ], '6z');
      final result = TwPatternEvaluator.evaluate(
        hand: hand,
        isSelfDraw: true,
        flowerCount: 0,
      );
      expect(result.finalMatches.any((m) => m.id == 'jianJianHu'), true);
    });
  });
}
