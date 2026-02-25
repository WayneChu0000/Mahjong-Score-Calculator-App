import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/utils/la_settlement.dart';

void main() {
  late LaSettlement la;

  setUp(() {
    la = LaSettlement();
  });

  group('LaSettlement - basic behaviour', () {
    test('first round has no La adjustment', () {
      final result = la.apply(
        rawScoreChanges: {'A': 30, 'B': -10, 'C': -10, 'D': -10},
        winnerId: 'A',
        isSelfDraw: true,
      );

      expect(result.adjustedScoreChanges, {'A': 30, 'B': -10, 'C': -10, 'D': -10});
      expect(result.descriptions, isEmpty);
    });

    test('different winner (non-loser, no special condition) has no carry-over', () {
      // Round 1: A wins from B's discard, only B loses
      la.apply(
        rawScoreChanges: {'A': 30, 'B': -30, 'C': 0, 'D': 0},
        winnerId: 'A',
        isSelfDraw: false,
        discarderId: 'B',
      );

      // Round 2: C wins from D's discard
      // C was NOT a previous loser, D (discarder) is NOT previous winner A
      // → no reduction/multiplier → La debts simply cleared
      final result = la.apply(
        rawScoreChanges: {'C': 30, 'D': -30, 'A': 0, 'B': 0},
        winnerId: 'C',
        isSelfDraw: false,
        discarderId: 'D',
      );

      expect(result.adjustedScoreChanges, {'C': 30, 'D': -30, 'A': 0, 'B': 0});
      expect(result.descriptions, isEmpty);
    });
  });

  group('LaSettlement - multiplier (×1.5)', () {
    test('same winner consecutive → losers pay ×1.5 carry-over', () {
      // Round 1: A wins, B/C/D lose 10 each
      la.apply(
        rawScoreChanges: {'A': 30, 'B': -10, 'C': -10, 'D': -10},
        winnerId: 'A',
        isSelfDraw: true,
      );

      // Round 2: A wins again, B/C/D lose 20 each
      // La carry-over: each loser's previous debt (10) × 1.5 = 15 extra
      final result = la.apply(
        rawScoreChanges: {'A': 60, 'B': -20, 'C': -20, 'D': -20},
        winnerId: 'A',
        isSelfDraw: true,
      );

      // B/C/D each: -20 (raw) - 15 (La) = -35
      // A: 60 (raw) + 45 (La from 3 losers) = 105
      expect(result.adjustedScoreChanges['B'], -35);
      expect(result.adjustedScoreChanges['C'], -35);
      expect(result.adjustedScoreChanges['D'], -35);
      expect(result.adjustedScoreChanges['A'], 105);
      expect(result.descriptions, isNotEmpty);
    });

    test('three consecutive wins → multiplier stacks', () {
      // Round 1: A wins
      la.apply(
        rawScoreChanges: {'A': 30, 'B': -10, 'C': -10, 'D': -10},
        winnerId: 'A',
        isSelfDraw: true,
      );

      // Round 2: A wins again → La ×1.5 on round 1 debts
      la.apply(
        rawScoreChanges: {'A': 30, 'B': -10, 'C': -10, 'D': -10},
        winnerId: 'A',
        isSelfDraw: true,
      );

      // Round 3: A wins again → La ×1.5 on round 2 (already inflated) debts
      // After round 2, each loser's accumulated debt = 10(raw) + 15(La) = 25
      // Round 3 carry-over: 25 × 1.5 = 37.5 ≈ 38
      final result = la.apply(
        rawScoreChanges: {'A': 30, 'B': -10, 'C': -10, 'D': -10},
        winnerId: 'A',
        isSelfDraw: true,
      );

      expect(result.adjustedScoreChanges['B'], -10 - 38);
      expect(result.adjustedScoreChanges['C'], -10 - 38);
      expect(result.adjustedScoreChanges['D'], -10 - 38);
      // A gets: 30 + 38*3 = 144
      expect(result.adjustedScoreChanges['A'], 30 + 38 * 3);
    });
  });

  group('LaSettlement - reduction (÷2)', () {
    test('previous loser self-draws → debts halved', () {
      // Round 1: A wins, B loses 10
      la.apply(
        rawScoreChanges: {'A': 30, 'B': -10, 'C': -10, 'D': -10},
        winnerId: 'A',
        isSelfDraw: true,
      );

      // Round 2: B (previous loser) self-draws
      // Reduction: all accumulated debts halved
      // B's debt 10 → recovered 5, C's debt 10 → recovered 5, D's debt 10 → recovered 5
      // A (previous winner) pays back 15 total
      final result = la.apply(
        rawScoreChanges: {'B': 30, 'A': -10, 'C': -10, 'D': -10},
        winnerId: 'B',
        isSelfDraw: true,
      );

      // B: 30 (raw) + 5 (La recovery) = 35
      // C: -10 (raw) + 5 (La recovery) = -5
      // D: -10 (raw) + 5 (La recovery) = -5
      // A: -10 (raw) - 15 (La payback) = -25
      expect(result.adjustedScoreChanges['B'], 35);
      expect(result.adjustedScoreChanges['C'], -5);
      expect(result.adjustedScoreChanges['D'], -5);
      expect(result.adjustedScoreChanges['A'], -25);
      expect(result.descriptions, isNotEmpty);
    });

    test('previous winner discards → debts halved', () {
      // Round 1: A wins from B's discard
      la.apply(
        rawScoreChanges: {'A': 30, 'B': -30, 'C': 0, 'D': 0},
        winnerId: 'A',
        isSelfDraw: false,
        discarderId: 'B',
      );

      // Round 2: C wins from A's discard (A was previous winner)
      // Reduction condition: previous winner (A) discards
      // B's accumulated debt = 30 → recovered 15
      // A (previous winner) pays back 15
      final result = la.apply(
        rawScoreChanges: {'C': 30, 'A': -30, 'B': 0, 'D': 0},
        winnerId: 'C',
        isSelfDraw: false,
        discarderId: 'A',
      );

      // A: -30 (raw) - 15 (La payback) = -45
      // B: 0 (raw) + 15 (La recovery) = 15
      // C: 30 (raw, unaffected by La)
      // D: 0
      expect(result.adjustedScoreChanges['A'], -45);
      expect(result.adjustedScoreChanges['B'], 15);
      expect(result.adjustedScoreChanges['C'], 30);
      expect(result.adjustedScoreChanges['D'], 0);
    });
  });

  group('LaSettlement - reset & no result', () {
    test('onNoResult clears all state', () {
      la.apply(
        rawScoreChanges: {'A': 30, 'B': -10, 'C': -10, 'D': -10},
        winnerId: 'A',
        isSelfDraw: true,
      );

      la.onNoResult();

      expect(la.previousWinnerId, isNull);
      expect(la.accumulatedDebt, isEmpty);
      expect(la.hasCarryOver, isFalse);
    });

    test('reset clears all state', () {
      la.apply(
        rawScoreChanges: {'A': 30, 'B': -10, 'C': -10, 'D': -10},
        winnerId: 'A',
        isSelfDraw: true,
      );

      la.reset();

      expect(la.previousWinnerId, isNull);
      expect(la.accumulatedDebt, isEmpty);
    });

    test('after onNoResult, next round has no carry-over', () {
      la.apply(
        rawScoreChanges: {'A': 30, 'B': -10, 'C': -10, 'D': -10},
        winnerId: 'A',
        isSelfDraw: true,
      );

      la.onNoResult();

      // A wins again but no La applies since reset happened
      final result = la.apply(
        rawScoreChanges: {'A': 30, 'B': -10, 'C': -10, 'D': -10},
        winnerId: 'A',
        isSelfDraw: true,
      );

      expect(result.adjustedScoreChanges, {'A': 30, 'B': -10, 'C': -10, 'D': -10});
      expect(result.descriptions, isEmpty);
    });
  });

  group('LaSettlement - edge cases', () {
    test('non-self-draw with no discarder → no La reduction', () {
      la.apply(
        rawScoreChanges: {'A': 30, 'B': -10, 'C': -10, 'D': -10},
        winnerId: 'A',
        isSelfDraw: true,
      );

      // Different winner, not self-draw, discarder is NOT previous winner
      final result = la.apply(
        rawScoreChanges: {'B': 30, 'A': -30, 'C': 0, 'D': 0},
        winnerId: 'B',
        isSelfDraw: false,
        discarderId: 'C',
      );

      // No reduction (discarder C ≠ previous winner A, and B was not previous loser who self-drew)
      // No carry-over → scores unchanged
      expect(result.adjustedScoreChanges, {'B': 30, 'A': -30, 'C': 0, 'D': 0});
      expect(result.descriptions, isEmpty);
    });

    test('only losers with actual losses have accumulated debt', () {
      la.apply(
        rawScoreChanges: {'A': 30, 'B': -30, 'C': 0, 'D': 0},
        winnerId: 'A',
        isSelfDraw: false,
        discarderId: 'B',
      );

      // Only B should have accumulated debt
      expect(la.accumulatedDebt['B'], 30);
      expect(la.accumulatedDebt.containsKey('C'), isFalse);
      expect(la.accumulatedDebt.containsKey('D'), isFalse);
    });

    test('hasCarryOver is true when debt exists', () {
      la.apply(
        rawScoreChanges: {'A': 30, 'B': -10, 'C': -10, 'D': -10},
        winnerId: 'A',
        isSelfDraw: true,
      );

      expect(la.hasCarryOver, isTrue);
    });

    test('hasCarryOver is false at start', () {
      expect(la.hasCarryOver, isFalse);
    });
  });
}
