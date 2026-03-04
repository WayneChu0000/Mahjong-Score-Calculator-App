import '../models/achievement.dart';
import '../models/game_mode.dart';
import 'achievement_registry.dart';

/// Data describing what happened in a single round, used by the checker.
class RoundContext {
  /// Game mode of the current session.
  final GameMode gameMode;

  /// Player ID (name) being evaluated.
  final String playerId;

  /// Whether this player won this round.
  final bool isWinner;

  /// Whether the win was self-drawn.
  final bool isSelfDraw;

  /// Whether this player dealt into someone else's win.
  final bool dealtIn;

  /// Whether this player was the dealer this round.
  final bool isDealer;

  /// Whether the dealer won this round (any player).
  final bool dealerWon;

  /// Fan value achieved (HK mode).
  final int? fanCount;

  /// Tai value achieved (TW mode).
  final int? taiCount;

  /// Maximum fan cap for HK (used to detect max-fan wins).
  final int maxFan;

  /// Names of winning patterns/hands detected (e.g. "allOneSuit", "allPongs").
  final Set<String> patterns;

  /// Score change for this player this round (can be negative).
  final int scoreChange;

  /// Current consecutive dealer count (from game state).
  final int consecutiveDealerCount;

  /// The round number just completed.
  final int roundNumber;

  /// Total rounds in the game.
  final int totalRounds;

  /// Is this the final round of the game?
  final bool isLastRound;

  /// Player was in last place before this round.
  final bool wasLastPlace;

  /// Player is now in first place after this round.
  final bool isNowFirstPlace;

  const RoundContext({
    required this.gameMode,
    required this.playerId,
    this.isWinner = false,
    this.isSelfDraw = false,
    this.dealtIn = false,
    this.isDealer = false,
    this.dealerWon = false,
    this.fanCount,
    this.taiCount,
    this.maxFan = 13,
    this.patterns = const {},
    this.scoreChange = 0,
    this.consecutiveDealerCount = 1,
    this.roundNumber = 1,
    this.totalRounds = 16,
    this.isLastRound = false,
    this.wasLastPlace = false,
    this.isNowFirstPlace = false,
  });
}

/// Result of checking achievements after a round.
class CheckResult {
  /// Updated counters.
  final AchievementCounters counters;

  /// Updated progress map (all achievements).
  final Map<String, AchievementProgress> progress;

  /// Newly unlocked achievement IDs this round.
  final List<String> newlyUnlocked;

  const CheckResult({
    required this.counters,
    required this.progress,
    required this.newlyUnlocked,
  });
}

/// Pure-logic checker: given old state + round context, returns new state.
///
/// This class has NO Firebase dependency; it's fully testable.
class AchievementChecker {
  AchievementChecker._();

  /// Main entry point: update counters, evaluate all achievements.
  static CheckResult check({
    required AchievementCounters oldCounters,
    required Map<String, AchievementProgress> oldProgress,
    required RoundContext ctx,
  }) {
    // Step 1: Update raw counters based on what happened.
    final counters = _updateCounters(oldCounters, ctx);

    // Step 2: Evaluate every achievement against the new counters.
    final newlyUnlocked = <String>[];
    final progress = Map<String, AchievementProgress>.from(oldProgress);

    for (final def in AchievementRegistry.all) {
      // Skip if already unlocked.
      final existing = progress[def.id];
      if (existing != null && existing.isUnlocked) continue;

      // Skip achievements that require a different game mode.
      if (def.requiredMode != null && def.requiredMode != ctx.gameMode)
        continue;

      // Evaluate progress.
      final currentValue = _evaluate(def, counters, ctx);
      // Skip externally-managed achievements (return -1 sentinel).
      if (currentValue < 0) continue;
      final reachedTarget = currentValue >= def.target;

      if (reachedTarget) {
        progress[def.id] = AchievementProgress(
          achievementId: def.id,
          isUnlocked: true,
          unlockedAt: DateTime.now(),
          progress: currentValue,
        );
        newlyUnlocked.add(def.id);
      } else {
        progress[def.id] = AchievementProgress(
          achievementId: def.id,
          isUnlocked: false,
          progress: currentValue,
        );
      }
    }

    return CheckResult(
      counters: counters,
      progress: progress,
      newlyUnlocked: newlyUnlocked,
    );
  }

  // ── Counter update ───────────────────────────────────────────────

