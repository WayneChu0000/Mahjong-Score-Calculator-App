import 'package:flutter/material.dart';
import '../../models/player.dart';
import '../../services/score_service.dart';
import '../../services/player_group_service.dart';
import '../../services/settings_service.dart';
import '../../models/player_stats.dart';
import '../../models/game_mode.dart';
import '../../models/tw_rules.dart';
import '../../localization/app_localizations.dart';
import '../../routes/app_routes.dart';
import '../../utils/la_settlement.dart';
import '../../utils/achievement_checker.dart';
import '../../services/achievement_service.dart';
import '../../models/achievement.dart';
import '../../utils/achievement_registry.dart';
import 'widgets/stats_dialog.dart';
import 'widgets/game_table_layout.dart';
import 'widgets/la_debt_panel.dart';
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

  // Track whether the dealer won any hand in the current round
  bool _dealerWonInCurrentRound = false;

  // ── Achievement tracking ──────────────────────────────────────
  /// Per-player counters keyed by player name.
  final Map<String, AchievementCounters> _achvCounters = {};

  /// Per-player progress keyed by player name → achievementId → progress.
  final Map<String, Map<String, AchievementProgress>> _achvProgress = {};

  /// Track instant payments applied (for achievements).
  int _instantPaymentCount = 0;

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

      // Check if total rounds exceeded (must be after initGame so
      // _totalRounds and _currentRound are correct and not stale).
      if (_scoreService.isGameEnd()) {
        _showGameEndDialog();
      }
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
                score: gameData[player.id.toString()] ?? player.score,
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
  }

  Future<void> _loadRoundHistory() async {
    if (widget.groupName != null) {
      final group = await PlayerGroupService.loadGroup(widget.groupName!);
      if (group != null) {
        if (group.roundHistory != null) {
          _roundHistory = List.from(group.roundHistory!);
        }
        // Restore La (拉) settlement state from Firebase
        if (group.laState != null && widget.gameMode == GameMode.taiwan) {
          _laSettlement.restoreFromJson(group.laState!);
        }
        setState(() {
          _isRoundHistoryLoaded = true;
        });
        return;
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
      final oldCounters = _achvCounters[pName] ?? const AchievementCounters();
      final oldProgress =
          _achvProgress[pName] ?? <String, AchievementProgress>{};

      // Determine per-player facts
      final isWinner = winnerId != null && winnerId == pName;
      final dealtIn = discarderId != null && discarderId == pName;
      final isDealer = pid == dealerId;
      final change = scoreChanges[pid] ?? 0;

      // Check whether player was last place BEFORE this round's scores
      // We already applied scores before calling this, so subtract back.
      final prevScore = _scoreService.getPlayerScore(pid) - change;
      final wasLast = widget.players.every((other) {
        if (other.id == player.id) return true;
        final os =
            _scoreService.getPlayerScore(other.id.toString()) -
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
                          IconData(
                            def.iconCodePoint,
                            fontFamily: 'MaterialIcons',
                          ),
                          color: AchievementRegistry.tierColor(def.tier),
                        ),
                        title: Text(AppLocalizations.getString(def.titleKey)),
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
        for (var p in widget.players) {
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
          final handCount = _roundHistory
              .where(
                (r) =>
                    r['resultType'] != 'InstantPayment',
              )
              .length;
          stats[p.name] = s.copyWith(
            totalGamesPlayed: s.totalGamesPlayed + handCount, // Total Hands
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
    // Settle any remaining La debts at game end (TW Mahjong)
    if (widget.gameMode == GameMode.taiwan) {
      final gameEndAdj = _laSettlement.settleAtGameEnd();
      if (gameEndAdj.isNotEmpty) {
        _scoreService.updateScores(gameEndAdj);
        setState(() {
          _updatedPlayers = widget.players.map((player) {
            return player.copyWith(
              score: _scoreService.getPlayerScore(player.id.toString()),
            );
          }).toList();
        });
      }
    }

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
            Text(
              '${AppLocalizations.totalRoundsPlayed} ${_scoreService.getCurrentRound() - 1}',
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.finalScores,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
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

  /// Show the stop rule (逼停) dialog, asking a player if they want
  /// to force-settle their La debt at full value.
  Future<bool> _showStopRuleDialog(
    String playerName,
    String streakWinnerName,
    int lossCount,
  ) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: Text(AppLocalizations.twLaStopRuleTitle),
            content: Text(
              AppLocalizations.twLaStopRuleMessage(
                playerName,
                lossCount,
                streakWinnerName,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(AppLocalizations.twLaStopRuleContinue),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(AppLocalizations.twLaStopRuleSettle),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _openScoreCalculator() {
    _dealerWonInCurrentRound = false;

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
    ).then((result) async {
      if (result == null) {
        return;
      }

      Map<String, int> scoreChanges;
      String? winnerId;
      bool isSelfDraw = false;
      String? discarderId;

      int? fanCount;
      int? taiCount;
      List<String> patterns = [];

      if (result is Map<String, int>) {
        scoreChanges = result;
      } else if (result is Map<String, dynamic> &&
          result.containsKey('scores')) {
        scoreChanges = Map<String, int>.from(result['scores']);
        winnerId = result['winningPlayer']?.toString();
        isSelfDraw = result['isSelfDraw'] == true;
        discarderId = result['discardPlayer']?.toString();
        fanCount = result['fanCount'] as int?;
        taiCount = result['effectiveFan'] as int?; // effectiveFan = tai for TW
        patterns = (result['patterns'] as List<dynamic>?)?.cast<String>() ?? [];

        // Record in history
        final historyEntry = Map<String, dynamic>.from(result);
        _roundHistory.add(historyEntry);
      } else {
        return;
      }

      // Track whether the dealer won (based on winner, not score changes,
      // because La deferred scoring may zero out changes)
      final dealerName = widget.players[_dealerIndex].name;
      if (winnerId == dealerName) {
        _dealerWonInCurrentRound = true;
      }

      // ── TW win → apply La immediately ──
      if (widget.gameMode == GameMode.taiwan && winnerId != null) {
        // TW self-draw — apply La normally
        String nameToId(String name) {
          return widget.players.firstWhere((p) => p.name == name).id.toString();
        }

        final winnerIdStr = nameToId(winnerId);
        final discarderIdStr = discarderId != null
            ? nameToId(discarderId)
            : null;

        final laResult = _laSettlement.apply(
          rawScoreChanges: scoreChanges,
          winnerId: winnerIdStr,
          isSelfDraw: isSelfDraw,
          discarderId: discarderIdStr,
        );
        scoreChanges = laResult.adjustedScoreChanges;

        // Handle stop rule (逼停)
        if (laResult.stopEligible.isNotEmpty && mounted) {
          String idToName(String id) {
            return widget.players
                .firstWhere((p) => p.id.toString() == id)
                .name;
          }
          for (final entry in laResult.stopEligible.entries) {
            if (!_laSettlement.hasActiveStreak) break;
            final playerName = idToName(entry.key);
            final streakWinnerName = idToName(_laSettlement.streakWinnerId!);
            final wantsToStop = await _showStopRuleDialog(
              playerName,
              streakWinnerName,
              entry.value,
            );
            if (wantsToStop) {
              final forceAdj = _laSettlement.forceSettle(entry.key);
              for (final adj in forceAdj.entries) {
                scoreChanges[adj.key] =
                    (scoreChanges[adj.key] ?? 0) + adj.value;
              }
            } else {
              _laSettlement.recordStopDeclined(entry.key);
            }
          }
        }
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

      // Refresh player scores UI
      setState(() {
        _updatedPlayers = widget.players.map((player) {
          return player.copyWith(
            score: _scoreService.getPlayerScore(player.id.toString()),
          );
        }).toList();
      });

      // Finalize round (dealer rotation, increment round, etc.)
      _finalizeRound();
    });
  }

  /// Finalize the current round: dealer rotation, increment round, and
  /// check game end.
  void _finalizeRound() {
    if (_dealerWonInCurrentRound) {
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

  void _endRoundWithNoResult() {
    Map<String, int> noChangeScores = {};
    for (var player in widget.players) {
      noChangeScores[player.id.toString()] = 0;
    }

    // La carry-over persists through draw rounds (Taiwan Mahjong).
    // No action needed — debts remain unchanged.

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
        score: _scoreService.getPlayerScore(player.id.toString()),
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
        content: Text(
          AppLocalizations.swapPositionsContent(fromPlayer.name, toPlayer.name),
        ),
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
            },
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
        laState: widget.gameMode == GameMode.taiwan
            ? _laSettlement.toJson()
            : null,
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
      AppLocalizations.windNorth,
    ];
    final windName = windNames[_prevalentWindIndex];

    if (widget.groupName != null && widget.groupName!.isNotEmpty) {
      title =
          '${widget.groupName} - ${AppLocalizations.roundInfo(windName, _currentDealerGameCount)}';
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
              icon: const Icon(Icons.history),
              tooltip: AppLocalizations.roundHistory,
              onPressed: _showRoundHistoryDialog,
            ),
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
                          AppLocalizations.roundInfo(
                            windName,
                            _currentDealerGameCount,
                          ),
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

              // La debt tracker (TW only)
              if (widget.gameMode == GameMode.taiwan)
                LaDebtPanel(
                  laSettlement: _laSettlement,
                  players: _updatedPlayers,
                  onForceSettle: _handleForceSettle,
                ),

              // Action buttons
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Instant Payment (TW only) ────────────────────────────────────

  /// Maps a built-in rule name to its stable persistence key
  String _builtInPayKey(String ruleName) {
    if (ruleName == AppLocalizations.twChaseRule) return 'twChaseRule';
    if (ruleName == AppLocalizations.twConcealedKongPay)
      return 'twConcealedKongPay';
    if (ruleName == AppLocalizations.twFlowerSeasonSetPay)
      return 'twFlowerSeasonSetPay';
    if (ruleName == AppLocalizations.twFlowerGroupPay)
      return 'twFlowerGroupPay';
    if (ruleName == AppLocalizations.twFalseWinPay) return 'twFalseWinPay';
    if (ruleName == AppLocalizations.twCalledPongPenalty)
      return 'twCalledPongPenalty';
    return ruleName;
  }

  int _builtInPayDefaultValue(String key) {
    const defaults = {
      'twChaseRule': 10,
      'twConcealedKongPay': 10,
      'twFlowerSeasonSetPay': 5,
      'twFlowerGroupPay': 10,
      'twFalseWinPay': 10,
      'twCalledPongPenalty': 10,
    };
    return defaults[key] ?? 10;
  }

  void _showInstantPaymentDialog() {
    // Build the list of available payment items
    // 1. Built-in instant pay rules from tw_rules.dart
    // 2. Custom payments from settings
    final builtInItems = twInstantPayRules.where((r) => r.name.isNotEmpty).map((
      r,
    ) {
      final key = _builtInPayKey(r.name);
      final defaultVal = _builtInPayDefaultValue(key);
      final value = SettingsService.instance.getTwBuiltInPayValue(
        key,
        defaultVal,
      );
      return {'name': r.name, 'value': value, 'isBuiltIn': true};
    }).toList();
    final customItems = SettingsService.instance.twPayments
        .map(
          (p) => {
            'name': p['name'] as String,
            'value': p['value'] as int,
            'isBuiltIn': false,
          },
        )
        .toList();
    final allItems = [...builtInItems, ...customItems];

    String? selectedPayerName;
    String? selectedReceiverName;
    int selectedItemIndex = 0;
    int amount = allItems.isNotEmpty ? (allItems.first['value'] as int) : 0;
    final amtController = TextEditingController(text: '$amount');
    bool payAllOthers = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            final currentItem = allItems[selectedItemIndex];
            // ignore: unused_local_variable
            final isCustom = currentItem['isBuiltIn'] == false;

            return AlertDialog(
              title: Row(
                children: [
                  const Icon(Icons.payments, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(AppLocalizations.instantPayment),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Payment item selector
                    Text(
                      AppLocalizations.selectPaymentItem,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      isExpanded: true,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      value: selectedItemIndex,
                      items: allItems.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final item = entry.value;
                        final name = item['name'] as String;
                        final val = item['value'] as int;
                        return DropdownMenuItem<int>(
                          value: idx,
                          child: Text(
                            val > 0 ? '$name ($val)' : name,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val == null) return;
                        setDialogState(() {
                          selectedItemIndex = val;
                          final item = allItems[val];
                          amount = item['value'] as int;
                          amtController.text = '$amount';
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    // Amount input
                    Text(
                      AppLocalizations.paymentAmount,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: amtController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        hintText: AppLocalizations.customAmount,
                      ),
                      onChanged: (val) {
                        amount = int.tryParse(val) ?? 0;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Select payer
                    Text(
                      AppLocalizations.selectPayer,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...widget.players.map((p) {
                      return RadioListTile<String>(
                        title: Text(p.name),
                        value: p.name,
                        groupValue: selectedPayerName,
                        dense: true,
                        onChanged: (val) {
                          setDialogState(() {
                            selectedPayerName = val;
                            payAllOthers = false;
                          });
                        },
                      );
                    }),

                    const SizedBox(height: 8),

                    // Select receiver
                    Text(
                      AppLocalizations.selectReceiver,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    // Option: all other players
                    RadioListTile<String>(
                      title: Text(AppLocalizations.allOtherPlayers),
                      value: '__all_others__',
                      groupValue: payAllOthers
                          ? '__all_others__'
                          : selectedReceiverName,
                      dense: true,
                      onChanged: (val) {
                        setDialogState(() {
                          payAllOthers = true;
                          selectedReceiverName = null;
                        });
                      },
                    ),
                    ...widget.players
                        .where((p) => p.name != selectedPayerName)
                        .map((p) {
                          return RadioListTile<String>(
                            title: Text(p.name),
                            value: p.name,
                            groupValue: payAllOthers
                                ? null
                                : selectedReceiverName,
                            dense: true,
                            onChanged: (val) {
                              setDialogState(() {
                                selectedReceiverName = val;
                                payAllOthers = false;
                              });
                            },
                          );
                        }),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(AppLocalizations.cancel),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (selectedPayerName == null || amount <= 0) return;
                    if (!payAllOthers && selectedReceiverName == null) return;

                    // Build score changes
                    final Map<String, int> changes = {};
                    final payerId = widget.players
                        .firstWhere((p) => p.name == selectedPayerName)
                        .id
                        .toString();

                    if (payAllOthers) {
                      // Payer pays each other player the amount
                      int totalPaid = 0;
                      for (var p in widget.players) {
                        if (p.name != selectedPayerName) {
                          changes[p.id.toString()] =
                              (changes[p.id.toString()] ?? 0) + amount;
                          totalPaid += amount;
                        }
                      }
                      changes[payerId] = (changes[payerId] ?? 0) - totalPaid;
                    } else {
                      final receiverId = widget.players
                          .firstWhere((p) => p.name == selectedReceiverName)
                          .id
                          .toString();
                      changes[payerId] = (changes[payerId] ?? 0) - amount;
                      changes[receiverId] = (changes[receiverId] ?? 0) + amount;
                    }

                    // Apply score changes
                    _scoreService.updateScores(changes);
                    setState(() {
                      _updatedPlayers = widget.players.map((player) {
                        return player.copyWith(
                          score: _scoreService.getPlayerScore(
                            player.id.toString(),
                          ),
                        );
                      }).toList();
                      _instantPaymentCount++;
                    });

                    // Record in round history
                    _roundHistory.add({
                      'scores': changes,
                      'winningPlayer': null,
                      'isSelfDraw': false,
                      'resultType': 'InstantPayment',
                      'paymentItem': allItems[selectedItemIndex]['name'],
                      'amount': amount,
                      'payer': selectedPayerName,
                      'receiver': payAllOthers
                          ? 'all_others'
                          : selectedReceiverName,
                      'timestamp': DateTime.now().toIso8601String(),
                    });

                    _saveGameState();

                    // Check achievements for instant payment milestones
                    _checkInstantPaymentAchievements();

                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(AppLocalizations.paymentApplied)),
                    );
                  },
                  child: Text(AppLocalizations.apply),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Check achievements related to instant payments.
  void _checkInstantPaymentAchievements() {
    if (widget.groupName == null) return;
    // Evaluate instant-payment achievements for all players
    for (final player in widget.players) {
      final pName = player.name;
      final oldProgress =
          _achvProgress[pName] ?? <String, AchievementProgress>{};

      final newlyUnlocked = <String>[];

      // tw_instant_pay_5
      final def5 = AchievementRegistry.getById('tw_instant_pay_5');
      if (def5 != null) {
        final existing = oldProgress[def5.id];
        if (existing == null || !existing.isUnlocked) {
          if (_instantPaymentCount >= def5.target) {
            oldProgress[def5.id] = AchievementProgress(
              achievementId: def5.id,
              isUnlocked: true,
              unlockedAt: DateTime.now(),
              progress: _instantPaymentCount,
            );
            newlyUnlocked.add(def5.id);
          } else {
            oldProgress[def5.id] = AchievementProgress(
              achievementId: def5.id,
              progress: _instantPaymentCount,
            );
          }
        }
      }

      // tw_instant_pay_20
      final def20 = AchievementRegistry.getById('tw_instant_pay_20');
      if (def20 != null) {
        final existing = oldProgress[def20.id];
        if (existing == null || !existing.isUnlocked) {
          if (_instantPaymentCount >= def20.target) {
            oldProgress[def20.id] = AchievementProgress(
              achievementId: def20.id,
              isUnlocked: true,
              unlockedAt: DateTime.now(),
              progress: _instantPaymentCount,
            );
            newlyUnlocked.add(def20.id);
          } else {
            oldProgress[def20.id] = AchievementProgress(
              achievementId: def20.id,
              progress: _instantPaymentCount,
            );
          }
        }
      }

      _achvProgress[pName] = oldProgress;

      // Persist
      AchievementService.saveAll(
        widget.groupName!,
        pName,
        counters: _achvCounters[pName] ?? const AchievementCounters(),
        progress: oldProgress,
      );

      if (newlyUnlocked.isNotEmpty) {
        _showAchievementUnlockPopup({pName: newlyUnlocked});
      }
    }
  }

  /// Handle force settlement from the La debt panel UI.
  /// Force-settles ONLY the triggering player's debt (per-player settlement).
  void _handleForceSettle(String playerId) {
    final playerName = widget.players
        .firstWhere((p) => p.id.toString() == playerId)
        .name;
    final streakWinnerName = widget.players
        .firstWhere((p) => p.id.toString() == _laSettlement.streakWinnerId)
        .name;

    // Show only this player's debt in the confirmation dialog
    final playerDebt = _laSettlement.debts[playerId] ?? 0;
    final lossCount = _laSettlement.consecutiveLosses[playerId] ?? 0;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.twLaStopRuleTitle),
        content: Text(
          '${AppLocalizations.twLaStopRuleMessage(playerName, lossCount, streakWinnerName)}\n\n'
          '${AppLocalizations.twLaDebtTotal}:\n  $playerName: $playerDebt\n\n'
          '$streakWinnerName: +$playerDebt',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              final forceAdj = _laSettlement.forceSettle(playerId);
              if (forceAdj.isNotEmpty) {
                _scoreService.updateScores(forceAdj);
                setState(() {
                  _updatedPlayers = widget.players.map((player) {
                    return player.copyWith(
                      score: _scoreService.getPlayerScore(player.id.toString()),
                    );
                  }).toList();
                });
                _saveGameState();
              }
            },
            child: Text(AppLocalizations.twLaForceSettleAction),
          ),
        ],
      ),
    );
  }

  void _showRoundHistoryDialog() {
    final isTW = widget.gameMode == GameMode.taiwan;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.roundHistory),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: _roundHistory.isEmpty
              ? Center(child: Text(AppLocalizations.noResult))
              : ListView.separated(
                  itemCount: _roundHistory.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final entry = _roundHistory[index];
                    final resultType = entry['resultType'] as String? ?? '';
                    final winner = entry['winningPlayer'] as String?;
                    final isSelfDraw = entry['isSelfDraw'] == true;
                    final scores = entry['scores'] as Map<String, dynamic>?;
                    final fanCount = entry['fanCount'] as int?;
                    final taiCount = entry['effectiveFan'] as int?;

                    // Determine display label
                    String subtitle;
                    if (resultType == 'No Result') {
                      subtitle = AppLocalizations.noResult;
                    } else if (resultType == 'InstantPayment') {
                      subtitle = AppLocalizations.instantPayment;
                    } else if (winner != null) {
                      final winType = isSelfDraw
                          ? AppLocalizations.selfDraw
                          : AppLocalizations.discard;
                      final fanLabel = isTW && taiCount != null
                          ? AppLocalizations.taiCount(taiCount)
                          : fanCount != null
                          ? AppLocalizations.fan(fanCount)
                          : '';
                      subtitle = '$winner ($winType) $fanLabel';
                    } else {
                      subtitle = resultType;
                    }

                    // Build score change chips
                    List<Widget> scoreChips = [];
                    if (scores != null) {
                      for (var player in widget.players) {
                        final pid = player.id.toString();
                        final sc = scores[pid] ?? 0;
                        if (sc != 0) {
                          scoreChips.add(
                            Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: Chip(
                                visualDensity: VisualDensity.compact,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                label: Text(
                                  '${player.name}: ${sc > 0 ? "+$sc" : "$sc"}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: sc > 0
                                        ? AppColors.primary
                                        : AppColors.destructive,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                      }
                    }

                    // Round number (skip multi-win extras for numbering)
                    final roundNum = index + 1;

                    return ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        radius: 14,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        child: Text(
                          '$roundNum',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      title: Text(
                        subtitle,
                        style: const TextStyle(fontSize: 13),
                      ),
                      subtitle: scoreChips.isNotEmpty
                          ? Wrap(children: scoreChips)
                          : null,
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
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final isTW = widget.gameMode == GameMode.taiwan;

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
                  foregroundColor:
                      Theme.of(context).brightness == Brightness.dark
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
        if (isTW) ...[
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.payments),
              label: Text(AppLocalizations.instantPayment),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: AppColors.white,
                padding: AppDimens.paddingVerticalMd,
              ),
              onPressed: _showInstantPaymentDialog,
            ),
          ),
        ],
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


