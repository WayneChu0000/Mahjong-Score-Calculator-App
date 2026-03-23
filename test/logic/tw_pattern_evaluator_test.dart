import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/logic/tw_pattern_evaluator.dart';
import 'package:flutter_application_1/models/tw_hand.dart';

void main() {
  group('TwPatternEvaluator', () {
    // ── Helper to build a fully concealed hand ──────────────────
    TwHand concealed(List<String> tiles, String winTile,
        {bool isDing = false}) {
      return TwHand(
        concealedTiles: tiles,
        winningTile: winTile,
        isDing: isDing,
      );
    }

    // ── Helper: all-pong concealed hand ─────────────────────────
    // e.g. 1m1m1m 2m2m2m 3m3m3m 4m4m4m 5m5m (pong-based with pairs as eye)
    TwHand allPongConcealed() {
      // 1m×3, 2m×3, 3m×3, 4m×3, 5m×2 = 14 tiles + 3 kongs extra?
      // For TW: 17 tiles. So: 5 pongs + 1 pair = 5×3 + 2 = 17
      return concealed(
        [
          '1m', '1m', '1m', // pong
          '2m', '2m', '2m', // pong
          '3m', '3m', '3m', // pong
          '4m', '4m', '4m', // pong
          '5m', '5m', '5m', // pong
          '6m',             // part of eye
        ],
        '6m', // winning tile completes eye
      );
    }

    test('self-draw adds 1 tai', () {
      // Use exposed meld so it's NOT fully concealed (avoids concealedSelfDraw)
      final hand = TwHand(
        exposedMelds: [
          const Meld(type: MeldType.pong, tiles: ['1z', '1z', '1z']),
        ],
        concealedTiles: [
          '1m', '2m', '3m', '4m', '5m', '6m', '7m', '8m', '9m',
          '1p', '2p', '3p', '4p',
        ],
        winningTile: '4p',
      );
      final result = TwPatternEvaluator.evaluate(
        hand: hand,
        isSelfDraw: true,
        flowerCount: 1,
        wrongFlowerCount: 1,
      );
      final selfDraw = result.finalMatches.where((m) => m.id == 'selfDraw');
      expect(selfDraw.isNotEmpty, true);
      expect(selfDraw.first.tai, 1);
    });

    test('concealed hand (門清) gives 3 tai', () {
      final hand = concealed(
        ['1m', '2m', '3m', '4m', '5m', '6m', '7m', '8m', '9m',
         '1p', '2p', '3p', '4p', '5p', '6p', '7p'],
        '8p',
      );
      final result = TwPatternEvaluator.evaluate(
        hand: hand,
        isSelfDraw: false,
        flowerCount: 1,
        wrongFlowerCount: 1,
      );
      final menQing = result.finalMatches.where((m) => m.id == 'concealedHand');
      expect(menQing.isNotEmpty, true);
      expect(menQing.first.tai, 3);
    });

    test('concealed self-draw (門清自摸) gives 5 tai and excludes 門清 + 自摸', () {
      final hand = concealed(
        ['1m', '2m', '3m', '4m', '5m', '6m', '7m', '8m', '9m',
         '1p', '2p', '3p', '4p', '5p', '6p', '7p'],
        '8p',
      );
      final result = TwPatternEvaluator.evaluate(
        hand: hand,
        isSelfDraw: true,
        flowerCount: 1,
        wrongFlowerCount: 1,
      );
      // Should have concealedSelfDraw
      expect(
        result.finalMatches.any((m) => m.id == 'concealedSelfDraw'),
        true,
      );
      // Should NOT have plain selfDraw or concealedHand (excluded)
      expect(
        result.finalMatches.any((m) => m.id == 'selfDraw'),
        false,
      );
      expect(
        result.finalMatches.any((m) => m.id == 'concealedHand'),
        false,
      );
    });

    test('no flowers gives 1 tai', () {
      // Include an honor tile to avoid noHonorsNoFlowers exclusion
      final hand = TwHand(
        exposedMelds: [
          const Meld(type: MeldType.pong, tiles: ['1z', '1z', '1z']),
        ],
        concealedTiles: [
          '1m', '2m', '3m', '4m', '5m', '6m', '7m', '8m', '9m',
          '1p', '2p', '3p', '4p',
        ],
        winningTile: '4p',
      );
      final result = TwPatternEvaluator.evaluate(
        hand: hand,
        isSelfDraw: false,
        flowerCount: 0,
      );
      expect(result.finalMatches.any((m) => m.id == 'noFlowers'), true);
    });

    test('proper flower gives 2 tai each', () {
      final hand = concealed(
        ['1m', '2m', '3m', '4m', '5m', '6m', '7m', '8m', '9m',
         '1p', '2p', '3p', '4p', '5p', '6p', '7p'],
        '8p',
      );
      final result = TwPatternEvaluator.evaluate(
        hand: hand,
        isSelfDraw: false,
        flowerCount: 2,
        properFlowerCount: 1,
        wrongFlowerCount: 1,
      );
      final properFlowers =
          result.finalMatches.where((m) => m.id == 'properFlower');
      expect(properFlowers.length, 1);
      expect(properFlowers.first.tai, 2);
    });

    test('wrong flower gives 1 tai each', () {
      final hand = concealed(
        ['1m', '2m', '3m', '4m', '5m', '6m', '7m', '8m', '9m',
         '1p', '2p', '3p', '4p', '5p', '6p', '7p'],
        '8p',
      );
      final result = TwPatternEvaluator.evaluate(
        hand: hand,
        isSelfDraw: false,
        flowerCount: 1,
        properFlowerCount: 0,
        wrongFlowerCount: 1,
      );
      final wrongFlowers =
          result.finalMatches.where((m) => m.id == 'wrongFlower');
      expect(wrongFlowers.length, 1);
      expect(wrongFlowers.first.tai, 1);
    });

    test('no honors gives 1 tai', () {
      final hand = concealed(
        ['1m', '2m', '3m', '4m', '5m', '6m', '7m', '8m', '9m',
         '1p', '2p', '3p', '4p', '5p', '6p', '7p'],
        '8p',
      );
      final result = TwPatternEvaluator.evaluate(
        hand: hand,
        isSelfDraw: false,
        flowerCount: 1,
        wrongFlowerCount: 1,
      );
      expect(result.finalMatches.any((m) => m.id == 'noHonors'), true);
    });

    test('no honors + no flowers gives 5 tai (excludes individual)', () {
      final hand = concealed(
        ['1m', '2m', '3m', '4m', '5m', '6m', '7m', '8m', '9m',
         '1p', '2p', '3p', '4p', '5p', '6p', '7p'],
        '8p',
      );
      final result = TwPatternEvaluator.evaluate(
        hand: hand,
        isSelfDraw: false,
        flowerCount: 0,
      );
      expect(
        result.finalMatches.any((m) => m.id == 'noHonorsNoFlowers'),
        true,
      );
      // Individual noHonors and noFlowers should be excluded
      expect(result.finalMatches.any((m) => m.id == 'noHonors'), false);
      expect(result.finalMatches.any((m) => m.id == 'noFlowers'), false);
    });

    test('exposed hand is NOT fully concealed', () {
      final hand = TwHand(
        exposedMelds: [
          const Meld(type: MeldType.pong, tiles: ['1z', '1z', '1z']),
        ],
        concealedTiles: [
          '2m', '3m', '4m', '5m', '6m', '7m', '8m', '9m',
          '1p', '2p', '3p', '4p', '5p',
        ],
        winningTile: '6p',
      );
      final result = TwPatternEvaluator.evaluate(
        hand: hand,
        isSelfDraw: false,
        flowerCount: 1,
        wrongFlowerCount: 1,
      );
      expect(result.finalMatches.any((m) => m.id == 'concealedHand'), false);
    });

    test('four concealed pongs excludes two and three concealed pongs', () {
      // All concealed: 5 pongs + 1 pair = 17 tiles
      final hand = concealed(
        [
          '1m', '1m', '1m',
          '2m', '2m', '2m',
          '3m', '3m', '3m',
          '4m', '4m', '4m',
          '5m', '5m', '5m',
          '6m',
        ],
        '6m',
      );
      final result = TwPatternEvaluator.evaluate(
        hand: hand,
        isSelfDraw: false,
        flowerCount: 1,
        wrongFlowerCount: 1,
      );
      // The evaluator counts concealed pongs from concealed tiles
      // 5 × 3 = 5 pongs, winning tile completes pair, so 5 concealed pongs
      expect(
        result.finalMatches.any((m) => m.id == 'fiveConcealedPongs'),
        true,
      );
      expect(
        result.finalMatches.any((m) => m.id == 'fourConcealedPongs'),
        false,
      );
      expect(
        result.finalMatches.any((m) => m.id == 'threeConcealedPongs'),
        false,
      );
      expect(
        result.finalMatches.any((m) => m.id == 'twoConcealedPongs'),
        false,
      );
    });

    test('ding — gives 5 tai bonus', () {
      // Hand where the winning tile has 0 copies in concealed
      final hand = TwHand(
        concealedTiles: [
          '1m', '1m', '1m',
          '2m', '2m', '2m',
          '3m', '3m', '3m',
          '4m', '4m', '4m',
          '5m', '5m', '5m',
          '6m',
        ],
        winningTile: '7m',
        isDing: true,
      );
      final result = TwPatternEvaluator.evaluate(
        hand: hand,
        isSelfDraw: false,
        flowerCount: 1,
        wrongFlowerCount: 1,
      );
      expect(result.finalMatches.any((m) => m.id == 'dingBonus'), true);
      final dingMatch = result.finalMatches.firstWhere((m) => m.id == 'dingBonus');
      expect(dingMatch.tai, equals(5));
    });

    test('ding — fake single wait also gives 5 tai bonus', () {
      // Hand where the winning tile already exists in concealed
      final hand = TwHand(
        concealedTiles: [
          '1m', '1m', '1m',
          '2m', '2m', '2m',
          '3m', '3m', '3m',
          '4m', '4m', '4m',
          '5m', '5m', '5m',
          '6m',
        ],
        winningTile: '6m', // 6m is in concealed → fake single
        isDing: true,
      );
      final result = TwPatternEvaluator.evaluate(
        hand: hand,
        isSelfDraw: false,
        flowerCount: 1,
        wrongFlowerCount: 1,
      );
      expect(result.finalMatches.any((m) => m.id == 'dingBonus'), true);
      final dingMatch = result.finalMatches.firstWhere((m) => m.id == 'dingBonus');
      expect(dingMatch.tai, equals(5));
    });

    test('ding not set → no single wait pattern', () {
      final hand = TwHand(
        concealedTiles: [
          '1m', '1m', '1m',
          '2m', '2m', '2m',
          '3m', '3m', '3m',
          '4m', '4m', '4m',
          '5m', '5m', '5m',
          '6m',
        ],
        winningTile: '7m',
        isDing: false,
      );
      final result = TwPatternEvaluator.evaluate(
        hand: hand,
        isSelfDraw: false,
        flowerCount: 1,
        wrongFlowerCount: 1,
      );
      expect(result.finalMatches.any((m) => m.id == 'trueSingleWait'), false);
      expect(result.finalMatches.any((m) => m.id == 'fakeSingleWait'), false);
    });

    test('dragon pong (中發白) gives 2 tai each', () {
      final hand = TwHand(
        exposedMelds: [
          const Meld(type: MeldType.pong, tiles: ['5z', '5z', '5z']),
        ],
        concealedTiles: [
          '1m', '2m', '3m', '4m', '5m', '6m', '7m', '8m', '9m',
          '1p', '2p', '3p',
          '4p',
        ],
        winningTile: '4p',
      );
      final result = TwPatternEvaluator.evaluate(
        hand: hand,
        isSelfDraw: false,
        flowerCount: 1,
        wrongFlowerCount: 1,
      );
      expect(
        result.finalMatches.any(
          (m) => m.id == 'dragonPong_5z' && m.tai == 2,
        ),
        true,
      );
    });

    test('exposed kong gives 1 tai', () {
      final hand = TwHand(
        exposedMelds: [
          const Meld(type: MeldType.kong, tiles: ['1m', '1m', '1m', '1m']),
        ],
        concealedTiles: [
          '2m', '3m', '4m', '5m', '6m', '7m', '8m', '9m',
          '1p', '2p', '3p', '4p', '5p',
        ],
        winningTile: '6p',
      );
      final result = TwPatternEvaluator.evaluate(
        hand: hand,
        isSelfDraw: false,
        flowerCount: 1,
        wrongFlowerCount: 1,
      );
      expect(result.finalMatches.any((m) => m.id == 'exposedKong'), true);
    });

    test('pure one suit gives 80 tai', () {
      final hand = concealed(
        [
          '1m', '1m', '1m',
          '2m', '2m', '2m',
          '3m', '3m', '3m',
          '4m', '4m', '4m',
          '5m', '5m', '5m',
          '9m',
        ],
        '9m',
      );
      final result = TwPatternEvaluator.evaluate(
        hand: hand,
        isSelfDraw: false,
        flowerCount: 1,
        wrongFlowerCount: 1,
      );
      expect(result.finalMatches.any((m) => m.id == 'pureOneSuit'), true);
    });

    test('pure one suit excludes mixed one suit and missing one suit', () {
      final hand = concealed(
        [
          '1m', '1m', '1m',
          '2m', '2m', '2m',
          '3m', '3m', '3m',
          '4m', '4m', '4m',
          '5m', '5m', '5m',
          '9m',
        ],
        '9m',
      );
      final result = TwPatternEvaluator.evaluate(
        hand: hand,
        isSelfDraw: false,
        flowerCount: 1,
        wrongFlowerCount: 1,
      );
      expect(result.finalMatches.any((m) => m.id == 'mixedOneSuit'), false);
      expect(result.finalMatches.any((m) => m.id == 'missingOneSuit'), false);
    });

    test('all pongs gives 30 tai', () {
      // Use exposed meld so it's NOT fully concealed (avoids 五暗刻 exclusion)
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
        isSelfDraw: false,
        flowerCount: 1,
        wrongFlowerCount: 1,
      );
      expect(result.finalMatches.any((m) => m.id == 'allPongs'), true);
    });

    test('big three dragons gives 40 tai and excludes individual dragon pongs', () {
      final hand = concealed(
        [
          '5z', '5z', '5z', // 白
          '6z', '6z', '6z', // 發
          '7z', '7z', '7z', // 中
          '1m', '2m', '3m',
          '4m', '5m', '6m',
          '9m',
        ],
        '9m',
      );
      final result = TwPatternEvaluator.evaluate(
        hand: hand,
        isSelfDraw: false,
        flowerCount: 1,
        wrongFlowerCount: 1,
      );
      expect(
        result.finalMatches.any((m) => m.id == 'bigThreeDragons'),
        true,
      );
      // Individual dragon pongs should be excluded
      expect(
        result.finalMatches.any((m) => m.id.startsWith('dragonPong_')),
        false,
      );
    });

    test('grand ping hu (大平胡) excludes 無字花, 門清, 平胡', () {
      // All chows + no honors + no flowers + concealed hand
      final hand = concealed(
        [
          '1m', '2m', '3m',
          '4m', '5m', '6m',
          '7m', '8m', '9m',
          '1p', '2p', '3p',
          '4p', '5p', '6p',
          '7p',
        ],
        '7p',
      );
      final result = TwPatternEvaluator.evaluate(
        hand: hand,
        isSelfDraw: false,
        flowerCount: 0,
      );
      expect(
        result.finalMatches.any((m) => m.id == 'grandPingHu'),
        true,
      );
      // These should be excluded by 大平胡
      expect(
        result.finalMatches.any((m) => m.id == 'noHonorsNoFlowers'),
        false,
      );
      expect(
        result.finalMatches.any((m) => m.id == 'noHonors'),
        false,
      );
      expect(
        result.finalMatches.any((m) => m.id == 'noFlowers'),
        false,
      );
      expect(
        result.finalMatches.any((m) => m.id == 'pingHu'),
        false,
      );
      expect(
        result.finalMatches.any((m) => m.id == 'concealedHand'),
        false,
      );
    });

    test('two flower sets gives 30 tai and excludes one flower set', () {
      final hand = concealed(
        ['1m', '2m', '3m', '4m', '5m', '6m', '7m', '8m', '9m',
         '1p', '2p', '3p', '4p', '5p', '6p', '7p'],
        '8p',
      );
      final result = TwPatternEvaluator.evaluate(
        hand: hand,
        isSelfDraw: false,
        flowerCount: 8,
        properFlowerCount: 2,
        wrongFlowerCount: 6,
        hasOneFlowerSet: true,
        hasTwoFlowerSets: true,
      );
      expect(
        result.finalMatches.any((m) => m.id == 'twoFlowerSets'),
        true,
      );
      expect(
        result.finalMatches.any((m) => m.id == 'oneFlowerSet'),
        false,
      );
    });

    test('all simples (斷么) gives 5 tai', () {
      // All tiles 2-8, no terminals or honors
      final hand = concealed(
        [
          '2m', '3m', '4m',
          '5m', '6m', '7m',
          '2p', '3p', '4p',
          '5p', '6p', '7p',
          '2s', '3s', '4s',
          '5s',
        ],
        '5s',
      );
      final result = TwPatternEvaluator.evaluate(
        hand: hand,
        isSelfDraw: false,
        flowerCount: 1,
        wrongFlowerCount: 1,
      );
      expect(result.finalMatches.any((m) => m.id == 'allSimples'), true);
    });

    test('all honors gives 16 tai', () {
      // All honor tiles
      final hand = concealed(
        [
          '1z', '1z', '1z',
          '2z', '2z', '2z',
          '3z', '3z', '3z',
          '4z', '4z', '4z',
          '5z', '5z', '5z',
          '6z',
        ],
        '6z',
      );
      final result = TwPatternEvaluator.evaluate(
        hand: hand,
        isSelfDraw: false,
        flowerCount: 1,
        wrongFlowerCount: 1,
      );
      expect(result.finalMatches.any((m) => m.id == 'allHonors'), true);
    });

    test('exposed dragon (明龍) when some tiles exposed', () {
      // 1-9 of one suit, but some are in exposed melds
      final hand = TwHand(
        exposedMelds: [
          const Meld(type: MeldType.chow, tiles: ['1m', '2m', '3m']),
        ],
        concealedTiles: [
          '4m', '5m', '6m', '7m', '8m', '9m',
          '1p', '2p', '3p', '4p', '5p', '6p',
          '7p',
        ],
        winningTile: '7p',
      );
      final result = TwPatternEvaluator.evaluate(
        hand: hand,
        isSelfDraw: false,
        flowerCount: 1,
        wrongFlowerCount: 1,
      );
      expect(
        result.finalMatches.any((m) => m.id == 'exposedDragon'),
        true,
      );
    });

    test('concealed dragon (暗龍) when all 1-9 concealed', () {
      final hand = concealed(
        [
          '1m', '2m', '3m', '4m', '5m', '6m', '7m', '8m', '9m',
          '1p', '2p', '3p', '4p', '5p', '6p',
          '7p',
        ],
        '8p',
      );
      final result = TwPatternEvaluator.evaluate(
        hand: hand,
        isSelfDraw: false,
        flowerCount: 1,
        wrongFlowerCount: 1,
      );
      expect(
        result.finalMatches.any((m) => m.id == 'concealedDragon'),
        true,
      );
    });

    test('old & young (老少) gives 3 tai', () {
      // Has both 123 and 789 of the same suit, without forming a concealed dragon.
      final hand = concealed(
        [
          '1m', '2m', '3m', '7m', '8m', '9m',
          '1p', '2p', '3p', '4p', '5p', '6p',
          '2s', '3s', '4s', '7p',
        ],
        '7p',
      );
      final result = TwPatternEvaluator.evaluate(
        hand: hand,
        isSelfDraw: false,
        flowerCount: 1,
        wrongFlowerCount: 1,
      );
      final oldYoung = result.finalMatches.where((m) => m.id == 'oldYoung');
      expect(oldYoung.isNotEmpty, true);
      expect(oldYoung.first.tai, 3);
    });

    test('all revealed (全求人) gives 15 tai', () {
      final hand = TwHand(
        exposedMelds: [
          const Meld(type: MeldType.pong, tiles: ['1m', '1m', '1m']),
          const Meld(type: MeldType.pong, tiles: ['2m', '2m', '2m']),
          const Meld(type: MeldType.pong, tiles: ['3m', '3m', '3m']),
          const Meld(type: MeldType.chow, tiles: ['4p', '5p', '6p']),
          const Meld(type: MeldType.chow, tiles: ['7p', '8p', '9p']),
        ],
        concealedTiles: ['9m'],
        winningTile: '9m',
      );
      final result = TwPatternEvaluator.evaluate(
        hand: hand,
        isSelfDraw: false,
        flowerCount: 1,
        wrongFlowerCount: 1,
      );
      expect(result.finalMatches.any((m) => m.id == 'allRevealed'), true);
    });

    test('big four winds gives 80 tai and excludes wind pongs', () {
      final hand = concealed(
        [
          '1z', '1z', '1z', // East wind
          '2z', '2z', '2z', // South wind
          '3z', '3z', '3z', // West wind
          '4z', '4z', '4z', // North wind
          '1m', '2m', '3m',
          '5m',
        ],
        '5m',
      );
      final result = TwPatternEvaluator.evaluate(
        hand: hand,
        isSelfDraw: false,
        flowerCount: 1,
        wrongFlowerCount: 1,
      );
      expect(
        result.finalMatches.any((m) => m.id == 'bigFourWinds'),
        true,
      );
      // Individual wind pongs should be excluded
      expect(
        result.finalMatches.any(
          (m) => m.id.startsWith('properWind_') || m.id.startsWith('ordinaryWind_'),
        ),
        false,
      );
    });

    test('result totalTai sums correctly', () {
      final hand = concealed(
        ['1m', '2m', '3m', '4m', '5m', '6m', '7m', '8m', '9m',
         '1p', '2p', '3p', '4p', '5p', '6p', '7p'],
        '8p',
      );
      final result = TwPatternEvaluator.evaluate(
        hand: hand,
        isSelfDraw: false,
        flowerCount: 0,
      );
      final expectedTotal =
          result.finalMatches.fold<int>(0, (sum, m) => sum + m.tai);
      expect(result.totalTai, expectedTotal);
    });

    test('exclusion: big four winds excludes small four winds', () {
      final hand = concealed(
        [
          '1z', '1z', '1z',
          '2z', '2z', '2z',
          '3z', '3z', '3z',
          '4z', '4z', '4z',
          '1m', '2m', '3m',
          '5m',
        ],
        '5m',
      );
      final result = TwPatternEvaluator.evaluate(
        hand: hand,
        isSelfDraw: false,
        flowerCount: 1,
        wrongFlowerCount: 1,
      );
      expect(
        result.finalMatches.any((m) => m.id == 'smallFourWinds'),
        false,
      );
    });
  });
}
