import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/logic/tw_pattern_evaluator.dart';
import 'package:flutter_application_1/models/tw_hand.dart';

void main() {
  const baseExposed3 = [
    Meld(type: MeldType.chow, tiles: ['1m', '2m', '3m']),
    Meld(type: MeldType.chow, tiles: ['4m', '5m', '6m']),
    Meld(type: MeldType.chow, tiles: ['7m', '8m', '9m']),
  ];

  const baseExposed4 = [
    Meld(type: MeldType.chow, tiles: ['1m', '2m', '3m']),
    Meld(type: MeldType.chow, tiles: ['4m', '5m', '6m']),
    Meld(type: MeldType.chow, tiles: ['7m', '8m', '9m']),
    Meld(type: MeldType.chow, tiles: ['2p', '3p', '4p']),
  ];

  test('True Single Wait: middle wait 1s3s + win 2s', () {
    final hand = TwHand(
      exposedMelds: baseExposed3,
      concealedTiles: ['1s', '3s', '5p', '6p', '7p', '9s', '9s'],
      winningTile: '2s',
    );

    final result = TwPatternEvaluator.evaluate(
      hand: hand,
      isSelfDraw: false,
      flowerCount: 1,
      wrongFlowerCount: 1,
    );

    expect(result.finalMatches.any((m) => m.id == 'trueSingleWait'), isTrue);
    expect(result.finalMatches.any((m) => m.id == 'fakeSingleWait'), isFalse);
  });

  test('True Single Wait: edge wait 1s2s + win 3s', () {
    final hand = TwHand(
      exposedMelds: baseExposed3,
      concealedTiles: ['1s', '2s', '5p', '6p', '7p', '9s', '9s'],
      winningTile: '3s',
    );

    final result = TwPatternEvaluator.evaluate(
      hand: hand,
      isSelfDraw: false,
      flowerCount: 1,
      wrongFlowerCount: 1,
    );

    expect(result.finalMatches.any((m) => m.id == 'trueSingleWait'), isTrue);
  });

  test('True Single Wait: pair wait single tile + win to form eyes', () {
    final hand = TwHand(
      exposedMelds: baseExposed4,
      concealedTiles: ['1s', '5p', '6p', '7p'],
      winningTile: '1s',
    );

    final result = TwPatternEvaluator.evaluate(
      hand: hand,
      isSelfDraw: false,
      flowerCount: 1,
      wrongFlowerCount: 1,
    );

    expect(result.finalMatches.any((m) => m.id == 'trueSingleWait'), isTrue);
  });

  test('Fake Single Wait: 2s3s4s4s + win 4s (can also win 1s)', () {
    final hand = TwHand(
      exposedMelds: baseExposed4,
      concealedTiles: ['2s', '3s', '4s', '4s'],
      winningTile: '4s',
    );

    final result = TwPatternEvaluator.evaluate(
      hand: hand,
      isSelfDraw: false,
      flowerCount: 1,
      wrongFlowerCount: 1,
    );

    expect(result.finalMatches.any((m) => m.id == 'fakeSingleWait'), isTrue);
    expect(result.finalMatches.any((m) => m.id == 'trueSingleWait'), isFalse);
  });

  test('Not single wait: 2s3s4s4s + win 1s', () {
    final hand = TwHand(
      exposedMelds: baseExposed4,
      concealedTiles: ['2s', '3s', '4s', '4s'],
      winningTile: '1s',
    );

    final result = TwPatternEvaluator.evaluate(
      hand: hand,
      isSelfDraw: false,
      flowerCount: 1,
      wrongFlowerCount: 1,
    );

    expect(result.finalMatches.any((m) => m.id == 'fakeSingleWait'), isFalse);
    expect(result.finalMatches.any((m) => m.id == 'trueSingleWait'), isFalse);
  });
}
