/// Tracks and applies the Taiwan Mahjong "La" (拉) carry-over settlement.
///
/// ### How La works
/// - After each round, the settlement records who won and who lost.
/// - **Multiplier (×1.5)**: If the same player wins two rounds in a row,
///   every loser's _accumulated_ La debt from the previous round is
///   multiplied by 1.5 before the new round's losses are added on top.
/// - **Reduction (÷2)**: If a previous-round loser self-draws this round,
///   **or** the previous-round winner discards the winning tile this round,
///   all accumulated La debts are halved before applying this round.
/// - If neither condition applies, accumulated La debts are cleared (reset).
///
/// La debts are tracked **per loser** and only paid to the current winner.
class LaSettlement {
  /// Player ID of the previous round's winner. Null if no previous round.
  String? _previousWinnerId;

  /// Accumulated La debt per player (player ID → debt amount, always >= 0).
  /// Only losers from the previous round have entries here.
  final Map<String, int> _accumulatedDebt = {};

  // ── Getters ──────────────────────────────────

  String? get previousWinnerId => _previousWinnerId;
  Map<String, int> get accumulatedDebt => Map.unmodifiable(_accumulatedDebt);

  /// True if there is any carry-over debt from the previous round.
  bool get hasCarryOver => _accumulatedDebt.values.any((v) => v > 0);

  // ── Core logic ───────────────────────────────

  /// Apply La settlement to the raw score changes from this round.
  ///
  /// Returns a new map of adjusted score changes (player ID → total change),
  /// and a list of La adjustment descriptions for display.
  ///
  /// Parameters:
  /// - [rawScoreChanges]: the base score changes from this round's hand
  /// - [winnerId]: ID of this round's winner
  /// - [isSelfDraw]: whether the win was a self-draw
  /// - [discarderId]: ID of the player who discarded (null if self-draw)
  LaResult apply({
    required Map<String, int> rawScoreChanges,
    required String winnerId,
    required bool isSelfDraw,
    String? discarderId,
  }) {
    final adjustedChanges = Map<String, int>.from(rawScoreChanges);
    final descriptions = <String>[];

    // Determine which La scenario applies
    if (_previousWinnerId != null && _accumulatedDebt.isNotEmpty) {
      if (winnerId == _previousWinnerId) {
        // ─── Multiplier: same winner again ───
        // Previous losers' debts × 1.5, then add new losses
        for (final entry in _accumulatedDebt.entries) {
          final loserId = entry.key;
          final oldDebt = entry.value;
          if (oldDebt > 0) {
            final carryOver = (oldDebt * 1.5).round();
            // Loser pays extra carry-over to the winner
            adjustedChanges[loserId] =
                (adjustedChanges[loserId] ?? 0) - carryOver;
            adjustedChanges[winnerId] =
                (adjustedChanges[winnerId] ?? 0) + carryOver;
            descriptions.add(
                'La ×1.5: $loserId → -$carryOver');
          }
        }
      } else {
        // Check for reduction condition
        bool reductionApplies = false;

        // Condition 1: a previous loser self-draws this round
        if (isSelfDraw && _accumulatedDebt.containsKey(winnerId)) {
          reductionApplies = true;
        }

        // Condition 2: previous winner discards (becomes discarder) this round
        if (!isSelfDraw &&
            discarderId != null &&
            discarderId == _previousWinnerId) {
          reductionApplies = true;
        }

        if (reductionApplies) {
          // ─── Reduction: debts halved ───
          for (final entry in _accumulatedDebt.entries) {
            final loserId = entry.key;
            final oldDebt = entry.value;
            if (oldDebt > 0) {
              final recovered = (oldDebt / 2).round();
              // Loser recovers half their accumulated debt
              adjustedChanges[loserId] =
                  (adjustedChanges[loserId] ?? 0) + recovered;
              // The previous winner pays back that amount
              adjustedChanges[_previousWinnerId!] =
                  (adjustedChanges[_previousWinnerId!] ?? 0) - recovered;
              descriptions.add(
                  'La ÷2: $loserId recovers $recovered');
            }
          }
        }
        // If neither multiplier nor reduction applies, La debts are
        // simply cleared (no carry-over adjustment to this round).
      }
    }

    // ─── Update state for next round ───
    _updateState(
      scoreChanges: adjustedChanges,
      winnerId: winnerId,
    );

    return LaResult(
      adjustedScoreChanges: adjustedChanges,
      descriptions: descriptions,
    );
  }

  /// Update internal state after a round is settled.
  void _updateState({
    required Map<String, int> scoreChanges,
    required String winnerId,
  }) {
    _accumulatedDebt.clear();

    // Record each loser's total loss amount as their new La debt
    for (final entry in scoreChanges.entries) {
      if (entry.value < 0) {
        _accumulatedDebt[entry.key] = entry.value.abs();
      }
    }

    _previousWinnerId = winnerId;
  }

  /// Reset all La state (e.g. at game start or after a draw round).
  void reset() {
    _previousWinnerId = null;
    _accumulatedDebt.clear();
  }

  /// Call this when a round ends with no result (流局).
  /// La debts are cleared.
  void onNoResult() {
    reset();
  }
}

/// Result of applying La settlement to a round.
class LaResult {
  /// Score changes after La adjustments.
  final Map<String, int> adjustedScoreChanges;

  /// Human-readable descriptions of La adjustments applied.
  final List<String> descriptions;

  const LaResult({
    required this.adjustedScoreChanges,
    required this.descriptions,
  });
}
