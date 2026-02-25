import 'package:flutter/foundation.dart';
import '../models/player.dart';
import '../models/rule.dart';
import '../models/game_mode.dart';
import '../localization/app_localizations.dart';

/// Controller that holds all state and business logic for score calculation.
///
/// Extracted from ScoreCalculationScreen to separate concerns:
/// - UI ↔ business logic
/// - Easier to unit-test without widget dependencies
class ScoreCalculationController extends ChangeNotifier {
  // =============================================
  //  Constructor parameters (read-only config)
  // =============================================

  final List<Player> players;
  final int minFan;
  final int maxFan;
  final GameMode gameMode;
  final int consecutiveDealerCount;
  final int? roundWindIndex;
  final int? dealerIndex;

  // =============================================
  //  State
  // =============================================

  bool isSelfDraw = true;
  String? winningPlayer;
  String? discardPlayer;

  String roundWind = 'East';
  String seatWind = 'East';
  final List<String> winds = const ['East', 'South', 'West', 'North'];

  int fanCount = 1;
  int effectiveFan = 1;

  final Map<String, bool> selectedFlowers = {};
  String selectedSpecialCondition = 'None';

  final List<String> specialConditions = const [
    'None',
    'Men Qian Qing',
    'Robbing the Kong',
    'Haidilao',
    'Kong on Kong/Flower',
    'Heavenly Hand',
    'Earthly Hand',
  ];

  final List<String> twSpecialConditions = const [
    'None',
    'Men Qian Qing',
    'Declared Ready',
    'Kong on Kong/Flower',
    'Under the Sea',
    'Heavenly Hand',
    'Earthly Hand',
  ];

  List<String> get activeSpecialConditions =>
      gameMode == GameMode.taiwan ? twSpecialConditions : specialConditions;

  bool isAnalyzing = false;
  List<String> selectedTiles = [];
  List<Map<String, dynamic>> matchedRulesDetails = [];
  List<Map<String, dynamic>> displayRules = [];

  int totalPoints = 0;
  final Map<String, int> playerScores = {};

  // =============================================
  //  Constructor & initialisation
  // =============================================

  ScoreCalculationController({
    required this.players,
    required this.minFan,
    required this.maxFan,
    required this.gameMode,
    required this.consecutiveDealerCount,
    this.roundWindIndex,
    this.dealerIndex,
  }) {
    _init();
  }

  void _init() {
    for (var player in players) {
      playerScores[player.name] = 0;
    }
    winningPlayer = players.isNotEmpty ? players[0].name : 'Player 1';

    if (roundWindIndex != null) {
      roundWind = winds[roundWindIndex! % 4];
    }

    _updateSeatWind();
    _ensureValidDiscardPlayer();
    _calculateScoreInternal();
  }

  // =============================================
  //  Wind / Player helpers
  // =============================================

  void _updateSeatWind() {
    if (dealerIndex != null && winningPlayer != null) {
      int winnerIndex = players.indexWhere((p) => p.name == winningPlayer);
      if (winnerIndex != -1) {
        int windIndex = (winnerIndex - dealerIndex! + 4) % 4;
        seatWind = winds[windIndex];
      }
    }
  }

  void _ensureValidDiscardPlayer() {
    if (isSelfDraw) {
      discardPlayer = null;
      return;
    }
    if (discardPlayer == null || discardPlayer == winningPlayer) {
      final validPlayers =
          players.where((p) => p.name != winningPlayer).toList();
      if (validPlayers.isNotEmpty) {
        discardPlayer = validPlayers.first.name;
      }
    }
  }

  int getPlayerCurrentScore(String playerName) {
    try {
      return players.firstWhere((p) => p.name == playerName).score;
    } catch (e) {
      return 0;
    }
  }

  // =============================================
  //  Localization helpers
  // =============================================

