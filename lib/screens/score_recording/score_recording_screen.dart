import 'package:flutter/material.dart';
import '../../models/player.dart';
import '../../services/score_service.dart';
import '../../services/player_group_service.dart';
import '../../models/player_stats.dart';
import '../../models/game_mode.dart';
import '../../localization/app_localizations.dart';
import '../../routes/app_routes.dart';
import '../../utils/la_settlement.dart';
import '../../utils/achievement_checker.dart';
import '../../services/achievement_service.dart';
import '../../models/achievement.dart';
import '../../utils/achievement_registry.dart';
import 'widgets/stats_dialog.dart';
import 'widgets/game_table_layout.dart';
import 'dart:async';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';

class ScoreRecordingScreen extends StatefulWidget {
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

  const ScoreRecordingScreen({
    super.key,
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

  @override
  State<ScoreRecordingScreen> createState() => _ScoreRecordingScreenState();
}

class _ScoreRecordingScreenState extends State<ScoreRecordingScreen> {

  int _dealerIndex = 0;

  int _prevalentWindIndex = 0;

  int _currentDealerGameCount = 1;

  int _totalWindRounds = 1;

  final ScoreService _scoreService = ScoreService();
  StreamSubscription? _scoreSubscription;
  late List<Player> _updatedPlayers;

  // La (拉) carry-over settlement for Taiwan Mahjong
  final LaSettlement _laSettlement = LaSettlement();

  // Round History for stats
  List<Map<String, dynamic>> _roundHistory = [];
  
  // Flag to check if round history is loaded
  // ignore: unused_field
  bool _isRoundHistoryLoaded = false;

  // ── Achievement tracking ──────────────────────────────────────
  /// Per-player counters keyed by player name.
  final Map<String, AchievementCounters> _achvCounters = {};
  /// Per-player progress keyed by player name → achievementId → progress.
  final Map<String, Map<String, AchievementProgress>> _achvProgress = {};
  
  @override
  void initState() {
    super.initState();
    
    // Load round history if group exists
    _loadRoundHistory();

    // Load achievement data for all players
    _loadAchievements();
    // Initialize player list
    _updatedPlayers = List.from(widget.players);
    
    // Defer ScoreService.initGame to after the build phase so that
    // notifyListeners() does not trigger markNeedsBuild() on the
    // ChangeNotifierProvider ancestor while the widget tree is still
    // being constructed.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scoreService.initGame(
        widget.players, 
        initialPublicScore: 0,
        currentRound: widget.currentRound,
        totalRounds: widget.totalRounds,
      );
    });
    
    // Subscribe to score changes safely
    try {
      // Subscribe to score changes
      _scoreSubscription = _scoreService.scoreStream.listen((gameData) {
        if (mounted) {
          setState(() {
            // Update player list to reflect latest scores
            _updatedPlayers = widget.players.map((player) {
              return player.copyWith(
                score: gameData[player.id.toString()] ?? player.score
              );
            }).toList();
          });
          // Save game state
          _saveGameState();
        }
      });
    } catch (e) {
      debugPrint('Error subscribing to score stream: $e');
    }
    
    // Initialize dealer and wind
    _dealerIndex = widget.initialDealerIndex ?? 0;
    _prevalentWindIndex = widget.initialPrevalentWindIndex ?? 0;
    _currentDealerGameCount = widget.initialDealerGameCount ?? 1;
    _totalWindRounds = widget.initialTotalWindRounds ?? 1;
    