  static AchievementCounters _updateCounters(
    AchievementCounters c,
    RoundContext ctx,
  ) {
    int newConsecutiveWins = ctx.isWinner ? c.currentConsecutiveWins + 1 : 0;
    int newMaxConsecutiveWins = newConsecutiveWins > c.maxConsecutiveWins
        ? newConsecutiveWins
        : c.maxConsecutiveWins;

    var updated = c.copyWith(
      totalGames: c.totalGames + 1,
      totalWins: c.totalWins + (ctx.isWinner ? 1 : 0),
      totalSelfDrawn:
          c.totalSelfDrawn + (ctx.isWinner && ctx.isSelfDraw ? 1 : 0),
      totalDealerWins:
          c.totalDealerWins + (ctx.isDealer && ctx.isWinner ? 1 : 0),
      totalFangChong: c.totalFangChong + (ctx.dealtIn ? 1 : 0),
      currentConsecutiveWins: newConsecutiveWins,
      maxConsecutiveWins: newMaxConsecutiveWins,
      maxConsecutiveDealer: ctx.consecutiveDealerCount > c.maxConsecutiveDealer
          ? ctx.consecutiveDealerCount
          : c.maxConsecutiveDealer,
      totalScore: c.totalScore + ctx.scoreChange,
    );

    // Mode-specific counters
    if (ctx.gameMode == GameMode.hongKong) {
      updated = updated.copyWith(
        hkGames: c.hkGames + 1,
        hkWins: c.hkWins + (ctx.isWinner ? 1 : 0),
        hkMaxFan: (ctx.fanCount ?? 0) > c.hkMaxFan
            ? (ctx.fanCount ?? 0)
            : c.hkMaxFan,
        hkConcealedHand:
            c.hkConcealedHand +
            (ctx.isWinner && ctx.patterns.contains('concealedHand') ? 1 : 0),
        hkAllOneSuit:
            c.hkAllOneSuit +
            (ctx.isWinner && ctx.patterns.contains('allOneSuit') ? 1 : 0),
        hkAllPongs:
            c.hkAllPongs +
            (ctx.isWinner && ctx.patterns.contains('allPongs') ? 1 : 0),
        hkBigThreeDragons:
            c.hkBigThreeDragons +
            (ctx.isWinner && ctx.patterns.contains('bigThreeDragons') ? 1 : 0),
        hkBigFourWinds:
            c.hkBigFourWinds +
            (ctx.isWinner && ctx.patterns.contains('bigFourWinds') ? 1 : 0),
        hkThirteenOrphans:
            c.hkThirteenOrphans +
            (ctx.isWinner && ctx.patterns.contains('thirteenOrphans') ? 1 : 0),
        hkNineGates:
            c.hkNineGates +
            (ctx.isWinner && ctx.patterns.contains('nineGates') ? 1 : 0),
        hkLastTileWin:
            c.hkLastTileWin +
            (ctx.isWinner && ctx.patterns.contains('lastTileWin') ? 1 : 0),
        hkRobbingKong:
            c.hkRobbingKong +
            (ctx.isWinner && ctx.patterns.contains('robbingKong') ? 1 : 0),
      );
    } else if (ctx.gameMode == GameMode.taiwan) {
      updated = updated.copyWith(
        twGames: c.twGames + 1,
        twWins: c.twWins + (ctx.isWinner ? 1 : 0),
        twMaxTai: (ctx.taiCount ?? 0) > c.twMaxTai
            ? (ctx.taiCount ?? 0)
            : c.twMaxTai,
        twCommonHand:
            c.twCommonHand +
            (ctx.isWinner && ctx.patterns.contains('commonHand') ? 1 : 0),
        twConcealedSelfDrawn:
            c.twConcealedSelfDrawn +
            (ctx.isWinner && ctx.patterns.contains('concealedSelfDrawn')
                ? 1
                : 0),
        twMaxConsecutiveDealer:
            ctx.consecutiveDealerCount > c.twMaxConsecutiveDealer
            ? ctx.consecutiveDealerCount
            : c.twMaxConsecutiveDealer,
        twKongWin:
            c.twKongWin +
            (ctx.isWinner && ctx.patterns.contains('kongWin') ? 1 : 0),
        twFlowerWin:
            c.twFlowerWin +
            (ctx.isWinner && ctx.patterns.contains('flowerWin') ? 1 : 0),
        twSevenRobOne:
            c.twSevenRobOne +
            (ctx.isWinner && ctx.patterns.contains('sevenRobOne') ? 1 : 0),
        twHeavenlyListen:
            c.twHeavenlyListen +
            (ctx.isWinner && ctx.patterns.contains('heavenlyListen') ? 1 : 0),
        twChickenHand:
            c.twChickenHand +
            (ctx.isWinner && ctx.patterns.contains('chickenHand') ? 1 : 0),
        twLikuliku:
            c.twLikuliku +
            (ctx.isWinner && ctx.patterns.contains('likuliku') ? 1 : 0),
      );
    }

    return updated;
  }

