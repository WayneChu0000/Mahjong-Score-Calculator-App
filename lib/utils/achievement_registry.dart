import 'package:flutter/material.dart';
import '../models/achievement.dart';
import '../models/game_mode.dart';

/// Central registry of all achievement definitions.
///
/// Each achievement has a unique [id] that maps to l10n keys
/// `achv_{id}_title` / `achv_{id}_desc`.
class AchievementRegistry {
  AchievementRegistry._();

  // ═════════════════════════════════════════════════════════════════
  //  GENERAL
  // ═════════════════════════════════════════════════════════════════

  static const List<AchievementDef> general = [
    AchievementDef(
      id: 'gen_first_game',
      titleKey: 'achvGenFirstGameTitle',
      descriptionKey: 'achvGenFirstGameDesc',
      category: AchievementCategory.general,
      tier: AchievementTier.bronze,
      iconCodePoint: 0xe51c, // Icons.egg_alt
      target: 1,
    ),
    AchievementDef(
      id: 'gen_ten_games',
      titleKey: 'achvGenTenGamesTitle',
      descriptionKey: 'achvGenTenGamesDesc',
      category: AchievementCategory.general,
      tier: AchievementTier.bronze,
      iconCodePoint: 0xe87d, // Icons.star
      target: 10,
    ),
    AchievementDef(
      id: 'gen_hundred_games',
      titleKey: 'achvGenHundredGamesTitle',
      descriptionKey: 'achvGenHundredGamesDesc',
      category: AchievementCategory.general,
      tier: AchievementTier.gold,
      iconCodePoint: 0xea23, // Icons.military_tech
      target: 100,
    ),
    AchievementDef(
      id: 'gen_first_win',
      titleKey: 'achvGenFirstWinTitle',
      descriptionKey: 'achvGenFirstWinDesc',
      category: AchievementCategory.general,
      tier: AchievementTier.bronze,
      iconCodePoint: 0xe877, // Icons.celebration
      target: 1,
    ),
    AchievementDef(
      id: 'gen_win_streak_3',
      titleKey: 'achvGenWinStreak3Title',
      descriptionKey: 'achvGenWinStreak3Desc',
      category: AchievementCategory.general,
      tier: AchievementTier.silver,
      iconCodePoint: 0xe80e, // Icons.local_fire_department
      target: 3,
    ),
    AchievementDef(
      id: 'gen_win_streak_5',
      titleKey: 'achvGenWinStreak5Title',
      descriptionKey: 'achvGenWinStreak5Desc',
      category: AchievementCategory.general,
      tier: AchievementTier.gold,
      iconCodePoint: 0xe80e, // Icons.local_fire_department
      target: 5,
    ),
    AchievementDef(
      id: 'gen_self_draw_10',
      titleKey: 'achvGenSelfDraw10Title',
      descriptionKey: 'achvGenSelfDraw10Desc',
      category: AchievementCategory.general,
      tier: AchievementTier.silver,
      iconCodePoint: 0xf05b8, // Icons.ads_click
      target: 10,
    ),
    AchievementDef(
      id: 'gen_self_draw_50',
      titleKey: 'achvGenSelfDraw50Title',
      descriptionKey: 'achvGenSelfDraw50Desc',
      category: AchievementCategory.general,
      tier: AchievementTier.gold,
      iconCodePoint: 0xe3af, // Icons.emoji_events
      target: 50,
    ),
    AchievementDef(
      id: 'gen_dealer_streak_3',
      titleKey: 'achvGenDealerStreak3Title',
      descriptionKey: 'achvGenDealerStreak3Desc',
      category: AchievementCategory.general,
      tier: AchievementTier.silver,
      iconCodePoint: 0xe943, // Icons.castle
      target: 3,
    ),
    AchievementDef(
      id: 'gen_never_deal_in',
      titleKey: 'achvGenNeverDealInTitle',
      descriptionKey: 'achvGenNeverDealInDesc',
      category: AchievementCategory.general,
      tier: AchievementTier.silver,
      iconCodePoint: 0xe9e0, // Icons.shield
      target: 1,
    ),
    AchievementDef(
      id: 'gen_comeback',
      titleKey: 'achvGenComebackTitle',
      descriptionKey: 'achvGenComebackDesc',
      category: AchievementCategory.general,
      tier: AchievementTier.gold,
      iconCodePoint: 0xe863, // Icons.swap_vert
      target: 1,
    ),
  ];

  // ═════════════════════════════════════════════════════════════════
  //  HONG KONG
  // ═════════════════════════════════════════════════════════════════