    // Check if total rounds exceeded
    if (_scoreService.isGameEnd()) {
      // Delay execution to avoid direct navigation in initState
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showGameEndDialog();
      });
    }
  }

  Future<void> _loadRoundHistory() async {
      if (widget.groupName != null) {
          final group = await PlayerGroupService.loadGroup(widget.groupName!);
          if (group != null && group.roundHistory != null) {
              setState(() {
                  _roundHistory = List.from(group.roundHistory!);
                  _isRoundHistoryLoaded = true;
              });
          }
      }
      setState(() {
          _isRoundHistoryLoaded = true;
      });
  }

  // ── Achievement helpers ──────────────────────────────────────────

  /// Load counters & progress for every player from Firebase.
  Future<void> _loadAchievements() async {
    if (widget.groupName == null) return;
    for (final player in widget.players) {
      try {
        final data = await AchievementService.loadAll(
          widget.groupName!,
          player.name,
        );
        _achvCounters[player.name] = data.counters;
        _achvProgress[player.name] = data.progress;
      } catch (e) {
        debugPrint('Error loading achievements for ${player.name}: $e');
        _achvCounters[player.name] = const AchievementCounters();
        _achvProgress[player.name] = {};
      }
    }
  }

  /// Run achievement checker for every player after a scored round,
  /// persist updated data, and show unlock popups.
  Future<void> _checkAchievements({
    required Map<String, int> scoreChanges,
    String? winnerId,
    bool isSelfDraw = false,
    String? discarderId,
    int? fanCount,
    int? taiCount,
    List<String> patterns = const [],
  }) async {
    if (widget.groupName == null) return;

    final dealerId = widget.players[_dealerIndex].id.toString();
    final dealerWon = winnerId != null && winnerId == dealerId;
    final currentRound = _scoreService.getCurrentRound();
    final totalRounds = _scoreService.getTotalRounds();
    final isLastRound = totalRounds > 0 && currentRound >= totalRounds;
    final patternSet = patterns.toSet();

    // Pre-compute rankings for comeback detection
    final sortedByScore = List<Player>.from(_updatedPlayers)
      ..sort((a, b) {
        final sa = _scoreService.getPlayerScore(a.id.toString());
        final sb = _scoreService.getPlayerScore(b.id.toString());
        return sa.compareTo(sb);
      });
    final firstPlaceName = sortedByScore.last.name;
    final lastPlaceName = sortedByScore.first.name;

    final allNewlyUnlocked = <String, List<String>>{};

    for (final player in widget.players) {
      final pid = player.id.toString();
      final pName = player.name;
      final oldCounters =
          _achvCounters[pName] ?? const AchievementCounters();
      final oldProgress =
          _achvProgress[pName] ?? <String, AchievementProgress>{};

      // Determine per-player facts
      final isWinner = winnerId != null && winnerId == pName;
      final dealtIn = discarderId != null && discarderId == pName;
      final isDealer = pid == dealerId;
      final change = scoreChanges[pid] ?? 0;

      // Check whether player was last place BEFORE this round's scores
      // We already applied scores before calling this, so subtract back.
      final prevScore =
          _scoreService.getPlayerScore(pid) - change;
      final wasLast = widget.players.every((other) {
        if (other.id == player.id) return true;
        final os = _scoreService.getPlayerScore(other.id.toString()) -
            (scoreChanges[other.id.toString()] ?? 0);
        return prevScore <= os;
      });

      final ctx = RoundContext(
        gameMode: widget.gameMode,
        playerId: pName,
        isWinner: isWinner,
        isSelfDraw: isWinner && isSelfDraw,
        dealtIn: dealtIn,
        isDealer: isDealer,
        dealerWon: dealerWon,
        fanCount: isWinner ? fanCount : null,
        taiCount: isWinner ? taiCount : null,
        maxFan: widget.maxFan,
        patterns: isWinner ? patternSet : const {},
        scoreChange: change,
        consecutiveDealerCount: _currentDealerGameCount,
        roundNumber: currentRound,
        totalRounds: totalRounds,
        isLastRound: isLastRound,
        wasLastPlace: wasLast,
        isNowFirstPlace: pName == firstPlaceName,
      );

      final result = AchievementChecker.check(
        oldCounters: oldCounters,
        oldProgress: oldProgress,
        ctx: ctx,
      );

      _achvCounters[pName] = result.counters;
      _achvProgress[pName] = result.progress;

      if (result.newlyUnlocked.isNotEmpty) {
        allNewlyUnlocked[pName] = result.newlyUnlocked;
      }

      // Persist asynchronously
      AchievementService.saveAll(
        widget.groupName!,
        pName,
        counters: result.counters,
        progress: result.progress,
      );
    }

    // Show unlock popup for any newly unlocked achievements
    if (allNewlyUnlocked.isNotEmpty && mounted) {
      _showAchievementUnlockPopup(allNewlyUnlocked);
    }
  }

  /// Display a dialog listing newly unlocked achievements.
  void _showAchievementUnlockPopup(Map<String, List<String>> unlocked) {
    showDialog(
      context: context,
      builder: (ctx) {
        final entries = unlocked.entries.toList();
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.emoji_events, color: Colors.amber),
              const SizedBox(width: 8),
              Text(AppLocalizations.achvNewUnlock),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: entries.length,
              itemBuilder: (_, i) {
                final playerName = entries[i].key;
                final achvIds = entries[i].value;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (entries.length > 1)
                      Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 4),
                        child: Text(
                          playerName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ...achvIds.map((id) {
                      final def = AchievementRegistry.getById(id);
                      if (def == null) return const SizedBox.shrink();
                      return ListTile(
                        leading: Icon(
                          IconData(def.iconCodePoint,
                              fontFamily: 'MaterialIcons'),
                          color: AchievementRegistry.tierColor(def.tier),
                        ),
                        title: Text(
                          AppLocalizations.getString(def.titleKey),
                        ),
                        subtitle: Text(
                          AppLocalizations.getString(def.descriptionKey),
                        ),
                        dense: true,
                      );
                    }),
                  ],
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(AppLocalizations.ok),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    // Cancel subscription safely
    try {
      _scoreSubscription?.cancel();
    } catch (e) {
      debugPrint('Error canceling score subscription: $e');
    }
    super.dispose();
  }
  
  // ─── Game lifecycle ────────────────────────────────────────────────

  Future<void> _finishGame() async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    if (widget.groupName != null) {
      final group = await PlayerGroupService.loadGroup(widget.groupName!);
      if (group != null) {
        // Calculate stats additions
        Map<String, PlayerStats> stats = Map.from(group.playerStats ?? {});
        
        // Ensure all players have stats initialized
        for(var p in widget.players) {
            if (!stats.containsKey(p.name)) {
                stats[p.name] = PlayerStats(playerName: p.name);
            }
        }

        // Update stats per player
        for (var p in widget.players) {
             var s = stats[p.name]!;
             
             // Total Score (Net score change)
             int finalScore = _scoreService.getPlayerScore(p.id.toString());
             
             int handsWon = 0;
             int tsumoCount = 0;
             int ronCount = 0;
             
             for (var round in _roundHistory) {
                 if (round['winningPlayer'] == p.name) {
                     handsWon++;
                     if (round['isSelfDraw'] == true) {
                         tsumoCount++;
                     } else {
                         ronCount++;
                     }
                 }
             }

            // Update stats
            stats[p.name] = s.copyWith(
                totalGamesPlayed: s.totalGamesPlayed + _roundHistory.length, // Total Hands
                totalWins: s.totalWins + handsWon,
                totalTsumo: s.totalTsumo + tsumoCount,
                totalRon: s.totalRon + ronCount,
                totalScore: s.totalScore + finalScore,
            );
        }

        final updatedGroup = group.copyWith(
            playerStats: stats,
            // Do NOT increment here anymore, we increment on START
            totalGamesPlayedInGroup: group.totalGamesPlayedInGroup,
            lastPlayedAt: DateTime.now(),
        );
        
        await PlayerGroupService.saveGroup(updatedGroup);
      }
    }
    
    if (mounted) {
       // Close loading
       Navigator.pop(context); 
       // Return to home
       Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  void _showGameEndDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.gameOver),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${AppLocalizations.totalWindRounds} $_totalWindRounds'),
            Text('${AppLocalizations.totalRoundsPlayed} ${_scoreService.getCurrentRound() - 1}'),
            const SizedBox(height: 16),
            Text(AppLocalizations.finalScores, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...widget.players.map((player) {
              final score = _scoreService.getPlayerScore(player.id.toString());
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(player.name),
                    Text(
                      '$score',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.scoreColor(score),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
            },
            child: Text(AppLocalizations.backToGame),
          ),
          TextButton(
            onPressed: _finishGame,
            child: Text(AppLocalizations.finishGame),
          ),
        ],
      ),
    );
  }

  // ─── Round actions ─────────────────────────────────────────────────

  void _openScoreCalculator() {
    Navigator.pushNamed(
      context,
      AppRoutes.scoreCalculation,
      arguments: ScoreCalculationArgs(
        players: _updatedPlayers,
        roundWindIndex: _prevalentWindIndex,
        dealerIndex: _dealerIndex,
        minFan: widget.minFan,
        maxFan: widget.maxFan,
        gameMode: widget.gameMode,
        consecutiveDealerCount: _currentDealerGameCount,
      ),
    ).then((result) {
      if (result != null) {
        Map<String, int> scoreChanges;
        String? winnerId;
        bool isSelfDraw = false;
        String? discarderId;
        
        int? fanCount;
        int? taiCount;
        List<String> patterns = [];

        if (result is Map<String, int>) {
           scoreChanges = result;
        } else if (result is Map<String, dynamic> && result.containsKey('scores')) {
           scoreChanges = Map<String, int>.from(result['scores']);
           winnerId = result['winningPlayer']?.toString();
           isSelfDraw = result['isSelfDraw'] == true;
           discarderId = result['discardPlayer']?.toString();
           fanCount = result['fanCount'] as int?;
           taiCount = result['effectiveFan'] as int?; // effectiveFan = tai for TW
           patterns = (result['patterns'] as List<dynamic>?)?.cast<String>() ?? [];
           _roundHistory.add(result);
        } else {
           return;
        }

        // Apply La (拉) carry-over settlement for Taiwan Mahjong
        if (widget.gameMode == GameMode.taiwan && winnerId != null) {
          final laResult = _laSettlement.apply(
            rawScoreChanges: scoreChanges,
            winnerId: winnerId,
            isSelfDraw: isSelfDraw,
            discarderId: discarderId,
          );
          scoreChanges = laResult.adjustedScoreChanges;
        }

        widget.onScoreSubmitted(scoreChanges);
        _scoreService.updateScores(scoreChanges);

        // Check achievements after scores are applied
        _checkAchievements(
          scoreChanges: scoreChanges,
          winnerId: winnerId,
          isSelfDraw: isSelfDraw,
          discarderId: discarderId,
          fanCount: widget.gameMode == GameMode.hongKong ? fanCount : null,
          taiCount: widget.gameMode == GameMode.taiwan ? taiCount : null,
          patterns: patterns,
        );
        
        final dealerId = widget.players[_dealerIndex].id.toString();
        bool dealerWon = false;
        
        if (scoreChanges.containsKey(dealerId) && scoreChanges[dealerId]! > 0) {
          dealerWon = true;
        }
        
        if (dealerWon) {
          setState(() {
            _currentDealerGameCount++;
          });
        } else {
          setState(() {
            _dealerIndex = (_dealerIndex + 1) % 4;
            _currentDealerGameCount = 1;
            if (_dealerIndex == 0) {
              _prevalentWindIndex = (_prevalentWindIndex + 1) % 4;
              _totalWindRounds++;
            }
          });
        }
        
        _scoreService.incrementRound();
        
        if (_scoreService.isGameEnd()) {
          _showGameEndDialog();
          return;
        }
        
        _startNextRound();
      }
    });
  }

  void _endRoundWithNoResult() {
    Map<String, int> noChangeScores = {};
    for (var player in widget.players) {
      noChangeScores[player.id.toString()] = 0;
    }
    
    // Reset La carry-over on draw rounds (Taiwan Mahjong)
    if (widget.gameMode == GameMode.taiwan) {
      _laSettlement.onNoResult();
    }
    
    widget.onScoreSubmitted(noChangeScores);
    
    _roundHistory.add({
      'scores': noChangeScores,
      'winningPlayer': null,
      'isSelfDraw': false,
      'resultType': 'No Result',
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    setState(() {
      _currentDealerGameCount++;
    });

    _scoreService.updateScores(noChangeScores);

    // Check achievements for draw round (increment game counts, etc.)
    _checkAchievements(scoreChanges: noChangeScores);

    _scoreService.incrementRound();
    
    if (_scoreService.isGameEnd()) {
      _showGameEndDialog();
      return;
    }
    
    _startNextRound();
  }
  
  void _startNextRound() {
    final currentRound = _scoreService.getCurrentRound();
    final totalRounds = _scoreService.getTotalRounds();
    
    if (totalRounds > 0 && currentRound > totalRounds) {
      _showGameEndDialog();
      return;
    }
    
    final updatedPlayers = widget.players.map((player) {
      return player.copyWith(
        score: _scoreService.getPlayerScore(player.id.toString())
      );
    }).toList();
    
    setState(() {
      _updatedPlayers = updatedPlayers;
    });
  }

  // ─── Dealer / seat management ──────────────────────────────────────

  void _selectDealer() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.selectDealer),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _updatedPlayers.length,
            itemBuilder: (context, index) {
              return RadioListTile<int>(
                title: Text(_updatedPlayers[index].name),
                value: index,
                // ignore: deprecated_member_use
                groupValue: _dealerIndex,
                // ignore: deprecated_member_use
                onChanged: (int? value) {
                  if (value != null) {
                    setState(() {
                      _dealerIndex = value;
                    });
                    Navigator.pop(context);
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _handlePlayerSwap(int fromIndex, int toIndex) async {
    if (fromIndex == toIndex) return;

    final fromPlayer = _updatedPlayers[fromIndex];
    final toPlayer = _updatedPlayers[toIndex];

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.changePosition),
        content: Text(AppLocalizations.swapPositionsContent(fromPlayer.name, toPlayer.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(AppLocalizations.swap),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        final dealerId = _updatedPlayers[_dealerIndex].id;
        
        final temp = _updatedPlayers[fromIndex];
        _updatedPlayers[fromIndex] = _updatedPlayers[toIndex];
        _updatedPlayers[toIndex] = temp;
        
        for (int i = 0; i < _updatedPlayers.length; i++) {
          if (_updatedPlayers[i].id == dealerId) {
            _dealerIndex = i;
            break;
          }
        }
      });
      
      await _saveGameState();
      
      if (!mounted) return;

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          bool resetDealer = false;
          bool resetWind = false;
          
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text(AppLocalizations.resetGameState),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                     CheckboxListTile(
                       title: Text(AppLocalizations.resetDealer),
                       subtitle: Text(AppLocalizations.resetDealerSubtitle),
                       value: resetDealer,
                       onChanged: (val) => setState(() => resetDealer = val!),
                     ),
                     CheckboxListTile(
                       title: Text(AppLocalizations.resetWind),
                       subtitle: Text(AppLocalizations.resetWindSubtitle),
                       value: resetWind,
                       onChanged: (val) => setState(() => resetWind = val!),
                     ),
                  ],
                ),
                actions: [
                  TextButton(
                     onPressed: () => Navigator.pop(context),
                     child: Text(AppLocalizations.cancelReset),
                  ),
                  ElevatedButton(
                    onPressed: () {
                        Navigator.pop(context);
                        this.setState(() {
                             if (resetWind) {
                                 _prevalentWindIndex = 0;
                                 _currentDealerGameCount = 1; 
                                 _totalWindRounds = 1;
                             }
                        });
                        
                        if (resetDealer) {
                             _selectDealer();
                        }
                    },
                    child: Text(AppLocalizations.apply),
                  ),
                ],
              );
            }
          );
        },
      );
    }
  }

  // ─── Persistence ───────────────────────────────────────────────────

  Future<void> _saveGameState() async {
    if (widget.groupName == null) return;
    
    final group = await PlayerGroupService.loadGroup(widget.groupName!);
    if (group != null) {
      final Map<String, int> currentScores = {};
      for (var player in _updatedPlayers) {
        currentScores[player.name] = player.score;
      }
      
      final updatedGroup = group.copyWith(
        lastPlayedAt: DateTime.now(),
        players: _updatedPlayers.map((p) => p.name).toList(),
        currentScores: currentScores,
        currentRound: _scoreService.getCurrentRound(),
        dealerIndex: _dealerIndex,
        prevalentWindIndex: _prevalentWindIndex,
        currentDealerGameCount: _currentDealerGameCount,
        totalWindRounds: _totalWindRounds,
        roundHistory: _roundHistory,
      );
      
      await PlayerGroupService.saveGroup(updatedGroup);
    }
  }

  // ─── Build ─────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Title setting
    String title = AppLocalizations.mahjongScoringTitle;
    
    final windNames = [
      AppLocalizations.windEast, 
      AppLocalizations.windSouth, 
      AppLocalizations.windWest, 
      AppLocalizations.windNorth
    ];
    final windName = windNames[_prevalentWindIndex];
    
    if (widget.groupName != null && widget.groupName!.isNotEmpty) {
      title = '${widget.groupName} - ${AppLocalizations.roundInfo(windName, _currentDealerGameCount)}';
    }
    
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _saveGameState();
        if (context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          actions: [
            IconButton(
              icon: const Icon(Icons.bar_chart),
              tooltip: AppLocalizations.tooltipStats,
              onPressed: () => showStatsDialog(
                context: context,
                players: widget.players,
                roundHistory: _roundHistory,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.menu_book),
              tooltip: AppLocalizations.tooltipRules,
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.rules);
              },
            ),
            IconButton(
              icon: const Icon(Icons.home),
              tooltip: AppLocalizations.tooltipHome,
              onPressed: () {
                _saveGameState();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ],
        ),
        body: Padding(
          padding: AppDimens.paddingAllLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Round info card
              Card(
                elevation: 2,
                child: Padding(
                  padding: AppDimens.paddingAllLg,
                  child: Row(
                    children: [
                      const Icon(Icons.casino, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          AppLocalizations.roundInfo(windName, _currentDealerGameCount),
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Player table
              Expanded(
                child: Center(
                  child: GameTableLayout(
                    players: _updatedPlayers,
                    dealerIndex: _dealerIndex,
                    prevalentWindIndex: _prevalentWindIndex,
                    currentDealerGameCount: _currentDealerGameCount,
                    gameMode: widget.gameMode,
                    getPlayerScore: (id) => _scoreService.getPlayerScore(id),
                    onSwap: _handlePlayerSwap,
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Action buttons
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.calculate),
                label: Text(AppLocalizations.calculate),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: AppDimens.paddingVerticalMd,
                ),
                onPressed: _openScoreCalculator,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.close),
                label: Text(AppLocalizations.noResult),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).brightness == Brightness.dark 
                      ? AppColors.white 
                      : AppColors.black,
                  side: BorderSide(
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? AppColors.grey600 
                        : AppColors.grey300,
                  ),
                  padding: AppDimens.paddingVerticalMd,
                ),
                onPressed: _endRoundWithNoResult,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.flag),
            label: Text(AppLocalizations.finishGame),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.destructive,
              foregroundColor: AppColors.white,
              padding: AppDimens.paddingVerticalMd,
            ),
            onPressed: _showGameEndDialog,
          ),
        ),
      ],
    );
  }
}
