import '../models/player.dart';
import '../models/game_mode.dart';
import '../models/tw_hand.dart';

/// Centralized route name constants.
///
/// Using named routes makes navigation easier to trace and
/// prevents typos scattered across multiple files.
class AppRoutes {
  AppRoutes._(); // prevent instantiation

  static const String splash = '/';
  static const String auth = '/auth';
  static const String home = '/home';
  static const String login = '/login';
  static const String playerSetup = '/player-setup';
  static const String scoreRecording = '/score-recording';
  static const String scoreCalculation = '/score-calculation';
  static const String tileSelection = '/tile-selection';
  static const String twTileSelection = '/tw-tile-selection';
  static const String rules = '/rules';
  static const String settings = '/settings';
  static const String savedGroups = '/saved-groups';
  static const String groupDetail = '/group-detail';
  static const String achievements = '/achievements';
  static const String customFanEditor = '/custom-fan-editor';
}

// ─── Typed argument classes ────────────────────────────────────────

/// Arguments for [PlayerSetupScreen].
class PlayerSetupArgs {
  final List<Player>? existingPlayers;
  final String? groupName;
  final String? groupId;
  final bool directStart;
  final int? currentRound;
  final int? dealerIndex;
  final int? prevalentWindIndex;
  final int? currentDealerGameCount;
  final int? totalWindRounds;
  final GameMode? initialGameMode;

  const PlayerSetupArgs({
    this.existingPlayers,
    this.groupName,
    this.groupId,
    this.directStart = false,
    this.currentRound,
    this.dealerIndex,
    this.prevalentWindIndex,
    this.currentDealerGameCount,
    this.totalWindRounds,
    this.initialGameMode,
  });
}

/// Arguments for [GroupDetailScreen].
class GroupDetailArgs {
  final dynamic group;
  const GroupDetailArgs({required this.group});
}

/// Arguments for [ScoreRecordingScreen].
class ScoreRecordingArgs {
  final List<Player> players;
  final int currentRound;
  final int totalRounds;
  final Function(Map<String, int>) onScoreSubmitted;
  final String? groupId;
  final String? groupName;
  final int? initialDealerIndex;
  final int? initialPrevalentWindIndex;
  final int? initialDealerGameCount;
  final int? initialTotalWindRounds;
  final int minFan;
  final int maxFan;
  final GameMode gameMode;

  const ScoreRecordingArgs({
    required this.players,
    required this.currentRound,
    required this.totalRounds,
    required this.onScoreSubmitted,
    this.groupId,
    this.groupName,
    this.initialDealerIndex,
    this.initialPrevalentWindIndex,
    this.initialDealerGameCount,
    this.initialTotalWindRounds,
    this.minFan = 3,
    this.maxFan = 13,
    this.gameMode = GameMode.hongKong,
  });
}

/// Arguments for [ScoreCalculationScreen].
class ScoreCalculationArgs {
  final List<Player> players;
  final String? groupName;
  final int? roundWindIndex;
  final int? dealerIndex;
  final int minFan;
  final int maxFan;
  final GameMode gameMode;
  final int consecutiveDealerCount;

  const ScoreCalculationArgs({
    required this.players,
    this.groupName,
    this.roundWindIndex,
    this.dealerIndex,
    this.minFan = 3,
    this.maxFan = 13,
    this.gameMode = GameMode.hongKong,
    this.consecutiveDealerCount = 1,
  });
}

/// Arguments for [TileSelectionScreen].
class TileSelectionArgs {
  final List<String> initialTiles;
  final GameMode gameMode;

  const TileSelectionArgs({
    this.initialTiles = const [],
    this.gameMode = GameMode.hongKong,
  });
}

/// Arguments for [TwTileSelectionScreen].
class TwTileSelectionArgs {
  final TwHand? initialHand;

  const TwTileSelectionArgs({this.initialHand});
}

/// Arguments for [AchievementScreen].
class AchievementArgs {
  final String groupName;
  final String playerName;

  const AchievementArgs({required this.groupName, required this.playerName});
}