  String getLocalizedCondition(String condition) {
    switch (condition) {
      case 'None':
        return AppLocalizations.ruleNone;
      case 'Men Qian Qing':
        return AppLocalizations.ruleMenQianQing;
      case 'Robbing the Kong':
        return AppLocalizations.ruleRobbingKong;
      case 'Haidilao':
        return AppLocalizations.ruleHaidilao;
      case 'Kong on Kong/Flower':
        return AppLocalizations.ruleKongOnKong;
      case 'Heavenly Hand':
        return AppLocalizations.ruleHeavenlyHand;
      case 'Earthly Hand':
        return AppLocalizations.ruleEarthlyHand;
      case 'Declared Ready':
        return AppLocalizations.twDeclaredReady;
      case 'Under the Sea':
        return AppLocalizations.twUnderTheSea;
      default:
        return condition;
    }
  }

  String getLocalizedWind(String wind) {
    switch (wind) {
      case 'East':
        return AppLocalizations.east;
      case 'South':
        return AppLocalizations.south;
      case 'West':
        return AppLocalizations.west;
      case 'North':
        return AppLocalizations.north;
      default:
        return wind;
    }
  }

  // =============================================
  //  Public mutation methods (called by UI)
  // =============================================

  void setSelfDraw(bool value) {
    if (value == isSelfDraw) return;
    isSelfDraw = value;
    _ensureValidDiscardPlayer();
    if (selectedTiles.isEmpty) {
      fanCount = value
          ? (fanCount + 1).clamp(0, 13)
          : (fanCount - 1).clamp(0, 13);
    }
    calculateFanFromTiles();
    calculateScore();
    notifyListeners();
  }

  void setWinningPlayer(String? newValue) {
    if (newValue == null) return;
    winningPlayer = newValue;
    _updateSeatWind();
    _ensureValidDiscardPlayer();
    calculateFanFromTiles();
    calculateScore();
    notifyListeners();
  }

  void setDiscardPlayer(String? newValue) {
    if (newValue == null) return;
    discardPlayer = newValue;
    notifyListeners();
  }

  void setRoundWind(String? newValue) {
    if (newValue == null) return;
    roundWind = newValue;
    calculateFanFromTiles();
    calculateScore();
    notifyListeners();
  }

  void setSeatWind(String? newValue) {
    if (newValue == null) return;
    seatWind = newValue;
    calculateFanFromTiles();
    calculateScore();
    notifyListeners();
  }

  void setFan(int? newValue) {
    if (newValue == null) return;
    int diff = newValue - effectiveFan;
    fanCount = fanCount + diff;
    if (fanCount < 0) fanCount = 0;
    calculateScore();
    notifyListeners();
  }

  void setSpecialCondition(String? newValue) {
    if (newValue == null) return;
    selectedSpecialCondition = newValue;
    if (newValue == 'Heavenly Hand') {
      isSelfDraw = true;
    } else if (newValue == 'Earthly Hand') {
      isSelfDraw = false;
    }
    calculateScore();
    notifyListeners();
  }

  void toggleFlower(String key) {
    selectedFlowers[key] = !(selectedFlowers[key] ?? false);
    calculateScore();
    notifyListeners();
  }

  void setSelectedTiles(List<String> tiles) {
    selectedTiles = tiles;
    calculateFanFromTiles();
    calculateScore();
    notifyListeners();
  }

  void setAnalyzing(bool value) {
    isAnalyzing = value;
    notifyListeners();
  }

  // =============================================
  //  Score Calculation Logic
  // =============================================