  static const List<AchievementDef> hk = [
    AchievementDef(
      id: 'hk_first_win',
      titleKey: 'achvHkFirstWinTitle',
      descriptionKey: 'achvHkFirstWinDesc',
      category: AchievementCategory.hk,
      tier: AchievementTier.bronze,
      iconCodePoint: 0xe332, // Icons.filter_1
      target: 1,
      requiredMode: GameMode.hongKong,
    ),
    AchievementDef(
      id: 'hk_fan_3',
      titleKey: 'achvHkFan3Title',
      descriptionKey: 'achvHkFan3Desc',
      category: AchievementCategory.hk,
      tier: AchievementTier.bronze,
      iconCodePoint: 0xe335, // Icons.filter_3
      target: 1,
      requiredMode: GameMode.hongKong,
    ),
    AchievementDef(
      id: 'hk_full_flush',
      titleKey: 'achvHkFullFlushTitle',
      descriptionKey: 'achvHkFullFlushDesc',
      category: AchievementCategory.hk,
      tier: AchievementTier.gold,
      iconCodePoint: 0xe23a, // Icons.format_paint
      target: 1,
      requiredMode: GameMode.hongKong,
    ),
    AchievementDef(
      id: 'hk_all_pongs_5',
      titleKey: 'achvHkAllPongs5Title',
      descriptionKey: 'achvHkAllPongs5Desc',
      category: AchievementCategory.hk,
      tier: AchievementTier.silver,
      iconCodePoint: 0xe94b, // Icons.grid_view
      target: 5,
      requiredMode: GameMode.hongKong,
    ),
    AchievementDef(
      id: 'hk_big_three_dragons',
      titleKey: 'achvHkBigThreeDragonsTitle',
      descriptionKey: 'achvHkBigThreeDragonsDesc',
      category: AchievementCategory.hk,
      tier: AchievementTier.gold,
      iconCodePoint: 0xf06bb, // Icons.whatshot
      target: 1,
      requiredMode: GameMode.hongKong,
    ),
    AchievementDef(
      id: 'hk_big_four_winds',
      titleKey: 'achvHkBigFourWindsTitle',
      descriptionKey: 'achvHkBigFourWindsDesc',
      category: AchievementCategory.hk,
      tier: AchievementTier.diamond,
      iconCodePoint: 0xe81a, // Icons.air
      target: 1,
      requiredMode: GameMode.hongKong,
    ),
    AchievementDef(
      id: 'hk_thirteen_orphans',
      titleKey: 'achvHkThirteenOrphansTitle',
      descriptionKey: 'achvHkThirteenOrphansDesc',
      category: AchievementCategory.hk,
      tier: AchievementTier.diamond,
      iconCodePoint: 0xe838, // Icons.auto_awesome
      target: 1,
      requiredMode: GameMode.hongKong,
    ),
    AchievementDef(
      id: 'hk_nine_gates',
      titleKey: 'achvHkNineGatesTitle',
      descriptionKey: 'achvHkNineGatesDesc',
      category: AchievementCategory.hk,
      tier: AchievementTier.diamond,
      iconCodePoint: 0xea0b, // Icons.temple_buddhist
      target: 1,
      requiredMode: GameMode.hongKong,
    ),
    AchievementDef(
      id: 'hk_concealed_hand_10',
      titleKey: 'achvHkConcealedHand10Title',
      descriptionKey: 'achvHkConcealedHand10Desc',
      category: AchievementCategory.hk,
      tier: AchievementTier.silver,
      iconCodePoint: 0xe897, // Icons.visibility_off
      target: 10,
      requiredMode: GameMode.hongKong,
    ),
    AchievementDef(
      id: 'hk_last_tile_win',
      titleKey: 'achvHkLastTileWinTitle',
      descriptionKey: 'achvHkLastTileWinDesc',
      category: AchievementCategory.hk,
      tier: AchievementTier.gold,
      iconCodePoint: 0xe3a5, // Icons.nightlight
      target: 1,
      requiredMode: GameMode.hongKong,
    ),
    AchievementDef(
      id: 'hk_robbing_kong',
      titleKey: 'achvHkRobbingKongTitle',
      descriptionKey: 'achvHkRobbingKongDesc',
      category: AchievementCategory.hk,
      tier: AchievementTier.silver,
      iconCodePoint: 0xe0e7, // Icons.flash_on
      target: 1,
      requiredMode: GameMode.hongKong,
    ),
    AchievementDef(
      id: 'hk_max_fan',
      titleKey: 'achvHkMaxFanTitle',
      descriptionKey: 'achvHkMaxFanDesc',
      category: AchievementCategory.hk,
      tier: AchievementTier.gold,
      iconCodePoint: 0xe1a6, // Icons.diamond
      target: 1,
      requiredMode: GameMode.hongKong,
    ),
  ];

