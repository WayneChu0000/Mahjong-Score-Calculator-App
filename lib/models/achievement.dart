import 'game_mode.dart';

/// Achievement tier representing difficulty/rarity.
enum AchievementTier {
  bronze,
  silver,
  gold,
  diamond,
}

/// Category of achievement.
enum AchievementCategory {
  general,
  hk,
  tw,
  milestone,
}

/// Static definition of an achievement (immutable template).
class AchievementDef {
  /// Unique identifier, e.g. "general_first_game".
  final String id;

  /// Localization key for the title.
  final String titleKey;

  /// Localization key for the description.
  final String descriptionKey;

  /// Category (general / hk / tw / milestone).
  final AchievementCategory category;

  /// Difficulty tier.
  final AchievementTier tier;

  /// Icon code point from Material Icons.
  final int iconCodePoint;

  /// Target value to unlock (e.g. 10 for "self-draw 10 times").
  final int target;

  /// Which game mode(s) this achievement applies to.
  /// null means all modes.
  final GameMode? requiredMode;

  const AchievementDef({
    required this.id,
    required this.titleKey,
    required this.descriptionKey,
    required this.category,
    required this.tier,
    required this.iconCodePoint,
    this.target = 1,
    this.requiredMode,
  });
}

/// Player's progress toward a specific achievement.
class AchievementProgress {
  /// Achievement definition ID.
  final String achievementId;

  /// Whether this achievement is unlocked.
  final bool isUnlocked;

  /// Timestamp of when it was unlocked (null if not yet).
  final DateTime? unlockedAt;

  /// Current progress count toward the target.
  final int progress;

  const AchievementProgress({
    required this.achievementId,
    this.isUnlocked = false,
    this.unlockedAt,
    this.progress = 0,
  });

  AchievementProgress copyWith({
    String? achievementId,
    bool? isUnlocked,
    DateTime? unlockedAt,
    int? progress,
  }) {
    return AchievementProgress(
      achievementId: achievementId ?? this.achievementId,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      progress: progress ?? this.progress,
    );
  }

  Map<String, dynamic> toJson() => {
    'achievementId': achievementId,
    'isUnlocked': isUnlocked,
    'unlockedAt': unlockedAt?.toUtc().toIso8601String(),
    'progress': progress,
  };

  factory AchievementProgress.fromJson(Map<String, dynamic> json) {
    return AchievementProgress(
      achievementId: json['achievementId'] ?? '',
      isUnlocked: json['isUnlocked'] ?? false,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt']).toLocal()
          : null,
      progress: json['progress'] ?? 0,
    );
  }
}

/// Counters tracked per player within a group for achievement checking.
class AchievementCounters {
  // ── General ───────────────────────────────────────────────────────
  final int totalGames;
  final int totalWins;
  final int totalSelfDrawn;
  final int totalDealerWins;
  final int totalFangChong;
  final int maxConsecutiveWins;
  final int maxConsecutiveDealer;
  final int currentConsecutiveWins;

  // ── HK specific ──────────────────────────────────────────────────
  final int hkGames;
  final int hkWins;
  final int hkMaxFan;
  final int hkConcealedHand;
  final int hkAllOneSuit;
  final int hkAllPongs;
  final int hkBigThreeDragons;
  final int hkBigFourWinds;
  final int hkThirteenOrphans;
  final int hkNineGates;
  final int hkLastTileWin;
  final int hkRobbingKong;

  // ── TW specific ──────────────────────────────────────────────────
  final int twGames;
  final int twWins;
  final int twMaxTai;
  final int twCommonHand;
  final int twConcealedSelfDrawn;
  final int twMaxConsecutiveDealer;
  final int twKongWin;
  final int twFlowerWin;
  final int twSevenRobOne;
  final int twHeavenlyListen;
  final int twChickenHand;
  final int twLikuliku;

  // ── Milestone ────────────────────────────────────────────────────
  final int totalScore;