  void calculateFanFromTiles() {
    if (selectedTiles.isEmpty) return;

    int calculatedFan = 0;
    List<Map<String, dynamic>> matchedRules = [];

    List<Rule> currentRules = getRules(gameMode);

    for (var rule in currentRules) {
      if (rule.validator != null) {
        if (rule.validator!(selectedTiles)) {
          int fan = rule.fanValue;
          calculatedFan += fan;
          matchedRules.add({'name': rule.name, 'fan': fan});
        }
      }
    }

    // Manual Check for Dragons
    bool hasBigThreeDragons =
        matchedRules.any((r) => r['name'] == AppLocalizations.ruleBigThreeDragons);
    bool hasSmallThreeDragons =
        matchedRules.any((r) => r['name'] == AppLocalizations.ruleSmallThreeDragons);

    if (!hasBigThreeDragons && !hasSmallThreeDragons) {
      Map<String, int> counts = {};
      for (var t in selectedTiles) {
        if (t == '5z' || t == '6z' || t == '7z') {
          counts[t] = (counts[t] ?? 0) + 1;
        }
      }

      int dragonFanValue = gameMode == GameMode.taiwan ? 2 : 1;
      for (var entry in counts.entries) {
        if (entry.value >= 3) {
          String ruleName = '';
          if (entry.key == '5z') ruleName = AppLocalizations.rulePongOfWhite;
          if (entry.key == '6z') ruleName = AppLocalizations.rulePongOfGreen;
          if (entry.key == '7z') ruleName = AppLocalizations.rulePongOfRed;

          calculatedFan += dragonFanValue;
          matchedRules.add({'name': ruleName, 'fan': dragonFanValue});
        }
      }
    }

    // Manual Check for Winds
    bool hasBigFourWinds =
        matchedRules.any((r) => r['name'] == AppLocalizations.ruleBigFourWinds);
    bool hasSmallFourWinds =
        matchedRules.any((r) => r['name'] == AppLocalizations.ruleSmallFourWinds);

    if (!hasBigFourWinds && !hasSmallFourWinds) {
      Map<String, int> windCounts = {};
      for (var t in selectedTiles) {
        if (t.endsWith('z') && int.parse(t.substring(0, 1)) <= 4) {
          windCounts[t] = (windCounts[t] ?? 0) + 1;
        }
      }

      Map<String, String> windMap = {
        'East': '1z',
        'South': '2z',
        'West': '3z',
        'North': '4z',
      };

      String? roundWindTile = windMap[roundWind];
      String? seatWindTile = windMap[seatWind];

      if (roundWindTile != null && (windCounts[roundWindTile] ?? 0) >= 3) {
        int windFan = gameMode == GameMode.taiwan ? 2 : 1;
        calculatedFan += windFan;
        matchedRules.add({
          'name': '${AppLocalizations.ruleRoundWind} (${getLocalizedWind(roundWind)})',
          'fan': windFan,
        });
      }

      if (seatWindTile != null && (windCounts[seatWindTile] ?? 0) >= 3) {
        int windFan = gameMode == GameMode.taiwan ? 2 : 1;
        calculatedFan += windFan;
        matchedRules.add({
          'name': '${AppLocalizations.ruleSeatWind} (${getLocalizedWind(seatWind)})',
          'fan': windFan,
        });
      }

      // TW: Ordinary Wind Pongs
      if (gameMode == GameMode.taiwan) {
        Map<String, String> windTileToName = {
          '1z': 'East',
          '2z': 'South',
          '3z': 'West',
          '4z': 'North',
        };
        for (var entry in windCounts.entries) {
          if (entry.value >= 3 &&
              entry.key != roundWindTile &&
              entry.key != seatWindTile) {
            calculatedFan += 1;
            matchedRules.add({
              'name':
                  '${AppLocalizations.twOrdinaryWind} (${getLocalizedWind(windTileToName[entry.key] ?? '')})',
              'fan': 1,
            });
          }
        }
      }
    }

    // Add Self-Draw fan
    if (isSelfDraw) {
      bool isSpecialHand =
          selectedFlowers.values.where((v) => v).length >= 7 ||
              selectedSpecialCondition == 'Heavenly Hand';

      if (!isSpecialHand) {
        calculatedFan += 1;
        matchedRules.add({'name': AppLocalizations.ruleSelfDraw, 'fan': 1});
      }
    }

    // Cap at max fan
    if (maxFan != 999 && calculatedFan > maxFan) {
      calculatedFan = maxFan;
    }

    fanCount = calculatedFan;
    matchedRulesDetails = matchedRules;
  }

  void calculateScore() {
    _calculateScoreInternal();
  }

