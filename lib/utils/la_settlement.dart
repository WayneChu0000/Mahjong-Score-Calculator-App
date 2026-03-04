/// Tracks and applies the Taiwan Mahjong "La" (拉) carry-over settlement.
///
/// ### How La works (per-column deferred model)
/// - Each debtor has an independent "column" under the streak winner,
///   tracking their own debt, mark count, and force-settlement status.
/// - **No scores are applied during a streak.** All scoring is deferred
///   until the streak ends or a force settlement occurs.
/// - **Compounding (×1.5)**: When the same player wins consecutively,
///   each loser's column debt is multiplied by 1.5 before the new
///   round's loss is added on top.
///   - Self-draw: ALL losers' columns compound.
///   - Discard win: ONLY the discarder's column compounds.
/// - **Settlement**: When a different player wins, the streak ends and
///   all remaining compounded debts are applied to the scores. The new
///   round's raw scores are deferred (a new streak starts).
/// - **Debt reduction (÷2)**: On settlement, if the previous streak
///   winner discards the winning tile, or if a debtor self-draws,
///   ONLY that specific player's debt is halved. Other debtors pay full.
/// - **Stop rule (逼停)**: When a player's mark count reaches a multiple
///   of 3 (3, 6, 9, …), they get ONE chance to force-settle their column.
///   If they decline, they won't be asked again until the next multiple.
///   Force-settling resets only that player's column; the streak continues
///   and the player can accumulate new debt if the winner keeps winning.
///   When all columns reach zero debt, La resets completely.
class LaSettlement {
  /// Player ID of the current streak winner. Null if no active streak.
  String? _streakWinnerId;

  /// Per-debtor columns keyed by player ID.
  final Map<String, _LaColumn> _columns = {};

  /// Total rounds in the current streak.
  int _streakRounds = 0;

  // ── Getters ──────────────────────────────────

  String? get streakWinnerId => _streakWinnerId;

  /// Debt per debtor (player ID → total debt amount).
  /// Includes columns with zero debt (force-settled but still in streak).
  Map<String, int> get debts =>
      _columns.map((k, v) => MapEntry(k, v.debt));

  /// Mark count per debtor (player ID → consecutive loss count in column).
  Map<String, int> get consecutiveLosses =>
      _columns.map((k, v) => MapEntry(k, v.marks));

  /// Players whose columns have been force-settled (debt = 0 and marks = 0).
  Set<String> get settledPlayers => _columns.entries
      .where((e) => e.value.debt == 0 && e.value.marks == 0)
      .map((e) => e.key)
      .toSet();

  /// True if there is an active winning streak with at least one debtor.
  bool get hasActiveStreak =>
      _streakWinnerId != null && _columns.values.any((c) => c.debt > 0);

  /// Total number of rounds in the current streak.
  int get streakLength => _streakRounds;

  /// Whether a specific player can currently force-settle via the stop rule.
  ///
  /// Returns true only at a NEW threshold (marks divisible by 3) that has
  /// not yet been offered. Returns false once the player accepts or declines.
  bool canForceSettle(String playerId) {
    final col = _columns[playerId];
    if (col == null) return false;
    return col.debt > 0 &&
        col.marks >= 3 &&
        col.marks % 3 == 0 &&
        col.marks > col.lastAskedAt;
  }

  // Legacy getters for backward compatibility
  String? get previousWinnerId => _streakWinnerId;
  Map<String, int> get accumulatedDebt => debts;
  bool get hasCarryOver => hasActiveStreak;

  // ── Core logic ───────────────────────────────