  // ── Evaluate a single achievement ────────────────────────────────

  /// Returns the current progress value toward `def.target`.
  static int _evaluate(
    AchievementDef def,
    AchievementCounters c,
    RoundContext ctx,
  ) {
    switch (def.id) {
      // ── General ────────────────────────────────────────────────
      case 'gen_first_game':
        return c.totalGames >= 1 ? 1 : 0;
      case 'gen_ten_games':
        return c.totalGames;
      case 'gen_hundred_games':
        return c.totalGames;
      case 'gen_first_win':
        return c.totalWins >= 1 ? 1 : 0;
      case 'gen_win_streak_3':
        return c.maxConsecutiveWins;
      case 'gen_win_streak_5':
        return c.maxConsecutiveWins;
      case 'gen_self_draw_10':
        return c.totalSelfDrawn;
      case 'gen_self_draw_50':
        return c.totalSelfDrawn;
      case 'gen_dealer_streak_3':
        return c.maxConsecutiveDealer;
      case 'gen_never_deal_in':
        // Unlocks when a full game is completed with zero deal-ins.
        // We use a special flag: if the game just ended and totalFangChong is 0.
        if (ctx.isLastRound && c.totalFangChong == 0 && c.totalGames >= 16) {
          return 1;
        }
        return 0;
      case 'gen_comeback':
        return (ctx.isLastRound && ctx.wasLastPlace && ctx.isNowFirstPlace)
            ? 1
            : 0;

      // ── HK ─────────────────────────────────────────────────────
      case 'hk_first_win':
        return c.hkWins >= 1 ? 1 : 0;
      case 'hk_fan_3':
        return c.hkMaxFan >= 3 ? 1 : 0;
      case 'hk_full_flush':
        return c.hkAllOneSuit >= 1 ? 1 : 0;
      case 'hk_all_pongs_5':
        return c.hkAllPongs;
      case 'hk_big_three_dragons':
        return c.hkBigThreeDragons >= 1 ? 1 : 0;
      case 'hk_big_four_winds':
        return c.hkBigFourWinds >= 1 ? 1 : 0;
      case 'hk_thirteen_orphans':
        return c.hkThirteenOrphans >= 1 ? 1 : 0;
      case 'hk_nine_gates':
        return c.hkNineGates >= 1 ? 1 : 0;
      case 'hk_concealed_hand_10':
        return c.hkConcealedHand;
      case 'hk_last_tile_win':
        return c.hkLastTileWin >= 1 ? 1 : 0;
      case 'hk_robbing_kong':
        return c.hkRobbingKong >= 1 ? 1 : 0;
      case 'hk_max_fan':
        return c.hkMaxFan >= ctx.maxFan ? 1 : 0;

      // ── TW ─────────────────────────────────────────────────────
      case 'tw_first_win':
        return c.twWins >= 1 ? 1 : 0;
      case 'tw_tai_10':
        return c.twMaxTai >= 10 ? 1 : 0;
      case 'tw_tai_30':
        return c.twMaxTai >= 30 ? 1 : 0;
      case 'tw_tai_80':
        return c.twMaxTai >= 80 ? 1 : 0;
      case 'tw_common_hand_10':
        return c.twCommonHand;
      case 'tw_concealed_self_drawn_5':
        return c.twConcealedSelfDrawn;
      case 'tw_dealer_streak_5':
        return c.twMaxConsecutiveDealer;
      case 'tw_kong_win':
        return c.twKongWin >= 1 ? 1 : 0;
      case 'tw_flower_win':
        return c.twFlowerWin >= 1 ? 1 : 0;
      case 'tw_seven_rob_one':
        return c.twSevenRobOne >= 1 ? 1 : 0;
      case 'tw_heavenly_listen':
        return c.twHeavenlyListen >= 1 ? 1 : 0;
      case 'tw_chicken_hand_10':
        return c.twChickenHand;
      case 'tw_likuliku':
        return c.twLikuliku >= 1 ? 1 : 0;
      // Instant-payment achievements are tracked directly in the UI,
      // not via counters. Return existing progress so the checker
      // never accidentally resets them.
      case 'tw_instant_pay_5':
      case 'tw_instant_pay_20':
        return -1; // sentinel: skip evaluation

      // ── Milestones ─────────────────────────────────────────────
      case 'ms_wins_100':
        return c.totalWins;
      case 'ms_wins_500':
        return c.totalWins;
      case 'ms_score_10000':
        return c.totalScore;
      case 'ms_score_100000':
        return c.totalScore;
      case 'ms_dual_mode':
        return (c.hkGames >= 10 && c.twGames >= 10) ? 1 : 0;

      default:
        return 0;
    }
  }
}
