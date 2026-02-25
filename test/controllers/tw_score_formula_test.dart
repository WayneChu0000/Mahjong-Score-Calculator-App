import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/controllers/score_calculation_controller.dart';
import 'package:flutter_application_1/models/player.dart';
import 'package:flutter_application_1/models/game_mode.dart';
import 'package:flutter_application_1/localization/app_localizations.dart';

/// Tests for TW total score formula:
///   totalPoints = baseTai + (effectiveFan × taiValue)
/// where:
///   baseTai  = minFan (default 10)
///   taiValue = maxFan (default 5)
///   effectiveFan = fanCount + flowers + specialCondition + dealerBonus
///
/// Also tests self-draw payment distribution and discard payment.
void main() {
  AppLocalizations.setLocale('English');

  const players = [
    Player(id: 0, name: 'Alice', score: 0),
    Player(id: 1, name: 'Bob', score: 0),
    Player(id: 2, name: 'Charlie', score: 0),
    Player(id: 3, name: 'Diana', score: 0),
  ];

  /// Creates a TW controller with precise control over parameters.
  ScoreCalculationController _tw({
    int minFan = 10,
    int maxFan = 5,
    int consecutiveDealerCount = 1,
    int dealerIndex = 0,
    String winningPlayer = 'Bob', // Non-dealer by default
    bool selfDraw = false,
    String? discardPlayer,
    String specialCondition = 'None',
    Map<String, bool>? flowers,
  }) {
    final ctrl = ScoreCalculationController(
      players: players,
      minFan: minFan,
      maxFan: maxFan,
      gameMode: GameMode.taiwan,
      consecutiveDealerCount: consecutiveDealerCount,
      dealerIndex: dealerIndex,
    );
    ctrl.winningPlayer = winningPlayer;
    ctrl.isSelfDraw = selfDraw;
    ctrl.discardPlayer = discardPlayer;
    ctrl.selectedSpecialCondition = specialCondition;

    // Clear all flowers by default
    for (var key in ctrl.selectedFlowers.keys.toList()) {
      ctrl.selectedFlowers[key] = false;
    }
    // Apply provided flowers
    if (flowers != null) {
      flowers.forEach((k, v) => ctrl.selectedFlowers[k] = v);
    }
    // Manually update seatWind since direct field assignment
    // bypasses the _updateSeatWind() called by setWinningPlayer()
    final winnerIdx = players.indexWhere((p) => p.name == winningPlayer);
    if (winnerIdx >= 0) {
      const winds = ['East', 'South', 'West', 'North'];
      final windIdx = (winnerIdx - dealerIndex + 4) % 4;
      ctrl.seatWind = winds[windIdx];
    }
    return ctrl;
  }

  // ═══════════════════════════════════════════════════════════
  // Basic formula: baseTai + (effectiveFan × taiValue)
  // ═══════════════════════════════════════════════════════════
  group('TW score formula: baseTai + (effectiveFan × taiValue)', () {
    test('fanCount=0, no flowers → effectiveFan=1(noFlowers) → 10+(1×5)=15', () {
      final ctrl = _tw(winningPlayer: 'Bob');
      ctrl.fanCount = 0;
      ctrl.calculateScore();
      // effectiveFan = 0 + 1(no flowers) = 1
      expect(ctrl.totalPoints, equals(15));
    });

    test('fanCount=3, no flowers → effectiveFan=4 → 10+(4×5)=30', () {
      final ctrl = _tw(winningPlayer: 'Bob');
      ctrl.fanCount = 3;
      ctrl.calculateScore();
      expect(ctrl.totalPoints, equals(30));
    });

    test('fanCount=10, no flowers → effectiveFan=11 → 10+(11×5)=65', () {
      final ctrl = _tw(winningPlayer: 'Bob');
      ctrl.fanCount = 10;
      ctrl.calculateScore();
      expect(ctrl.totalPoints, equals(65));
    });

    test('Custom baseTai=20, taiValue=10, fanCount=5, no flowers → 20+(6×10)=80', () {
      final ctrl = _tw(minFan: 20, maxFan: 10, winningPlayer: 'Bob');
      ctrl.fanCount = 5;
      ctrl.calculateScore();
      // effectiveFan = 5 + 1(no flowers) = 6
      expect(ctrl.totalPoints, equals(80));
    });
  });

  // ═══════════════════════════════════════════════════════════
  // Flower fans in TW mode (per-tile: proper=2, wrong=1)
  // ═══════════════════════════════════════════════════════════
  group('TW flower fan contribution', () {
    test('Bob (seat index 2, South) with proper flower 2f → +2 tai', () {
      // dealerIndex=0 (Alice=East), Bob is index 1
      // Seat wind for Bob: offset = (1-0+4)%4 = 1 → South → seatIndex=2
      // Proper flower = 2f, proper season = 6f
      final ctrl = _tw(
        winningPlayer: 'Bob',
        flowers: {'2f': true}, // proper flower
      );
      ctrl.fanCount = 3;
      ctrl.calculateScore();
      // effectiveFan = 3 + 2(proper flower) = 5
      // totalPoints = 10 + (5*5) = 35
      expect(ctrl.totalPoints, equals(35));
    });

    test('Bob with wrong flower 1f → +1 tai', () {
      final ctrl = _tw(
        winningPlayer: 'Bob',
        flowers: {'1f': true}, // wrong flower for Bob
      );
      ctrl.fanCount = 3;
      ctrl.calculateScore();
      // effectiveFan = 3 + 1(wrong flower) = 4
      // totalPoints = 10 + (4*5) = 30
      expect(ctrl.totalPoints, equals(30));
    });

    test('No flowers selected → +1 (No Flowers fan)', () {
      final ctrl = _tw(winningPlayer: 'Bob');
      ctrl.fanCount = 3;
      ctrl.calculateScore();
      // effectiveFan = 3 + 1(no flowers) = 4
      expect(ctrl.totalPoints, equals(30));
    });

    test('Multiple flowers: 1 proper + 2 wrong → 2+1+1 = 4 flower tai', () {
      final ctrl = _tw(
        winningPlayer: 'Bob',
        flowers: {'2f': true, '3f': true, '4f': true}, // 2f proper, 3f/4f wrong
      );
      ctrl.fanCount = 3;
      ctrl.calculateScore();
      // effectiveFan = 3 + 2(proper) + 1(wrong) + 1(wrong) = 7
      // totalPoints = 10 + (7*5) = 45
      expect(ctrl.totalPoints, equals(45));
    });
  });

  // ═══════════════════════════════════════════════════════════
  // Special conditions add tai
  // ═══════════════════════════════════════════════════════════
  group('TW special condition fan additions', () {
    test('Men Qian Qing (non-self-draw) → +3 tai', () {
      final ctrl = _tw(
        winningPlayer: 'Bob',
        selfDraw: false,
        specialCondition: 'Men Qian Qing',
      );
      ctrl.fanCount = 3;
      ctrl.calculateScore();
      // effectiveFan = 3 + 1(no flowers) + 3(MQQ) = 7
      // totalPoints = 10 + (7*5) = 45
      expect(ctrl.totalPoints, equals(45));
    });

    test('Men Qian Qing + Self-Draw → Concealed Self-Draw = +5 tai + Self-Draw +1', () {
      final ctrl = _tw(
        winningPlayer: 'Bob',
        selfDraw: true,
        specialCondition: 'Men Qian Qing',
      );
      ctrl.fanCount = 3;
      ctrl.calculateScore();
      // Concealed Self-Draw (5) + separate Self-Draw (1) + noFlowers (1) = 7 extra
      // effectiveFan = 3 + 5 + 1 + 1 = 10
      // totalPoints = 10 + (10*5) = 60
      expect(ctrl.totalPoints, equals(60));
    });

    test('Declared Ready → +5 tai', () {
      final ctrl = _tw(
        winningPlayer: 'Bob',
        specialCondition: 'Declared Ready',
      );
      ctrl.fanCount = 3;
      ctrl.calculateScore();
      // effectiveFan = 3 + 1(no flowers) + 5(declared ready) = 9
      expect(ctrl.totalPoints, equals(55));
    });

    test('Kong on Kong/Flower → +1 tai', () {
      final ctrl = _tw(
        winningPlayer: 'Bob',
        specialCondition: 'Kong on Kong/Flower',
      );
      ctrl.fanCount = 3;
      ctrl.calculateScore();
      // effectiveFan = 3 + 1(no flowers) + 1(kong on kong) = 5
      expect(ctrl.totalPoints, equals(35));
    });

    test('Under the Sea → +20 tai', () {
      final ctrl = _tw(
        winningPlayer: 'Bob',
        specialCondition: 'Under the Sea',
      );
      ctrl.fanCount = 3;
      ctrl.calculateScore();
      // effectiveFan = 3 + 1(no flowers) + 20(under the sea) = 24
      expect(ctrl.totalPoints, equals(130));
    });

    test('Heavenly Hand → +100 tai', () {
      final ctrl = _tw(
        winningPlayer: 'Bob',
        specialCondition: 'Heavenly Hand',
      );
      ctrl.fanCount = 3;
      ctrl.calculateScore();
      // effectiveFan = 3 + 1(no flowers) + 100(heavenly hand) = 104
      expect(ctrl.totalPoints, equals(530));
    });

    test('Earthly Hand → +80 tai', () {
      final ctrl = _tw(
        winningPlayer: 'Bob',
        specialCondition: 'Earthly Hand',
      );
      ctrl.fanCount = 3;
      ctrl.calculateScore();
      // effectiveFan = 3 + 1(no flowers) + 80(earthly hand) = 84
      expect(ctrl.totalPoints, equals(430));
    });
  });

  // ═══════════════════════════════════════════════════════════
  // Self-draw scoring in TW: same formula, but self-draw adds 1
  // ═══════════════════════════════════════════════════════════
  group('TW self-draw fan', () {
    test('Self-draw without special condition adds +1 fan (manual mode)', () {
      final ctrl = _tw(
        winningPlayer: 'Bob',
        selfDraw: true,
      );
      // In manual mode (no selected tiles), self-draw adds +1
      ctrl.fanCount = 3;
      ctrl.calculateScore();

      final selfDrawRule = ctrl.displayRules.where(
        (r) => (r['name'] as String).contains(AppLocalizations.ruleSelfDraw),
      );
      expect(selfDrawRule.isNotEmpty, isTrue);
    });
  });

  // ═══════════════════════════════════════════════════════════
  // Payment distribution
  // ═══════════════════════════════════════════════════════════
  group('TW payment distribution', () {
    test('Self-draw: each loser pays totalPoints, winner gets 3× total', () {
      final ctrl = _tw(
        winningPlayer: 'Bob',
        selfDraw: true,
      );
      ctrl.fanCount = 3;
      ctrl.calculateScore();

      final result = ctrl.buildSubmitResult();
      expect(result, isNotNull);

      final scores = result!['scores'] as Map<String, int>;
      final winnerScore = scores['1']; // Bob's id=1
      final total = ctrl.totalPoints;

      // Winner gets totalPoints × (numPlayers - 1) = total × 3
      expect(winnerScore, equals(total * 3));
      // Each loser pays -totalPoints
      for (final entry in scores.entries) {
        if (entry.key != '1') {
          expect(entry.value, equals(-total));
        }
      }
    });

    test('Discard: discarder pays totalPoints, winner gets totalPoints', () {
      final ctrl = _tw(
        winningPlayer: 'Bob',
        selfDraw: false,
        discardPlayer: 'Alice',
      );
      ctrl.fanCount = 3;
      ctrl.calculateScore();

      final result = ctrl.buildSubmitResult();
      expect(result, isNotNull);

      final scores = result!['scores'] as Map<String, int>;
      final total = ctrl.totalPoints;

      expect(scores['0'], equals(-total)); // Alice pays
      expect(scores['1'], equals(total));  // Bob wins
    });
  });

  // ═══════════════════════════════════════════════════════════
  // 8-Immortals special flower hand
  // ═══════════════════════════════════════════════════════════
  group('TW 8 Immortals flower hand', () {
    test('All 8 flowers selected → 8 Immortals overrides everything', () {
      final allFlowers = <String, bool>{};
      for (int i = 1; i <= 8; i++) {
        allFlowers['${i}f'] = true;
      }
      final ctrl = _tw(
        winningPlayer: 'Bob',
        flowers: allFlowers,
      );
      ctrl.fanCount = 5;
      ctrl.calculateScore();

      // 8 Immortals: effective fan is set to 8
      // totalPoints = baseTai + (8 * taiValue) = 10 + (8*5) = 50
      expect(ctrl.totalPoints, equals(50));
      expect(ctrl.displayRules.any((r) => (r['name'] as String).contains(AppLocalizations.ruleEightImmortals)), isTrue);
    });
  });
}