  // ═════════════════════════════════════════════════════════════════
  //  TAIWAN
  // ═════════════════════════════════════════════════════════════════

  static const List<AchievementDef> tw = [
    AchievementDef(
      id: 'tw_first_win',
      titleKey: 'achvTwFirstWinTitle',
      descriptionKey: 'achvTwFirstWinDesc',
      category: AchievementCategory.tw,
      tier: AchievementTier.bronze,
      iconCodePoint: 0xf04db, // Icons.temple_hindu
      target: 1,
      requiredMode: GameMode.taiwan,
    ),
    AchievementDef(
      id: 'tw_tai_10',
      titleKey: 'achvTwTai10Title',
      descriptionKey: 'achvTwTai10Desc',
      category: AchievementCategory.tw,
      tier: AchievementTier.bronze,
      iconCodePoint: 0xe6e1, // Icons.trending_up
      target: 1,
      requiredMode: GameMode.taiwan,
    ),
    AchievementDef(
      id: 'tw_tai_30',
      titleKey: 'achvTwTai30Title',
      descriptionKey: 'achvTwTai30Desc',
      category: AchievementCategory.tw,
      tier: AchievementTier.silver,
      iconCodePoint: 0xe6e1, // Icons.trending_up
      target: 1,
      requiredMode: GameMode.taiwan,
    ),
    AchievementDef(
      id: 'tw_tai_80',
      titleKey: 'achvTwTai80Title',
      descriptionKey: 'achvTwTai80Desc',
      category: AchievementCategory.tw,
      tier: AchievementTier.gold,
      iconCodePoint: 0xe6e1, // Icons.trending_up
      target: 1,
      requiredMode: GameMode.taiwan,
    ),
    AchievementDef(
      id: 'tw_common_hand_10',
      titleKey: 'achvTwCommonHand10Title',
      descriptionKey: 'achvTwCommonHand10Desc',
      category: AchievementCategory.tw,
      tier: AchievementTier.silver,
      iconCodePoint: 0xe8e8, // Icons.horizontal_rule
      target: 10,
      requiredMode: GameMode.taiwan,
    ),
    AchievementDef(
      id: 'tw_concealed_self_drawn_5',
      titleKey: 'achvTwConcealedSelfDrawn5Title',
      descriptionKey: 'achvTwConcealedSelfDrawn5Desc',
      category: AchievementCategory.tw,
      tier: AchievementTier.silver,
      iconCodePoint: 0xe88a, // Icons.home
      target: 5,
      requiredMode: GameMode.taiwan,
    ),
    AchievementDef(
      id: 'tw_dealer_streak_5',
      titleKey: 'achvTwDealerStreak5Title',
      descriptionKey: 'achvTwDealerStreak5Desc',
      category: AchievementCategory.tw,
      tier: AchievementTier.gold,
      iconCodePoint: 0xe943, // Icons.castle
      target: 5,
      requiredMode: GameMode.taiwan,
    ),
    AchievementDef(
      id: 'tw_kong_win',
      titleKey: 'achvTwKongWinTitle',
      descriptionKey: 'achvTwKongWinDesc',
      category: AchievementCategory.tw,
      tier: AchievementTier.silver,
      iconCodePoint: 0xeaf3, // Icons.add_box
      target: 1,
      requiredMode: GameMode.taiwan,
    ),
    AchievementDef(
      id: 'tw_flower_win',
      titleKey: 'achvTwFlowerWinTitle',
      descriptionKey: 'achvTwFlowerWinDesc',
      category: AchievementCategory.tw,
      tier: AchievementTier.gold,
      iconCodePoint: 0xf0597, // Icons.local_florist
      target: 1,
      requiredMode: GameMode.taiwan,
    ),
    AchievementDef(
      id: 'tw_seven_rob_one',
      titleKey: 'achvTwSevenRobOneTitle',
      descriptionKey: 'achvTwSevenRobOneDesc',
      category: AchievementCategory.tw,
      tier: AchievementTier.diamond,
      iconCodePoint: 0xe3a7, // Icons.numbers
      target: 1,
      requiredMode: GameMode.taiwan,
    ),
    AchievementDef(
      id: 'tw_heavenly_listen',
      titleKey: 'achvTwHeavenlyListenTitle',
      descriptionKey: 'achvTwHeavenlyListenDesc',
      category: AchievementCategory.tw,
      tier: AchievementTier.gold,
      iconCodePoint: 0xe518, // Icons.hearing
      target: 1,
      requiredMode: GameMode.taiwan,
    ),
    AchievementDef(
      id: 'tw_chicken_hand_10',
      titleKey: 'achvTwChickenHand10Title',
      descriptionKey: 'achvTwChickenHand10Desc',
      category: AchievementCategory.tw,
      tier: AchievementTier.bronze,
      iconCodePoint: 0xea60, // Icons.egg
      target: 10,
      requiredMode: GameMode.taiwan,
    ),
    AchievementDef(
      id: 'tw_likuliku',
      titleKey: 'achvTwLikulikuTitle',
      descriptionKey: 'achvTwLikulikuDesc',
      category: AchievementCategory.tw,
      tier: AchievementTier.diamond,
      iconCodePoint: 0xf06bd, // Icons.casino
      target: 1,
      requiredMode: GameMode.taiwan,
    ),
  ];

