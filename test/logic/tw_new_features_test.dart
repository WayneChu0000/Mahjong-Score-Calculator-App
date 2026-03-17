import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/logic/tw_pattern_evaluator.dart';
import 'package:flutter_application_1/models/tw_hand.dart';
import 'package:flutter_application_1/controllers/score_calculation_controller.dart';
import 'package:flutter_application_1/models/player.dart';
import 'package:flutter_application_1/models/game_mode.dart';
import 'package:flutter_application_1/localization/app_localizations.dart';

void main() {
  // ── Helper: fully concealed hand ────────────────────────────
  TwHand concealed(List<String> tiles, String winTile, {bool isDing = false}) {
    return TwHand(concealedTiles: tiles, winningTile: winTile, isDing: isDing);
  }

  TwHand withExposed(
    List<Meld> melds,
    List<String> concealed,
    String winTile, {
    bool isDing = false,
  }) {
    return TwHand(
      exposedMelds: melds,
      concealedTiles: concealed,
      winningTile: winTile,
      isDing: isDing,
    );
  }

  // ── Helper: controller-based tests ──────────────────────────
  AppLocalizations.setLocale('zh');

  final basePlayers = [
    Player(id: 0, name: '東家', score: 1000),
    Player(id: 1, name: '南家', score: 1000),
    Player(id: 2, name: '西家', score: 1000),
    Player(id: 3, name: '北家', score: 1000),
  ];

  ScoreCalculationController setupController({
    required int dealerIndex,
    int consecutiveDealerCount = 1,
    required String winningPlayer,
    required bool isSelfDraw,
    String? discardPlayer,
    TwHand? hand,
    List<String> flowers = const [],
    String specialCondition = 'None',
    String seatWind = 'East',
  }) {
    final ctrl = ScoreCalculationController(
      players: basePlayers,
      minFan: 2,
      maxFan: 1,
      gameMode: GameMode.taiwan,
      consecutiveDealerCount: consecutiveDealerCount,
      dealerIndex: dealerIndex,
      roundWindIndex: 0,
    );

    ctrl.winningPlayer = winningPlayer;
    ctrl.isSelfDraw = isSelfDraw;
    if (!isSelfDraw) {
      ctrl.discardPlayer = discardPlayer;
    }
    ctrl.roundWind = 'East';
    ctrl.seatWind = seatWind;

    for (var key in ctrl.selectedFlowers.keys.toList()) {
      ctrl.selectedFlowers[key] = false;
    }
    for (var f in flowers) {
      ctrl.selectedFlowers[f] = true;
    }

    ctrl.selectedSpecialCondition = specialCondition;

    if (hand != null) {
      ctrl.setTwHand(hand);
    } else {
      ctrl.calculateScore();
    }

    return ctrl;
  }

  // ═══════════════════════════════════════════════════════════════
  // 1. 缺一門 — Missing One Suit (no honor requirement)
  // ═══════════════════════════════════════════════════════════════
  group('缺一門 (Missing One Suit) no honor requirement', () {
    test('two numbered suits + honors → 缺一門', () {
      // m + s + honors (missing p)
      final hand = concealed([
        '1m', '2m', '3m',
        '4m', '5m', '6m',
        '7s', '8s', '9s',
        '1s', '2s', '3s',
        '1z', '1z', '1z',
        '5m',
      ], '5m');

      final result = TwPatternEvaluator.evaluate(
        hand: hand,
        isSelfDraw: false,
        flowerCount: 0,
      );
      expect(
        result.finalMatches.any((m) => m.id == 'missingOneSuit'),
        true,
        reason: '缺一門: missing p suit with honors → should trigger',
      );
    });

    test('two numbered suits WITHOUT honors → still 缺一門', () {
      // m + s only, no honors — still triggers
      final hand = concealed([
        '1m', '2m', '3m',
        '4m', '5m', '6m',
        '7s', '8s', '9s',
        '1s', '2s', '3s',
        '7m', '8m', '9m',
        '5s',
      ], '5s');

      final result = TwPatternEvaluator.evaluate(
        hand: hand,
        isSelfDraw: false,
        flowerCount: 0,
      );
      expect(
        result.finalMatches.any((m) => m.id == 'missingOneSuit'),
        true,
        reason: '缺一門: two suits without honors → should still trigger',
      );
    });

    test('all three numbered suits + honors → NOT 缺一門', () {
      // m + p + s + honors
      final hand = concealed([
        '1m', '2m', '3m',
        '4p', '5p', '6p',
        '7s', '8s', '9s',
        '1s', '2s', '3s',
        '1z', '1z', '1z',
        '5m',
      ], '5m');

      final result = TwPatternEvaluator.evaluate(
        hand: hand,
        isSelfDraw: false,
        flowerCount: 0,
      );
      expect(
        result.finalMatches.any((m) => m.id == 'missingOneSuit'),
        false,
        reason: '缺一門: all three suits present → should NOT trigger',
      );
    });
  });

  // ═══════════════════════════════════════════════════════════════
  // 2. 嚦咕嚦咕 — Eight Pairs: 1 pong + 7 pairs
  // ═══════════════════════════════════════════════════════════════
  group('嚦咕嚦咕 (Eight Pairs) = 1 pong + 7 pairs', () {
    test('1 pong + 7 pairs → 嚦咕嚦咕 (40 tai)', () {
      // 1m×3 (pong) + 2m×2, 3m×2, 4m×2, 1p×2, 5s×2, 6s×2 + 7s (half pair)
      // winning 7s completes 7th pair
      final hand = concealed([
        '1m', '1m', '1m', // pong
        '2m', '2m',       // pair 1
        '3m', '3m',       // pair 2
        '4m', '4m',       // pair 3
        '1p', '1p',       // pair 4
        '5s', '5s',       // pair 5
        '6s', '6s',       // pair 6
        '7s',             // half pair
      ], '7s'); // completes pair 7

      final result = TwPatternEvaluator.evaluate(
        hand: hand,
        isSelfDraw: false,
        flowerCount: 0,
      );
      expect(
        result.finalMatches.any((m) => m.id == 'eightPairs'),
        true,
        reason: '1m×3 pong + 7 pairs = 嚦咕嚦咕',
      );
      expect(
        result.finalMatches.firstWhere((m) => m.id == 'eightPairs').tai,
        40,
        reason: '嚦咕嚦咕 = 40 tai',
      );
    });

    test('8 pure pairs (no pong) → NOT 嚦咕嚦咕', () {
      // All pairs, no tile has count ≥ 3
      final hand = concealed([
        '1m', '1m',
        '2m', '2m',
        '3m', '3m',
        '4m', '4m',
        '1p', '1p',
        '5s', '5s',
        '6s', '6s',
        '7s', '7s',
        '8s', // singleton → not a valid pair either
      ], '9s'); // no pair here

      final result = TwPatternEvaluator.evaluate(
        hand: hand,
        isSelfDraw: false,
        flowerCount: 0,
      );
      expect(
        result.finalMatches.any((m) => m.id == 'eightPairs'),
        false,
        reason: '8 pure pairs without a pong → should NOT trigger',
      );
    });

    test('2 pongs + 5 pairs (17 tiles) → NOT 嚦咕嚦咕', () {
      // Two tiles with count ≥ 3: too many pongs
      final hand = concealed([
        '1m', '1m', '1m', // pong 1
        '2m', '2m', '2m', // pong 2
        '3m', '3m',       // pair 1
        '4m', '4m',       // pair 2
        '5m', '5m',       // pair 3
        '6m', '6m',       // pair 4
        '7m',             // half pair
      ], '7m'); // completes pair 5

      final result = TwPatternEvaluator.evaluate(
        hand: hand,
        isSelfDraw: false,
        flowerCount: 0,
      );
      expect(
        result.finalMatches.any((m) => m.id == 'eightPairs'),
        false,
        reason: '2 pongs + 5 pairs → NOT 嚦咕嚦咕 (need exactly 1 pong)',
      );
    });
  });

  // ═══════════════════════════════════════════════════════════════
  // 3. Concealed pong decomposition (backtracking)
  // ═══════════════════════════════════════════════════════════════
  group('Concealed pong decomposition: ambiguous tiles', () {
    test('1s1s1s2s3s = pair(1s) + chow(1s2s3s) → NOT a pong', () {
      // Hand where 1s×3 should decompose as pair + chow, not pong
      // 1s×3 + 2s + 3s + other melds
      final hand = concealed([
        '1s', '1s', '1s',
        '2s', '3s',
        '4m', '5m', '6m',
        '7p', '8p', '9p',
        '1m', '2m', '3m',
        '5s', '5s',
      ], '5s');

      final result = TwPatternEvaluator.evaluate(
        hand: hand,
        isSelfDraw: true,
        flowerCount: 0,
      );

      // 1s×3 should decompose as: pair(1s) + chow(1s,2s,3s)
      // Other melds: 4m5m6m, 7p8p9p, 1m2m3m + 5s pair
      // Wait, that's 2 possible pairs (1s or 5s). Best decomposition considers 5s as pair:
      // Then 1s1s1s is pong → 1 concealed pong.
      // Or 1s as pair → 1s2s3s chow + 5s5s need to be in meld → but 5s only has 2, must be pair.
      //
      // Actually with 5s as pair: 1s(pong) + 2s3s(incomplete)? No:
      // With pair=5s: remaining=1s×3,2s,3s,4m5m6m,7p8p9p,1m2m3m → 1s(pong)+2s3s(...) 2s3s is only 2 tiles,
      // not enough. Need 1s2s3s to form chow: uses 1 of 1s → remaining: 1s×2 + chow(1s2s3s).
      // Then 1s×2 can't form meld → invalid.
      // With pair=1s: remaining=1s+2s+3s → chow(1s2s3s) ✓ + 4m5m6m ✓ + 7p8p9p ✓ + 1m2m3m ✓ + 5s5s ✓
      // 0 pongs!
      // Best decomposition: pair=1s → 0 concealed pongs.
      // But wait, _bestPongDecomposition maximizes pongs! So pair=5s is tried:
      // remaining=1s×3,2s,3s,4m5m6m,7p8p9p,1m2m3m
      // First sorted tile is 1m → try pong 1m? count=1 → no. Try chow 1m2m3m → yes.
      // After removing chow: 1s×3,2s,3s,4m5m6m,7p8p9p
      // First tile: 1s → try pong 1s? count=3 → yes → remove pong 1s.
      // remaining: 2s,3s,4m,5m,6m,7p,8p,9p
      // first tile: 2s → try pong 2s? count=1 → no. Try chow 2s3s4s? no 4s → fail.
      // Backtrack: don't pong 1s. Try chow 1s2s3s → yes.
      // remaining: 1s×2,4m5m6m,7p8p9p → first tile: 1s count=2, no pong, no chow 1s2s3s(only 1s) → fail.
      // So pair=5s gives 0 valid.
      // pair=1s: 0 pongs valid. 
      // Max = 0 concealed pongs.
      expect(
        result.finalMatches.any((m) => m.id == 'twoConcealedPongs'),
        false,
        reason: '1s×3 decomposes as pair+chow when best → 0 concealed pongs',
      );
    });

    test('true concealed pongs in valid decomposition', () {
      // 2p×3 + 5s×3 + 1m2m3m + 4p5p6p + 7m7m pair, win 9m→doesn't complete pong
      // Actually let's make a clear case: 3 real pongs
      final hand = concealed([
        '2p', '2p', '2p', // pong
        '5s', '5s', '5s', // pong
        '9m', '9m', '9m', // pong
        '1m', '2m', '3m', // chow
        '4p', '5p', '6p', // chow → but 5p is used here
        '7m',
      ], '7m'); // pair 7m

      final result = TwPatternEvaluator.evaluate(
        hand: hand,
        isSelfDraw: true,
        flowerCount: 0,
      );
      expect(
        result.finalMatches.any((m) => m.id == 'threeConcealedPongs'),
        true,
        reason: 'Three clear concealed pongs: 2p, 5s, 9m → 三暗刻',
      );
    });
  });

  // ═══════════════════════════════════════════════════════════════
  // 4. 老少 — includes pong pairs (1×3 or 9×3)
  // ═══════════════════════════════════════════════════════════════
  group('老少 (Old & Young) includes pong pairs', () {
    test('pong of 1s + chow 7s8s9s → 老少', () {
      final hand = concealed([
        '1s', '1s', '1s', // pong of 1 (low)
        '7s', '8s', '9s', // chow 7-8-9 (high)
        '1m', '2m', '3m',
        '4p', '5p', '6p',
        '2m', '3m', '4m',
        '7p',
      ], '7p');

      final result = TwPatternEvaluator.evaluate(
        hand: hand,
        isSelfDraw: false,
        flowerCount: 0,
      );
      expect(
        result.finalMatches.any((m) => m.id == 'oldYoung'),
        true,
        reason: 'Pong of 1s (low) + chow 789s (high) = 老少',
      );
    });

    test('chow 1s2s3s + pong of 9s → 老少', () {
      final hand = concealed([
        '1s', '2s', '3s', // chow 1-2-3 (low)
        '9s', '9s', '9s', // pong of 9 (high)
        '1m', '2m', '3m',
        '4p', '5p', '6p',
        '2m', '3m', '4m',
        '7p',
      ], '7p');

      final result = TwPatternEvaluator.evaluate(
        hand: hand,
        isSelfDraw: false,
        flowerCount: 0,
      );
      expect(
        result.finalMatches.any((m) => m.id == 'oldYoung'),
        true,
        reason: 'Chow 123s (low) + pong of 9s (high) = 老少',
      );
    });

    test('pong of 1s + pong of 9s → 老少', () {
      final hand = concealed([
        '1s', '1s', '1s', // pong of 1 (low)
        '9s', '9s', '9s', // pong of 9 (high)
        '1m', '2m', '3m',
        '4p', '5p', '6p',
        '2m', '3m', '4m',
        '7p',
      ], '7p');

      final result = TwPatternEvaluator.evaluate(
        hand: hand,
        isSelfDraw: false,
        flowerCount: 0,
      );
      expect(
        result.finalMatches.any((m) => m.id == 'oldYoung'),
        true,
        reason: 'Pong of 1s + pong of 9s = 老少',
      );
    });

    test('chow 123s + chow 789s (classic) → 老少', () {
      final hand = concealed([
        '1s', '2s', '3s', // chow 1-2-3
        '7s', '8s', '9s', // chow 7-8-9
        '1m', '2m', '3m',
        '4p', '5p', '6p',
        '2m', '3m', '4m',
        '7p',
      ], '7p');

      final result = TwPatternEvaluator.evaluate(
        hand: hand,
        isSelfDraw: false,
        flowerCount: 0,
      );
      expect(
        result.finalMatches.any((m) => m.id == 'oldYoung'),
        true,
        reason: 'Classic chow 123s + chow 789s = 老少',
      );
    });

    test('only low (1s group) without high → NOT 老少', () {
      final hand = concealed([
        '1s', '1s', '1s', // pong of 1 (low)
        '4s', '5s', '6s', // mid
        '1m', '2m', '3m',
        '4p', '5p', '6p',
        '2m', '3m', '4m',
        '7p',
      ], '7p');

      final result = TwPatternEvaluator.evaluate(
        hand: hand,
        isSelfDraw: false,
        flowerCount: 0,
      );
      expect(
        result.finalMatches.any((m) => m.id == 'oldYoung'),
        false,
        reason: 'Only low group without high → NOT 老少',
      );
    });
  });

  // ═══════════════════════════════════════════════════════════════
  // 5. 明雜龍 = 5 tai (changed from 8)
  // ═══════════════════════════════════════════════════════════════
  group('明雜龍 (Exposed Mixed Dragon) = 5 tai', () {
    test('exposed mixed dragon gives 5 tai', () {
      // 1m2m3m (exposed) + 4s5s6s (exposed) + 7p8p9p (exposed) = mixed dragon
      final hand = withExposed([
        const Meld(type: MeldType.chow, tiles: ['1m', '2m', '3m']),
        const Meld(type: MeldType.chow, tiles: ['4s', '5s', '6s']),
        const Meld(type: MeldType.chow, tiles: ['7p', '8p', '9p']),
        const Meld(type: MeldType.chow, tiles: ['2m', '3m', '4m']),
      ], ['5m', '5m', '5m'], '5m');

      final result = TwPatternEvaluator.evaluate(
        hand: hand,
        isSelfDraw: false,
        flowerCount: 0,
      );
      final mixed = result.finalMatches.where((m) => m.id == 'exposedMixedDragon');
      expect(mixed.isNotEmpty, true, reason: 'Should detect exposed mixed dragon');
      expect(mixed.first.tai, 5, reason: '明雜龍 should be 5 tai (not 8)');
    });
  });

  // ═══════════════════════════════════════════════════════════════
  // 6. Mixed dragon multi-count (segment-count approach)
  // ═══════════════════════════════════════════════════════════════
  group('Mixed dragon multi-count with duplicate sets', () {
    test('single mixed dragon detected correctly', () {
      // 1m2m3m + 4s5s6s + 7p8p9p = one mixed dragon
      final hand = withExposed([
        const Meld(type: MeldType.chow, tiles: ['1m', '2m', '3m']),
        const Meld(type: MeldType.chow, tiles: ['4s', '5s', '6s']),
        const Meld(type: MeldType.chow, tiles: ['7p', '8p', '9p']),
        const Meld(type: MeldType.chow, tiles: ['2m', '3m', '4m']),
      ], ['5m', '5m', '5m'], '5m');

      final result = TwPatternEvaluator.evaluate(
        hand: hand,
        isSelfDraw: false,
        flowerCount: 0,
      );
      final mixedCount = result.finalMatches
          .where((m) => m.id == 'exposedMixedDragon' || m.id == 'concealedMixedDragon')
          .length;
      expect(mixedCount, greaterThanOrEqualTo(1),
          reason: 'At least one mixed dragon should be detected');
    });
  });

  // ═══════════════════════════════════════════════════════════════
  // 7. 一台花 — flower set doesn't double-count individual flowers
  // ═══════════════════════════════════════════════════════════════
  group('一台花 flower counting fix', () {
    test('春夏秋冬 set: only 10 tai for set, no individual flower tai', () {
      final ctrl = setupController(
        dealerIndex: 1, // not dealer
        winningPlayer: '南家',
        isSelfDraw: false,
        discardPlayer: '西家',
        seatWind: 'South',
        flowers: ['1f', '2f', '3f', '4f'], // 春夏秋冬
        hand: const TwHand(
          exposedMelds: [
            Meld(type: MeldType.chow, tiles: ['1m', '2m', '3m']),
            Meld(type: MeldType.chow, tiles: ['4m', '5m', '6m']),
            Meld(type: MeldType.chow, tiles: ['7m', '8m', '9m']),
            Meld(type: MeldType.chow, tiles: ['2p', '3p', '4p']),
            Meld(type: MeldType.chow, tiles: ['5s', '6s', '7s']),
          ],
          concealedTiles: ['1z'],
          winningTile: '1z',
        ),
      );

      final rules = ctrl.displayRules;
      // Should have 一台花 (10 tai) but NOT individual flower entries
      final hasFlowerSet = rules.any((r) =>
          (r['name'] as String).contains('一台花') ||
          (r['name'] as String).contains('One Flower Set'));
      expect(hasFlowerSet, true, reason: '應有一台花');

      // Count individual flower entries — should be 0 for complete set flowers
      final properFlowerEntries = rules.where((r) =>
          (r['name'] as String).contains('正花') ||
          (r['name'] as String).contains('Proper Flower')).length;
      final wrongFlowerEntries = rules.where((r) =>
          (r['name'] as String).contains('爛花') ||
          (r['name'] as String).contains('Wrong Flower')).length;

      // If 南家 (player 1, seat South), 春=1f is East's proper flower.
      // For South, 2f is proper. So:
      // 1f→East(wrong for South), 2f→South(proper), 3f→West(wrong), 4f→North(wrong)
      // With complete set, individual flowers are subtracted.
      // So properFlowerEntries should be 0 and wrongFlowerEntries should be 0.
      expect(properFlowerEntries + wrongFlowerEntries, 0,
          reason: 'Complete flower set → individual flowers NOT counted separately');
    });
  });

  // ═══════════════════════════════════════════════════════════════
  // 8. 雞胡 — Chicken Hand (fixed 10 tai)
  // ═══════════════════════════════════════════════════════════════
  group('雞胡 (Chicken Hand)', () {
    test('discard win with only 1 fan (from wrong flower) → 雞胡 = 10 tai', () {
      // Non-dealer, discard, 1 wrong flower = 1 tai.
      // Hand has a pong (avoids 平胡/All Chows), no matching chow ranges across suits
      final ctrl = setupController(
        dealerIndex: 0, // 東家 is dealer, winner is 南家
        winningPlayer: '南家',
        isSelfDraw: false,
        discardPlayer: '西家',
        seatWind: 'South',
        flowers: ['1f'], // 春 = East's flower → wrong for South = 1 tai
        hand: const TwHand(
          exposedMelds: [
            Meld(type: MeldType.pong, tiles: ['5m', '5m', '5m']),
            Meld(type: MeldType.chow, tiles: ['2p', '3p', '4p']),
            Meld(type: MeldType.chow, tiles: ['6s', '7s', '8s']),
          ],
          concealedTiles: ['7m', '8m', '5s', '6s', '7s', '1z', '1z'],
          winningTile: '9m', // two-sided wait (6m/9m), not single wait
        ),
      );

      final rules = ctrl.displayRules;
      final ruleNames = rules.map((r) => '${r['name']}(${r['fan']})').toList();
      final hasChickenHand = rules.any((r) =>
          (r['name'] as String).contains('雞胡') ||
          (r['name'] as String).contains('Chicken'));
      expect(hasChickenHand, true, reason: '1 fan (wrong flower) + discard → 雞胡. Rules=$ruleNames, effectiveFan=${ctrl.effectiveFan}');

      // Total should be exactly 10
      final result = ctrl.buildSubmitResult()!;
      final scores = result['scores'] as Map<String, int>;
      // 雞胡 = flat 10 points, no base tai, no dealer bonus
      // 西家 pays 10 to 南家
      expect(scores['1'], equals(10), reason: '南家 gets 10 from 雞胡');
      expect(scores['2'], equals(-10), reason: '西家 pays 10 for 雞胡');
    });

    test('self-draw with 1 fan → NOT 雞胡 (self-draw only)', () {
      // 雞胡 only triggers on discard; self-draw adds its own tai
      final ctrl = setupController(
        dealerIndex: 0,
        winningPlayer: '南家',
        isSelfDraw: true,
        seatWind: 'South',
        flowers: ['1f'], // 1 wrong flower
        hand: const TwHand(
          exposedMelds: [
            Meld(type: MeldType.pong, tiles: ['5m', '5m', '5m']),
            Meld(type: MeldType.chow, tiles: ['2p', '3p', '4p']),
            Meld(type: MeldType.chow, tiles: ['6s', '7s', '8s']),
          ],
          concealedTiles: ['7m', '8m', '5s', '6s', '7s', '1z', '1z'],
          winningTile: '9m',
        ),
      );

      final rules = ctrl.displayRules;
      final hasChickenHand = rules.any((r) =>
          (r['name'] as String).contains('雞胡') ||
          (r['name'] as String).contains('Chicken'));
      expect(hasChickenHand, false, reason: 'Self-draw cannot be 雞胡');
    });

    test('discard with 無花(1) = 1 fan → 雞胡', () {
      // No flowers → 無花(1 tai). Discard. No other patterns → 雞胡.
      final ctrl = setupController(
        dealerIndex: 0,
        winningPlayer: '南家',
        isSelfDraw: false,
        discardPlayer: '西家',
        seatWind: 'South',
        flowers: [], // no flowers → 無花(1 tai)
        hand: const TwHand(
          exposedMelds: [
            Meld(type: MeldType.pong, tiles: ['5m', '5m', '5m']),
            Meld(type: MeldType.chow, tiles: ['2p', '3p', '4p']),
            Meld(type: MeldType.chow, tiles: ['6s', '7s', '8s']),
          ],
          concealedTiles: ['7m', '8m', '5s', '6s', '7s', '1z', '1z'],
          winningTile: '9m',
        ),
      );

      final rules = ctrl.displayRules;
      final ruleNames = rules.map((r) => '${r['name']}(${r['fan']})').toList();
      final hasChickenHand = rules.any((r) =>
          (r['name'] as String).contains('雞胡') ||
          (r['name'] as String).contains('Chicken'));
      expect(hasChickenHand, true,
          reason: 'No flowers → 無花(1 tai) = 1 fan → 雞胡. Rules=$ruleNames, effectiveFan=${ctrl.effectiveFan}');
    });

    test('discard with >1 fan total → NOT 雞胡', () {
      // Multiple patterns that sum to >1 fan
      final ctrl = setupController(
        dealerIndex: 0,
        winningPlayer: '南家',
        isSelfDraw: false,
        discardPlayer: '西家',
        seatWind: 'South',
        flowers: ['2f', '3f'], // 2f=proper(2tai), 3f=wrong(1tai) = 3 tai
        hand: const TwHand(
          exposedMelds: [
            Meld(type: MeldType.pong, tiles: ['5m', '5m', '5m']),
            Meld(type: MeldType.chow, tiles: ['2p', '3p', '4p']),
            Meld(type: MeldType.chow, tiles: ['6s', '7s', '8s']),
          ],
          concealedTiles: ['7m', '8m', '5s', '6s', '7s', '1z', '1z'],
          winningTile: '9m',
        ),
      );

      final rules = ctrl.displayRules;
      final hasChickenHand = rules.any((r) =>
          (r['name'] as String).contains('雞胡') ||
          (r['name'] as String).contains('Chicken'));
      expect(hasChickenHand, false,
          reason: 'Multiple flowers = >1 fan → NOT 雞胡');
    });
  });

  // ═══════════════════════════════════════════════════════════════
  // 9. Special winning conditions in TW path
  // ═══════════════════════════════════════════════════════════════
  group('Special winning conditions in TW path', () {
    test('海底撈月 (Under the Sea) = 20 tai', () {
      final ctrl = setupController(
        dealerIndex: 0,
        winningPlayer: '東家',
        isSelfDraw: true,
        seatWind: 'East',
        specialCondition: 'Under the Sea',
        hand: const TwHand(
          exposedMelds: [
            Meld(type: MeldType.chow, tiles: ['1m', '2m', '3m']),
            Meld(type: MeldType.chow, tiles: ['4m', '5m', '6m']),
            Meld(type: MeldType.chow, tiles: ['7m', '8m', '9m']),
            Meld(type: MeldType.chow, tiles: ['2p', '3p', '4p']),
          ],
          concealedTiles: ['5s', '6s', '7s', '1z', '1z'],
          winningTile: '1z',
        ),
      );

      final rules = ctrl.displayRules;
      final hasUnderSea = rules.any((r) =>
          (r['name'] as String).contains('海底') ||
          (r['name'] as String).contains('Under the Sea'));
      expect(hasUnderSea, true, reason: '海底撈月 should appear in display rules');
    });

    test('槓上開花 (Kong on Kong/Flower) = 1 tai', () {
      final ctrl = setupController(
        dealerIndex: 0,
        winningPlayer: '東家',
        isSelfDraw: true,
        seatWind: 'East',
        specialCondition: 'Kong on Kong/Flower',
        hand: const TwHand(
          exposedMelds: [
            Meld(type: MeldType.chow, tiles: ['1m', '2m', '3m']),
            Meld(type: MeldType.chow, tiles: ['4m', '5m', '6m']),
            Meld(type: MeldType.chow, tiles: ['7m', '8m', '9m']),
            Meld(type: MeldType.chow, tiles: ['2p', '3p', '4p']),
          ],
          concealedTiles: ['5s', '6s', '7s', '1z', '1z'],
          winningTile: '1z',
        ),
      );

      final rules = ctrl.displayRules;
      final hasKongFlower = rules.any((r) =>
          (r['name'] as String).contains('槓') ||
          (r['name'] as String).contains('Kong'));
      expect(hasKongFlower, true,
          reason: '槓上開花 should appear in display rules');
    });
  });

  // ═══════════════════════════════════════════════════════════════
  // 10. Newly implemented combo tiers
  // ═══════════════════════════════════════════════════════════════
  group('五同順 / 四歸二 / 四歸四', () {
    test('五同順 should exclude 相逢 and 般高 series', () {
      final ctrl = setupController(
        dealerIndex: 0,
        winningPlayer: '東家',
        isSelfDraw: true,
        seatWind: 'East',
        hand: const TwHand(
          exposedMelds: [
            Meld(type: MeldType.chow, tiles: ['1s', '2s', '3s']),
            Meld(type: MeldType.chow, tiles: ['1s', '2s', '3s']),
            Meld(type: MeldType.chow, tiles: ['1m', '2m', '3m']),
            Meld(type: MeldType.chow, tiles: ['1m', '2m', '3m']),
          ],
          concealedTiles: ['1p', '2p', '9z', '9z'],
          winningTile: '3p',
        ),
      );

      final names = ctrl.displayRules.map((r) => r['name'] as String).toList();
      bool has(String k) => names.any((n) => n.contains(k));
      bool hasAny(List<String> ks) => ks.any(has);

      expect(hasAny(['五同順', 'Five Identical']), true, reason: 'rules=$names');
      expect(has('二相逢'), false, reason: '五同順應排除二相逢. rules=$names');
      expect(has('三相逢'), false, reason: '五同順應排除三相逢. rules=$names');
      expect(has('一般高'), false, reason: '五同順應排除一般高. rules=$names');
      expect(has('二般高'), false, reason: '五同順應排除二般高. rules=$names');
      expect(has('三般高'), false, reason: '五同順應排除三般高. rules=$names');
    });

    test('二相逢 and 三相逢 can coexist when from different ranges', () {
      // 123 in all three suits => 三相逢
      // 789 in two suits => 二相逢
      final hand = const TwHand(
        exposedMelds: [
          Meld(type: MeldType.chow, tiles: ['1s', '2s', '3s']),
          Meld(type: MeldType.chow, tiles: ['1p', '2p', '3p']),
          Meld(type: MeldType.chow, tiles: ['1m', '2m', '3m']),
          Meld(type: MeldType.chow, tiles: ['7s', '8s', '9s']),
          Meld(type: MeldType.chow, tiles: ['7m', '8m', '9m']),
        ],
        concealedTiles: ['5z'],
        winningTile: '5z',
      );

      final result = TwPatternEvaluator.evaluate(
        hand: hand,
        isSelfDraw: false,
        flowerCount: 0,
      );

      final ids = result.finalMatches.map((m) => m.id).toList();
      expect(ids.contains('mixedTripleSeq'), true, reason: 'ids=$ids');
      expect(ids.contains('mixedDoubleSeq'), true, reason: 'ids=$ids');
    });

    test('四歸二 should be detected and exclude 四歸一', () {
      final hand = const TwHand(
        exposedMelds: [
          Meld(type: MeldType.pong, tiles: ['1m', '1m', '1m']),
          Meld(type: MeldType.chow, tiles: ['1m', '2m', '3m']),
          Meld(type: MeldType.pong, tiles: ['9p', '9p', '9p']),
          Meld(type: MeldType.chow, tiles: ['7p', '8p', '9p']),
        ],
        concealedTiles: ['1s', '2s', '5z', '5z'],
        winningTile: '3s',
      );

      final result = TwPatternEvaluator.evaluate(
        hand: hand,
        isSelfDraw: false,
        flowerCount: 0,
      );

      final ids = result.finalMatches.map((m) => m.id).toList();
      expect(ids.contains('fourToTwo'), true, reason: 'ids=$ids');
      expect(ids.contains('fourToOne'), false,
          reason: '四歸二應排除四歸一. ids=$ids');
    });

    test('四歸四 should be detected and exclude lower tiers', () {
      // Synthetic stress hand to verify tier detection priority.
      final hand = const TwHand(
        concealedTiles: [
          '1m', '1m', '1m', '1m',
          '2m', '2m', '2m', '2m',
          '3m', '3m', '3m', '3m',
          '4m', '4m', '4m', '4m',
        ],
        winningTile: '5m',
      );

      final result = TwPatternEvaluator.evaluate(
        hand: hand,
        isSelfDraw: false,
        flowerCount: 0,
      );

      final ids = result.finalMatches.map((m) => m.id).toList();
      expect(ids.contains('fourToFour'), true, reason: 'ids=$ids');
      expect(ids.contains('fourToTwo'), false,
          reason: '四歸四應排除四歸二. ids=$ids');
      expect(ids.contains('fourToOne'), false,
          reason: '四歸四應排除四歸一. ids=$ids');
    });
  });
}
