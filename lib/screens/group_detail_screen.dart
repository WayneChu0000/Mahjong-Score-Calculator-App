import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/player_group.dart';
import '../models/player_stats.dart';
import '../services/player_group_service.dart';
import 'score_recording_screen.dart';
import '../services/score_service.dart';
import '../localization/app_localizations.dart';

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
    setState(() => _isLoading = false);
  }

  void _startNewGame() {
    // Check if there is an active unfinished game
    bool hasActiveGame = _group.currentRound != null && _group.currentRound! > 1; // Round 1 is default
    // Or if scores are different from 0 (simple check)
    if (_group.currentScores != null && _group.currentScores!.values.any((score) => score != 0)) {
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
          for(var p in _group.players) {
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
                  totalGamesPlayed: s.totalGamesPlayed + (_group.roundHistory?.length ?? 0),
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
        onDealerSelected: (dealerIndex) {
          Navigator.pop(context); // Close dialog
          _navigateToGame(dealerIndex, isNewGame: true);
        },
      ),
    );
  }

  void _resumeGame() {
    // Navigate to game with current saved state
    // Dealer index should be preserved in _group
    _navigateToGame(_group.dealerIndex ?? 0, isNewGame: false);
  }

  void _navigateToGame(int dealerIndex, {required bool isNewGame}) async {
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
        score: isNewGame ? 0 : (_group.currentScores?[_group.players[index]] ?? 0),
      ),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScoreRecordingScreen(
          players: players,
          currentRound: isNewGame ? 1 : (_group.currentRound ?? 1),
          totalRounds: 16, 
          onScoreSubmitted: (scores) {},
          groupName: _group.name,
          initialDealerIndex: dealerIndex,
          initialPrevalentWindIndex: isNewGame ? 0 : (_group.prevalentWindIndex ?? 0),
          initialDealerGameCount: isNewGame ? 1 : (_group.currentDealerGameCount ?? 1),
          initialTotalWindRounds: isNewGame ? 1 : (_group.totalWindRounds ?? 1),
        ),
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
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshGroup,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCard(),
                  const SizedBox(height: 20),
                  Text(AppLocalizations.playerStatsTitle, style: Theme.of(context).textTheme.titleLarge),
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
                              foregroundColor: Colors.white,
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

    // Merge current game round history
    if (_group.roundHistory != null && _group.roundHistory!.isNotEmpty) {
       for (var round in _group.roundHistory!) {
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
              stats[dealInPlayer] = s.copyWith(
                  totalDealsIn: s.totalDealsIn + 1
              );
         }

         // Update total hands played for all players
         // Note: Logic assumes all players played all rounds.
         for (var p in _group.players) {
             if (stats.containsKey(p)) {
                 final s = stats[p]!;
                 stats[p] = s.copyWith(
                     totalGamesPlayed: s.totalGamesPlayed + 1
                 );
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
    
    // Iterate through rounds to count global stats if cleaner
    // Since stats is map<Player, Stat>, it's hard to get global No Result count just from player stats unless we track it there (we don't)
    // We should parse round history for current game + some stored global stat?
    // Current group model doesn't store total No Results explicitly.
    // It stores playerStats.
    // We can iterate roundHistory if available for current game.
    // For past games, unless we saved it, we might lose it if not in PlayerStats.
    // But PlayerStats doesn't track "No Result".
    // Wait, the prompt implies we should have this data.
    // Maybe we need to count (Total Hands - Sum of One Player's Wins - Sum of Other Wins - ...)?
    // No, multiple people can't win usually (unless double ron).
    // Let's assume No Result = Total Hands - Total Wins (by anyone).
    
    // Calculate total wins by anyone
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
    // Handled Double Ron? If double ron, totalWinsByAnyone > totalHandsPlayed potentially?
    // If double ron is recorded as 2 wins in 1 hand... yes.
    // But our logic increment totalGamesPlayed by 1 for everyone per round.
    // Standard mahjong: 1 hand = 1 result.
    // If No Result, no one wins. totalWinsByAnyone increases by 0.
    // If 1 person wins, increases by 1.
    // If Double Ron, increases by 2.
    // So No Result Rate might be inaccurate if Double Ron exists.
    // But assuming standard or "No Result" explicitly tracked would be better.
    // Given current data structure limitations, let's use the (Total - Wins) approximation or 0 if negative.
    if (totalNoResultHands < 0) totalNoResultHands = 0;

    double noResultRate = totalHandsPlayed > 0 ? totalNoResultHands / totalHandsPlayed : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppLocalizations.totalGamesMatches),
                Text('${_group.totalGamesPlayedInGroup}', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppLocalizations.totalHandsPlayed),
                Text('$totalHandsPlayed', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppLocalizations.noResultRate),
                Text('${(noResultRate * 100).toStringAsFixed(2)}%', style: const TextStyle(fontWeight: FontWeight.bold)),
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
        // Scores are game-specific usually, but here we show accumulative score from finished games?
        // Or current score? The prompt asks for "data in group detail page".
        // Usually stats page shows historical aggregate.
        // Let's stick to showing historical total score, as calculating current score change requires
        // parsing every round detail or using currentScores.
        // If we want total score across all time, we normally sum up finished games.
        // If we want to include current game score... it's _group.currentScores.
        // Let's add current game score to totalScore for display?
        
        // Calculate No Result Rate
        double noResultRate = 0.0;
        if (stats.totalGamesPlayed > 0) {
             // Assuming totalGamesPlayed = Wins + Deal-ins? No.
             // Wins + Losses + Draws (No Result) = Total Games
             // But we don't track Draws explicitly in stats model.
             // We can infer or assuming sum of win rates + no result rate = 1.
             // If we want No Result Rate of the *Player*, normally it's global.
             // But here we are displaying per player card.
             // Maybe user means global No Result Rate?
             // "add a no result rate under the number of hands which is no result/total hands"
             // This sounds like it belongs to Summary Card.
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _statItem(AppLocalizations.statsWinRate, '${(stats.winningRate * 100).toStringAsFixed(2)}%'),
                    _statItem(AppLocalizations.statsSelfDraw, '${stats.totalTsumo}'),
                    _statItem(AppLocalizations.statsRon, '${stats.totalRon}'),
                    _statItem(AppLocalizations.statsDealIn, '${stats.totalDealsIn}'),
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
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

//   Widget _statItem(String label, String value) {
//     return Column(
//       children: [
//         Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
//         Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
//       ],
//     );
//   }
// }

class DealerSelectionDialog extends StatefulWidget {
  final List<String> players;
  final Function(int) onDealerSelected;

  const DealerSelectionDialog({
    super.key,
    required this.players,
    required this.onDealerSelected,
  });

  @override
  State<DealerSelectionDialog> createState() => _DealerSelectionDialogState();
}

class _DealerSelectionDialogState extends State<DealerSelectionDialog> {
  int _selectedDealer = 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.selectDealer),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(widget.players.length, (index) {
          return RadioListTile<int>(
            title: Text(widget.players[index]),
            value: index,
            groupValue: _selectedDealer,
            onChanged: (value) {
              setState(() {
                _selectedDealer = value!;
              });
            },
          );
        }),
      ),
      actions: [
        TextButton(
          onPressed: () => widget.onDealerSelected(_selectedDealer),
          child: Text(AppLocalizations.startGame),
        ),
      ],
    );
  }
}