  // ═════════════════════════════════════════════════════════════════
  //  MILESTONE
  // ═════════════════════════════════════════════════════════════════

  static const List<AchievementDef> milestone = [
    AchievementDef(
      id: 'ms_wins_100',
      titleKey: 'achvMsWins100Title',
      descriptionKey: 'achvMsWins100Desc',
      category: AchievementCategory.milestone,
      tier: AchievementTier.silver,
      iconCodePoint: 0xe23e, // Icons.looks_one
      target: 100,
    ),
    AchievementDef(
      id: 'ms_wins_500',
      titleKey: 'achvMsWins500Title',
      descriptionKey: 'achvMsWins500Desc',
      category: AchievementCategory.milestone,
      tier: AchievementTier.gold,
      iconCodePoint: 0xea23, // Icons.military_tech
      target: 500,
    ),
    AchievementDef(
      id: 'ms_score_10000',
      titleKey: 'achvMsScore10000Title',
      descriptionKey: 'achvMsScore10000Desc',
      category: AchievementCategory.milestone,
      tier: AchievementTier.silver,
      iconCodePoint: 0xe263, // Icons.savings
      target: 10000,
    ),
    AchievementDef(
      id: 'ms_score_100000',
      titleKey: 'achvMsScore100000Title',
      descriptionKey: 'achvMsScore100000Desc',
      category: AchievementCategory.milestone,
      tier: AchievementTier.gold,
      iconCodePoint: 0xe263, // Icons.savings
      target: 100000,
    ),
    AchievementDef(
      id: 'ms_dual_mode',
      titleKey: 'achvMsDualModeTitle',
      descriptionKey: 'achvMsDualModeDesc',
      category: AchievementCategory.milestone,
      tier: AchievementTier.silver,
      iconCodePoint: 0xe8d4, // Icons.sync_alt
      target: 1,
    ),
  ];

  // ═════════════════════════════════════════════════════════════════
  //  CONVENIENCE
  // ═════════════════════════════════════════════════════════════════

  /// All achievements, flat list.
  static List<AchievementDef> get all => [
    ...general,
    ...hk,
    ...tw,
    ...milestone,
  ];

  /// Look up a definition by ID.
  static AchievementDef? getById(String id) {
    try {
      return all.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  /// All achievements for a specific category.
  static List<AchievementDef> byCategory(AchievementCategory category) =>
      all.where((a) => a.category == category).toList();

  /// Total number of achievements.
  static int get totalCount => all.length;

  /// Get the color for a tier.
  static Color tierColor(AchievementTier tier) {
    switch (tier) {
      case AchievementTier.bronze:
        return const Color(0xFFCD7F32);
      case AchievementTier.silver:
        return const Color(0xFFC0C0C0);
      case AchievementTier.gold:
        return const Color(0xFFFFD700);
      case AchievementTier.diamond:
        return const Color(0xFFB9F2FF);
    }
  }

  /// Get the tier display name l10n key.
  static String tierKey(AchievementTier tier) {
    switch (tier) {
      case AchievementTier.bronze:
        return 'achvTierBronze';
      case AchievementTier.silver:
        return 'achvTierSilver';
      case AchievementTier.gold:
        return 'achvTierGold';
      case AchievementTier.diamond:
        return 'achvTierDiamond';
    }
  }
}