  void _calculateScoreInternal() {
    int localEffectiveFan = fanCount;
    displayRules = List.from(matchedRulesDetails);

    // Check for Hidden Treasure combination
    bool hasAllPongs =
        displayRules.any((r) => r['name'] == AppLocalizations.ruleAllPongs);
    bool isMenQianQing = selectedSpecialCondition == 'Men Qian Qing';

    if (hasAllPongs && isMenQianQing) {
      displayRules.removeWhere((r) => r['name'] == AppLocalizations.ruleAllPongs);
      displayRules.add({'name': AppLocalizations.ruleHiddenTreasure, 'fan': 8});
      localEffectiveFan = localEffectiveFan - 3 + 8;
    } else {
      bool isTW = gameMode == GameMode.taiwan;
      int specialFan = 0;
      String? specialName;

      if (selectedSpecialCondition == 'Men Qian Qing') {
        specialFan = isTW ? 3 : 1;
        specialName = AppLocalizations.ruleMenQianQing;
        if (isTW && isSelfDraw) {
          displayRules.removeWhere((r) => r['name'] == AppLocalizations.ruleSelfDraw);
          specialFan = 5;
          specialName = AppLocalizations.twConcealedSelfDraw;
        }
      } else if (selectedSpecialCondition == 'Robbing the Kong') {
        specialFan = 1;
        specialName = AppLocalizations.ruleRobbingKong;
      } else if (selectedSpecialCondition == 'Haidilao') {
        specialFan = 1;
        specialName = AppLocalizations.ruleHaidilao;
      } else if (selectedSpecialCondition == 'Kong on Kong/Flower') {
        specialFan = isTW ? 1 : 2;
        specialName = AppLocalizations.ruleKongOnKong;
      } else if (selectedSpecialCondition == 'Heavenly Hand') {
        specialFan = isTW ? 100 : 13;
        specialName = AppLocalizations.ruleHeavenlyHand;
      } else if (selectedSpecialCondition == 'Earthly Hand') {
        specialFan = isTW ? 80 : 13;
        specialName = AppLocalizations.ruleEarthlyHand;
      } else if (selectedSpecialCondition == 'Declared Ready') {
        specialFan = 5;
        specialName = AppLocalizations.twDeclaredReady;
      } else if (selectedSpecialCondition == 'Under the Sea') {
        specialFan = 20;
        specialName = AppLocalizations.twUnderTheSea;
      }

      if (specialName != null) {
        localEffectiveFan += specialFan;
        displayRules.add({'name': specialName, 'fan': specialFan});
      }
    }

    // Self-draw in manual mode
    bool hasSelfDrawRule =
        displayRules.any((r) => r['name'] == AppLocalizations.ruleSelfDraw);
    if (isSelfDraw && !hasSelfDrawRule && selectedTiles.isEmpty) {
      bool isSpecialHand =
          selectedSpecialCondition == 'Heavenly Hand' ||
              selectedFlowers.values.where((v) => v).length >= 7;
      if (!isSpecialHand) {
        localEffectiveFan += 1;
        displayRules.add({'name': AppLocalizations.ruleSelfDraw, 'fan': 1});
      }
    }

    // Handle Flower Logic
    int flowerFan = 0;
    int flowerCount = selectedFlowers.values.where((v) => v).length;
    bool isTW = gameMode == GameMode.taiwan;

    if (flowerCount == 0) {
      flowerFan += 1;
      displayRules.add({'name': AppLocalizations.ruleNoFlowers, 'fan': 1});
      localEffectiveFan += flowerFan;
    } else if (flowerCount == 7) {
      if (gameMode == GameMode.taiwan) {
        _calculateTwFlowerFan(localEffectiveFan);
        return;
      } else {
        displayRules = [
          {'name': AppLocalizations.ruleSevenFlowers, 'fan': 3}
        ];
        localEffectiveFan = 3;
      }
    } else if (flowerCount == 8) {
      int val = 8;
      displayRules = [
        {'name': AppLocalizations.ruleEightImmortals, 'fan': val}
      ];
      localEffectiveFan = val;
    } else if (isTW) {
      _calculateTwFlowerFan(localEffectiveFan);
      return;
    } else {
      // HK flower scoring
      int seatIndex = 0;
      if (seatWind == 'East') {
        seatIndex = 1;
      } else if (seatWind == 'South') {
        seatIndex = 2;
      } else if (seatWind == 'West') {
        seatIndex = 3;
      } else if (seatWind == 'North') {
        seatIndex = 4;
      }

      String ownFlower = '${seatIndex}f';
      String ownSeason = '${seatIndex + 4}f';

      bool hasFlowers1to4 = true;
      for (int i = 1; i <= 4; i++) {
        if (selectedFlowers['${i}f'] != true) hasFlowers1to4 = false;
      }

      if (hasFlowers1to4) {
        flowerFan += 2;
        displayRules.add({'name': AppLocalizations.ruleFlowerPlatform14, 'fan': 2});
      } else {
        if (selectedFlowers[ownFlower] == true) {
          flowerFan += 1;
          displayRules.add({'name': AppLocalizations.ruleOwnFlower, 'fan': 1});
        }
      }

      bool hasSeasons1to4 = true;
      for (int i = 5; i <= 8; i++) {
        if (selectedFlowers['${i}f'] != true) hasSeasons1to4 = false;
      }

      if (hasSeasons1to4) {
        flowerFan += 2;
        displayRules.add({'name': AppLocalizations.ruleFlowerPlatform58, 'fan': 2});
      } else {
        if (selectedFlowers[ownSeason] == true) {
          flowerFan += 1;
          displayRules.add({'name': AppLocalizations.ruleOwnSeason, 'fan': 1});
        }
      }

      localEffectiveFan += flowerFan;
    }

    // Cap at fan limit
    if (gameMode != GameMode.taiwan &&
        maxFan != 999 &&
        localEffectiveFan > maxFan) {
      localEffectiveFan = maxFan;
    }

    effectiveFan = localEffectiveFan;

    // Calculate Score based on Mode
    if (gameMode == GameMode.taiwan) {
      int baseTai = minFan;
      int taiValue = maxFan;

      bool winnerIsDealer = false;
      if (dealerIndex != null && winningPlayer != null) {
        int winnerIdx = players.indexWhere((p) => p.name == winningPlayer);
        winnerIsDealer = (winnerIdx == dealerIndex);
      }

      int dealerBonusTai = 0;
      if (winnerIsDealer) {
        if (consecutiveDealerCount > 1) {
          // Formula: (consecutive count × 2) + 1
          // e.g. 連一=3, 連二=5, 連五=11
          int n = consecutiveDealerCount - 1;
          dealerBonusTai = (n * 2) + 1;
        } else {
          dealerBonusTai = 1; // Base dealer bonus
        }
        localEffectiveFan += dealerBonusTai;
        displayRules.add({
          'name': consecutiveDealerCount > 1
              ? '${AppLocalizations.twConsecutiveDealer} (${AppLocalizations.consecutiveDealerCount(consecutiveDealerCount - 1)})'
              : AppLocalizations.twDealerBonusBase,
          'fan': dealerBonusTai,
        });
      }

      totalPoints = baseTai + (localEffectiveFan * taiValue);
    } else {
      int discardScore = _getScoreFromFan(localEffectiveFan);

      bool countsAsSelfDraw = isSelfDraw;
      if (flowerCount >= 7 || selectedSpecialCondition == 'Heavenly Hand') {
        countsAsSelfDraw = true;
      }

      if (countsAsSelfDraw) {
        if (localEffectiveFan < 1) {
          totalPoints = 1;
        } else {
          totalPoints = discardScore ~/ 2;
        }
      } else {
        totalPoints = discardScore;
      }
    }
  }