  const AchievementCounters({
    this.totalGames = 0,
    this.totalWins = 0,
    this.totalSelfDrawn = 0,
    this.totalDealerWins = 0,
    this.totalFangChong = 0,
    this.maxConsecutiveWins = 0,
    this.maxConsecutiveDealer = 0,
    this.currentConsecutiveWins = 0,
    this.hkGames = 0,
    this.hkWins = 0,
    this.hkMaxFan = 0,
    this.hkConcealedHand = 0,
    this.hkAllOneSuit = 0,
    this.hkAllPongs = 0,
    this.hkBigThreeDragons = 0,
    this.hkBigFourWinds = 0,
    this.hkThirteenOrphans = 0,
    this.hkNineGates = 0,
    this.hkLastTileWin = 0,
    this.hkRobbingKong = 0,
    this.twGames = 0,
    this.twWins = 0,
    this.twMaxTai = 0,
    this.twCommonHand = 0,
    this.twConcealedSelfDrawn = 0,
    this.twMaxConsecutiveDealer = 0,
    this.twKongWin = 0,
    this.twFlowerWin = 0,
    this.twSevenRobOne = 0,
    this.twHeavenlyListen = 0,
    this.twChickenHand = 0,
    this.twLikuliku = 0,
    this.totalScore = 0,
  });

  AchievementCounters copyWith({
    int? totalGames,
    int? totalWins,
    int? totalSelfDrawn,
    int? totalDealerWins,
    int? totalFangChong,
    int? maxConsecutiveWins,
    int? maxConsecutiveDealer,
    int? currentConsecutiveWins,
    int? hkGames,
    int? hkWins,
    int? hkMaxFan,
    int? hkConcealedHand,
    int? hkAllOneSuit,
    int? hkAllPongs,
    int? hkBigThreeDragons,
    int? hkBigFourWinds,
    int? hkThirteenOrphans,
    int? hkNineGates,
    int? hkLastTileWin,
    int? hkRobbingKong,
    int? twGames,
    int? twWins,
    int? twMaxTai,
    int? twCommonHand,
    int? twConcealedSelfDrawn,
    int? twMaxConsecutiveDealer,
    int? twKongWin,
    int? twFlowerWin,
    int? twSevenRobOne,
    int? twHeavenlyListen,
    int? twChickenHand,
    int? twLikuliku,
    int? totalScore,
  }) {
    return AchievementCounters(
      totalGames: totalGames ?? this.totalGames,
      totalWins: totalWins ?? this.totalWins,
      totalSelfDrawn: totalSelfDrawn ?? this.totalSelfDrawn,
      totalDealerWins: totalDealerWins ?? this.totalDealerWins,
      totalFangChong: totalFangChong ?? this.totalFangChong,
      maxConsecutiveWins: maxConsecutiveWins ?? this.maxConsecutiveWins,
      maxConsecutiveDealer: maxConsecutiveDealer ?? this.maxConsecutiveDealer,
      currentConsecutiveWins: currentConsecutiveWins ?? this.currentConsecutiveWins,
      hkGames: hkGames ?? this.hkGames,
      hkWins: hkWins ?? this.hkWins,
      hkMaxFan: hkMaxFan ?? this.hkMaxFan,
      hkConcealedHand: hkConcealedHand ?? this.hkConcealedHand,
      hkAllOneSuit: hkAllOneSuit ?? this.hkAllOneSuit,
      hkAllPongs: hkAllPongs ?? this.hkAllPongs,
      hkBigThreeDragons: hkBigThreeDragons ?? this.hkBigThreeDragons,
      hkBigFourWinds: hkBigFourWinds ?? this.hkBigFourWinds,
      hkThirteenOrphans: hkThirteenOrphans ?? this.hkThirteenOrphans,
      hkNineGates: hkNineGates ?? this.hkNineGates,
      hkLastTileWin: hkLastTileWin ?? this.hkLastTileWin,
      hkRobbingKong: hkRobbingKong ?? this.hkRobbingKong,
      twGames: twGames ?? this.twGames,
      twWins: twWins ?? this.twWins,
      twMaxTai: twMaxTai ?? this.twMaxTai,
      twCommonHand: twCommonHand ?? this.twCommonHand,
      twConcealedSelfDrawn: twConcealedSelfDrawn ?? this.twConcealedSelfDrawn,
      twMaxConsecutiveDealer: twMaxConsecutiveDealer ?? this.twMaxConsecutiveDealer,
      twKongWin: twKongWin ?? this.twKongWin,
      twFlowerWin: twFlowerWin ?? this.twFlowerWin,
      twSevenRobOne: twSevenRobOne ?? this.twSevenRobOne,
      twHeavenlyListen: twHeavenlyListen ?? this.twHeavenlyListen,
      twChickenHand: twChickenHand ?? this.twChickenHand,
      twLikuliku: twLikuliku ?? this.twLikuliku,
      totalScore: totalScore ?? this.totalScore,
    );
  }

