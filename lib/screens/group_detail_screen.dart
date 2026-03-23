import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/player_group.dart';
import '../models/player_stats.dart';
import '../services/player_group_service.dart';
import '../services/settings_service.dart';
import '../routes/app_routes.dart';
import '../localization/app_localizations.dart';
import '../models/game_mode.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';

class GroupDetailScreen extends StatefulWidget {
  final PlayerGroup group;

  const GroupDetailScreen({super.key, required this.group});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  late PlayerGroup _group;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _group = widget.group;
    _refreshGroup();
  }

  Future<void> _refreshGroup() async {
    setState(() => _isLoading = true);
    final updatedGroup = await PlayerGroupService.loadGroup(_group.name);
    if (updatedGroup != null && mounted) {
      setState(() {
        _group = updatedGroup;
      });
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _startNewGame() {
    // Check if there is an active unfinished game
    bool hasActiveGame =
        _group.currentRound != null &&
        _group.currentRound! > 1; // Round 1 is default
    // Or if scores are different from 0 (simple check)
    if (_group.currentScores != null &&
        _group.currentScores!.values.any((score) => score != 0)) {
      hasActiveGame = true;
    }

    if (hasActiveGame) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(AppLocalizations.gameInProgressTitle),
          content: Text(AppLocalizations.gameInProgressContent),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.cancel),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _finishCurrentGameAndStartNew();
              },
              child: Text(AppLocalizations.startNewGame),
            ),
          ],
        ),
      );
    } else {
      _showDealerSelection();
    }
  }

  Future<void> _finishCurrentGameAndStartNew() async {
    setState(() => _isLoading = true);

    // Save stats for the abandoned game
    if (_group.roundHistory != null && _group.roundHistory!.isNotEmpty) {
      Map<String, PlayerStats> stats = Map.from(_group.playerStats ?? {});

      // Ensure all players have stats initialized
      for (var p in _group.players) {
        if (!stats.containsKey(p)) {
          stats[p] = PlayerStats(playerName: p);
        }
      }

      for (var pName in _group.players) {
        var s = stats[pName]!;
        int finalScore = _group.currentScores?[pName] ?? 0;

        int handsWon = 0;
        int tsumoCount = 0;
        int ronCount = 0;

        // Use saved round history
        for (var round in _group.roundHistory!) {
          if (round['winningPlayer'] == pName) {
            handsWon++;
            if (round['isSelfDraw'] == true) {
              tsumoCount++;
            } else {
              ronCount++;
            }
          }
        }

        stats[pName] = s.copyWith(
          totalGamesPlayed:
              s.totalGamesPlayed + (_group.roundHistory?.length ?? 0),
          totalWins: s.totalWins + handsWon,
          totalTsumo: s.totalTsumo + tsumoCount,
          totalRon: s.totalRon + ronCount,
          totalScore: s.totalScore + finalScore,
        );
      }

      final finishedGroup = _group.copyWith(
        playerStats: stats,
        // Do NOT increment here anymore, we increment on START
        totalGamesPlayedInGroup: _group.totalGamesPlayedInGroup,
        // Reset game state
        currentScores: {for (var p in _group.players) p: 0},
        roundHistory: [],
        currentRound: 1,
        totalWindRounds: 1,
        currentDealerGameCount: 1,
        dealerIndex: 0,
        prevalentWindIndex: 0,
      );

      await PlayerGroupService.saveGroup(finishedGroup);

      if (mounted) {
        setState(() {
          _group = finishedGroup;
        });
      }
    } else {
      // If no rounds played, just reset state without stats update
      final finishedGroup = _group.copyWith(
        currentScores: {for (var p in _group.players) p: 0},
        roundHistory: [],
        currentRound: 1,
        totalWindRounds: 1,
        currentDealerGameCount: 1,
        dealerIndex: 0,
        prevalentWindIndex: 0,
      );
      await PlayerGroupService.saveGroup(finishedGroup);
      if (mounted) {
        setState(() {
          _group = finishedGroup;
        });
      }
    }

    setState(() => _isLoading = false);
    _showDealerSelection();
  }

  void _showDealerSelection() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => DealerSelectionDialog(
        players: _group.players,
        gameMode: _group.gameMode,
        initialMinFan: _group.minFan,
        initialMaxFan: _group.maxFan,
        onDealerSelected: (dealerIndex, minFan, maxFan, gameMode) {
          Navigator.pop(context); // Close dialog
          _navigateToGame(
            dealerIndex,
            isNewGame: true,
            minFan: minFan,
            maxFan: maxFan,
            gameMode: gameMode,
          );
        },
      ),
    );
  }

  void _resumeGame() {
    // Navigate to game with current saved state
    // Dealer index should be preserved in _group
    _navigateToGame(_group.dealerIndex ?? 0, isNewGame: false);
  }

  void _navigateToGame(
    int dealerIndex, {
    required bool isNewGame,
    int? minFan,
    int? maxFan,
    GameMode? gameMode,
  }) async {
    final effectiveGameMode = gameMode ?? _group.gameMode;

    if (isNewGame) {
      // Increment Total Match count immediately when creating a new game
      final updatedGroup = _group.copyWith(
        totalGamesPlayedInGroup: _group.totalGamesPlayedInGroup + 1,
        // Ensure we reset game state in DB for the new game
        currentScores: {for (var p in _group.players) p: 0},
        roundHistory: [],
        currentRound: 1,
        totalWindRounds: 1,
        currentDealerGameCount: 1,
        dealerIndex: dealerIndex,
        prevalentWindIndex: 0,
        minFan: minFan,
        maxFan: maxFan,
        gameMode: effectiveGameMode,
      );
      await PlayerGroupService.saveGroup(updatedGroup);
      if (mounted) {
        setState(() {
          _group = updatedGroup;
        });
      }
    }

    if (!mounted) return;

    // Create Player objects
    final players = List.generate(
      _group.players.length,
      (index) => Player(
        id: index,
        name: _group.players[index],
        score: isNewGame
            ? 0
            : (_group.currentScores?[_group.players[index]] ?? 0),
      ),
    );

    Navigator.pushNamed(
      context,
      AppRoutes.scoreRecording,
      arguments: ScoreRecordingArgs(
        players: players,
        currentRound: isNewGame ? 1 : (_group.currentRound ?? 1),
        totalRounds: 0,
        onScoreSubmitted: (scores) {},
        groupId: _group.name,
        groupName: _group.name,
        initialDealerIndex: dealerIndex,
        initialPrevalentWindIndex: isNewGame
            ? 0
            : (_group.prevalentWindIndex ?? 0),
        initialDealerGameCount: isNewGame
            ? 1
            : (_group.currentDealerGameCount ?? 1),
        initialTotalWindRounds: isNewGame ? 1 : (_group.totalWindRounds ?? 1),
        minFan: minFan ?? _group.minFan,
        maxFan: maxFan ?? _group.maxFan,
        gameMode: isNewGame ? effectiveGameMode : _group.gameMode,
      ),
    ).then((_) => _refreshGroup());
  }

  @override
  Widget build(BuildContext context) {
    // Always allow resuming if we have basic game structure (scores initialized)
    // This allows resuming a game that is just started (Round 1, Score 0)
    bool hasActiveGame = _group.currentScores != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(_group.name),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshGroup),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: AppDimens.paddingAllLg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCard(),
                  const SizedBox(height: 20),
                  Text(
                    AppLocalizations.playerStatsTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  _buildPlayerStatsList(),
                  const SizedBox(height: 20),

                  if (hasActiveGame)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _resumeGame,
                          icon: const Icon(Icons.play_circle_fill),
                          label: Text(AppLocalizations.backToGame),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            backgroundColor: Colors.orange,
                            foregroundColor: AppColors.white,
                          ),
                        ),
                      ),
                    ),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _startNewGame,
                      icon: const Icon(Icons.play_arrow),
                      label: Text(AppLocalizations.startNewGame),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Map<String, PlayerStats> _getMergedStats() {
    Map<String, PlayerStats> stats = Map.from(_group.playerStats ?? {});

    // Initialize if missing
    for (var p in _group.players) {
      if (!stats.containsKey(p)) {
        stats[p] = PlayerStats(playerName: p);
      }
    }

    // Merge current game round history (skip instant payments)
    if (_group.roundHistory != null && _group.roundHistory!.isNotEmpty) {
      for (var round in _group.roundHistory!) {
        if (round['resultType'] == 'InstantPayment')
          continue;
        final winningPlayer = round['winningPlayer'];
        final isSelfDraw = round['isSelfDraw'] == true;

        if (winningPlayer != null && stats.containsKey(winningPlayer)) {
          final s = stats[winningPlayer]!;
          stats[winningPlayer] = s.copyWith(
            totalWins: s.totalWins + 1,
            totalTsumo: s.totalTsumo + (isSelfDraw ? 1 : 0),
            totalRon: s.totalRon + (isSelfDraw ? 0 : 1),
          );
        }

        // Identify deal-in player
        // 'discardPlayer' might be in the round map if passed from Calculator
        // Otherwise infer from negative score
        String? dealInPlayer = round['discardPlayer'];

        if (dealInPlayer != null && stats.containsKey(dealInPlayer)) {
          final s = stats[dealInPlayer]!;
          stats[dealInPlayer] = s.copyWith(totalDealsIn: s.totalDealsIn + 1);
        }

        // Update total hands played for all players
        // Note: Logic assumes all players played all rounds.
        for (var p in _group.players) {
          if (stats.containsKey(p)) {
            final s = stats[p]!;
            stats[p] = s.copyWith(totalGamesPlayed: s.totalGamesPlayed + 1);
          }
        }
      }
    }

    return stats;
  }

  Widget _buildSummaryCard() {
    final mergedStats = _getMergedStats();

    // Calculate total hands played across all games in this group
    int totalHandsPlayed = 0;
    int totalNoResultHands = 0;

    // No Result = Total Hands − Total Wins (approximation; may under-count if double-ron exists)
    int totalWinsByAnyone = 0;
    if (mergedStats.isNotEmpty) {
      for (var stat in mergedStats.values) {
        totalWinsByAnyone += stat.totalWins;
        if (stat.totalGamesPlayed > totalHandsPlayed) {
          totalHandsPlayed = stat.totalGamesPlayed;
        }
      }
    }

    totalNoResultHands = totalHandsPlayed - totalWinsByAnyone;
    // Clamp to zero in case double-ron inflated win count
    if (totalNoResultHands < 0) totalNoResultHands = 0;

    double noResultRate = totalHandsPlayed > 0
        ? totalNoResultHands / totalHandsPlayed
        : 0.0;

    return Card(
      child: Padding(
        padding: AppDimens.paddingAllLg,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppLocalizations.totalGamesMatches),
                Text(
                  '${_group.totalGamesPlayedInGroup}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppLocalizations.totalHandsPlayed),
                Text(
                  '$totalHandsPlayed',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppLocalizations.noResultRate),
                Text(
                  '${(noResultRate * 100).toStringAsFixed(2)}%',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerStatsList() {
    final mergedStats = _getMergedStats();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _group.players.length,
      itemBuilder: (context, index) {
        final name = _group.players[index];
        final stats = mergedStats[name] ?? PlayerStats(playerName: name);

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: Padding(
            padding: AppDimens.paddingAllLg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.emoji_events, color: Colors.amber),
                      tooltip: AppLocalizations.achvTitle,
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.achievements,
                          arguments: AchievementArgs(
                            groupName: _group.name,
                            playerName: name,
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _statItem(
                      AppLocalizations.statsWinRate,
                      '${(stats.winningRate * 100).toStringAsFixed(2)}%',
                    ),
                    _statItem(
                      AppLocalizations.statsSelfDraw,
                      '${stats.totalTsumo}',
                    ),
                    _statItem(AppLocalizations.statsRon, '${stats.totalRon}'),
                    _statItem(
                      AppLocalizations.statsDealIn,
                      '${stats.totalDealsIn}',
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class DealerSelectionDialog extends StatefulWidget {
  final List<String> players;
  final Function(int, int, int, GameMode)
  onDealerSelected; // (dealerIndex, minFan/baseTai, maxFan/fixedTaiUnit, gameMode)
  final int initialMinFan;
  final int initialMaxFan;
  final GameMode gameMode;

  DealerSelectionDialog({
    super.key,
    required this.players,
    required this.onDealerSelected,
    int? initialMinFan,
    int? initialMaxFan,
    this.gameMode = GameMode.hongKong,
  }) : initialMinFan = initialMinFan ?? SettingsService.instance.hkMinFan,
       initialMaxFan = initialMaxFan ?? SettingsService.instance.hkMaxFan;

  @override
  State<DealerSelectionDialog> createState() => _DealerSelectionDialogState();
}

class _DealerSelectionDialogState extends State<DealerSelectionDialog> {
  int _selectedDealer = 0;
  late int _param1; // minFan or baseTai
  late int _param2; // maxFan or fixed TW tai unit (always 1)
  late GameMode _selectedGameMode;

  @override
  void initState() {
    super.initState();
    _selectedGameMode = widget.gameMode;
    _param1 = widget.initialMinFan;
    _param2 = widget.initialMaxFan;

    // Default values if switching modes or not set properly
    _applyModeDefaults();
  }

  void _applyModeDefaults() {
    if (_selectedGameMode == GameMode.taiwan) {
      if (_param1 < 10) _param1 = SettingsService.instance.twBaseTai;
      _param2 = 1;
    } else {
      // Restore HK defaults if params look like TW values
      if (_param1 > 13) _param1 = SettingsService.instance.hkMinFan;
      if (_param2 < 3 && _param2 != 0)
        _param2 = SettingsService.instance.hkMaxFan;
    }
  }

  void _onGameModeChanged(GameMode mode) {
    if (mode == _selectedGameMode) return;
    setState(() {
      _selectedGameMode = mode;
      // Reset to sensible defaults for the new mode
      if (mode == GameMode.taiwan) {
        _param1 = SettingsService.instance.twBaseTai;
        _param2 = 1;
      } else {
        _param1 = SettingsService.instance.hkMinFan;
        _param2 = SettingsService.instance.hkMaxFan;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isTaiwan = _selectedGameMode == GameMode.taiwan;

    return AlertDialog(
      title: Text(AppLocalizations.selectDealer),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Game Mode Selector ──────────────────────────────
            Text(
              AppLocalizations.gameMode,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<GameMode>(
                segments: [
                  ButtonSegment(
                    value: GameMode.hongKong,
                    label: Text(
                      AppLocalizations.hongKongMahjong,
                      style: const TextStyle(fontSize: 12),
                    ),
                    icon: const Icon(Icons.casino, size: 16),
                  ),
                  ButtonSegment(
                    value: GameMode.taiwan,
                    label: Text(
                      AppLocalizations.taiwaneseMahjong,
                      style: const TextStyle(fontSize: 12),
                    ),
                    icon: const Icon(Icons.casino, size: 16),
                  ),
                ],
                selected: {_selectedGameMode},
                onSelectionChanged: (value) => _onGameModeChanged(value.first),
                showSelectedIcon: false,
              ),
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 4),
            Text(
              AppLocalizations.selectDealer,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            ...List.generate(widget.players.length, (index) {
              return RadioListTile<int>(
                title: Text(widget.players[index]),
                value: index,
                // ignore: deprecated_member_use
                groupValue: _selectedDealer,
                // ignore: deprecated_member_use
                onChanged: (value) {
                  setState(() {
                    _selectedDealer = value!;
                  });
                },
              );
            }),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              isTaiwan ? AppLocalizations.gameMode : AppLocalizations.gameRules,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ), // Label Reuse? Or just Settings
            const SizedBox(height: 8),

            // Param 1: Min Fan (HK) or Base Tai (TW)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isTaiwan ? AppLocalizations.baseTai : AppLocalizations.minFan,
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () {
                        setState(() {
                          if (_param1 > 0) _param1--;
                        });
                      },
                    ),
                    Text('$_param1', style: const TextStyle(fontSize: 16)),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () {
                        setState(() {
                          if (!isTaiwan) {
                            // HK Logic: minFan < maxFan unless max is unlimited
                            if (_param2 != 999 && _param1 < _param2) {
                              _param1++;
                            } else if (_param2 == 999) {
                              _param1++;
                            }
                          } else {
                            // TW Logic: Base Tai can be anything
                            _param1++;
                          }
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),

            if (!isTaiwan)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppLocalizations.maxFan),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () {
                          setState(() {
                            if (_param2 == 999) {
                              _param2 = 13;
                            } else if (_param2 > _param1) {
                              _param2--;
                            }
                          });
                        },
                      ),
                      Text(
                        _param2 == 999 ? AppLocalizations.noLimit : '$_param2',
                        style: const TextStyle(fontSize: 16),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () {
                          setState(() {
                            if (_param2 < 100) {
                              _param2++;
                            } else {
                              _param2 = 999;
                            }
                            if (_param2 > 13) _param2 = 999;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => widget.onDealerSelected(
            _selectedDealer,
            _param1,
            _param2,
            _selectedGameMode,
          ),
          child: Text(AppLocalizations.startGame),
        ),
      ],
    );
  }
}
