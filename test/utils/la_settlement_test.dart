import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/utils/la_settlement.dart';

void main() {
  late LaSettlement la;

  setUp(() {
    la = LaSettlement();
  });

  // ── Fully-deferred La model ────────────────────────────────────────
  //
  // - NO scores are applied during a winning streak. apply() returns
  //   all-zero score changes while the streak is active.
  // - Debts compound internally (×1.5 + new loss).
  // - When the streak ends (different winner), the FULL compounded debts
  //   are returned as settlement. The new round's raw scores are deferred
  //   into the new streak.
  // - forceSettle() settles ALL remaining debtors and resets La.

  group('LaSettlement - first round (deferred)', () {
    test('first round returns all zeros (deferred)', () {
      final result = la.apply(
        rawScoreChanges: {'E': 108, 'S': -36, 'W': -36, 'N': -36},
        winnerId: 'E',
        isSelfDraw: true,
      );

      expect(result.adjustedScoreChanges, {'E': 0, 'S': 0, 'W': 0, 'N': 0});
      expect(result.descriptions, isEmpty);
    });

    test('first round initializes streak with correct debts', () {
      la.apply(
        rawScoreChanges: {'E': 108, 'S': -36, 'W': -36, 'N': -36},
        winnerId: 'E',
        isSelfDraw: true,
      );

      expect(la.streakWinnerId, 'E');
      expect(la.debts, {'S': 36, 'W': 36, 'N': 36});
      expect(la.hasActiveStreak, isTrue);
    });
  });

  group('LaSettlement - streak continuation (same winner)', () {
    test('same winner via discard → only discarder compounds', () {
      // Round 1: E self-draws, each loser = $36
      la.apply(
        rawScoreChanges: {'E': 108, 'S': -36, 'W': -36, 'N': -36},
        winnerId: 'E',
        isSelfDraw: true,
      );

      // Round 2: S deals to E, 5 fan = $20
      final result = la.apply(
        rawScoreChanges: {'E': 20, 'S': -20},
        winnerId: 'E',
        isSelfDraw: false,
        discarderId: 'S',
      );

      // All zeros (deferred)
      expect(result.adjustedScoreChanges, {'E': 0, 'S': 0});
      expect(result.descriptions, isEmpty);

      // Debts: S compounded = 36×1.5+20 = 74, W/N unchanged = 36
      expect(la.debts['S'], 74);
      expect(la.debts['W'], 36);
      expect(la.debts['N'], 36);
    });

    test('same winner via self-draw → ALL compound', () {
      // Round 1: E self-draws ($36 each)
      la.apply(
        rawScoreChanges: {'E': 108, 'S': -36, 'W': -36, 'N': -36},
        winnerId: 'E',
        isSelfDraw: true,
      );

      // Round 2: E self-draws ($20 each)
      final result = la.apply(
        rawScoreChanges: {'E': 60, 'S': -20, 'W': -20, 'N': -20},
        winnerId: 'E',
        isSelfDraw: true,
      );

      // All zeros (deferred)
      expect(result.adjustedScoreChanges, {'E': 0, 'S': 0, 'W': 0, 'N': 0});

      // All debts compound: 36×1.5+20 = 74 each
      expect(la.debts['S'], 74);
      expect(la.debts['W'], 74);
      expect(la.debts['N'], 74);
    });

    test('three consecutive wins → compound stacks', () {
      // Round 1: E self-draws ($10 each)
      la.apply(
        rawScoreChanges: {'E': 30, 'S': -10, 'W': -10, 'N': -10},
        winnerId: 'E',
        isSelfDraw: true,
      );

      // Round 2: E self-draws ($10 each)
      la.apply(
        rawScoreChanges: {'E': 30, 'S': -10, 'W': -10, 'N': -10},
        winnerId: 'E',
        isSelfDraw: true,
      );
      // Debts: 10×1.5+10 = 25 each

      // Round 3: E self-draws ($10 each)
      la.apply(
        rawScoreChanges: {'E': 30, 'S': -10, 'W': -10, 'N': -10},
        winnerId: 'E',
        isSelfDraw: true,
      );
      // Debts: 25×1.5+10 = 37.5→38+10 = 48 each
      expect(la.debts['S'], 48);
      expect(la.debts['W'], 48);
      expect(la.debts['N'], 48);
    });

    test('new loser joins streak without existing debt', () {
      // Round 1: E wins from S only ($30)
      la.apply(
        rawScoreChanges: {'E': 30, 'S': -30},
        winnerId: 'E',
        isSelfDraw: false,
        discarderId: 'S',
      );

      // Round 2: E self-draws ($10 each) — W/N join as new debtors
      la.apply(
        rawScoreChanges: {'E': 30, 'S': -10, 'W': -10, 'N': -10},
        winnerId: 'E',
        isSelfDraw: true,
      );

      // S: 30×1.5+10 = 55. W/N: 0×1.5+10 = 10 (new debtors)
      expect(la.debts['S'], 55);
      expect(la.debts['W'], 10);
      expect(la.debts['N'], 10);
    });
  });

  group('LaSettlement - streak end: no reduction (full settlement)', () {
    test('third party wins → full debt settlement', () {
      // Round 1: E self-draws ($36 each), deferred
      la.apply(
        rawScoreChanges: {'E': 108, 'S': -36, 'W': -36, 'N': -36},
        winnerId: 'E',
        isSelfDraw: true,
      );

      // Round 2: S deals to E ($20), deferred
      la.apply(
        rawScoreChanges: {'E': 20, 'S': -20},
        winnerId: 'E',
        isSelfDraw: false,
        discarderId: 'S',
      );
      // Debts: S=74, W=36, N=36

      // Round 3: N deals to W ($16). Streak ends!
      final result = la.apply(
        rawScoreChanges: {'W': 16, 'N': -16},
        winnerId: 'W',
        isSelfDraw: false,
        discarderId: 'N',
      );

      // Full settlement: S=74, W=36, N=36. E gets 146.
      // R3 raw scores deferred into new streak.
      expect(result.adjustedScoreChanges['S'], -74);
      expect(result.adjustedScoreChanges['W'], -36);
      expect(result.adjustedScoreChanges['N'], -36);
      expect(result.adjustedScoreChanges['E'], 146);
      expect(result.descriptions, isNotEmpty);
    });

    test('single-round streak → full settlement', () {
      // Round 1: E self-draws ($10 each)
      la.apply(
        rawScoreChanges: {'E': 30, 'S': -10, 'W': -10, 'N': -10},
        winnerId: 'E',
        isSelfDraw: true,
      );

      // Round 2: S wins from W. Streak ends. No reduction.
      final result = la.apply(
        rawScoreChanges: {'S': 20, 'W': -20},
        winnerId: 'S',
        isSelfDraw: false,
        discarderId: 'W',
      );

      // Full debts: S=10, W=10, N=10. E gets 30.
      expect(result.adjustedScoreChanges['S'], -10);
      expect(result.adjustedScoreChanges['W'], -10);
      expect(result.adjustedScoreChanges['N'], -10);
      expect(result.adjustedScoreChanges['E'], 30);
      expect(result.descriptions, isNotEmpty);
    });
  });

  group('LaSettlement - streak end: reduction (÷2)', () {
    test('streak winner discards → ONLY new winner debt halved', () {
      // Round 1: E self-draws ($36 each)
      la.apply(
        rawScoreChanges: {'E': 108, 'S': -36, 'W': -36, 'N': -36},
        winnerId: 'E',
        isSelfDraw: true,
      );

      // Round 2: S deals to E ($20)
      la.apply(
        rawScoreChanges: {'E': 20, 'S': -20},
        winnerId: 'E',
        isSelfDraw: false,
        discarderId: 'S',
      );
      // Debts: S=74, W=36, N=36

      // Round 3: E deals to S ($18). Reduction: E is discarder == streak winner.
      final result = la.apply(
        rawScoreChanges: {'S': 18, 'E': -18},
        winnerId: 'S',
        isSelfDraw: false,
        discarderId: 'E',
      );

      // S: debt=74, halved=37. W: 36. N: 36.
      // E gets 37+36+36 = 109
      expect(result.adjustedScoreChanges['S'], -37);
      expect(result.adjustedScoreChanges['W'], -36);
      expect(result.adjustedScoreChanges['N'], -36);
      expect(result.adjustedScoreChanges['E'], 109);
    });

    test('debtor self-draws → ONLY self-drawer debt halved', () {
      // Round 1: E self-draws ($36 each)
      la.apply(
        rawScoreChanges: {'E': 108, 'S': -36, 'W': -36, 'N': -36},
        winnerId: 'E',
        isSelfDraw: true,
      );

      // Round 2: E self-draws ($20 each)
      la.apply(
        rawScoreChanges: {'E': 60, 'S': -20, 'W': -20, 'N': -20},
        winnerId: 'E',
        isSelfDraw: true,
      );
      // Debts: all = 74

      // Round 3: S self-draws ($15 each). S was a debtor → reduction.
      final result = la.apply(
        rawScoreChanges: {'S': 45, 'E': -15, 'W': -15, 'N': -15},
        winnerId: 'S',
        isSelfDraw: true,
      );

      // S: debt=74, halved=37. W/N: full=74.
      // E gets 37+74+74 = 185
      expect(result.adjustedScoreChanges['S'], -37);
      expect(result.adjustedScoreChanges['W'], -74);
      expect(result.adjustedScoreChanges['N'], -74);
      expect(result.adjustedScoreChanges['E'], 185);
    });

    test('non-debtor self-draws → no reduction, settlement only', () {
      // Round 1: E wins from S ($30). Only S has debt.
      la.apply(
        rawScoreChanges: {'E': 30, 'S': -30},
        winnerId: 'E',
        isSelfDraw: false,
        discarderId: 'S',
      );

      // Round 2: W self-draws ($10 each). W is NOT a debtor.
      final result = la.apply(
        rawScoreChanges: {'W': 30, 'E': -10, 'S': -10, 'N': -10},
        winnerId: 'W',
        isSelfDraw: true,
      );

      // S: debt=30, full. E gets 30.
      // W/N have no debt → not in settlement.
      expect(result.adjustedScoreChanges['S'], -30);
      expect(result.adjustedScoreChanges['E'], 30);
      expect(result.adjustedScoreChanges.containsKey('W'), isFalse);
      expect(result.adjustedScoreChanges.containsKey('N'), isFalse);
    });

    test('single-round streak with reduction → debt halved', () {
      // Round 1: E self-draws ($10 each)
      la.apply(
        rawScoreChanges: {'E': 30, 'S': -10, 'W': -10, 'N': -10},
        winnerId: 'E',
        isSelfDraw: true,
      );

      // Round 2: E (streak winner) deals to S ($20). Reduction.
      final result = la.apply(
        rawScoreChanges: {'S': 20, 'E': -20},
        winnerId: 'S',
        isSelfDraw: false,
        discarderId: 'E',
      );

      // S: debt=10, halved=5. W: 10. N: 10. E gets 25.
      expect(result.adjustedScoreChanges['S'], -5);
      expect(result.adjustedScoreChanges['W'], -10);
      expect(result.adjustedScoreChanges['N'], -10);
      expect(result.adjustedScoreChanges['E'], 25);
    });
  });

  group('LaSettlement - Chinese rules example (full trace)', () {
    test('complete example: baseTai=10, taiValue=2 — debt tracking', () {
      // Round 1: East self-draws 13 fan → each = 13×2+10 = $36
      la.apply(
        rawScoreChanges: {'E': 108, 'S': -36, 'W': -36, 'N': -36},
        winnerId: 'E',
        isSelfDraw: true,
      );

      // Round 2: South deals to East 5 fan → $20
      la.apply(
        rawScoreChanges: {'E': 20, 'S': -20},
        winnerId: 'E',
        isSelfDraw: false,
        discarderId: 'S',
      );

      // Verify debts match Chinese example:
      // S: $36×1.5 + $20 = $74, W: $36, N: $36
      expect(la.debts['S'], 74);
      expect(la.debts['W'], 36);
      expect(la.debts['N'], 36);
    });

    test('scenario 1: third party deals → E collects full debts', () {
      // Setup: R1 E self-draws $36, R2 S deals to E $20
      la.apply(
        rawScoreChanges: {'E': 108, 'S': -36, 'W': -36, 'N': -36},
        winnerId: 'E',
        isSelfDraw: true,
      );
      la.apply(
        rawScoreChanges: {'E': 20, 'S': -20},
        winnerId: 'E',
        isSelfDraw: false,
        discarderId: 'S',
      );

      // R3: N deals to W $16
      final r3 = la.apply(
        rawScoreChanges: {'W': 16, 'N': -16},
        winnerId: 'W',
        isSelfDraw: false,
        discarderId: 'N',
      );

      // Full settlement: S=74, W=36, N=36. E gets 146.
      expect(r3.adjustedScoreChanges['E'], 146);
      expect(r3.adjustedScoreChanges['S'], -74);
      expect(r3.adjustedScoreChanges['W'], -36);
      expect(r3.adjustedScoreChanges['N'], -36);
    });

    test('scenario 2: E deals to S → S debt halved', () {
      // Setup
      la.apply(
        rawScoreChanges: {'E': 108, 'S': -36, 'W': -36, 'N': -36},
        winnerId: 'E',
        isSelfDraw: true,
      );
      la.apply(
        rawScoreChanges: {'E': 20, 'S': -20},
        winnerId: 'E',
        isSelfDraw: false,
        discarderId: 'S',
      );

      // R3: E deals to S $18
      final r3 = la.apply(
        rawScoreChanges: {'S': 18, 'E': -18},
        winnerId: 'S',
        isSelfDraw: false,
        discarderId: 'E',
      );

      // S: debt=74, halved=37. W: 36. N: 36. E gets 109.
      expect(r3.adjustedScoreChanges['S'], -37);
      expect(r3.adjustedScoreChanges['W'], -36);
      expect(r3.adjustedScoreChanges['N'], -36);
      expect(r3.adjustedScoreChanges['E'], 109);
    });

    test(
      'scenario 3: E continues winning → further compounding (deferred)',
      () {
        // Setup
        la.apply(
          rawScoreChanges: {'E': 108, 'S': -36, 'W': -36, 'N': -36},
          winnerId: 'E',
          isSelfDraw: true,
        );
        la.apply(
          rawScoreChanges: {'E': 20, 'S': -20},
          winnerId: 'E',
          isSelfDraw: false,
          discarderId: 'S',
        );

        // R3: E self-draws $26 each (8 fan)
        final r3 = la.apply(
          rawScoreChanges: {'E': 78, 'S': -26, 'W': -26, 'N': -26},
          winnerId: 'E',
          isSelfDraw: true,
        );

        // All zeros (deferred during streak)
        expect(r3.adjustedScoreChanges, {'E': 0, 'S': 0, 'W': 0, 'N': 0});

        // Debts compound: S=74×1.5+26=137, W=36×1.5+26=80, N=80
        expect(la.debts['S'], 137);
        expect(la.debts['W'], 80);
        expect(la.debts['N'], 80);
      },
    );
  });

  group('LaSettlement - reset & no result', () {
    test('onNoResult clears all state', () {
      la.apply(
        rawScoreChanges: {'E': 30, 'S': -10, 'W': -10, 'N': -10},
        winnerId: 'E',
        isSelfDraw: true,
      );

      la.onNoResult();

      expect(la.streakWinnerId, isNull);
      expect(la.debts, isEmpty);
      expect(la.hasActiveStreak, isFalse);
    });

    test('reset clears all state', () {
      la.apply(
        rawScoreChanges: {'E': 30, 'S': -10, 'W': -10, 'N': -10},
        winnerId: 'E',
        isSelfDraw: true,
      );

      la.reset();

      expect(la.streakWinnerId, isNull);
      expect(la.debts, isEmpty);
    });

    test('after onNoResult, next round starts fresh (deferred)', () {
      la.apply(
        rawScoreChanges: {'E': 30, 'S': -10, 'W': -10, 'N': -10},
        winnerId: 'E',
        isSelfDraw: true,
      );
      la.onNoResult();

      // Same player wins but should start a new streak (deferred)
      final result = la.apply(
        rawScoreChanges: {'E': 30, 'S': -10, 'W': -10, 'N': -10},
        winnerId: 'E',
        isSelfDraw: true,
      );

      expect(result.adjustedScoreChanges, {'E': 0, 'S': 0, 'W': 0, 'N': 0});
      expect(result.descriptions, isEmpty);
    });
  });

  group('LaSettlement - stop rule (逼停)', () {
    test('stop eligible after 3 consecutive losses', () {
      // E self-draws 3 times
      la.apply(
        rawScoreChanges: {'E': 30, 'S': -10, 'W': -10, 'N': -10},
        winnerId: 'E',
        isSelfDraw: true,
      );
      la.apply(
        rawScoreChanges: {'E': 30, 'S': -10, 'W': -10, 'N': -10},
        winnerId: 'E',
        isSelfDraw: true,
      );
      final r3 = la.apply(
        rawScoreChanges: {'E': 30, 'S': -10, 'W': -10, 'N': -10},
        winnerId: 'E',
        isSelfDraw: true,
      );

      // All 3 players have lost 3 times → eligible
      expect(r3.stopEligible, {'S': 3, 'W': 3, 'N': 3});
      expect(la.consecutiveLosses['S'], 3);
    });

    test('stop eligible at 6 but not 4 or 5', () {
      for (int i = 0; i < 4; i++) {
        final r = la.apply(
          rawScoreChanges: {'E': 30, 'S': -10, 'W': -10, 'N': -10},
          winnerId: 'E',
          isSelfDraw: true,
        );
        if (i < 2) {
          expect(r.stopEligible, isEmpty); // rounds 1,2 → not eligible
        } else if (i == 2) {
          expect(r.stopEligible, {'S': 3, 'W': 3, 'N': 3}); // round 3
        } else {
          expect(r.stopEligible, isEmpty); // round 4 → not eligible
        }
      }

      // Rounds 5 and 6
      la.apply(
        rawScoreChanges: {'E': 30, 'S': -10, 'W': -10, 'N': -10},
        winnerId: 'E',
        isSelfDraw: true,
      );
      final r6 = la.apply(
        rawScoreChanges: {'E': 30, 'S': -10, 'W': -10, 'N': -10},
        winnerId: 'E',
        isSelfDraw: true,
      );

      expect(r6.stopEligible, {'S': 6, 'W': 6, 'N': 6});
    });

    test('forceSettle settles ONLY the triggering player', () {
      // E self-draws 3 times ($10 each)
      la.apply(
        rawScoreChanges: {'E': 30, 'S': -10, 'W': -10, 'N': -10},
        winnerId: 'E',
        isSelfDraw: true,
      );
      la.apply(
        rawScoreChanges: {'E': 30, 'S': -10, 'W': -10, 'N': -10},
        winnerId: 'E',
        isSelfDraw: true,
      );
      la.apply(
        rawScoreChanges: {'E': 30, 'S': -10, 'W': -10, 'N': -10},
        winnerId: 'E',
        isSelfDraw: true,
      );
      // All debts = 48

      final settlement = la.forceSettle('S');

      // Only S settles — W and N are NOT affected
      expect(settlement['S'], -48);
      expect(settlement['E'], 48);
      expect(settlement.containsKey('W'), isFalse);
      expect(settlement.containsKey('N'), isFalse);

      // La streak continues for W and N
      expect(la.hasActiveStreak, isTrue);
      expect(la.streakWinnerId, 'E');
      expect(la.debts['W'], 48);
      expect(la.debts['N'], 48);
      expect(la.settledPlayers, contains('S'));
    });

    test('forceSettle: streak resets when ALL debtors are settled', () {
      la.apply(
        rawScoreChanges: {'E': 30, 'S': -10, 'W': -10, 'N': -10},
        winnerId: 'E',
        isSelfDraw: true,
      );
      la.apply(
        rawScoreChanges: {'E': 30, 'S': -10, 'W': -10, 'N': -10},
        winnerId: 'E',
        isSelfDraw: true,
      );
      la.apply(
        rawScoreChanges: {'E': 30, 'S': -10, 'W': -10, 'N': -10},
        winnerId: 'E',
        isSelfDraw: true,
      );

      // Settle each debtor one by one
      la.forceSettle('S');
      expect(la.hasActiveStreak, isTrue);

      la.forceSettle('W');
      expect(la.hasActiveStreak, isTrue);

      la.forceSettle('N');
      // All debtors settled → La fully resets
      expect(la.hasActiveStreak, isFalse);
      expect(la.debts, isEmpty);
      expect(la.streakWinnerId, isNull);
    });

    test('forceSettle returns empty for already-settled player', () {
      la.apply(
        rawScoreChanges: {'E': 30, 'S': -10, 'W': -10, 'N': -10},
        winnerId: 'E',
        isSelfDraw: true,
      );
      la.apply(
        rawScoreChanges: {'E': 30, 'S': -10, 'W': -10, 'N': -10},
        winnerId: 'E',
        isSelfDraw: true,
      );
      la.apply(
        rawScoreChanges: {'E': 30, 'S': -10, 'W': -10, 'N': -10},
        winnerId: 'E',
        isSelfDraw: true,
      );

      la.forceSettle('S');
      final again = la.forceSettle('S');
      expect(again, isEmpty);
    });

    test('settled player can accumulate fresh debt on next win', () {
      la.apply(
        rawScoreChanges: {'E': 30, 'S': -10, 'W': -10, 'N': -10},
        winnerId: 'E',
        isSelfDraw: true,
      );
      la.apply(
        rawScoreChanges: {'E': 30, 'S': -10, 'W': -10, 'N': -10},
        winnerId: 'E',
        isSelfDraw: true,
      );
      la.apply(
        rawScoreChanges: {'E': 30, 'S': -10, 'W': -10, 'N': -10},
        winnerId: 'E',
        isSelfDraw: true,
      );
      // Debts all = 48
      la.forceSettle('S'); // S pays 48, column resets

      // E wins again — S gets fresh debt (not excluded)
      la.apply(
        rawScoreChanges: {'E': 30, 'S': -10, 'W': -10, 'N': -10},
        winnerId: 'E',
        isSelfDraw: true,
      );

      // W & N compound: 48*1.5+10 = 82
      expect(la.debts['W'], 82);
      expect(la.debts['N'], 82);
      // S was force-settled and now has fresh debt
      expect(la.debts['S'], 10);
      expect(la.consecutiveLosses['S'], 1);
    });

    test('after ALL debtors forceSettle, La is fresh for next round', () {
      la.apply(
        rawScoreChanges: {'E': 30, 'S': -10, 'W': -10, 'N': -10},
        winnerId: 'E',
        isSelfDraw: true,
      );
      la.apply(
        rawScoreChanges: {'E': 30, 'S': -10, 'W': -10, 'N': -10},
        winnerId: 'E',
        isSelfDraw: true,
      );
      la.apply(
        rawScoreChanges: {'E': 30, 'S': -10, 'W': -10, 'N': -10},
        winnerId: 'E',
        isSelfDraw: true,
      );
      la.forceSettle('S');
      la.forceSettle('W');
      la.forceSettle('N');

      // La is fully reset — next round starts a fresh streak
      final result = la.apply(
        rawScoreChanges: {'E': 30, 'S': -10, 'W': -10, 'N': -10},
        winnerId: 'E',
        isSelfDraw: true,
      );

      // Deferred (new streak)
      expect(result.adjustedScoreChanges, {'E': 0, 'S': 0, 'W': 0, 'N': 0});
      expect(la.debts, {'S': 10, 'W': 10, 'N': 10});
    });

    test('forceSettle returns empty if no active streak', () {
      expect(la.forceSettle('S'), isEmpty);
    });
  });

  group('LaSettlement - settleAtGameEnd', () {
    test('settles all remaining debts at full value', () {
      la.apply(
        rawScoreChanges: {'E': 30, 'S': -10, 'W': -10, 'N': -10},
        winnerId: 'E',
        isSelfDraw: true,
      );
      la.apply(
        rawScoreChanges: {'E': 30, 'S': -10, 'W': -10, 'N': -10},
        winnerId: 'E',
        isSelfDraw: true,
      );
      // Debts: each = 25

      final settlement = la.settleAtGameEnd();

      expect(settlement['S'], -25);
      expect(settlement['W'], -25);
      expect(settlement['N'], -25);
      expect(settlement['E'], 75);

      // La reset after settlement
      expect(la.hasActiveStreak, isFalse);
      expect(la.debts, isEmpty);
    });

    test('single-round streak settles at game end', () {
      la.apply(
        rawScoreChanges: {'E': 30, 'S': -30},
        winnerId: 'E',
        isSelfDraw: false,
        discarderId: 'S',
      );

      final settlement = la.settleAtGameEnd();

      expect(settlement['S'], -30);
      expect(settlement['E'], 30);
      expect(la.hasActiveStreak, isFalse);
    });

    test('returns empty if no active streak', () {
      expect(la.settleAtGameEnd(), isEmpty);
    });

    test('zero-sum verification for game end settlement', () {
      la.apply(
        rawScoreChanges: {'E': 108, 'S': -36, 'W': -36, 'N': -36},
        winnerId: 'E',
        isSelfDraw: true,
      );
      la.apply(
        rawScoreChanges: {'E': 20, 'S': -20},
        winnerId: 'E',
        isSelfDraw: false,
        discarderId: 'S',
      );

      final settlement = la.settleAtGameEnd();
      final sum = settlement.values.fold(0, (a, b) => a + b);
      expect(sum, 0, reason: 'Game-end settlement must be zero-sum');
    });
  });

  group('LaSettlement - edge cases', () {
    test('discard-only streak: only discarder has debt', () {
      la.apply(
        rawScoreChanges: {'E': 30, 'S': -30},
        winnerId: 'E',
        isSelfDraw: false,
        discarderId: 'S',
      );

      expect(la.debts['S'], 30);
      expect(la.debts.containsKey('W'), isFalse);
      expect(la.debts.containsKey('N'), isFalse);
    });

    test(
      'streak winner deals to non-debtor → settlement with no reduction effect',
      () {
        // R1: E wins from S ($30)
        la.apply(
          rawScoreChanges: {'E': 30, 'S': -30},
          winnerId: 'E',
          isSelfDraw: false,
          discarderId: 'S',
        );

        // R2: E deals to W. Reduction: discarderId==E (streak winner).
        // Beneficiary W has no debt → no practical effect.
        final result = la.apply(
          rawScoreChanges: {'W': 20, 'E': -20},
          winnerId: 'W',
          isSelfDraw: false,
          discarderId: 'E',
        );

        // S: debt=30, full. E gets 30.
        expect(result.adjustedScoreChanges['S'], -30);
        expect(result.adjustedScoreChanges['E'], 30);
      },
    );

    test('zero-sum verification across multi-round streak', () {
      // Full 3-round streak with settlement
      la.apply(
        rawScoreChanges: {'E': 108, 'S': -36, 'W': -36, 'N': -36},
        winnerId: 'E',
        isSelfDraw: true,
      );
      la.apply(
        rawScoreChanges: {'E': 20, 'S': -20},
        winnerId: 'E',
        isSelfDraw: false,
        discarderId: 'S',
      );

      final r3 = la.apply(
        rawScoreChanges: {'W': 16, 'N': -16},
        winnerId: 'W',
        isSelfDraw: false,
        discarderId: 'N',
      );

      // Verify zero-sum
      final adj = r3.adjustedScoreChanges;
      final sum = adj.values.fold(0, (a, b) => a + b);
      expect(sum, 0, reason: 'Settlement must be zero-sum');
    });

    test('hasActiveStreak is false at start', () {
      expect(la.hasActiveStreak, isFalse);
    });

    test('hasActiveStreak is true during streak', () {
      la.apply(
        rawScoreChanges: {'E': 30, 'S': -10, 'W': -10, 'N': -10},
        winnerId: 'E',
        isSelfDraw: true,
      );
      expect(la.hasActiveStreak, isTrue);
    });

    test('legacy getters work', () {
      la.apply(
        rawScoreChanges: {'E': 30, 'S': -10, 'W': -10, 'N': -10},
        winnerId: 'E',
        isSelfDraw: true,
      );

      expect(la.previousWinnerId, 'E');
      expect(la.accumulatedDebt, la.debts);
      expect(la.hasCarryOver, la.hasActiveStreak);
    });
  });

  group('LaSettlement - user simplified examples (deferred)', () {
    test('P1 wins P2, P3 wins from P1 → P2 full debt settled', () {
      // R1: P1 wins from P2 ($20), deferred
      la.apply(
        rawScoreChanges: {'P1': 20, 'P2': -20},
        winnerId: 'P1',
        isSelfDraw: false,
        discarderId: 'P2',
      );

      // R2: P3 wins from P1.
      // Reduction: discarderId=P1==streakWinner → beneficiary=P3.
      // P3 has no debt → no reduction effect.
      // P2: debt=20, full.
      final r2 = la.apply(
        rawScoreChanges: {'P3': 30, 'P1': -30},
        winnerId: 'P3',
        isSelfDraw: false,
        discarderId: 'P1',
      );

      // Settlement: P2 pays 20, P1 gets 20.
      expect(r2.adjustedScoreChanges['P2'], -20);
      expect(r2.adjustedScoreChanges['P1'], 20);
    });

    test('P1 wins P2, P2 wins from P1 → P2 debt halved', () {
      // R1: P1 wins from P2 ($20), deferred
      la.apply(
        rawScoreChanges: {'P1': 20, 'P2': -20},
        winnerId: 'P1',
        isSelfDraw: false,
        discarderId: 'P2',
      );

      // R2: P2 wins from P1 ($20). Reduction: P1 is discarder == streak winner.
      // P2: debt=20, halved=10.
      final r2 = la.apply(
        rawScoreChanges: {'P2': 20, 'P1': -20},
        winnerId: 'P2',
        isSelfDraw: false,
        discarderId: 'P1',
      );

      // Settlement: P2 pays 10, P1 gets 10.
      expect(r2.adjustedScoreChanges['P2'], -10);
      expect(r2.adjustedScoreChanges['P1'], 10);
    });

    test('P1 wins P2 twice, P3 wins → compound settlement', () {
      // R1: P1 wins from P2 ($20), deferred
      la.apply(
        rawScoreChanges: {'P1': 20, 'P2': -20},
        winnerId: 'P1',
        isSelfDraw: false,
        discarderId: 'P2',
      );

      // R2: P1 wins from P2 again ($20), deferred
      la.apply(
        rawScoreChanges: {'P1': 20, 'P2': -20},
        winnerId: 'P1',
        isSelfDraw: false,
        discarderId: 'P2',
      );
      // P2: debt = 20×1.5+20 = 50

      // R3: P3 wins from P4 ($30). No reduction.
      final r3 = la.apply(
        rawScoreChanges: {'P3': 30, 'P4': -30},
        winnerId: 'P3',
        isSelfDraw: false,
        discarderId: 'P4',
      );

      // Full settlement: P2=50. P1 gets 50.
      expect(r3.adjustedScoreChanges['P2'], -50);
      expect(r3.adjustedScoreChanges['P1'], 50);
    });
  });

  // ── Per-column independent tracking ──────────────────────────────
  group('LaSettlement - per-column independent tracking', () {
    test('force-settled player gets fresh marks independent of others', () {
      // P1 self-draws 3 times
      la.apply(
        rawScoreChanges: {'P1': 30, 'P2': -10, 'P3': -10, 'P4': -10},
        winnerId: 'P1',
        isSelfDraw: true,
      );
      la.apply(
        rawScoreChanges: {'P1': 30, 'P2': -10, 'P3': -10, 'P4': -10},
        winnerId: 'P1',
        isSelfDraw: true,
      );
      la.apply(
        rawScoreChanges: {'P1': 30, 'P2': -10, 'P3': -10, 'P4': -10},
        winnerId: 'P1',
        isSelfDraw: true,
      );
      // All at marks=3, debt=48

      // P2 and P3 force-settle, P4 declines
      la.forceSettle('P2');
      la.forceSettle('P3');
      la.recordStopDeclined('P4');

      // Verify: P2/P3 columns reset, P4 still has debt
      expect(la.hasActiveStreak, isTrue);
      expect(la.debts['P4'], 48);

      // P1 self-draws again → P2/P3 get fresh marks, P4 compounds
      la.apply(
        rawScoreChanges: {'P1': 30, 'P2': -10, 'P3': -10, 'P4': -10},
        winnerId: 'P1',
        isSelfDraw: true,
      );

      // P2, P3: fresh debt 10, marks=1
      expect(la.debts['P2'], 10);
      expect(la.debts['P3'], 10);
      expect(la.consecutiveLosses['P2'], 1);
      expect(la.consecutiveLosses['P3'], 1);

      // P4: 48*1.5+10=82, marks=4
      expect(la.debts['P4'], 82);
      expect(la.consecutiveLosses['P4'], 4);
    });

    test('declined player not re-asked until next threshold', () {
      // P1 self-draws 3 times
      la.apply(
        rawScoreChanges: {'P1': 30, 'P2': -10, 'P3': -10, 'P4': -10},
        winnerId: 'P1',
        isSelfDraw: true,
      );
      la.apply(
        rawScoreChanges: {'P1': 30, 'P2': -10, 'P3': -10, 'P4': -10},
        winnerId: 'P1',
        isSelfDraw: true,
      );
      final r3 = la.apply(
        rawScoreChanges: {'P1': 30, 'P2': -10, 'P3': -10, 'P4': -10},
        winnerId: 'P1',
        isSelfDraw: true,
      );

      // All eligible at 3
      expect(r3.stopEligible, {'P2': 3, 'P3': 3, 'P4': 3});

      // P2 force-settles, P3 force-settles, P4 declines
      la.forceSettle('P2');
      la.forceSettle('P3');
      la.recordStopDeclined('P4');

      // P1 self-draws round 4 — P4 at marks=4, not divisible by 3
      final r4 = la.apply(
        rawScoreChanges: {'P1': 30, 'P2': -10, 'P3': -10, 'P4': -10},
        winnerId: 'P1',
        isSelfDraw: true,
      );
      expect(r4.stopEligible, isEmpty);

      // P1 self-draws round 5 — P4 at marks=5
      final r5 = la.apply(
        rawScoreChanges: {'P1': 30, 'P2': -10, 'P3': -10, 'P4': -10},
        winnerId: 'P1',
        isSelfDraw: true,
      );
      expect(r5.stopEligible, isEmpty);

      // P1 self-draws round 6 — P4 at marks=6 (6>3, 6%3==0), P2 at marks=3
      final r6 = la.apply(
        rawScoreChanges: {'P1': 30, 'P2': -10, 'P3': -10, 'P4': -10},
        winnerId: 'P1',
        isSelfDraw: true,
      );
      expect(r6.stopEligible.containsKey('P4'), isTrue);
      expect(r6.stopEligible['P4'], 6);
      // P2 and P3 also reach 3 (fresh marks after force-settle)
      expect(r6.stopEligible.containsKey('P2'), isTrue);
      expect(r6.stopEligible.containsKey('P3'), isTrue);
    });

    test('discard win only adds mark to discarder column', () {
      // P1 self-draws → all get marks
      la.apply(
        rawScoreChanges: {'P1': 30, 'P2': -10, 'P3': -10, 'P4': -10},
        winnerId: 'P1',
        isSelfDraw: true,
      );

      // P1 wins from P2 (discard) → only P2 gets additional mark
      la.apply(
        rawScoreChanges: {'P1': 20, 'P2': -20},
        winnerId: 'P1',
        isSelfDraw: false,
        discarderId: 'P2',
      );

      expect(la.consecutiveLosses['P2'], 2);
      expect(la.consecutiveLosses['P3'], 1);
      expect(la.consecutiveLosses['P4'], 1);
    });

    test('declined player stays unchanged on discard win to others', () {
      // P1 self-draws 3 times → all at marks=3
      for (int i = 0; i < 3; i++) {
        la.apply(
          rawScoreChanges: {'P1': 30, 'P2': -10, 'P3': -10, 'P4': -10},
          winnerId: 'P1',
          isSelfDraw: true,
        );
      }

      la.forceSettle('P2');
      la.forceSettle('P3');
      la.recordStopDeclined('P4'); // P4 declines at marks=3

      // P1 wins from P2 (discard) — P4 is NOT affected
      la.apply(
        rawScoreChanges: {'P1': 20, 'P2': -20},
        winnerId: 'P1',
        isSelfDraw: false,
        discarderId: 'P2',
      );

      // P4 still at marks=3 (unchanged by discard to P2)
      expect(la.consecutiveLosses['P4'], 3);
      // P4 should NOT be asked (3 > 3 is false)
      expect(la.canForceSettle('P4'), isFalse);
    });

    test('canForceSettle returns correct values at each state', () {
      // Round 1-2: not eligible
      la.apply(
        rawScoreChanges: {'E': 30, 'S': -10, 'W': -10, 'N': -10},
        winnerId: 'E',
        isSelfDraw: true,
      );
      expect(la.canForceSettle('S'), isFalse);

      la.apply(
        rawScoreChanges: {'E': 30, 'S': -10, 'W': -10, 'N': -10},
        winnerId: 'E',
        isSelfDraw: true,
      );
      expect(la.canForceSettle('S'), isFalse);

      // Round 3: marks=3, eligible
      la.apply(
        rawScoreChanges: {'E': 30, 'S': -10, 'W': -10, 'N': -10},
        winnerId: 'E',
        isSelfDraw: true,
      );
      expect(la.canForceSettle('S'), isTrue);

      // S declines
      la.recordStopDeclined('S');
      expect(la.canForceSettle('S'), isFalse);

      // Rounds 4-5: not at threshold
      la.apply(
        rawScoreChanges: {'E': 30, 'S': -10, 'W': -10, 'N': -10},
        winnerId: 'E',
        isSelfDraw: true,
      );
      expect(la.canForceSettle('S'), isFalse); // marks=4

      la.apply(
        rawScoreChanges: {'E': 30, 'S': -10, 'W': -10, 'N': -10},
        winnerId: 'E',
        isSelfDraw: true,
      );
      expect(la.canForceSettle('S'), isFalse); // marks=5

      // Round 6: marks=6, new threshold
      la.apply(
        rawScoreChanges: {'E': 30, 'S': -10, 'W': -10, 'N': -10},
        winnerId: 'E',
        isSelfDraw: true,
      );
      expect(la.canForceSettle('S'), isTrue); // marks=6, 6>3
    });

    test('recordStopDeclined: no effect on non-existent player', () {
      la.apply(
        rawScoreChanges: {'E': 30, 'S': -10, 'W': -10, 'N': -10},
        winnerId: 'E',
        isSelfDraw: true,
      );

      // 'X' is not in the streak
      la.recordStopDeclined('X');
      // No crash, no effect
      expect(la.hasActiveStreak, isTrue);
    });

    test('user scenario: full trace with independent columns', () {
      // Game 1: P1 self-draw → all get marks
      la.apply(
        rawScoreChanges: {'P1': 30, 'P2': -10, 'P3': -10, 'P4': -10},
        winnerId: 'P1',
        isSelfDraw: true,
      );
      expect(la.consecutiveLosses, {'P2': 1, 'P3': 1, 'P4': 1});

      // Game 2: P1 wins from P2 → only P2 marks increase
      la.apply(
        rawScoreChanges: {'P1': 20, 'P2': -20},
        winnerId: 'P1',
        isSelfDraw: false,
        discarderId: 'P2',
      );
      expect(la.consecutiveLosses['P2'], 2);
      expect(la.consecutiveLosses['P3'], 1);
      expect(la.consecutiveLosses['P4'], 1);

      // Game 3: P1 self-draw → all marks increase
      final r3 = la.apply(
        rawScoreChanges: {'P1': 30, 'P2': -10, 'P3': -10, 'P4': -10},
        winnerId: 'P1',
        isSelfDraw: true,
      );
      expect(la.consecutiveLosses['P2'], 3);
      expect(la.consecutiveLosses['P3'], 2);
      expect(la.consecutiveLosses['P4'], 2);
      // Only P2 eligible (marks=3)
      expect(r3.stopEligible, {'P2': 3});

      // P2 force-settles
      la.forceSettle('P2');

      // Game 4: P1 self-draw → P2 gets fresh mark, P3/P4 compound
      final r4 = la.apply(
        rawScoreChanges: {'P1': 30, 'P2': -10, 'P3': -10, 'P4': -10},
        winnerId: 'P1',
        isSelfDraw: true,
      );
      expect(la.consecutiveLosses['P2'], 1); // fresh
      expect(la.consecutiveLosses['P3'], 3);
      expect(la.consecutiveLosses['P4'], 3);
      // P3 and P4 eligible at marks=3
      expect(r4.stopEligible, {'P3': 3, 'P4': 3});

      // P3 force-settles, P4 declines
      la.forceSettle('P3');
      la.recordStopDeclined('P4');

      // Game 5: P1 wins from P2 → only P2 column affected
      final r5 = la.apply(
        rawScoreChanges: {'P1': 20, 'P2': -20},
        winnerId: 'P1',
        isSelfDraw: false,
        discarderId: 'P2',
      );
      expect(la.consecutiveLosses['P2'], 2);
      // P3 fresh (marks=0 after settle, not affected by discard)
      expect(la.consecutiveLosses['P3'], 0);
      // P4 unchanged (still 3, not affected by discard to P2)
      expect(la.consecutiveLosses['P4'], 3);
      // P4 should NOT be asked (was already asked at 3)
      expect(r5.stopEligible, isEmpty);
      expect(la.canForceSettle('P4'), isFalse);
    });
  });
}
