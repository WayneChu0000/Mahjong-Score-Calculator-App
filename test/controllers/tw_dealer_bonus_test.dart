import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/controllers/score_calculation_controller.dart';
import 'package:flutter_application_1/models/player.dart';
import 'package:flutter_application_1/models/game_mode.dart';
import 'package:flutter_application_1/localization/app_localizations.dart';

/// Tests for the dealer bonus formula in TW scoring mode:
///   - Non-dealer winner  → no bonus
///   - Dealer wins (first) → +1 台
///   - Dealer consecutive x → +((x-1)*2 + 1) 台
///       連一 = 3, 連二 = 5, 連三 = 7, 連五 = 11  etc.
///
/// The formula lives in ScoreCalculationController._calculateScoreInternal
/// and _calculateTwFlowerFan.
void main() {
  AppLocalizations.setLocale('English');

  const players = [
    Player(id: 0, name: 'Alice', score: 0),
    Player(id: 1, name: 'Bob', score: 0),
    Player(id: 2, name: 'Charlie', score: 0),
    Player(id: 3, name: 'Diana', score: 0),
  ];

  /// Creates a TW controller where:
  /// - dealerIndex = 0 (Alice is dealer) by default
  /// - winningPlayer defaults to Alice
  /// - one wrong flower selected → +1 fan (same as old No Flowers bonus)
  /// - no special conditions
  ScoreCalculationController _twCtrl({
    int minFan = 10,
    int maxFan = 5,
    int consecutiveDealerCount = 1,
    int dealerIndex = 0,
    String? winningPlayer,
    bool selfDraw = true,
  }) {
    final ctrl = ScoreCalculationController(
      players: players,
      minFan: minFan,
      maxFan: maxFan,
      gameMode: GameMode.taiwan,
      consecutiveDealerCount: consecutiveDealerCount,
      dealerIndex: dealerIndex,
    );
    ctrl.winningPlayer = winningPlayer ?? 'Alice';
    ctrl.isSelfDraw = selfDraw;
    // Clear all flowers, then toggle one wrong flower (+1 fan)
    // to bypass manual mode while keeping the same fan contribution
    for (var key in ctrl.selectedFlowers.keys.toList()) {
      ctrl.selectedFlowers[key] = false;
    }
    ctrl.selectedFlowers['3f'] = true; // wrong flower for Alice (East)
    return ctrl;
  }

  // ═══════════════════════════════════════════════════════════
  // Basic dealer bonus — no consecutive
  // ═══════════════════════════════════════════════════════════
  group('Basic dealer bonus (consecutiveDealerCount = 1)', () {
    test('Dealer wins → +1 bonus tai', () {
      final ctrl = _twCtrl(
        dealerIndex: 0, // Alice is dealer
        winningPlayer: 'Alice',
        consecutiveDealerCount: 1,
      );
      ctrl.fanCount = 3;
      ctrl.calculateScore();

      // displayRules should contain the base dealer bonus
      final dealerRule = ctrl.displayRules.firstWhere(
        (r) =>
            (r['name'] as String).contains(AppLocalizations.twDealerBonusBase),
        orElse: () => {},
      );
      expect(dealerRule, isNotEmpty, reason: 'Expected base dealer bonus rule');
      expect(dealerRule['fan'], equals(1));
    });

    test('Non-dealer wins → dealer bonus shown as "Dealer Pays Extra" (not added to totalPoints)', () {
      final ctrl = _twCtrl(
        dealerIndex: 0, // Alice is dealer
        winningPlayer: 'Bob', // Bob (index 1) wins
        consecutiveDealerCount: 1,
      );
      ctrl.fanCount = 3;
      ctrl.calculateScore();

      // The dealer bonus display rule should exist but marked as dealer-pays-extra
      final dealerExtraRules = ctrl.displayRules.where(
        (r) =>
            (r['name'] as String).contains(AppLocalizations.twDealerPaysExtra),
      );
      expect(
        dealerExtraRules.isNotEmpty,
        isTrue,
        reason: 'Dealer pays extra note should be shown when non-dealer wins',
      );
      // The bonus should NOT be added to totalPoints (base score)
      // totalPoints = baseTai(10) + (fanCount(3) + selfDraw(1) + wrongFlower(1)) = 10+5 = 15
      expect(ctrl.totalPoints, equals(15),
          reason: 'Dealer bonus should not inflate base totalPoints');
    });
  });

  // ═══════════════════════════════════════════════════════════
  // Consecutive dealer bonus formula
  // ═══════════════════════════════════════════════════════════
  group('Consecutive dealer bonus formula: (n×2)+1', () {
    // consecutiveDealerCount  |  n = count-1  |  bonus
    //          1              |      0         |   1  (base)
    //          2              |      1         |   3  (連一)
    //          3              |      2         |   5  (連二)
    //          4              |      3         |   7  (連三)
    //          6              |      5         |  11  (連五)

    final testCases = <int, int>{2: 3, 3: 5, 4: 7, 5: 9, 6: 11, 10: 19};

    testCases.forEach((consecutiveCount, expectedBonus) {
      test(
        'consecutiveDealerCount=$consecutiveCount → bonus=$expectedBonus',
        () {
          final ctrl = _twCtrl(
            dealerIndex: 0,
            winningPlayer: 'Alice',
            consecutiveDealerCount: consecutiveCount,
          );
          ctrl.fanCount = 3;
          ctrl.calculateScore();

          final dealerRule = ctrl.displayRules.firstWhere(
            (r) => (r['name'] as String).contains(
              AppLocalizations.twConsecutiveDealer,
            ),
            orElse: () => {},
          );
          expect(
            dealerRule,
            isNotEmpty,
            reason:
                'Expected consecutive dealer rule for count=$consecutiveCount',
          );
          expect(dealerRule['fan'], equals(expectedBonus));
        },
      );
    });
  });

  // ═══════════════════════════════════════════════════════════
  // Dealer bonus affects total score
  // ═══════════════════════════════════════════════════════════
  group('Dealer bonus contribution to totalPoints', () {
    test('Score without dealer bonus vs with dealer bonus', () {
      // Non-dealer: fanCount=3 → effective=3 + noFlowers(1) = 4
      // totalPoints = baseTai(10) + effectiveFan = 10+4 = 14
      final nonDealer = _twCtrl(
        dealerIndex: 0,
        winningPlayer: 'Bob', // non-dealer
        consecutiveDealerCount: 1,
      );
      nonDealer.fanCount = 3;
      nonDealer.calculateScore();
      final nonDealerScore = nonDealer.totalPoints;

      // Dealer (count=1): fanCount=3 → effective=3 + noFlowers(1) + bonus(1) = 5
      // totalPoints = 10+5 = 15
      final dealer = _twCtrl(
        dealerIndex: 0,
        winningPlayer: 'Alice', // dealer
        consecutiveDealerCount: 1,
      );
      dealer.fanCount = 3;
      dealer.calculateScore();
      final dealerScore = dealer.totalPoints;

      // Difference should be exactly 1 (1 bonus tai × taiValue(1) = 1)
      expect(dealerScore - nonDealerScore, equals(1));
    });

    test('Consecutive dealer count=3 adds 5 bonus tai to score', () {
      // Dealer consecutive(3): fanCount=3, selfDraw=false
      // effective = 3 + noFlowers(1) + dealerBonus(5) = 9
      // totalPoints = baseTai(10) + 9 = 19
      final ctrl = _twCtrl(
        dealerIndex: 0,
        winningPlayer: 'Alice',
        consecutiveDealerCount: 3,
        selfDraw: false,
      );
      ctrl.fanCount = 3;
      ctrl.calculateScore();
      expect(ctrl.totalPoints, equals(19));
    });
  });

  // ═══════════════════════════════════════════════════════════
  // Edge: consecutive dealer count = 1 is base, not consecutive
  // ═══════════════════════════════════════════════════════════
  group('Dealer bonus naming', () {
    test('count=1 uses base dealer name, not consecutive', () {
      final ctrl = _twCtrl(
        dealerIndex: 0,
        winningPlayer: 'Alice',
        consecutiveDealerCount: 1,
      );
      ctrl.fanCount = 1;
      ctrl.calculateScore();

      final hasBase = ctrl.displayRules.any(
        (r) => (r['name'] as String) == AppLocalizations.twDealerBonusBase,
      );
      final hasConsecutive = ctrl.displayRules.any(
        (r) => (r['name'] as String).contains(
          AppLocalizations.twConsecutiveDealer,
        ),
      );
      expect(hasBase, isTrue, reason: 'count=1 should use base dealer name');
      expect(
        hasConsecutive,
        isFalse,
        reason: 'count=1 should NOT use consecutive name',
      );
    });

    test('count=2 uses consecutive dealer name', () {
      final ctrl = _twCtrl(
        dealerIndex: 0,
        winningPlayer: 'Alice',
        consecutiveDealerCount: 2,
      );
      ctrl.fanCount = 1;
      ctrl.calculateScore();

      final hasConsecutive = ctrl.displayRules.any(
        (r) => (r['name'] as String).contains(
          AppLocalizations.twConsecutiveDealer,
        ),
      );
      expect(hasConsecutive, isTrue);
    });
  });

  // ═══════════════════════════════════════════════════════════
  // Dealer pays extra in buildSubmitResult (連莊 penalty)
  // ═══════════════════════════════════════════════════════════
  group('Dealer pays extra 連莊 in buildSubmitResult', () {
    test('Changing discarder to dealer should refresh and show dealer-extra item', () {
      final ctrl = ScoreCalculationController(
        players: players,
        minFan: 0,
        maxFan: 1,
        gameMode: GameMode.taiwan,
        consecutiveDealerCount: 2,
        dealerIndex: 0,
      );
      ctrl.winningPlayer = 'Bob';
      ctrl.isSelfDraw = false;
      for (var key in ctrl.selectedFlowers.keys.toList()) {
        ctrl.selectedFlowers[key] = false;
      }
      ctrl.selectedFlowers['3f'] = true;
      ctrl.fanCount = 1;

      // Start from non-dealer discard: no dealer-extra item.
      ctrl.setDiscardPlayer('Charlie');
      var hasDealerExtraRule = ctrl.displayRules.any(
        (r) =>
            (r['name'] as String).contains(AppLocalizations.twDealerPaysExtra),
      );
      expect(hasDealerExtraRule, isFalse);

      // Change to dealer discard: item should appear after recalculation.
      ctrl.setDiscardPlayer('Alice');
      hasDealerExtraRule = ctrl.displayRules.any(
        (r) =>
            (r['name'] as String).contains(AppLocalizations.twDealerPaysExtra),
      );
      expect(hasDealerExtraRule, isTrue,
          reason: 'Dealer discarder should show dealer-extra item in calculation list');
    });

    test('Self-draw by non-dealer: dealer pays extra, others pay base', () {
      // Player 1 (Bob) self-draws, dealer is Alice (index 0), 連莊 once.
      // Dealer bonus: (1*2)+1 = 3 tai.
      // minFan=0, maxFan=1 → taiValue=1
      final ctrl = ScoreCalculationController(
        players: players,
        minFan: 0,
        maxFan: 1,
        gameMode: GameMode.taiwan,
        consecutiveDealerCount: 2, // 連莊 once → bonus = 3
        dealerIndex: 0,
      );
      ctrl.winningPlayer = 'Bob';
      ctrl.isSelfDraw = true;
      // Select one wrong flower so we go through TW flower path (not manual mode)
      for (var key in ctrl.selectedFlowers.keys.toList()) {
        ctrl.selectedFlowers[key] = false;
      }
      ctrl.selectedFlowers['3f'] = true; // wrong flower → +1
      ctrl.fanCount = 1;
      ctrl.calculateScore();

      // totalPoints = 0 + (1 + selfDraw(1) + wrongFlower(1)) * 1 = 3
      final base = ctrl.totalPoints;
      expect(base, equals(3));

      final result = ctrl.buildSubmitResult()!;
      final scores = result['scores'] as Map<String, int>;

      // Alice (dealer, id=0) should pay base + 3*1 = 6
      expect(scores['0'], equals(-6),
          reason: 'Dealer should pay base + dealerBonusTai × taiValue');
      // Charlie (id=2) pays base = 3
      expect(scores['2'], equals(-3),
          reason: 'Non-dealer loser pays base only');
      // Diana (id=3) pays base = 3
      expect(scores['3'], equals(-3));
      // Bob (winner, id=1) gets 6+3+3 = 12
      expect(scores['1'], equals(12),
          reason: 'Winner receives sum of all payments');
    });

    test('Dealer discards to non-dealer: dealer pays extra', () {
      final ctrl = ScoreCalculationController(
        players: players,
        minFan: 0,
        maxFan: 1,
        gameMode: GameMode.taiwan,
        consecutiveDealerCount: 2, // 連莊 once → bonus = 3
        dealerIndex: 0,
      );
      ctrl.winningPlayer = 'Bob';
      ctrl.isSelfDraw = false;
      ctrl.discardPlayer = 'Alice'; // dealer discards
      for (var key in ctrl.selectedFlowers.keys.toList()) {
        ctrl.selectedFlowers[key] = false;
      }
      ctrl.selectedFlowers['3f'] = true; // wrong flower → +1
      ctrl.fanCount = 1;
      ctrl.calculateScore();

      final base = ctrl.totalPoints;
      // totalPoints includes dealer extra when dealer is the discarder:
      // base = 0 + (1 + wrongFlower(1)) * 1 = 2
      // dealer extra = 3
      // displayed totalPoints = 5
      expect(base, equals(5));

      final result = ctrl.buildSubmitResult()!;
      final scores = result['scores'] as Map<String, int>;

      // Alice (dealer, discarder) pays base + 3*1 = 5
      expect(scores['0'], equals(-5),
          reason: 'Dealer discarder pays base + dealerBonusTai × taiValue');
      // Bob (winner) gets 5
      expect(scores['1'], equals(5));
    });

    test('Non-dealer discards to non-dealer: dealer not involved, no extra', () {
      final ctrl = ScoreCalculationController(
        players: players,
        minFan: 0,
        maxFan: 1,
        gameMode: GameMode.taiwan,
        consecutiveDealerCount: 2, // 連莊 once → bonus = 3
        dealerIndex: 0,
      );
      ctrl.winningPlayer = 'Bob';
      ctrl.isSelfDraw = false;
      ctrl.discardPlayer = 'Charlie'; // non-dealer discards
      for (var key in ctrl.selectedFlowers.keys.toList()) {
        ctrl.selectedFlowers[key] = false;
      }
      ctrl.selectedFlowers['3f'] = true; // wrong flower → +1
      ctrl.fanCount = 1;
      ctrl.calculateScore();

        final hasDealerExtraRule = ctrl.displayRules.any(
        (r) =>
          (r['name'] as String).contains(AppLocalizations.twDealerPaysExtra),
        );
        expect(hasDealerExtraRule, isFalse,
          reason: 'Dealer not involved in discard win should not show dealer-extra item');

      final base = ctrl.totalPoints;
      // totalPoints = 0 + (1 + wrongFlower(1)) * 1 = 2
      expect(base, equals(2));

      final result = ctrl.buildSubmitResult()!;
      final scores = result['scores'] as Map<String, int>;

      // Charlie (non-dealer discarder) pays base only
      expect(scores['2'], equals(-2),
          reason: 'Non-dealer discarder pays base only');
      // Bob (winner) gets base
      expect(scores['1'], equals(2));
    });

    test('Dealer self-draws: all losers pay totalPoints (includes bonus)', () {
      final ctrl = ScoreCalculationController(
        players: players,
        minFan: 0,
        maxFan: 1,
        gameMode: GameMode.taiwan,
        consecutiveDealerCount: 2,
        dealerIndex: 0,
      );
      ctrl.winningPlayer = 'Alice'; // dealer self-draws
      ctrl.isSelfDraw = true;
      for (var key in ctrl.selectedFlowers.keys.toList()) {
        ctrl.selectedFlowers[key] = false;
      }
      ctrl.selectedFlowers['3f'] = true; // wrong flower → +1
      ctrl.fanCount = 1;
      ctrl.calculateScore();

      // totalPoints = 0 + (1 + selfDraw(1) + wrongFlower(1) + dealerBonus(3)) * 1 = 6
      expect(ctrl.totalPoints, equals(6));

      final result = ctrl.buildSubmitResult()!;
      final scores = result['scores'] as Map<String, int>;

      // All losers pay 6
      expect(scores['1'], equals(-6));
      expect(scores['2'], equals(-6));
      expect(scores['3'], equals(-6));
      // Alice (winner) gets 18
      expect(scores['0'], equals(18));
    });

    test('User example: non-dealer self-draw, dealer 連莊 once, pays extra', () {
      // Bob is dealer (index 1), 連莊 once (consecutiveDealerCount=2).
      // Alice self-draws, fanCount=1, wrong flower=+1, selfDraw=+1.
      // Base totalPoints = 0 + (1+1+1)*1 = 3
      // Dealer bonus: (1*2)+1 = 3 tai → dealer extra = 3*1 = 3
      // Bob pays 3+3 = 6, Charlie/Diana pay 3 each
      // Alice gets 6+3+3 = 12
      final ctrl = ScoreCalculationController(
        players: players,
        minFan: 0,
        maxFan: 1,
        gameMode: GameMode.taiwan,
        consecutiveDealerCount: 2, // 連莊 once
        dealerIndex: 1, // Bob is dealer
      );
      ctrl.winningPlayer = 'Alice';
      ctrl.isSelfDraw = true;
      for (var key in ctrl.selectedFlowers.keys.toList()) {
        ctrl.selectedFlowers[key] = false;
      }
      ctrl.selectedFlowers['3f'] = true; // wrong flower → +1
      ctrl.fanCount = 1;
      ctrl.calculateScore();

      final base = ctrl.totalPoints;
      expect(base, equals(3));

      final result = ctrl.buildSubmitResult()!;
      final scores = result['scores'] as Map<String, int>;

      // Bob (dealer, id=1) pays 3 + 3*1 = 6
      expect(scores['1'], equals(-6),
          reason: 'Dealer pays base + 連莊 bonus');
      // Charlie (id=2) pays 3
      expect(scores['2'], equals(-3));
      // Diana (id=3) pays 3
      expect(scores['3'], equals(-3));
      // Alice (winner, id=0) gets 6+3+3 = 12
      expect(scores['0'], equals(12));
    });
  });
}