  /// Apply La settlement to the raw score changes from this round.
  ///
  /// **Deferred model:** During a winning streak (same winner), zero score
  /// changes are returned while debts compound internally. When the streak
  /// ends (different winner), the full compounded debts are settled and
  /// the new round's raw scores are deferred into a new streak.
  ///
  /// Parameters:
  /// - [rawScoreChanges]: base score deltas (player ID → change)
  /// - [winnerId]: ID of this round's winner
  /// - [isSelfDraw]: whether the win was a self-draw
  /// - [discarderId]: ID of the discarder (null if self-draw)
  LaResult apply({
    required Map<String, int> rawScoreChanges,
    required String winnerId,
    required bool isSelfDraw,
    String? discarderId,
  }) {
    final descriptions = <String>[];
    Map<String, int> stopEligible = {};

    if (_streakWinnerId == null) {
      // ── No existing streak → start a new one, defer all scores ──
      _startStreak(winnerId, rawScoreChanges);
      return LaResult(
        adjustedScoreChanges: _zeroChanges(rawScoreChanges),
        descriptions: descriptions,
        stopEligible: stopEligible,
      );
    }

    if (winnerId == _streakWinnerId) {
      // ── Same winner → compound debts, defer all scores ──
      _compoundDebts(rawScoreChanges);
      _streakRounds++;
      stopEligible = _getStopEligible();
      return LaResult(
        adjustedScoreChanges: _zeroChanges(rawScoreChanges),
        descriptions: descriptions,
        stopEligible: stopEligible,
      );
    }

    // ── Different winner → streak ends, settle debts ──
    final settlement = _settleDebts(
      winnerId: winnerId,
      isSelfDraw: isSelfDraw,
      discarderId: discarderId,
    );

    // Build adjusted changes: settlement amounts only
    // (new round's raw scores are deferred in the new streak)
    final adjustedChanges = <String, int>{};
    for (final entry in settlement.entries) {
      adjustedChanges[entry.key] =
          (adjustedChanges[entry.key] ?? 0) + entry.value;
      if (entry.value != 0) {
        descriptions.add(
          'La: ${entry.key} ${entry.value > 0 ? "+" : ""}${entry.value}',
        );
      }
    }

    // Start a new streak with the new winner (raw scores deferred)
    _startStreak(winnerId, rawScoreChanges);

    return LaResult(
      adjustedScoreChanges: adjustedChanges,
      descriptions: descriptions,
      stopEligible: const {},
    );
  }

  /// Force-settle a SINGLE player's column and reset it.
  ///
  /// Only the triggering player pays their full compounded debt to the
  /// streak winner. Their column resets to zero so they can accumulate
  /// fresh debt if the winner keeps winning.
  /// If all columns now have zero debt, La resets completely.
  /// Returns the score adjustments to apply.
  Map<String, int> forceSettle(String triggerPlayerId) {
    if (_streakWinnerId == null) return {};

    final col = _columns[triggerPlayerId];
    if (col == null || col.debt <= 0) return {};

    final debt = col.debt;
    final adjustments = <String, int>{};
    adjustments[triggerPlayerId] = -debt;
    adjustments[_streakWinnerId!] = debt;

    // Reset this player's column (they can accumulate fresh debt later)
    col.debt = 0;
    col.marks = 0;
    col.lastAskedAt = 0;

    // If all columns now have zero debt, fully reset La
    if (_columns.values.every((c) => c.debt <= 0)) {
      reset();
    }

    return adjustments;
  }

  /// Record that a player declined force-settlement at the current threshold.
  ///
  /// This prevents the stop rule dialog from re-appearing for this player
  /// until they reach the next multiple-of-3 threshold.
  void recordStopDeclined(String playerId) {
    final col = _columns[playerId];
    if (col != null) {
      col.lastAskedAt = col.marks;
    }
  }

  /// Settle all remaining debts at game end. Returns score adjustments.
  ///
  /// Called when the game finishes while a La streak is still active.
  /// All debtors pay full compounded debt (no reduction).
  Map<String, int> settleAtGameEnd() {
    if (_streakWinnerId == null) return {};

    final adjustments = <String, int>{};
    int totalForStreakWinner = 0;

    for (final entry in _columns.entries) {
      final debt = entry.value.debt;
      if (debt > 0) {
        adjustments[entry.key] = -debt;
        totalForStreakWinner += debt;
      }
    }

    if (totalForStreakWinner > 0) {
      adjustments[_streakWinnerId!] =
          (adjustments[_streakWinnerId!] ?? 0) + totalForStreakWinner;
    }

    reset();
    return adjustments;
  }

  /// Reset all La state (e.g. at game start or after a draw round).
  void reset() {
    _streakWinnerId = null;
    _columns.clear();
    _streakRounds = 0;
  }

  /// Call this when a round ends with no result (流局).
  /// La debts are cleared without settlement.
  void onNoResult() {
    reset();
  }

  // ── Private helpers ──────────────────────────

  /// Return a map with all keys from [rawScoreChanges] set to 0.
  Map<String, int> _zeroChanges(Map<String, int> rawScoreChanges) {
    return rawScoreChanges.map((k, _) => MapEntry(k, 0));
  }