  void _calculateTwFlowerFan(int localEffectiveFan) {
    int seatIndex = 0;
    if (seatWind == 'East') {
      seatIndex = 1;
    } else if (seatWind == 'South') {
      seatIndex = 2;
    } else if (seatWind == 'West') {
      seatIndex = 3;
    } else if (seatWind == 'North') {
      seatIndex = 4;
    }

    String properFlower = '${seatIndex}f';
    String properSeason = '${seatIndex + 4}f';

    int flowerFan = 0;
    for (var entry in selectedFlowers.entries) {
      if (!entry.value) continue;
      if (entry.key == properFlower || entry.key == properSeason) {
        flowerFan += 2;
        displayRules.add({
          'name': '${AppLocalizations.twProperFlower} (${entry.key})',
          'fan': 2,
        });
      } else {
        flowerFan += 1;
        displayRules.add({
          'name': '${AppLocalizations.twWrongFlower} (${entry.key})',
          'fan': 1,
        });
      }
    }

    localEffectiveFan += flowerFan;

    bool winnerIsDealer = false;
    if (dealerIndex != null && winningPlayer != null) {
      int winnerIdx = players.indexWhere((p) => p.name == winningPlayer);
      winnerIsDealer = (winnerIdx == dealerIndex);
    }
    if (winnerIsDealer) {
      int dealerBonusTai;
      if (consecutiveDealerCount > 1) {
        int n = consecutiveDealerCount - 1;
        dealerBonusTai = (n * 2) + 1;
      } else {
        dealerBonusTai = 1;
      }
      localEffectiveFan += dealerBonusTai;
      displayRules.add({
        'name': consecutiveDealerCount > 1
            ? '${AppLocalizations.twConsecutiveDealer} (${AppLocalizations.consecutiveDealerCount(consecutiveDealerCount - 1)})'
            : AppLocalizations.twDealerBonusBase,
        'fan': dealerBonusTai,
      });
    }

    effectiveFan = localEffectiveFan;

    int baseTai = minFan;
    int taiValue = maxFan;
    totalPoints = baseTai + (localEffectiveFan * taiValue);
  }

