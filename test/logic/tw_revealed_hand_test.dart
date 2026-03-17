import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/logic/tw_pattern_evaluator.dart';
import 'package:flutter_application_1/models/tw_hand.dart';

void main() {
  // Helper: fully revealed hand (5 exposed melds + 1 concealed tile for eye)
  TwHand revealedHand() {
    return const TwHand(
      exposedMelds: [
        Meld(type: MeldType.pong, tiles: ['1m', '1m', '1m']),
        Meld(type: MeldType.pong, tiles: ['2m', '2m', '2m']),
        Meld(type: MeldType.chow, tiles: ['3p', '4p', '5p']),
        Meld(type: MeldType.chow, tiles: ['6p', '7p', '8p']),
        Meld(type: MeldType.chow, tiles: ['1s', '2s', '3s']),
      ],
      concealedTiles: ['9s'],
      winningTile: '9s',
    );
  }

  group('全求人 (All Revealed) — 15 Tai', () {
    test('valid: 5 exposed melds + 1 concealed tile + discard win → allRevealed', () {
      final hand = revealedHand();
      final result = TwPatternEvaluator.evaluate(
        hand: hand,
        isSelfDraw: false,
        flowerCount: 0,
      );
      expect(result.finalMatches.any((m) => m.id == 'allRevealed'), true);
      final match = result.finalMatches.firstWhere((m) => m.id == 'allRevealed');
      expect(match.tai, 15);
    });

    test('invalid: self-draw → not 全求人 (should be 半求人 instead)', () {
      final hand = revealedHand();
      final result = TwPatternEvaluator.evaluate(
        hand: hand,
        isSelfDraw: true,
        flowerCount: 0,
      );
      expect(result.finalMatches.any((m) => m.id == 'allRevealed'), false);
    });

    test('invalid: more than 1 concealed tile → not revealed hand', () {
      final hand = const TwHand(
        exposedMelds: [
          Meld(type: MeldType.pong, tiles: ['1m', '1m', '1m']),
          Meld(type: MeldType.pong, tiles: ['2m', '2m', '2m']),
          Meld(type: MeldType.chow, tiles: ['3p', '4p', '5p']),
          Meld(type: MeldType.chow, tiles: ['6p', '7p', '8p']),
        ],
        concealedTiles: ['1s', '2s', '3s', '9s'],
        winningTile: '9s',
      );
      final result = TwPatternEvaluator.evaluate(
        hand: hand,
        isSelfDraw: false,
        flowerCount: 0,
      );
      expect(result.finalMatches.any((m) => m.id == 'allRevealed'), false);
    });

    test('invalid: has concealed kong → not 全求人', () {
      final hand = const TwHand(
        exposedMelds: [
          Meld(type: MeldType.pong, tiles: ['1m', '1m', '1m']),
          Meld(type: MeldType.pong, tiles: ['2m', '2m', '2m']),
          Meld(type: MeldType.chow, tiles: ['3p', '4p', '5p']),
          Meld(type: MeldType.concealedKong, tiles: ['6p', '6p', '6p', '6p']),
          Meld(type: MeldType.chow, tiles: ['1s', '2s', '3s']),
        ],
        concealedTiles: ['9s'],
        winningTile: '9s',
      );
      final result = TwPatternEvaluator.evaluate(
        hand: hand,
        isSelfDraw: false,
        flowerCount: 0,
      );
      expect(result.finalMatches.any((m) => m.id == 'allRevealed'), false);
    });

    test('valid with kong: exposed kong counts as open call', () {
      final hand = const TwHand(
        exposedMelds: [
          Meld(type: MeldType.pong, tiles: ['1m', '1m', '1m']),
          Meld(type: MeldType.kong, tiles: ['2m', '2m', '2m', '2m']),
          Meld(type: MeldType.chow, tiles: ['3p', '4p', '5p']),
          Meld(type: MeldType.chow, tiles: ['6p', '7p', '8p']),
          Meld(type: MeldType.chow, tiles: ['1s', '2s', '3s']),
        ],
        concealedTiles: ['9s'],
        winningTile: '9s',
      );
      final result = TwPatternEvaluator.evaluate(
        hand: hand,
        isSelfDraw: false,
        flowerCount: 0,
      );
      expect(result.finalMatches.any((m) => m.id == 'allRevealed'), true);
    });
  });

  group('半求人 (Half Revealed) — 8 Tai', () {
    test('valid: 5 exposed melds + 1 concealed tile + self-draw → halfRevealed', () {
      final hand = revealedHand();
      final result = TwPatternEvaluator.evaluate(
        hand: hand,
        isSelfDraw: true,
        flowerCount: 0,
      );
      expect(result.finalMatches.any((m) => m.id == 'halfRevealed'), true);
      final match = result.finalMatches.firstWhere((m) => m.id == 'halfRevealed');
      expect(match.tai, 8);
    });

    test('invalid: discard win → not 半求人 (should be 全求人 instead)', () {
      final hand = revealedHand();
      final result = TwPatternEvaluator.evaluate(
        hand: hand,
        isSelfDraw: false,
        flowerCount: 0,
      );
      expect(result.finalMatches.any((m) => m.id == 'halfRevealed'), false);
    });

    test('invalid: more than 1 concealed tile → not 半求人', () {
      final hand = const TwHand(
        exposedMelds: [
          Meld(type: MeldType.pong, tiles: ['1m', '1m', '1m']),
          Meld(type: MeldType.pong, tiles: ['2m', '2m', '2m']),
          Meld(type: MeldType.chow, tiles: ['3p', '4p', '5p']),
          Meld(type: MeldType.chow, tiles: ['6p', '7p', '8p']),
        ],
        concealedTiles: ['1s', '2s', '3s', '9s'],
        winningTile: '9s',
      );
      final result = TwPatternEvaluator.evaluate(
        hand: hand,
        isSelfDraw: true,
        flowerCount: 0,
      );
      expect(result.finalMatches.any((m) => m.id == 'halfRevealed'), false);
    });
  });

  group('全求人 vs 半求人 mutual exclusivity', () {
    test('discard win → 全求人 only, not 半求人', () {
      final hand = revealedHand();
      final result = TwPatternEvaluator.evaluate(
        hand: hand,
        isSelfDraw: false,
        flowerCount: 0,
      );
      expect(result.finalMatches.any((m) => m.id == 'allRevealed'), true);
      expect(result.finalMatches.any((m) => m.id == 'halfRevealed'), false);
    });

    test('self-draw → 半求人 only, not 全求人', () {
      final hand = revealedHand();
      final result = TwPatternEvaluator.evaluate(
        hand: hand,
        isSelfDraw: true,
        flowerCount: 0,
      );
      expect(result.finalMatches.any((m) => m.id == 'halfRevealed'), true);
      expect(result.finalMatches.any((m) => m.id == 'allRevealed'), false);
    });
  });

  group('Exclusion: 半求人 excludes 全求人', () {
    test('halfRevealed excludes allRevealed in exclusion rules', () {
      final hand = revealedHand();
      final result = TwPatternEvaluator.evaluate(
        hand: hand,
        isSelfDraw: true,
        flowerCount: 0,
      );
      // Both cannot be in final output
      final hasAll = result.finalMatches.any((m) => m.id == 'allRevealed');
      final hasHalf = result.finalMatches.any((m) => m.id == 'halfRevealed');
      // At most one should be true
      expect(hasAll && hasHalf, false);
    });
  });
}