  Map<String, dynamic> toJson() => {
    'totalGames': totalGames,
    'totalWins': totalWins,
    'totalSelfDrawn': totalSelfDrawn,
    'totalDealerWins': totalDealerWins,
    'totalFangChong': totalFangChong,
    'maxConsecutiveWins': maxConsecutiveWins,
    'maxConsecutiveDealer': maxConsecutiveDealer,
    'currentConsecutiveWins': currentConsecutiveWins,
    'hkGames': hkGames,
    'hkWins': hkWins,
    'hkMaxFan': hkMaxFan,
    'hkConcealedHand': hkConcealedHand,
    'hkAllOneSuit': hkAllOneSuit,
    'hkAllPongs': hkAllPongs,
    'hkBigThreeDragons': hkBigThreeDragons,
    'hkBigFourWinds': hkBigFourWinds,
    'hkThirteenOrphans': hkThirteenOrphans,
    'hkNineGates': hkNineGates,
    'hkLastTileWin': hkLastTileWin,
    'hkRobbingKong': hkRobbingKong,
    'twGames': twGames,
    'twWins': twWins,
    'twMaxTai': twMaxTai,
    'twCommonHand': twCommonHand,
    'twConcealedSelfDrawn': twConcealedSelfDrawn,
    'twMaxConsecutiveDealer': twMaxConsecutiveDealer,
    'twKongWin': twKongWin,
    'twFlowerWin': twFlowerWin,
    'twSevenRobOne': twSevenRobOne,
    'twHeavenlyListen': twHeavenlyListen,
    'twChickenHand': twChickenHand,
    'twLikuliku': twLikuliku,
    'totalScore': totalScore,
  };

  factory AchievementCounters.fromJson(Map<String, dynamic> json) {
    return AchievementCounters(
      totalGames: json['totalGames'] ?? 0,
      totalWins: json['totalWins'] ?? 0,
      totalSelfDrawn: json['totalSelfDrawn'] ?? 0,
      totalDealerWins: json['totalDealerWins'] ?? 0,
      totalFangChong: json['totalFangChong'] ?? 0,
      maxConsecutiveWins: json['maxConsecutiveWins'] ?? 0,
      maxConsecutiveDealer: json['maxConsecutiveDealer'] ?? 0,
      currentConsecutiveWins: json['currentConsecutiveWins'] ?? 0,
      hkGames: json['hkGames'] ?? 0,
      hkWins: json['hkWins'] ?? 0,
      hkMaxFan: json['hkMaxFan'] ?? 0,
      hkConcealedHand: json['hkConcealedHand'] ?? 0,
      hkAllOneSuit: json['hkAllOneSuit'] ?? 0,
      hkAllPongs: json['hkAllPongs'] ?? 0,
      hkBigThreeDragons: json['hkBigThreeDragons'] ?? 0,
      hkBigFourWinds: json['hkBigFourWinds'] ?? 0,
      hkThirteenOrphans: json['hkThirteenOrphans'] ?? 0,
      hkNineGates: json['hkNineGates'] ?? 0,
      hkLastTileWin: json['hkLastTileWin'] ?? 0,
      hkRobbingKong: json['hkRobbingKong'] ?? 0,
      twGames: json['twGames'] ?? 0,
      twWins: json['twWins'] ?? 0,
      twMaxTai: json['twMaxTai'] ?? 0,
      twCommonHand: json['twCommonHand'] ?? 0,
      twConcealedSelfDrawn: json['twConcealedSelfDrawn'] ?? 0,
      twMaxConsecutiveDealer: json['twMaxConsecutiveDealer'] ?? 0,
      twKongWin: json['twKongWin'] ?? 0,
      twFlowerWin: json['twFlowerWin'] ?? 0,
      twSevenRobOne: json['twSevenRobOne'] ?? 0,
      twHeavenlyListen: json['twHeavenlyListen'] ?? 0,
      twChickenHand: json['twChickenHand'] ?? 0,
      twLikuliku: json['twLikuliku'] ?? 0,
      totalScore: json['totalScore'] ?? 0,
    );
  }
}
