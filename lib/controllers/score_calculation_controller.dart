import 'package:flutter/foundation.dart';
import '../models/player.dart';
import '../models/rule.dart';
import '../models/game_mode.dart';
import '../models/tw_hand.dart';
import '../logic/tw_pattern_evaluator.dart';
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
    'Flower Win',
    'Kong Win',
    'Last 7 Tiles',
    'Last 10 Tiles',
    'Under the Sea',
    'Heavenly Hand',
    'Earthly Hand',
  ];

  List<String> get activeSpecialConditions =>
      gameMode == GameMode.taiwan ? twSpecialConditions : specialConditions;

  bool isAnalyzing = false;
  List<String> selectedTiles = [];
  TwHand? twHand;
  List<Map<String, dynamic>> matchedRulesDetails = [];
  List<Map<String, dynamic>> displayRules = [];

  int totalPoints = 0;
  int _dealerBonusTai = 0; // Tracks 連莊 tai for dealer-pays scenarios
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
      final validPlayers = players
          .where((p) => p.name != winningPlayer)
          .toList();
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
      case 'Flower Win':
        return AppLocalizations.twFlowerWin;
      case 'Kong Win':
        return AppLocalizations.twKongWin;
      case 'Heavenly Hand':
        return AppLocalizations.ruleHeavenlyHand;
      case 'Earthly Hand':
        return AppLocalizations.ruleEarthlyHand;
      case 'Under the Sea':
        return AppLocalizations.twUnderTheSea;
      case 'Last 7 Tiles':
        return AppLocalizations.twLastSevenTiles;
      case 'Last 10 Tiles':
        return AppLocalizations.twLastTenTiles;
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

  /// Recalculate fan using the appropriate method for the current mode.
  void _recalculateFan() {
    if (twHand != null) {
      calculateFanFromTwHand();
    } else if (selectedTiles.isNotEmpty) {
      calculateFanFromTiles();
    }
  }

  void setSelfDraw(bool value) {
    if (value == isSelfDraw) return;
    isSelfDraw = value;
    _ensureValidDiscardPlayer();
    _recalculateFan();
    calculateScore();
    notifyListeners();
  }

  void setWinningPlayer(String? newValue) {
    if (newValue == null) return;
    winningPlayer = newValue;
    _updateSeatWind();
    _ensureValidDiscardPlayer();
    _recalculateFan();
    calculateScore();
    notifyListeners();
  }

  void setDiscardPlayer(String? newValue) {
    if (newValue == null) return;
    discardPlayer = newValue;
    _recalculateFan();
    calculateScore();
    notifyListeners();
  }

  void setRoundWind(String? newValue) {
    if (newValue == null) return;
    roundWind = newValue;
    _recalculateFan();
    calculateScore();
    notifyListeners();
  }

  void setSeatWind(String? newValue) {
    if (newValue == null) return;
    seatWind = newValue;
    _recalculateFan();
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
    _recalculateFan();
    calculateScore();
    notifyListeners();
  }

  void setSelectedTiles(List<String> tiles) {
    selectedTiles = tiles;
    calculateFanFromTiles();
    calculateScore();
    notifyListeners();
  }

  void setTwHand(TwHand hand) {
    twHand = hand;
    // Also set selectedTiles for backward compatibility (flower display, etc.)
    selectedTiles = hand.allTiles;
    calculateFanFromTwHand();
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
    bool hasBigThreeDragons = matchedRules.any(
      (r) => r['name'] == AppLocalizations.ruleBigThreeDragons,
    );
    bool hasSmallThreeDragons = matchedRules.any(
      (r) => r['name'] == AppLocalizations.ruleSmallThreeDragons,
    );

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
    bool hasBigFourWinds = matchedRules.any(
      (r) => r['name'] == AppLocalizations.ruleBigFourWinds,
    );
    bool hasSmallFourWinds = matchedRules.any(
      (r) => r['name'] == AppLocalizations.ruleSmallFourWinds,
    );

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
          'name':
              '${AppLocalizations.ruleRoundWind} (${getLocalizedWind(roundWind)})',
          'fan': windFan,
        });
      }

      if (seatWindTile != null && (windCounts[seatWindTile] ?? 0) >= 3) {
        int windFan = gameMode == GameMode.taiwan ? 2 : 1;
        calculatedFan += windFan;
        matchedRules.add({
          'name':
              '${AppLocalizations.ruleSeatWind} (${getLocalizedWind(seatWind)})',
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

  /// Calculate fan/tai from TwHand using the TwPatternEvaluator.
  void calculateFanFromTwHand() {
    if (twHand == null) return;
    final hand = twHand!;

    // Determine flower context
    int flowerCount = selectedFlowers.values.where((v) => v).length;
    int seatIndex = _seatIndex();
    String properFlower = '${seatIndex}f';
    String properSeason = '${seatIndex + 4}f';
    int properFlowerCount = 0;
    int wrongFlowerCount = 0;
    for (final entry in selectedFlowers.entries) {
      if (!entry.value) continue;
      if (entry.key == properFlower || entry.key == properSeason) {
        properFlowerCount++;
      } else {
        wrongFlowerCount++;
      }
    }

    // Determine if one or two flower sets are complete
    bool hasSpring = true, hasSeasons = true;
    for (int i = 1; i <= 4; i++) {
      if (selectedFlowers['${i}f'] != true) hasSpring = false;
    }
    for (int i = 5; i <= 8; i++) {
      if (selectedFlowers['${i}f'] != true) hasSeasons = false;
    }
    bool hasOneFlowerSet = hasSpring || hasSeasons;
    bool hasTwoFlowerSets = hasSpring && hasSeasons;

    // When a flower set is complete, its individual flowers do NOT
    // count separately — only the set bonus (一台花 / 兩台花) applies.
    // Flowers outside the complete set still count individually.
    if (hasSpring) {
      for (int i = 1; i <= 4; i++) {
        final key = '${i}f';
        if (selectedFlowers[key] == true) {
          if (key == properFlower || key == properSeason) {
            properFlowerCount--;
          } else {
            wrongFlowerCount--;
          }
        }
      }
    }
    if (hasSeasons) {
      for (int i = 5; i <= 8; i++) {
        final key = '${i}f';
        if (selectedFlowers[key] == true) {
          if (key == properFlower || key == properSeason) {
            properFlowerCount--;
          } else {
            wrongFlowerCount--;
          }
        }
      }
    }

    final result = TwPatternEvaluator.evaluate(
      hand: hand,
      isSelfDraw: isSelfDraw,
      seatWind: seatWind,
      roundWind: roundWind,
      flowerCount: flowerCount,
      properFlowerCount: properFlowerCount,
      wrongFlowerCount: wrongFlowerCount,
      hasOneFlowerSet: hasOneFlowerSet,
      hasTwoFlowerSets: hasTwoFlowerSets,
      specialCondition: selectedSpecialCondition,
      concealedKongCount: hand.concealedKongCount,
    );

    // Convert to display format
    List<Map<String, dynamic>> matchedRules = [];
    for (final m in result.finalMatches) {
      matchedRules.add({
        'name': _resolvePatternName(m.nameKey),
        'fan': m.tai,
      });
    }

    fanCount = result.totalTai;
    matchedRulesDetails = matchedRules;
  }

  int _seatIndex() {
    if (seatWind == 'East') return 1;
    if (seatWind == 'South') return 2;
    if (seatWind == 'West') return 3;
    if (seatWind == 'North') return 4;
    return 1;
  }

  bool _shouldShowDealerPaysExtra({required bool winnerIsDealer}) {
    if (winnerIsDealer) return false;
    if (isSelfDraw) return true;
    if (discardPlayer == null) return false;

    final discardIdx = players.indexWhere((p) => p.name == discardPlayer);
    return discardIdx == dealerIndex;
  }

  /// Convert a flower key like '1f' to a human-readable name.
  String _flowerKeyToName(String key) {
    const names = {
      '1f': '春 Spring',
      '2f': '夏 Summer',
      '3f': '秋 Autumn',
      '4f': '冬 Winter',
      '5f': '梅 Plum',
      '6f': '蘭 Orchid',
      '7f': '菊 Chrysanthemum',
      '8f': '竹 Bamboo',
    };
    return names[key] ?? key;
  }

  /// Resolve a pattern nameKey to its localized display name.
  String _resolvePatternName(String key) {
    // Map pattern nameKeys to AppLocalizations getters
    final map = <String, String>{
      'ruleNoFlowers': AppLocalizations.ruleNoFlowers,
      'twProperFlower': AppLocalizations.twProperFlower,
      'twWrongFlower': AppLocalizations.twWrongFlower,
      'twOneFlowerSet': AppLocalizations.twOneFlowerSet,
      'twTwoFlowerSets': AppLocalizations.twTwoFlowerSets,
      'twDragonPong': AppLocalizations.twDragonPong,
      'twProperWind': AppLocalizations.twProperWind,
      'twOrdinaryWind': AppLocalizations.twOrdinaryWind,
      'twNoHonors': AppLocalizations.twNoHonors,
      'twNoHonorsNoFlowers': AppLocalizations.twNoHonorsNoFlowers,
      'ruleSelfDraw': AppLocalizations.ruleSelfDraw,
      'ruleMenQianQing': AppLocalizations.ruleMenQianQing,
      'twConcealedSelfDraw': AppLocalizations.twConcealedSelfDraw,
      'ruleAllChows': AppLocalizations.ruleAllChows,
      'twNoHonorsNoFlowersPingHu': AppLocalizations.twNoHonorsNoFlowersPingHu,
      'twEyeOf258': AppLocalizations.twEyeOf258,
      'twDoublePong': AppLocalizations.twDoublePong,
      'twTrueSingle': AppLocalizations.twTrueSingle,
      'twDingBonus': AppLocalizations.twDingBonus,
      'twExposedKong': AppLocalizations.twExposedKong,
      'twConcealedKongTai': AppLocalizations.twConcealedKongTai,
      'twTwoConcealedPongs': AppLocalizations.twTwoConcealedPongs,
      'twThreeConcealedPongs': AppLocalizations.twThreeConcealedPongs,
      'twFourConcealedPongs': AppLocalizations.twFourConcealedPongs,
      'twFiveConcealedPongs': AppLocalizations.twFiveConcealedPongs,
      'twIdenticalSequenceTwo': AppLocalizations.twIdenticalSequenceTwo,
      'twIdenticalSequenceThree': AppLocalizations.twIdenticalSequenceThree,
      'twIdenticalSequenceFour': AppLocalizations.twIdenticalSequenceFour,
      'twFiveIdenticalSeq': AppLocalizations.twFiveIdenticalSeq,
      'twMixedDoubleSeq': AppLocalizations.twMixedDoubleSeq,
      'twMixedTripleSeq': AppLocalizations.twMixedTripleSeq,
      'twFourToOne': AppLocalizations.twFourToOne,
      'twFourToTwo': AppLocalizations.twFourToTwo,
      'twFourToFour': AppLocalizations.twFourToFour,
      'twExposedDragon': AppLocalizations.twExposedDragon,
      'twConcealedDragon': AppLocalizations.twConcealedDragon,
      'twExposedMixedDragon': AppLocalizations.twExposedMixedDragon,
      'twConcealedMixedDragon': AppLocalizations.twConcealedMixedDragon,
      'twFiveGates': AppLocalizations.twFiveGates,
      'twMissingOneSuit': AppLocalizations.twMissingOneSuit,
      'ruleMixedOneSuit': AppLocalizations.ruleMixedOneSuit,
      'rulePureOneSuit': AppLocalizations.rulePureOneSuit,
      'ruleAllPongs': AppLocalizations.ruleAllPongs,
      'twAllSimples': AppLocalizations.twAllSimples,
      'twMixedTerminalChows': AppLocalizations.twMixedTerminalChows,
      'twPureTerminalChows': AppLocalizations.twPureTerminalChows,
      'twQuanHunYao': AppLocalizations.twQuanHunYao,
      'twBanDaiHunYao': AppLocalizations.twBanDaiHunYao,
      'twMixedTerminalsPongs': AppLocalizations.twMixedTerminalsPongs,
      'twPureTerminalsTw': AppLocalizations.twPureTerminalsTw,
      'ruleAllHonors': AppLocalizations.ruleAllHonors,
      'ruleBigFourWinds': AppLocalizations.ruleBigFourWinds,
      'ruleSmallFourWinds': AppLocalizations.ruleSmallFourWinds,
      'twBigThreeWinds': AppLocalizations.twBigThreeWinds,
      'twSmallThreeWinds': AppLocalizations.twSmallThreeWinds,
      'ruleBigThreeDragons': AppLocalizations.ruleBigThreeDragons,
      'ruleSmallThreeDragons': AppLocalizations.ruleSmallThreeDragons,
      'twMiguiTw': AppLocalizations.twMiguiTw,
      'ruleNineGates': AppLocalizations.ruleNineGates,
      'ruleEighteenArhats': AppLocalizations.ruleEighteenArhats,
      'ruleThirteenOrphans': AppLocalizations.ruleThirteenOrphans,
      'twBigThreeBrothers': AppLocalizations.twBigThreeBrothers,
      'twTwoBrothers': AppLocalizations.twTwoBrothers,
      'twSmallThreeBrothers': AppLocalizations.twSmallThreeBrothers,
      'twBigThreeSisters': AppLocalizations.twBigThreeSisters,
      'twSmallThreeSisters': AppLocalizations.twSmallThreeSisters,
      'twAllRevealed': AppLocalizations.twAllRevealed,
      'twHalfRevealed': AppLocalizations.twHalfRevealed,
      'twOldYoung': AppLocalizations.twOldYoung,
      'twJianJianHu': AppLocalizations.twJianJianHu,
      'twSixteenNonMatching': AppLocalizations.twSixteenNonMatching,
      'twChickenHand': AppLocalizations.twChickenHand,
    };
    return map[key] ?? key;
  }

  void calculateScore() {
    _calculateScoreInternal();
  }

  void _calculateScoreInternal() {
    // ── Manual mode: user typed a fan/tai number with no tiles,
    //    no flowers, and no special condition ────────────────────────
    bool hasFlowers = selectedFlowers.values.any((v) => v);
    bool hasSpecialCondition = selectedSpecialCondition != 'None';

    if (selectedTiles.isEmpty && !hasFlowers && !hasSpecialCondition) {
      effectiveFan = fanCount;
      _dealerBonusTai = 0;
      displayRules = [
        {
          'name': gameMode == GameMode.taiwan
              ? AppLocalizations.userSetTai(fanCount)
              : AppLocalizations.userSetFan(fanCount),
          'fan': fanCount,
        },
      ];
      // In manual mode the entered number IS the per-person score
      totalPoints = fanCount;
      return;
    }

    // ── Tile-based calculation ──────────────────────────────────────
    int localEffectiveFan = fanCount;
    displayRules = List.from(matchedRulesDetails);

    // ── TW evaluator path: when twHand is set, the evaluator already
    //    computed all fans (flowers, special conditions, etc).
    //    Only add individual flower display names + dealer bonus. ────
    if (twHand != null && gameMode == GameMode.taiwan) {
      // Rename flower entries in displayRules to include flower names
      int flowerCount = selectedFlowers.values.where((v) => v).length;
      if (flowerCount > 0) {
        int seatIndex = _seatIndex();
        String properFlower = '${seatIndex}f';
        String properSeason = '${seatIndex + 4}f';

        // Build ordered lists of flower names
        final properNames = <String>[];
        final wrongNames = <String>[];
        for (var entry in selectedFlowers.entries) {
          if (!entry.value) continue;
          final flowerName = _flowerKeyToName(entry.key);
          if (entry.key == properFlower || entry.key == properSeason) {
            properNames.add(flowerName);
          } else {
            wrongNames.add(flowerName);
          }
        }

        // Rename proper flower entries to include the flower name
        int pi = 0;
        for (int i = 0; i < displayRules.length && pi < properNames.length; i++) {
          if (displayRules[i]['name'] == AppLocalizations.twProperFlower) {
            displayRules[i] = Map<String, dynamic>.from(displayRules[i]);
            displayRules[i]['name'] = '${AppLocalizations.twProperFlower} (${properNames[pi]})';
            pi++;
          }
        }

        // Rename wrong flower entries to include the flower name
        int wi = 0;
        for (int i = 0; i < displayRules.length && wi < wrongNames.length; i++) {
          if (displayRules[i]['name'] == AppLocalizations.twWrongFlower) {
            displayRules[i] = Map<String, dynamic>.from(displayRules[i]);
            displayRules[i]['name'] = '${AppLocalizations.twWrongFlower} (${wrongNames[wi]})';
            wi++;
          }
        }
      }

      // ── TW special winning conditions ──────────────────────────
      if (selectedSpecialCondition != 'None') {
        int specialFan = 0;
        String? specialName;
        if (selectedSpecialCondition == 'Flower Win') {
          specialFan = 1;
          specialName = AppLocalizations.twFlowerWin;
        } else if (selectedSpecialCondition == 'Kong Win') {
          specialFan = 1;
          specialName = AppLocalizations.twKongWin;
        } else if (selectedSpecialCondition == 'Kong on Kong/Flower') {
          // Legacy alias for backward compatibility.
          specialFan = 1;
          specialName = AppLocalizations.ruleKongOnKong;
        } else if (selectedSpecialCondition == 'Last 7 Tiles') {
          specialFan = 20;
          specialName = AppLocalizations.twLastSevenTiles;
        } else if (selectedSpecialCondition == 'Last 10 Tiles') {
          specialFan = 10;
          specialName = AppLocalizations.twLastTenTiles;
        } else if (selectedSpecialCondition == 'Under the Sea') {
          specialFan = 20;
          specialName = AppLocalizations.twUnderTheSea;
        } else if (selectedSpecialCondition == 'Heavenly Hand') {
          specialFan = 100;
          specialName = AppLocalizations.ruleHeavenlyHand;
        } else if (selectedSpecialCondition == 'Earthly Hand') {
          specialFan = 80;
          specialName = AppLocalizations.ruleEarthlyHand;
        }
        if (specialName != null) {
          localEffectiveFan += specialFan;
          displayRules.add({'name': specialName, 'fan': specialFan});
        }
      }

      // ── 雞胡 — Chicken Hand ────────────────────────────────────
      // If total fan (excluding dealer/base) is exactly 1 and win
      // is by discard → fixed 10 tai payout, no base tai, no dealer.
      if (!isSelfDraw && localEffectiveFan == 1) {
        displayRules.add({
          'name': _resolvePatternName('twChickenHand'),
          'fan': 10,
        });
        effectiveFan = 10;
        _dealerBonusTai = 0;
        totalPoints = 10;
        return;
      }

      // Dealer bonus (連莊)
      bool winnerIsDealer = false;
      if (dealerIndex != null && winningPlayer != null) {
        int winnerIdx = players.indexWhere((p) => p.name == winningPlayer);
        winnerIsDealer = (winnerIdx == dealerIndex);
      }

      int dealerBonusTai = 0;
      if (dealerIndex != null) {
        if (consecutiveDealerCount > 1) {
          int n = consecutiveDealerCount - 1;
          dealerBonusTai = (n * 2) + 1;
        } else {
          dealerBonusTai = 1;
        }
      }
      _dealerBonusTai = dealerBonusTai;

      if (winnerIsDealer && dealerBonusTai > 0) {
        localEffectiveFan += dealerBonusTai;
        displayRules.add({
          'name': consecutiveDealerCount > 1
              ? '${AppLocalizations.twConsecutiveDealer} (${AppLocalizations.consecutiveDealerCount(consecutiveDealerCount - 1)})'
              : AppLocalizations.twDealerBonusBase,
          'fan': dealerBonusTai,
        });
      } else if (!winnerIsDealer && dealerBonusTai > 0) {
        if (_shouldShowDealerPaysExtra(winnerIsDealer: winnerIsDealer)) {
          displayRules.add({
            'name': consecutiveDealerCount > 1
                ? '${AppLocalizations.twConsecutiveDealer} (${AppLocalizations.consecutiveDealerCount(consecutiveDealerCount - 1)}) [${AppLocalizations.twDealerPaysExtra}]'
                : '${AppLocalizations.twDealerBonusBase} [${AppLocalizations.twDealerPaysExtra}]',
            'fan': dealerBonusTai,
          });
        }
      }

      effectiveFan = localEffectiveFan;
      int baseTai = minFan;
      int taiValue = 1; // TW: 1 fan = 1 score
      // Show base tai in the item list
      displayRules.add({
        'name': AppLocalizations.baseTai,
        'fan': baseTai,
      });
      totalPoints = baseTai + (localEffectiveFan * taiValue);
      return;
    }

    // ── Legacy path (HK mode or TW without twHand) ─────────────────

    // Check for Hidden Treasure combination
    bool hasAllPongs = displayRules.any(
      (r) => r['name'] == AppLocalizations.ruleAllPongs,
    );
    bool isMenQianQing = selectedSpecialCondition == 'Men Qian Qing';

    if (hasAllPongs && isMenQianQing) {
      displayRules.removeWhere(
        (r) => r['name'] == AppLocalizations.ruleAllPongs,
      );
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
          displayRules.removeWhere(
            (r) => r['name'] == AppLocalizations.ruleSelfDraw,
          );
          specialFan = 5;
          specialName = AppLocalizations.twConcealedSelfDraw;
        }
      } else if (selectedSpecialCondition == 'Robbing the Kong') {
        specialFan = 1;
        specialName = AppLocalizations.ruleRobbingKong;
      } else if (selectedSpecialCondition == 'Haidilao') {
        specialFan = 1;
        specialName = AppLocalizations.ruleHaidilao;
      } else if (selectedSpecialCondition == 'Flower Win') {
        specialFan = 1;
        specialName = AppLocalizations.twFlowerWin;
      } else if (selectedSpecialCondition == 'Kong Win') {
        specialFan = 1;
        specialName = AppLocalizations.twKongWin;
      } else if (selectedSpecialCondition == 'Kong on Kong/Flower') {
        // Legacy alias for backward compatibility.
        specialFan = isTW ? 1 : 2;
        specialName = AppLocalizations.ruleKongOnKong;
      } else if (selectedSpecialCondition == 'Heavenly Hand') {
        specialFan = isTW ? 100 : 13;
        specialName = AppLocalizations.ruleHeavenlyHand;
      } else if (selectedSpecialCondition == 'Earthly Hand') {
        specialFan = isTW ? 80 : 13;
        specialName = AppLocalizations.ruleEarthlyHand;
      } else if (selectedSpecialCondition == 'Under the Sea') {
        specialFan = 20;
        specialName = AppLocalizations.twUnderTheSea;
      } else if (selectedSpecialCondition == 'Last 7 Tiles') {
        specialFan = 20;
        specialName = AppLocalizations.twLastSevenTiles;
      } else if (selectedSpecialCondition == 'Last 10 Tiles') {
        specialFan = 10;
        specialName = AppLocalizations.twLastTenTiles;
      }

      if (specialName != null) {
        localEffectiveFan += specialFan;
        displayRules.add({'name': specialName, 'fan': specialFan});
      }
    }

    // Self-draw in manual mode
    bool hasSelfDrawRule = displayRules.any(
      (r) => r['name'] == AppLocalizations.ruleSelfDraw,
    );
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
          {'name': AppLocalizations.ruleSevenFlowers, 'fan': 3},
        ];
        localEffectiveFan = 3;
      }
    } else if (flowerCount == 8) {
      int val = 8;
      displayRules = [
        {'name': AppLocalizations.ruleEightImmortals, 'fan': val},
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
        displayRules.add({
          'name': AppLocalizations.ruleFlowerPlatform14,
          'fan': 2,
        });
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
        displayRules.add({
          'name': AppLocalizations.ruleFlowerPlatform58,
          'fan': 2,
        });
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
      int taiValue = 1; // TW: 1 fan = 1 score

      bool winnerIsDealer = false;
      if (dealerIndex != null && winningPlayer != null) {
        int winnerIdx = players.indexWhere((p) => p.name == winningPlayer);
        winnerIsDealer = (winnerIdx == dealerIndex);
      }

      // Always calculate dealer bonus tai (連莊)
      int dealerBonusTai = 0;
      if (dealerIndex != null) {
        if (consecutiveDealerCount > 1) {
          int n = consecutiveDealerCount - 1;
          dealerBonusTai = (n * 2) + 1;
        } else {
          dealerBonusTai = 1; // Base dealer bonus
        }
      }
      _dealerBonusTai = dealerBonusTai;

      if (winnerIsDealer && dealerBonusTai > 0) {
        // Dealer wins → bonus added to total (all losers pay more)
        localEffectiveFan += dealerBonusTai;
        displayRules.add({
          'name': consecutiveDealerCount > 1
              ? '${AppLocalizations.twConsecutiveDealer} (${AppLocalizations.consecutiveDealerCount(consecutiveDealerCount - 1)})'
              : AppLocalizations.twDealerBonusBase,
          'fan': dealerBonusTai,
        });
      } else if (!winnerIsDealer && dealerBonusTai > 0) {
        // Dealer is NOT the winner → show info; dealer pays extra in buildSubmitResult
        if (_shouldShowDealerPaysExtra(winnerIsDealer: winnerIsDealer)) {
          displayRules.add({
            'name': consecutiveDealerCount > 1
                ? '${AppLocalizations.twConsecutiveDealer} (${AppLocalizations.consecutiveDealerCount(consecutiveDealerCount - 1)}) [${AppLocalizations.twDealerPaysExtra}]'
                : '${AppLocalizations.twDealerBonusBase} [${AppLocalizations.twDealerPaysExtra}]',
            'fan': dealerBonusTai,
          });
        }
      }

      // Show base tai in the item list
      displayRules.add({
        'name': AppLocalizations.baseTai,
        'fan': baseTai,
      });
      totalPoints = baseTai + (localEffectiveFan * taiValue);
    } else {
      _dealerBonusTai = 0; // HK mode: no dealer bonus
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
      final flowerName = _flowerKeyToName(entry.key);
      if (entry.key == properFlower || entry.key == properSeason) {
        flowerFan += 2;
        displayRules.add({
          'name': '${AppLocalizations.twProperFlower} ($flowerName)',
          'fan': 2,
        });
      } else {
        flowerFan += 1;
        displayRules.add({
          'name': '${AppLocalizations.twWrongFlower} ($flowerName)',
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

    // Always calculate dealer bonus tai (連莊)
    int dealerBonusTai = 0;
    if (dealerIndex != null) {
      if (consecutiveDealerCount > 1) {
        int n = consecutiveDealerCount - 1;
        dealerBonusTai = (n * 2) + 1;
      } else {
        dealerBonusTai = 1;
      }
    }
    _dealerBonusTai = dealerBonusTai;

    if (winnerIsDealer && dealerBonusTai > 0) {
      localEffectiveFan += dealerBonusTai;
      displayRules.add({
        'name': consecutiveDealerCount > 1
            ? '${AppLocalizations.twConsecutiveDealer} (${AppLocalizations.consecutiveDealerCount(consecutiveDealerCount - 1)})'
            : AppLocalizations.twDealerBonusBase,
        'fan': dealerBonusTai,
      });
    } else if (!winnerIsDealer && dealerBonusTai > 0) {
      if (_shouldShowDealerPaysExtra(winnerIsDealer: winnerIsDealer)) {
        displayRules.add({
          'name': consecutiveDealerCount > 1
              ? '${AppLocalizations.twConsecutiveDealer} (${AppLocalizations.consecutiveDealerCount(consecutiveDealerCount - 1)}) [${AppLocalizations.twDealerPaysExtra}]'
              : '${AppLocalizations.twDealerBonusBase} [${AppLocalizations.twDealerPaysExtra}]',
          'fan': dealerBonusTai,
        });
      }
    }

    effectiveFan = localEffectiveFan;

    int baseTai = minFan;
    int taiValue = 1; // TW: 1 fan = 1 score
    // Show base tai in the item list
    displayRules.add({
      'name': AppLocalizations.baseTai,
      'fan': baseTai,
    });
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
      bool isTw = gameMode == GameMode.taiwan;
      int winnerIdx = players.indexWhere((p) => p.name == winningPlayer);
      bool winnerIsDealer =
          dealerIndex != null && winnerIdx == dealerIndex;

      int winnerTotal = 0;
      for (var player in players) {
        if (player.name != winningPlayer) {
          int payment = totalPoints;
          // TW: dealer pays extra 連莊 when NOT the winner
          if (isTw && !winnerIsDealer && _dealerBonusTai > 0) {
            int playerIdx = players.indexOf(player);
            if (playerIdx == dealerIndex) {
              payment += _dealerBonusTai * maxFan;
            }
          }
          scoreChanges[getId(player.name)] = -payment;
          winnerTotal += payment;
        }
      }
      scoreChanges[getId(winningPlayer!)] = winnerTotal;
    } else if (!isSelfDraw && winningPlayer != null && discardPlayer != null) {
      bool isTw = gameMode == GameMode.taiwan;
      int discardIdx = players.indexWhere((p) => p.name == discardPlayer);
      bool discardIsDealer =
          dealerIndex != null && discardIdx == dealerIndex;
      int winnerIdx = players.indexWhere((p) => p.name == winningPlayer);
      bool winnerIsDealer =
          dealerIndex != null && winnerIdx == dealerIndex;

      int payment = totalPoints;
      // TW: dealer pays extra 連莊 when dealing the winning tile to someone else
      if (isTw && discardIsDealer && !winnerIsDealer && _dealerBonusTai > 0) {
        payment += _dealerBonusTai * maxFan;
      }
      scoreChanges[getId(discardPlayer!)] = -payment;
      scoreChanges[getId(winningPlayer!)] = payment;
    }

    return {
      'scores': scoreChanges,
      'winningPlayer': winningPlayer,
      'isSelfDraw': isSelfDraw,
      'discardPlayer': isSelfDraw ? null : discardPlayer,
      'totalPoints': totalPoints,
      'fanCount': fanCount,
      'effectiveFan': effectiveFan,
      'patterns': _buildPatternIds(),
    };
  }

  /// Derives a set of standardized pattern ID strings from display rules
  /// and special conditions for the achievement system.
  List<String> _buildPatternIds() {
    final patterns = <String>[];

    // Map localized rule names → achievement pattern IDs
    final ruleMapping = {
      AppLocalizations.ruleAllPongs: 'allPongs',
      AppLocalizations.ruleHiddenTreasure: 'allPongs',
      AppLocalizations.ruleMenQianQing: 'concealedHand',
      AppLocalizations.ruleSelfDraw: 'selfDraw',
      AppLocalizations.ruleHaidilao: 'lastTileWin',
      AppLocalizations.ruleRobbingKong: 'robbingKong',
      AppLocalizations.ruleKongOnKong: 'kongWin',
      AppLocalizations.twKongWin: 'kongWin',
      AppLocalizations.twFlowerWin: 'flowerWin',
      AppLocalizations.ruleHeavenlyHand: 'heavenlyHand',
      AppLocalizations.ruleEarthlyHand: 'earthlyHand',
      AppLocalizations.ruleBigThreeDragons: 'bigThreeDragons',
      AppLocalizations.ruleBigFourWinds: 'bigFourWinds',
    };

    // TW-specific rule names
    if (gameMode == GameMode.taiwan) {
      ruleMapping[AppLocalizations.twConcealedSelfDraw] = 'concealedSelfDrawn';
      ruleMapping[AppLocalizations.twDeclaredReady] = 'declaredReady';
      ruleMapping[AppLocalizations.twUnderTheSea] = 'lastTileWin';
      ruleMapping[AppLocalizations.twNoHonorsNoFlowersPingHu] = 'commonHand';
      ruleMapping[AppLocalizations.twChickenHand] = 'chickenHand';
      ruleMapping[AppLocalizations.twMiguiTw] = 'likuliku';
      ruleMapping[AppLocalizations.twHeavenlyReady] = 'heavenlyListen';
      ruleMapping[AppLocalizations.twSevenRobOne] = 'sevenRobOne';
    }

    for (final rule in displayRules) {
      final name = rule['name'] as String?;
      if (name != null && ruleMapping.containsKey(name)) {
        final id = ruleMapping[name]!;
        if (!patterns.contains(id)) {
          patterns.add(id);
        }
      }
    }

    // Check for all-one-suit patterns from matched rules
    for (final rule in matchedRulesDetails) {
      final name = rule['name'] as String?;
      // Detect full flush / all-one-suit by fan value (7 in HK)
      if (name != null) {
        if (ruleMapping.containsKey(name)) {
          final id = ruleMapping[name]!;
          if (!patterns.contains(id)) patterns.add(id);
        }
      }
    }

    // Detect special patterns from tile analysis that may use localized keys
    // Check for thirteen orphans and nine gates via fan cap
    if (gameMode == GameMode.hongKong) {
      for (final rule in displayRules) {
        final fan = rule['fan'] as int? ?? 0;
        final name = rule['name'] as String? ?? '';
        if (fan >= 13 || name.contains('十三') || name.contains('Thirteen')) {
          if (!patterns.contains('thirteenOrphans') &&
              (name.contains('十三') || name.contains('Thirteen'))) {
            patterns.add('thirteenOrphans');
          }
          if (!patterns.contains('nineGates') &&
              (name.contains('九子') || name.contains('Nine Gates'))) {
            patterns.add('nineGates');
          }
        }
      }
      // All one suit detection
      for (final rule in displayRules) {
        final name = rule['name'] as String? ?? '';
        if (name.contains('清一色') ||
            name.contains('Full Flush') ||
            name.contains('One Suit')) {
          if (!patterns.contains('allOneSuit')) patterns.add('allOneSuit');
        }
      }
    }

    // Flower win detection for TW
    if (gameMode == GameMode.taiwan) {
      final flowerCount = selectedFlowers.values.where((v) => v).length;
      if (flowerCount >= 7) {
        if (!patterns.contains('flowerWin')) patterns.add('flowerWin');
      }
    }

    return patterns;
  }
}
