import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/models/achievement.dart';
import 'package:flutter_application_1/models/game_mode.dart';
import 'package:flutter_application_1/utils/achievement_checker.dart';

void main() {
  // ── Helper ──────────────────────────────────────────────────────

  /// Shorthand: run the checker with fresh state + one round context.
  CheckResult runCheck({
    AchievementCounters counters = const AchievementCounters(),
    Map<String, AchievementProgress> progress = const {},
    required RoundContext ctx,
  }) {
    return AchievementChecker.check(
      oldCounters: counters,
      oldProgress: progress,
      ctx: ctx,
    );
  }

  const hkCtx = RoundContext(gameMode: GameMode.hongKong, playerId: 'Alice');
  const twCtx = RoundContext(gameMode: GameMode.taiwan, playerId: 'Alice');

  // ── Counter updates ────────────────────────────────────────────

  group('Counter updates - general', () {
    test('totalGames increments by 1 per round', () {
      final r = runCheck(ctx: hkCtx);
      expect(r.counters.totalGames, equals(1));

      final r2 = AchievementChecker.check(
        oldCounters: r.counters,
        oldProgress: r.progress,
        ctx: hkCtx,
      );
      expect(r2.counters.totalGames, equals(2));
    });

    test('totalWins increments on win', () {
      final r = runCheck(
        ctx: const RoundContext(
          gameMode: GameMode.hongKong,
          playerId: 'Alice',
          isWinner: true,
        ),
      );
      expect(r.counters.totalWins, equals(1));
    });

    test('totalWins does not increment on loss', () {
      final r = runCheck(ctx: hkCtx);
      expect(r.counters.totalWins, equals(0));
    });

    test('totalSelfDrawn increments on self-draw win', () {
      final r = runCheck(
        ctx: const RoundContext(
          gameMode: GameMode.hongKong,
          playerId: 'Alice',
          isWinner: true,
          isSelfDraw: true,
        ),
      );
      expect(r.counters.totalSelfDrawn, equals(1));
    });

    test('totalDealerWins increments when dealer wins', () {
      final r = runCheck(
        ctx: const RoundContext(
          gameMode: GameMode.hongKong,
          playerId: 'Alice',
          isWinner: true,
          isDealer: true,
        ),
      );
      expect(r.counters.totalDealerWins, equals(1));
    });

    test('totalFangChong increments on dealt in', () {
      final r = runCheck(
        ctx: const RoundContext(
          gameMode: GameMode.hongKong,
          playerId: 'Alice',
          dealtIn: true,
        ),
      );
      expect(r.counters.totalFangChong, equals(1));
    });

    test('consecutive wins track correctly', () {
      // Win round 1
      var r = runCheck(
        ctx: const RoundContext(
          gameMode: GameMode.hongKong,
          playerId: 'Alice',
          isWinner: true,
        ),
      );
      expect(r.counters.currentConsecutiveWins, equals(1));
      expect(r.counters.maxConsecutiveWins, equals(1));

      // Win round 2
      r = AchievementChecker.check(
        oldCounters: r.counters,
        oldProgress: r.progress,
        ctx: const RoundContext(
          gameMode: GameMode.hongKong,
          playerId: 'Alice',
          isWinner: true,
        ),
      );
      expect(r.counters.currentConsecutiveWins, equals(2));
      expect(r.counters.maxConsecutiveWins, equals(2));

      // Lose round 3
      r = AchievementChecker.check(
        oldCounters: r.counters,
        oldProgress: r.progress,
        ctx: hkCtx,
      );
      expect(r.counters.currentConsecutiveWins, equals(0));
      expect(r.counters.maxConsecutiveWins, equals(2)); // max preserved
    });

    test('scoreChange adds to totalScore', () {
      final r = runCheck(
        ctx: const RoundContext(
          gameMode: GameMode.hongKong,
          playerId: 'Alice',
          scoreChange: 100,
        ),
      );
      expect(r.counters.totalScore, equals(100));
    });

    test('negative score change subtracts', () {
      final r = runCheck(
        counters: const AchievementCounters(totalScore: 500),
        ctx: const RoundContext(
          gameMode: GameMode.hongKong,
          playerId: 'Alice',
          scoreChange: -200,
        ),
      );
      expect(r.counters.totalScore, equals(300));
    });
  });

  group('Counter updates - HK specific', () {
    test('hkGames increments in HK mode', () {
      final r = runCheck(ctx: hkCtx);
      expect(r.counters.hkGames, equals(1));
      expect(r.counters.twGames, equals(0));
    });

    test('hkMaxFan updates on higher fan', () {
      final r = runCheck(
        ctx: const RoundContext(
          gameMode: GameMode.hongKong,
          playerId: 'Alice',
          isWinner: true,
          fanCount: 8,
        ),
      );
      expect(r.counters.hkMaxFan, equals(8));
    });

    test('hkMaxFan does not decrease', () {
      final r = runCheck(
        counters: const AchievementCounters(hkMaxFan: 10),
        ctx: const RoundContext(
          gameMode: GameMode.hongKong,
          playerId: 'Alice',
          isWinner: true,
          fanCount: 5,
        ),
      );
      expect(r.counters.hkMaxFan, equals(10));
    });

    test('hk pattern counters increment on pattern match', () {
      final r = runCheck(
        ctx: const RoundContext(
          gameMode: GameMode.hongKong,
          playerId: 'Alice',
          isWinner: true,
          patterns: {'allPongs', 'concealedHand'},
        ),
      );
      expect(r.counters.hkAllPongs, equals(1));
      expect(r.counters.hkConcealedHand, equals(1));
      expect(r.counters.hkAllOneSuit, equals(0));
    });

    test('all HK patterns track correctly', () {
      final r = runCheck(
        ctx: const RoundContext(
          gameMode: GameMode.hongKong,
          playerId: 'Alice',
          isWinner: true,
          patterns: {
            'bigThreeDragons',
            'bigFourWinds',
            'thirteenOrphans',
            'nineGates',
            'lastTileWin',
            'robbingKong',
            'allOneSuit',
          },
        ),
      );
      expect(r.counters.hkBigThreeDragons, equals(1));
      expect(r.counters.hkBigFourWinds, equals(1));
      expect(r.counters.hkThirteenOrphans, equals(1));
      expect(r.counters.hkNineGates, equals(1));
      expect(r.counters.hkLastTileWin, equals(1));
      expect(r.counters.hkRobbingKong, equals(1));
      expect(r.counters.hkAllOneSuit, equals(1));
    });
  });

  group('Counter updates - TW specific', () {
    test('twGames increments in TW mode', () {
      final r = runCheck(ctx: twCtx);
      expect(r.counters.twGames, equals(1));
      expect(r.counters.hkGames, equals(0));
    });

    test('twMaxTai updates on higher tai', () {
      final r = runCheck(
        ctx: const RoundContext(
          gameMode: GameMode.taiwan,
          playerId: 'Alice',
          isWinner: true,
          taiCount: 15,
        ),
      );
      expect(r.counters.twMaxTai, equals(15));
    });

    test('all TW patterns track correctly', () {
      final r = runCheck(
        ctx: const RoundContext(
          gameMode: GameMode.taiwan,
          playerId: 'Alice',
          isWinner: true,
          patterns: {
            'commonHand',
            'concealedSelfDrawn',
            'kongWin',
            'flowerWin',
            'sevenRobOne',
            'heavenlyListen',
            'chickenHand',
            'likuliku',
          },
        ),
      );
      expect(r.counters.twCommonHand, equals(1));
      expect(r.counters.twConcealedSelfDrawn, equals(1));
      expect(r.counters.twKongWin, equals(1));
      expect(r.counters.twFlowerWin, equals(1));
      expect(r.counters.twSevenRobOne, equals(1));
      expect(r.counters.twHeavenlyListen, equals(1));
      expect(r.counters.twChickenHand, equals(1));
      expect(r.counters.twLikuliku, equals(1));
    });
  });

  // ── Achievement unlocking ──────────────────────────────────────

  group('General achievements - unlocking', () {
    test('gen_first_game unlocks on first round', () {
      final r = runCheck(ctx: hkCtx);
      expect(r.newlyUnlocked, contains('gen_first_game'));
    });

    test('gen_first_game does not unlock twice', () {
      final r = runCheck(ctx: hkCtx);
      final r2 = AchievementChecker.check(
        oldCounters: r.counters,
        oldProgress: r.progress,
        ctx: hkCtx,
      );
      expect(r2.newlyUnlocked, isNot(contains('gen_first_game')));
    });

    test('gen_first_win unlocks on first win', () {
      final r = runCheck(
        ctx: const RoundContext(
          gameMode: GameMode.hongKong,
          playerId: 'Alice',
          isWinner: true,
        ),
      );
      expect(r.newlyUnlocked, contains('gen_first_win'));
    });

    test('gen_ten_games unlocks at 10 games', () {
      var counters = const AchievementCounters(totalGames: 9);
      final r = runCheck(counters: counters, ctx: hkCtx);
      expect(r.counters.totalGames, equals(10));
      expect(r.newlyUnlocked, contains('gen_ten_games'));
    });

    test('gen_hundred_games unlocks at 100 games', () {
      var counters = const AchievementCounters(totalGames: 99);
      final r = runCheck(counters: counters, ctx: hkCtx);
      expect(r.counters.totalGames, equals(100));
      expect(r.newlyUnlocked, contains('gen_hundred_games'));
    });

    test('gen_win_streak_3 unlocks at 3 consecutive wins', () {
      var counters = const AchievementCounters(currentConsecutiveWins: 2);
      final r = runCheck(
        counters: counters,
        ctx: const RoundContext(
          gameMode: GameMode.hongKong,
          playerId: 'Alice',
          isWinner: true,
        ),
      );
      expect(r.counters.maxConsecutiveWins, equals(3));
      expect(r.newlyUnlocked, contains('gen_win_streak_3'));
    });

    test('gen_win_streak_5 unlocks at 5 consecutive wins', () {
      var counters = const AchievementCounters(
        currentConsecutiveWins: 4,
        maxConsecutiveWins: 4,
      );
      final r = runCheck(
        counters: counters,
        ctx: const RoundContext(
          gameMode: GameMode.hongKong,
          playerId: 'Alice',
          isWinner: true,
        ),
      );
      expect(r.counters.maxConsecutiveWins, equals(5));
      expect(r.newlyUnlocked, contains('gen_win_streak_5'));
    });

    test('gen_self_draw_10 unlocks at 10 self draws', () {
      var counters = const AchievementCounters(totalSelfDrawn: 9);
      final r = runCheck(
        counters: counters,
        ctx: const RoundContext(
          gameMode: GameMode.hongKong,
          playerId: 'Alice',
          isWinner: true,
          isSelfDraw: true,
        ),
      );
      expect(r.newlyUnlocked, contains('gen_self_draw_10'));
    });

    test('gen_self_draw_50 unlocks at 50 self draws', () {
      var counters = const AchievementCounters(totalSelfDrawn: 49);
      final r = runCheck(
        counters: counters,
        ctx: const RoundContext(
          gameMode: GameMode.hongKong,
          playerId: 'Alice',
          isWinner: true,
          isSelfDraw: true,
        ),
      );
      expect(r.newlyUnlocked, contains('gen_self_draw_50'));
    });

    test('gen_dealer_streak_3 unlocks at 3 consecutive dealer rounds', () {
      final r = runCheck(
        ctx: const RoundContext(
          gameMode: GameMode.hongKong,
          playerId: 'Alice',
          consecutiveDealerCount: 3,
        ),
      );
      expect(r.counters.maxConsecutiveDealer, equals(3));
      expect(r.newlyUnlocked, contains('gen_dealer_streak_3'));
    });

    test('gen_comeback unlocks on last-to-first in final round', () {
      final r = runCheck(
        ctx: const RoundContext(
          gameMode: GameMode.hongKong,
          playerId: 'Alice',
          isLastRound: true,
          wasLastPlace: true,
          isNowFirstPlace: true,
        ),
      );
      expect(r.newlyUnlocked, contains('gen_comeback'));
    });

    test('gen_comeback does NOT unlock if not last round', () {
      final r = runCheck(
        ctx: const RoundContext(
          gameMode: GameMode.hongKong,
          playerId: 'Alice',
          isLastRound: false,
          wasLastPlace: true,
          isNowFirstPlace: true,
        ),
      );
      expect(r.newlyUnlocked, isNot(contains('gen_comeback')));
    });
  });

  group('HK achievements - unlocking', () {
    test('hk_first_win unlocks on first HK win', () {
      final r = runCheck(
        ctx: const RoundContext(
          gameMode: GameMode.hongKong,
          playerId: 'Alice',
          isWinner: true,
        ),
      );
      expect(r.newlyUnlocked, contains('hk_first_win'));
    });

    test('hk_first_win does NOT unlock in TW mode', () {
      final r = runCheck(
        ctx: const RoundContext(
          gameMode: GameMode.taiwan,
          playerId: 'Alice',
          isWinner: true,
        ),
      );
      expect(r.newlyUnlocked, isNot(contains('hk_first_win')));
    });

    test('hk_fan_3 unlocks when max fan >= 3', () {
      final r = runCheck(
        ctx: const RoundContext(
          gameMode: GameMode.hongKong,
          playerId: 'Alice',
          isWinner: true,
          fanCount: 3,
        ),
      );
      expect(r.newlyUnlocked, contains('hk_fan_3'));
    });

    test('hk_big_three_dragons unlocks on pattern', () {
      final r = runCheck(
        ctx: const RoundContext(
          gameMode: GameMode.hongKong,
          playerId: 'Alice',
          isWinner: true,
          patterns: {'bigThreeDragons'},
          fanCount: 13,
        ),
      );
      expect(r.newlyUnlocked, contains('hk_big_three_dragons'));
    });

    test('hk_thirteen_orphans unlocks on pattern', () {
      final r = runCheck(
        ctx: const RoundContext(
          gameMode: GameMode.hongKong,
          playerId: 'Alice',
          isWinner: true,
          patterns: {'thirteenOrphans'},
          fanCount: 13,
        ),
      );
      expect(r.newlyUnlocked, contains('hk_thirteen_orphans'));
    });

    test('hk_nine_gates unlocks on pattern', () {
      final r = runCheck(
        ctx: const RoundContext(
          gameMode: GameMode.hongKong,
          playerId: 'Alice',
          isWinner: true,
          patterns: {'nineGates'},
          fanCount: 13,
        ),
      );
      expect(r.newlyUnlocked, contains('hk_nine_gates'));
    });

    test('hk_max_fan unlocks at maxFan', () {
      final r = runCheck(
        ctx: const RoundContext(
          gameMode: GameMode.hongKong,
          playerId: 'Alice',
          isWinner: true,
          fanCount: 13,
          maxFan: 13,
        ),
      );
      expect(r.newlyUnlocked, contains('hk_max_fan'));
    });

    test('hk_max_fan does NOT unlock below max', () {
      final r = runCheck(
        ctx: const RoundContext(
          gameMode: GameMode.hongKong,
          playerId: 'Alice',
          isWinner: true,
          fanCount: 10,
          maxFan: 13,
        ),
      );
      expect(r.newlyUnlocked, isNot(contains('hk_max_fan')));
    });

    test('hk_all_pongs_5 unlocks at 5 all-pong wins', () {
      var counters = const AchievementCounters(hkAllPongs: 4);
      final r = runCheck(
        counters: counters,
        ctx: const RoundContext(
          gameMode: GameMode.hongKong,
          playerId: 'Alice',
          isWinner: true,
          patterns: {'allPongs'},
        ),
      );
      expect(r.counters.hkAllPongs, equals(5));
      expect(r.newlyUnlocked, contains('hk_all_pongs_5'));
    });

    test('hk_concealed_hand_10 unlocks at 10', () {
      var counters = const AchievementCounters(hkConcealedHand: 9);
      final r = runCheck(
        counters: counters,
        ctx: const RoundContext(
          gameMode: GameMode.hongKong,
          playerId: 'Alice',
          isWinner: true,
          patterns: {'concealedHand'},
        ),
      );
      expect(r.counters.hkConcealedHand, equals(10));
      expect(r.newlyUnlocked, contains('hk_concealed_hand_10'));
    });

    test('hk_last_tile_win unlocks on pattern', () {
      final r = runCheck(
        ctx: const RoundContext(
          gameMode: GameMode.hongKong,
          playerId: 'Alice',
          isWinner: true,
          patterns: {'lastTileWin'},
        ),
      );
      expect(r.newlyUnlocked, contains('hk_last_tile_win'));
    });

    test('hk_robbing_kong unlocks on pattern', () {
      final r = runCheck(
        ctx: const RoundContext(
          gameMode: GameMode.hongKong,
          playerId: 'Alice',
          isWinner: true,
          patterns: {'robbingKong'},
        ),
      );
      expect(r.newlyUnlocked, contains('hk_robbing_kong'));
    });

    test('hk_full_flush unlocks on allOneSuit', () {
      final r = runCheck(
        ctx: const RoundContext(
          gameMode: GameMode.hongKong,
          playerId: 'Alice',
          isWinner: true,
          patterns: {'allOneSuit'},
        ),
      );
      expect(r.newlyUnlocked, contains('hk_full_flush'));
    });
  });

  group('TW achievements - unlocking', () {
    test('tw_first_win unlocks on first TW win', () {
      final r = runCheck(
        ctx: const RoundContext(
          gameMode: GameMode.taiwan,
          playerId: 'Alice',
          isWinner: true,
        ),
      );
      expect(r.newlyUnlocked, contains('tw_first_win'));
    });

    test('tw_first_win does NOT unlock in HK mode', () {
      final r = runCheck(
        ctx: const RoundContext(
          gameMode: GameMode.hongKong,
          playerId: 'Alice',
          isWinner: true,
        ),
      );
      expect(r.newlyUnlocked, isNot(contains('tw_first_win')));
    });

    test('tw_tai_10 unlocks at 10 tai', () {
      final r = runCheck(
        ctx: const RoundContext(
          gameMode: GameMode.taiwan,
          playerId: 'Alice',
          isWinner: true,
          taiCount: 10,
        ),
      );
      expect(r.newlyUnlocked, contains('tw_tai_10'));
    });

    test('tw_tai_30 unlocks at 30 tai', () {
      final r = runCheck(
        ctx: const RoundContext(
          gameMode: GameMode.taiwan,
          playerId: 'Alice',
          isWinner: true,
          taiCount: 30,
        ),
      );
      expect(r.newlyUnlocked, contains('tw_tai_30'));
    });

    test('tw_tai_80 unlocks at 80 tai', () {
      final r = runCheck(
        ctx: const RoundContext(
          gameMode: GameMode.taiwan,
          playerId: 'Alice',
          isWinner: true,
          taiCount: 80,
        ),
      );
      expect(r.newlyUnlocked, contains('tw_tai_80'));
    });

    test('tw_common_hand_10 unlocks at 10 common hands', () {
      var counters = const AchievementCounters(twCommonHand: 9);
      final r = runCheck(
        counters: counters,
        ctx: const RoundContext(
          gameMode: GameMode.taiwan,
          playerId: 'Alice',
          isWinner: true,
          patterns: {'commonHand'},
        ),
      );
      expect(r.newlyUnlocked, contains('tw_common_hand_10'));
    });

    test('tw_concealed_self_drawn_5 unlocks at 5', () {
      var counters = const AchievementCounters(twConcealedSelfDrawn: 4);
      final r = runCheck(
        counters: counters,
        ctx: const RoundContext(
          gameMode: GameMode.taiwan,
          playerId: 'Alice',
          isWinner: true,
          patterns: {'concealedSelfDrawn'},
        ),
      );
      expect(r.newlyUnlocked, contains('tw_concealed_self_drawn_5'));
    });

    test('tw_dealer_streak_5 unlocks at 5 consecutive dealer', () {
      final r = runCheck(
        ctx: const RoundContext(
          gameMode: GameMode.taiwan,
          playerId: 'Alice',
          consecutiveDealerCount: 5,
        ),
      );
      expect(r.newlyUnlocked, contains('tw_dealer_streak_5'));
    });

    test('tw_kong_win unlocks on kongWin pattern', () {
      final r = runCheck(
        ctx: const RoundContext(
          gameMode: GameMode.taiwan,
          playerId: 'Alice',
          isWinner: true,
          patterns: {'kongWin'},
        ),
      );
      expect(r.newlyUnlocked, contains('tw_kong_win'));
    });

    test('tw_flower_win unlocks on flowerWin pattern', () {
      final r = runCheck(
        ctx: const RoundContext(
          gameMode: GameMode.taiwan,
          playerId: 'Alice',
          isWinner: true,
          patterns: {'flowerWin'},
        ),
      );
      expect(r.newlyUnlocked, contains('tw_flower_win'));
    });

    test('tw_seven_rob_one unlocks on sevenRobOne', () {
      final r = runCheck(
        ctx: const RoundContext(
          gameMode: GameMode.taiwan,
          playerId: 'Alice',
          isWinner: true,
          patterns: {'sevenRobOne'},
        ),
      );
      expect(r.newlyUnlocked, contains('tw_seven_rob_one'));
    });

    test('tw_heavenly_listen unlocks on heavenlyListen', () {
      final r = runCheck(
        ctx: const RoundContext(
          gameMode: GameMode.taiwan,
          playerId: 'Alice',
          isWinner: true,
          patterns: {'heavenlyListen'},
        ),
      );
      expect(r.newlyUnlocked, contains('tw_heavenly_listen'));
    });

    test('tw_chicken_hand_10 unlocks at 10', () {
      var counters = const AchievementCounters(twChickenHand: 9);
      final r = runCheck(
        counters: counters,
        ctx: const RoundContext(
          gameMode: GameMode.taiwan,
          playerId: 'Alice',
          isWinner: true,
          patterns: {'chickenHand'},
        ),
      );
      expect(r.newlyUnlocked, contains('tw_chicken_hand_10'));
    });

    test('tw_likuliku unlocks on likuliku pattern', () {
      final r = runCheck(
        ctx: const RoundContext(
          gameMode: GameMode.taiwan,
          playerId: 'Alice',
          isWinner: true,
          patterns: {'likuliku'},
        ),
      );
      expect(r.newlyUnlocked, contains('tw_likuliku'));
    });
  });

  group('Milestone achievements - unlocking', () {
    test('ms_wins_100 unlocks at 100 total wins', () {
      var counters = const AchievementCounters(totalWins: 99);
      final r = runCheck(
        counters: counters,
        ctx: const RoundContext(
          gameMode: GameMode.hongKong,
          playerId: 'Alice',
          isWinner: true,
        ),
      );
      expect(r.newlyUnlocked, contains('ms_wins_100'));
    });

    test('ms_wins_500 unlocks at 500 total wins', () {
      var counters = const AchievementCounters(totalWins: 499);
      final r = runCheck(
        counters: counters,
        ctx: const RoundContext(
          gameMode: GameMode.hongKong,
          playerId: 'Alice',
          isWinner: true,
        ),
      );
      expect(r.newlyUnlocked, contains('ms_wins_500'));
    });

    test('ms_score_10000 unlocks at 10000 score', () {
      var counters = const AchievementCounters(totalScore: 9900);
      final r = runCheck(
        counters: counters,
        ctx: const RoundContext(
          gameMode: GameMode.hongKong,
          playerId: 'Alice',
          scoreChange: 100,
        ),
      );
      expect(r.counters.totalScore, equals(10000));
      expect(r.newlyUnlocked, contains('ms_score_10000'));
    });

    test('ms_score_100000 unlocks at 100000 score', () {
      var counters = const AchievementCounters(totalScore: 99990);
      final r = runCheck(
        counters: counters,
        ctx: const RoundContext(
          gameMode: GameMode.hongKong,
          playerId: 'Alice',
          scoreChange: 10,
        ),
      );
      expect(r.newlyUnlocked, contains('ms_score_100000'));
    });

    test('ms_dual_mode unlocks when both modes >= 10 games', () {
      var counters = const AchievementCounters(hkGames: 10, twGames: 9);
      final r = runCheck(
        counters: counters,
        ctx: const RoundContext(gameMode: GameMode.taiwan, playerId: 'Alice'),
      );
      expect(r.counters.twGames, equals(10));
      expect(r.newlyUnlocked, contains('ms_dual_mode'));
    });

    test('ms_dual_mode does NOT unlock when only one mode has enough', () {
      var counters = const AchievementCounters(hkGames: 10, twGames: 5);
      final r = runCheck(
        counters: counters,
        ctx: const RoundContext(gameMode: GameMode.taiwan, playerId: 'Alice'),
      );
      expect(r.newlyUnlocked, isNot(contains('ms_dual_mode')));
    });
  });

  // ── Progress tracking ──────────────────────────────────────────

  group('Progress tracking', () {
    test('progress updates for all evaluated achievements', () {
      final r = runCheck(ctx: hkCtx);
      // Should have progress entries for all general + HK achievements + milestones
      expect(r.progress.length, greaterThan(0));
    });

    test('unlocked achievement has isUnlocked true', () {
      final r = runCheck(ctx: hkCtx);
      expect(r.progress['gen_first_game']?.isUnlocked, isTrue);
    });

    test('unlocked achievement has unlockedAt set', () {
      final r = runCheck(ctx: hkCtx);
      expect(r.progress['gen_first_game']?.unlockedAt, isNotNull);
    });

    test('not-yet-unlocked achievement has isUnlocked false', () {
      final r = runCheck(ctx: hkCtx);
      expect(r.progress['gen_hundred_games']?.isUnlocked, isFalse);
      expect(
        r.progress['gen_hundred_games']?.progress,
        equals(1),
      ); // 1 total game
    });

    test('progress value is correct for partial achievements', () {
      var counters = const AchievementCounters(totalSelfDrawn: 5);
      final r = runCheck(
        counters: counters,
        ctx: const RoundContext(
          gameMode: GameMode.hongKong,
          playerId: 'Alice',
          isWinner: true,
          isSelfDraw: true,
        ),
      );
      expect(r.progress['gen_self_draw_10']?.progress, equals(6));
    });
  });

  // ── Edge cases ─────────────────────────────────────────────────

  group('Edge cases', () {
    test('already unlocked achievements are skipped', () {
      final now = DateTime.now();
      final preUnlocked = {
        'gen_first_game': AchievementProgress(
          achievementId: 'gen_first_game',
          isUnlocked: true,
          unlockedAt: now,
          progress: 1,
        ),
      };

      final r = runCheck(progress: preUnlocked, ctx: hkCtx);
      // Should NOT appear in newlyUnlocked
      expect(r.newlyUnlocked, isNot(contains('gen_first_game')));
      // But progress entry should still exist
      expect(r.progress['gen_first_game']?.isUnlocked, isTrue);
    });

    test('losing round does not unlock win achievements', () {
      final r = runCheck(ctx: hkCtx);
      expect(r.newlyUnlocked, isNot(contains('gen_first_win')));
      expect(r.newlyUnlocked, isNot(contains('hk_first_win')));
    });

    test('patterns only counted for winners', () {
      // Non-winner with patterns (shouldn't increment)
      final r = runCheck(
        ctx: const RoundContext(
          gameMode: GameMode.hongKong,
          playerId: 'Alice',
          isWinner: false,
          patterns: {'allPongs', 'allOneSuit'},
        ),
      );
      expect(r.counters.hkAllPongs, equals(0));
      expect(r.counters.hkAllOneSuit, equals(0));
    });

    test('multiple achievements can unlock in same round', () {
      // First round, first win, with self-draw in HK mode
      final r = runCheck(
        ctx: const RoundContext(
          gameMode: GameMode.hongKong,
          playerId: 'Alice',
          isWinner: true,
          isSelfDraw: true,
          fanCount: 5,
        ),
      );
      // Should unlock gen_first_game, gen_first_win, hk_first_win, hk_fan_3
      expect(r.newlyUnlocked, contains('gen_first_game'));
      expect(r.newlyUnlocked, contains('gen_first_win'));
      expect(r.newlyUnlocked, contains('hk_first_win'));
      expect(r.newlyUnlocked, contains('hk_fan_3'));
    });
  });

  // ── RoundContext ────────────────────────────────────────────────

  group('RoundContext', () {
    test('default values', () {
      const ctx = RoundContext(gameMode: GameMode.hongKong, playerId: 'Test');
      expect(ctx.isWinner, isFalse);
      expect(ctx.isSelfDraw, isFalse);
      expect(ctx.dealtIn, isFalse);
      expect(ctx.isDealer, isFalse);
      expect(ctx.dealerWon, isFalse);
      expect(ctx.fanCount, isNull);
      expect(ctx.taiCount, isNull);
      expect(ctx.maxFan, equals(13));
      expect(ctx.patterns, isEmpty);
      expect(ctx.scoreChange, equals(0));
      expect(ctx.consecutiveDealerCount, equals(1));
      expect(ctx.roundNumber, equals(1));
      expect(ctx.totalRounds, equals(16));
      expect(ctx.isLastRound, isFalse);
      expect(ctx.wasLastPlace, isFalse);
      expect(ctx.isNowFirstPlace, isFalse);
    });
  });

  group('CheckResult', () {
    test('provides counters, progress, and newlyUnlocked', () {
      final r = runCheck(ctx: hkCtx);
      expect(r.counters, isNotNull);
      expect(r.progress, isNotNull);
      expect(r.newlyUnlocked, isNotNull);
    });
  });
}