  /// Start tracking a new winning streak.
  /// Debts are recorded but NOT applied to the scoreboard (deferred).
  void _startStreak(String winnerId, Map<String, int> rawScoreChanges) {
    _streakWinnerId = winnerId;
    _columns.clear();
    _streakRounds = 1;

    for (final entry in rawScoreChanges.entries) {
      if (entry.value < 0) {
        _columns[entry.key] = _LaColumn(
          debt: entry.value.abs(),
          marks: 1,
        );
      }
    }
  }

  /// Compound debts when the streak winner wins again.
  ///
  /// For each loser in this round (negative score change):
  /// - If they have existing debt: new_debt = old_debt × 1.5 + raw_loss
  /// - If they have no existing debt (fresh/reset): new_debt = raw_loss
  /// Players not losing this round keep their columns unchanged.
  void _compoundDebts(Map<String, int> rawScoreChanges) {
    for (final entry in rawScoreChanges.entries) {
      if (entry.value >= 0) continue;
      final loserId = entry.key;
      final rawLoss = entry.value.abs();

      final col = _columns.putIfAbsent(loserId, () => _LaColumn());
      col.debt = (col.debt * 1.5).round() + rawLoss;
      col.marks += 1;
    }
  }

  /// Settle all outstanding debts and return the settlement adjustments.
  ///
  /// Determines whether a debt reduction applies:
  /// - Self-draw by a debtor → ONLY that debtor's debt is halved
  /// - Streak winner is the discarder → ONLY the new winner's debt is halved
  Map<String, int> _settleDebts({
    required String winnerId,
    required bool isSelfDraw,
    String? discarderId,
  }) {
    String? reductionBeneficiary;

    // Condition 1: new winner self-draws AND was a debtor with active debt
    if (isSelfDraw &&
        _columns.containsKey(winnerId) &&
        (_columns[winnerId]?.debt ?? 0) > 0) {
      reductionBeneficiary = winnerId;
    }

    // Condition 2: previous streak winner is the discarder
    if (!isSelfDraw && discarderId == _streakWinnerId) {
      reductionBeneficiary = winnerId;
    }

    final settlement = <String, int>{};
    int totalForStreakWinner = 0;

    for (final entry in _columns.entries) {
      final debtorId = entry.key;
      final debt = entry.value.debt;
      if (debt <= 0) continue;

      int debtToPay = debt;
      if (debtorId == reductionBeneficiary) {
        debtToPay = (debt / 2).round();
      }

      if (debtToPay != 0) {
        settlement[debtorId] = -debtToPay;
        totalForStreakWinner += debtToPay;
      }
    }

    if (totalForStreakWinner != 0) {
      settlement[_streakWinnerId!] =
          (settlement[_streakWinnerId!] ?? 0) + totalForStreakWinner;
    }

    return settlement;
  }

  /// Get players eligible for the stop rule (逼停).
  ///
  /// A player is eligible when their mark count reaches a NEW multiple
  /// of 3 (3, 6, 9, 12, …) that hasn't been offered yet.
  /// [lastAskedAt] tracks the last threshold where the player was offered,
  /// preventing re-asking at the same threshold.
  Map<String, int> _getStopEligible() {
    final eligible = <String, int>{};
    for (final entry in _columns.entries) {
      final col = entry.value;
      if (col.debt <= 0) continue;
      if (col.marks >= 3 &&
          col.marks % 3 == 0 &&
          col.marks > col.lastAskedAt) {
        eligible[entry.key] = col.marks;
      }
    }
    return eligible;
  }
}

/// Internal column data for a single debtor within a La streak.
class _LaColumn {
  /// Compounded debt amount (always >= 0).
  int debt;

  /// Number of rounds this player has lost to the streak winner.
  int marks;

  /// The mark count at which the stop rule was last offered.
  /// Prevents re-asking at the same threshold.
  int lastAskedAt;

  _LaColumn({this.debt = 0, this.marks = 0, this.lastAskedAt = 0});
}

/// Result of applying La settlement to a round.
class LaResult {
  /// Score changes after La adjustments.
  /// During a streak this is all zeros (deferred).
  /// When a streak ends, this contains the settlement amounts.
  final Map<String, int> adjustedScoreChanges;

  /// Human-readable descriptions of La adjustments applied.
  final List<String> descriptions;

  /// Players eligible for the stop rule, with their consecutive loss count.
  /// Empty if no player is eligible.
  final Map<String, int> stopEligible;

  const LaResult({
    required this.adjustedScoreChanges,
    required this.descriptions,
    this.stopEligible = const {},
  });
}