  int _getScoreFromFan(int fan) {
    if (fan <= 0) return 1;
    if (fan == 1) return 2;
    if (fan == 2) return 4;
    if (fan == 3) return 8;
    if (fan == 4) return 16;
    if (fan == 5) return 24;
    if (fan == 6) return 32;
    if (fan == 7) return 48;
    if (fan == 8) return 64;
    if (fan == 9) return 96;
    if (fan == 10) return 128;
    if (fan == 11) return 192;
    if (fan == 12) return 256;
    if (fan >= 13) return 384;
    return 384;
  }

  // =============================================
  //  Asset helpers
  // =============================================

  String getAssetPath(String tile) {
    String suit = tile.substring(1);
    String folder = '';
    switch (suit) {
      case 'm':
        folder = 'characters';
        break;
      case 'p':
        folder = 'dots';
        break;
      case 's':
        folder = 'bamboo';
        break;
      case 'z':
        folder = 'honors';
        break;
      case 'f':
        folder = 'flowers';
        break;
    }
    return 'assets/images/tiles/$folder/$tile.png';
  }

  // =============================================
  //  Score submission (returns data for UI to pop)
  // =============================================

  /// Builds the score-change map. Returns null if data is invalid.
  Map<String, dynamic>? buildSubmitResult() {
    Map<String, int> scoreChanges = {};

    String getId(String name) {
      return players.firstWhere((p) => p.name == name).id.toString();
    }

    if (isSelfDraw && winningPlayer != null) {
      for (var player in players) {
        if (player.name != winningPlayer) {
          scoreChanges[getId(player.name)] = -totalPoints;
        }
      }
      scoreChanges[getId(winningPlayer!)] =
          totalPoints * (players.length - 1);
    } else if (!isSelfDraw && winningPlayer != null && discardPlayer != null) {
      scoreChanges[getId(discardPlayer!)] = -totalPoints;
      scoreChanges[getId(winningPlayer!)] = totalPoints;
    }

    return {
      'scores': scoreChanges,
      'winningPlayer': winningPlayer,
      'isSelfDraw': isSelfDraw,
      'discardPlayer': isSelfDraw ? null : discardPlayer,
      'totalPoints': totalPoints,
    };
  }
}
