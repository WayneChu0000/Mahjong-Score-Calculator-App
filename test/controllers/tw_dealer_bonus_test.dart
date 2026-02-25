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
  /// - no flowers selected → +1 "No Flowers" fan
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
    // Ensure no flowers selected (gives +1 No Flowers fan)
    for (var key in ctrl.selectedFlowers.keys.toList()) {
      ctrl.selectedFlowers[key] = false;
    }
    return ctrl;
  }

  // ═══════════════════════════════════════════════════════════
  // Basic dealer bonus — no consecutive
  // ═══════════════════════════════════════════════════════════
  group('Basic dealer bonus (consecutiveDealerCount = 1)', () {
    test('Dealer wins → +1 bonus tai', () {
      final ctrl = _twCtrl(
        dealerIndex: 0,       // Alice is dealer
        winningPlayer: 'Alice',
        consecutiveDealerCount: 1,
      );
      ctrl.fanCount = 3;
      ctrl.calculateScore();

      // displayRules should contain the base dealer bonus
      final dealerRule = ctrl.displayRules.firstWhere(
        (r) => (r['name'] as String).contains(AppLocalizations.twDealerBonusBase),
        orElse: () => {},
      );
      expect(dealerRule, isNotEmpty, reason: 'Expected base dealer bonus rule');
      expect(dealerRule['fan'], equals(1));
    });

    test('Non-dealer wins → no dealer bonus', () {
      final ctrl = _twCtrl(
        dealerIndex: 0,       // Alice is dealer
        winningPlayer: 'Bob', // Bob (index 1) wins
        consecutiveDealerCount: 1,
      );
      ctrl.fanCount = 3;
      ctrl.calculateScore();

      final dealerRules = ctrl.displayRules.where(
        (r) => (r['name'] as String).contains('Dealer') ||
               (r['name'] as String).contains(AppLocalizations.twDealerBonusBase),
      );
      expect(dealerRules.isEmpty, isTrue, reason: 'Non-dealer should get no dealer bonus');
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

    final testCases = <int, int>{
      2: 3,
      3: 5,
      4: 7,
      5: 9,
      6: 11,
      10: 19,
    };

    testCases.forEach((consecutiveCount, expectedBonus) {
      test('consecutiveDealerCount=$consecutiveCount → bonus=$expectedBonus', () {
        final ctrl = _twCtrl(
          dealerIndex: 0,
          winningPlayer: 'Alice',
          consecutiveDealerCount: consecutiveCount,
        );
        ctrl.fanCount = 3;
        ctrl.calculateScore();

        final dealerRule = ctrl.displayRules.firstWhere(
          (r) => (r['name'] as String).contains(AppLocalizations.twConsecutiveDealer),
          orElse: () => {},
        );
        expect(dealerRule, isNotEmpty,
            reason: 'Expected consecutive dealer rule for count=$consecutiveCount');
        expect(dealerRule['fan'], equals(expectedBonus));
      });
    });
  });

  // ═══════════════════════════════════════════════════════════
  // Dealer bonus affects total score
  // ═══════════════════════════════════════════════════════════
  group('Dealer bonus contribution to totalPoints', () {
    test('Score without dealer bonus vs with dealer bonus', () {
      // Non-dealer: fanCount=3 → effective=3 + noFlowers(1) = 4
      // totalPoints = baseTai + (effectiveFan * taiValue) = 10 + (4*5) = 30
      final nonDealer = _twCtrl(
        dealerIndex: 0,
        winningPlayer: 'Bob', // non-dealer
        consecutiveDealerCount: 1,
      );
      nonDealer.fanCount = 3;
      nonDealer.calculateScore();
      final nonDealerScore = nonDealer.totalPoints;

      // Dealer (count=1): fanCount=3 → effective=3 + noFlowers(1) + bonus(1) = 5
      // totalPoints = 10 + (5*5) = 35
      final dealer = _twCtrl(
        dealerIndex: 0,
        winningPlayer: 'Alice', // dealer
        consecutiveDealerCount: 1,
      );
      dealer.fanCount = 3;
      dealer.calculateScore();
      final dealerScore = dealer.totalPoints;

      // Difference should be exactly 1 * taiValue = 5
      expect(dealerScore - nonDealerScore, equals(5));
    });

    test('Consecutive dealer count=3 adds 5 bonus tai to score', () {
      // Dealer consecutive(3): fanCount=3, selfDraw=false
      // effective = 3 + noFlowers(1) + dealerBonus(5) = 9
      // totalPoints = 10 + (9*5) = 55
      final ctrl = _twCtrl(
        dealerIndex: 0,
        winningPlayer: 'Alice',
        consecutiveDealerCount: 3,
        selfDraw: false,
      );
      ctrl.fanCount = 3;
      ctrl.calculateScore();
      expect(ctrl.totalPoints, equals(55));
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
        (r) => (r['name'] as String).contains(AppLocalizations.twConsecutiveDealer),
      );
      expect(hasBase, isTrue, reason: 'count=1 should use base dealer name');
      expect(hasConsecutive, isFalse, reason: 'count=1 should NOT use consecutive name');
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
        (r) => (r['name'] as String).contains(AppLocalizations.twConsecutiveDealer),
      );
      expect(hasConsecutive, isTrue);
    });
  });
}
