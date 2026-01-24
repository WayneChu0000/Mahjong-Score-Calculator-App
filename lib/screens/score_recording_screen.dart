import 'package:flutter/material.dart';
import '../models/player.dart';
import '../services/score_service.dart';
import '../services/player_group_service.dart';
import '../models/player_group.dart';
import '../models/player_stats.dart';
import 'score_calculation_screen.dart';
import 'rules_screen.dart';
import 'dart:async';

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
  });

  @override
  State<ScoreRecordingScreen> createState() => _ScoreRecordingScreenState();
}

class _ScoreRecordingScreenState extends State<ScoreRecordingScreen> {
  // Dealer index
  int _dealerIndex = 0;
  // Prevalent Wind index (0: East, 1: South, 2: West, 3: North)
  int _prevalentWindIndex = 0;
  // Current Dealer Game Count (Renchan count + 1)
  int _currentDealerGameCount = 1;
  // Total Wind Rounds (starts at 1)
  int _totalWindRounds = 1;
  
  // Use ScoreService
  final ScoreService _scoreService = ScoreService();
  
  // Score subscription
  StreamSubscription? _scoreSubscription;
  
  // Updated player list
  late List<Player> _updatedPlayers;

  // Round History for stats
  List<Map<String, dynamic>> _roundHistory = [];
  
  // Flag to check if round history is loaded
  bool _isRoundHistoryLoaded = false;
  
  @override
  void initState() {
    super.initState();
    
    // Load round history if group exists
    _loadRoundHistory();

    
    // Initialize player list
    _updatedPlayers = List.from(widget.players);
    
    // Initialize score service
    _scoreService.initGame(
      widget.players, 
      initialPublicScore: 0,
      currentRound: widget.currentRound,
      totalRounds: widget.totalRounds
    );
    
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
      print('Error subscribing to score stream: $e');
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

  @override
  void dispose() {
    // Cancel subscription safely
    try {
      _scoreSubscription?.cancel();
    } catch (e) {
      print('Error canceling score subscription: $e');
    }
    super.dispose();
  }
  
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

  // Show game end dialog
  void _showGameEndDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Game Over'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Wind Rounds: $_totalWindRounds'),
            Text('Total Games Played: ${_scoreService.getCurrentRound() - 1}'),
            const SizedBox(height: 16),
            const Text('Final Scores:', style: TextStyle(fontWeight: FontWeight.bold)),
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
                        color: score >= 0 ? Colors.green : Colors.red,
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
            child: const Text('Back to Game'),
          ),
          TextButton(
            onPressed: _finishGame,
            child: const Text('Finish Game'),
          ),
        ],
      ),
    );
  }


  // Open advanced score calculator
  void _openScoreCalculator() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScoreCalculationScreen(
          players: _updatedPlayers,
          roundWindIndex: _prevalentWindIndex,
          dealerIndex: _dealerIndex,
        ),
      ),
    ).then((result) {
      // Handle result when returning from score calculation screen
      if (result != null) {
        Map<String, int> scoreChanges;
        
        if (result is Map<String, int>) {
           scoreChanges = result;
        } else if (result is Map<String, dynamic> && result.containsKey('scores')) {
           scoreChanges = Map<String, int>.from(result['scores']);
           _roundHistory.add(result);
        } else {
           return;
        }

        // Call original callback to notify parent component
        widget.onScoreSubmitted(scoreChanges);
        
        // Update score service
        _scoreService.updateScores(scoreChanges);
        
        // Determine winner and rotate dealer if necessary
        // If dealer has positive score change, dealer stays (Renchan)
        // Otherwise, dealer rotates to next player
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
            // If dealer rotates back to 0, increment wind
            if (_dealerIndex == 0) {
              _prevalentWindIndex = (_prevalentWindIndex + 1) % 4;
              _totalWindRounds++;
            }
          });
        }
        
        // Increment round
        _scoreService.incrementRound();
        
        // Check if game has ended
        if (_scoreService.isGameEnd()) {
          _showGameEndDialog();
          return;
        }
        
        // Start next round
        _startNextRound();
      }
    });
  }

  // End round with no result
  void _endRoundWithNoResult() {
    // Create a zero score change map
    Map<String, int> noChangeScores = {};
    for (var player in widget.players) {
      noChangeScores[player.id.toString()] = 0;
    }
    
    // Call original callback to notify parent component
    widget.onScoreSubmitted(noChangeScores);
    
    // Add to history
    _roundHistory.add({
      'scores': noChangeScores,
      'winningPlayer': null,
      'isSelfDraw': false,
      'resultType': 'No Result',
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    // Update Game Count for No Result (Renchan)
    setState(() {
      _currentDealerGameCount++;
    });

    // Update scores (no change but keep consistent calling method)
    _scoreService.updateScores(noChangeScores);
    
    // Increment round
    _scoreService.incrementRound();
    
    // Check if game has ended
    if (_scoreService.isGameEnd()) {
      // Show game end dialog
      _showGameEndDialog();
      return;
    }
    
    // Start next round
    _startNextRound();
  }
  
  // Start next round
  void _startNextRound() {
    // Get current round and total rounds
    final currentRound = _scoreService.getCurrentRound();
    final totalRounds = _scoreService.getTotalRounds();
    
    // If total rounds exceeded, show game end dialog
    if (totalRounds > 0 && currentRound > totalRounds) {
      _showGameEndDialog();
      return;
    }
    
    // Get updated player list
    final updatedPlayers = widget.players.map((player) {
      return player.copyWith(
        score: _scoreService.getPlayerScore(player.id.toString())
      );
    }).toList();
    
    // Refresh current page
    setState(() {
      _updatedPlayers = updatedPlayers;
    });
    
    // Can choose not to create new page, just refresh current page
    // This avoids page stack getting too deep
  }

  // Select dealer
  void _selectDealer() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Dealer'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _updatedPlayers.length,
            itemBuilder: (context, index) {
              return RadioListTile<int>(
                title: Text(_updatedPlayers[index].name),
                value: index,
                groupValue: _dealerIndex,
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
        title: const Text('Change Position'),
        content: Text('Swap positions of ${fromPlayer.name} and ${toPlayer.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Swap'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        // Find current dealer ID to track them
        final dealerId = _updatedPlayers[_dealerIndex].id;
        
        // Swap
        final temp = _updatedPlayers[fromIndex];
        _updatedPlayers[fromIndex] = _updatedPlayers[toIndex];
        _updatedPlayers[toIndex] = temp;
        
        // Update dealer index
        for (int i = 0; i < _updatedPlayers.length; i++) {
          if (_updatedPlayers[i].id == dealerId) {
            _dealerIndex = i;
            break;
          }
        }
      });
      
      if (!mounted) return;

      // Show advanced reset dialog
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          bool resetDealer = false;
          bool resetWind = false;
          
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('Reset Game State?'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                     CheckboxListTile(
                       title: const Text("Reset Dealer Position"),
                       subtitle: const Text("Choose a new dealer"),
                       value: resetDealer,
                       onChanged: (val) => setState(() => resetDealer = val!),
                     ),
                     CheckboxListTile(
                       title: const Text("Reset Wind Round"),
                       subtitle: const Text("Reset to East 1"),
                       value: resetWind,
                       onChanged: (val) => setState(() => resetWind = val!),
                     ),
                  ],
                ),
                actions: [
                  TextButton(
                     onPressed: () => Navigator.pop(context),
                     child: const Text('Cancel Reset'),
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
                    child: const Text('Apply'),
                  ),
                ],
              );
            }
          );
        },
      );
    }
  }

  Widget _buildDraggablePosition(int index, Alignment alignment) {
     if (index >= _updatedPlayers.length) return const SizedBox.shrink();

     return Align(
        alignment: alignment,
        child: DragTarget<int>(
          onWillAccept: (data) => data != null && data != index,
          onAccept: (fromIndex) => _handlePlayerSwap(fromIndex, index),
          builder: (context, candidateData, rejectedData) {
            return LongPressDraggable<int>(
              data: index,
              feedback: Material(
                color: Colors.transparent,
                child: Opacity(
                  opacity: 0.7,
                  child: _buildCompactPlayerCard(_updatedPlayers[index], index),
                ),
              ),
              childWhenDragging: Opacity(
                opacity: 0.3,
                child: _buildCompactPlayerCard(_updatedPlayers[index], index),
              ),
              child: _buildCompactPlayerCard(_updatedPlayers[index], index),
            );
          },
        ),
     );
  }

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

  void _showStatsDialog() {
    int totalRounds = _roundHistory.length;
    int totalWins = 0;
    
    // Calculate total wins to derive No Result cnt
    // Using a map to avoid double counting if multiple winners per round (if supported)
    // But simplistic approach: iterate rounds.
    int noResultCount = 0;
    for (var round in _roundHistory) {
         if (round['winningPlayer'] == null) {
             noResultCount++;
         }
    }
    double noResultRate = totalRounds > 0 ? noResultCount / totalRounds : 0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                const Text('Current Game Stats'),
                if (totalRounds > 0)
                    Text('No Result Rate: ${(noResultRate * 100).toStringAsFixed(2)}%', 
                        style: const TextStyle(fontSize: 14, color: Colors.grey)),
            ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: totalRounds == 0 
            ? const Text('No rounds played yet.') 
            : ListView.builder(
                shrinkWrap: true,
                itemCount: widget.players.length,
                itemBuilder: (context, index) {
                  final player = widget.players[index];
                  int wins = 0;
                  int tsumos = 0;
                  int rons = 0;
                  int dealsIn = 0;
                  
                  for(var round in _roundHistory) {
                    if (round['winningPlayer'] == player.name) {
                      wins++;
                      if (round['isSelfDraw'] == true) tsumos++;
                      else rons++;
                    }
                    if (round['discardPlayer'] == player.name) {
                        dealsIn++;
                    }
                  }
                  
                  double winRate = totalRounds > 0 ? wins / totalRounds : 0;
                  
                  return ListTile(
                    title: Text(player.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Win Rate: ${(winRate * 100).toStringAsFixed(2)}%'),
                        Row(
                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                             children: [
                                 Text('Self-Draw: $tsumos'),
                                 Text('Discard: $rons'),
                                 Text('Deal-in: $dealsIn'),
                             ]
                        )
                      ],
                    ),
                  );
                },
              ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    // Get dealer
    final dealer = _updatedPlayers[_dealerIndex];
    
    // Get current round and total rounds from ScoreService
    final currentRound = _scoreService.getCurrentRound();
    final totalRounds = _scoreService.getTotalRounds();
    
    // Title setting
    String title = 'Mahjong Scoring';
    final windName = ['East', 'South', 'West', 'North'][_prevalentWindIndex];
    if (widget.groupName != null && widget.groupName!.isNotEmpty) {
      title = '${widget.groupName} - $windName Round - Game $_currentDealerGameCount';
    }
    
    return WillPopScope(
      onWillPop: () async {
        await _saveGameState();
        return true;
      },
      child: Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Game Statistics',
            onPressed: _showStatsDialog,
          ),
          IconButton(
            icon: const Icon(Icons.menu_book),
            tooltip: 'Rules Reference',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RulesScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.home),
            tooltip: 'Back to Home',
            onPressed: () {
              _saveGameState();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Current round information
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.casino, color: Colors.green),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '$windName Round - Game $_currentDealerGameCount',
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
            
            // Player scores display area - Table Layout
            Expanded(
              child: Center(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final size = constraints.biggest.shortestSide;
                    return SizedBox(
                      width: size,
                      height: size,
                      child: Stack(
                        children: [
                          // Center table
                          Center(
                            child: Container(
                              width: size * 0.3,
                              height: size * 0.3,
                              decoration: BoxDecoration(
                                color: Colors.green.shade800,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Mahjong',
                                    style: TextStyle(color: Colors.white70, fontSize: 10),
                                  ),
                                  Text(
                                    '${['East', 'South', 'West', 'North'][_prevalentWindIndex]} Round',
                                    style: const TextStyle(
                                      color: Colors.white, 
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    'Game $_currentDealerGameCount',
                                    style: const TextStyle(
                                      color: Colors.white70, 
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          // Player 2 (Opposite/West relative to 0) - Top
                          if (_updatedPlayers.length > 2)
                            _buildDraggablePosition(2, Alignment.topCenter),
                            
                          // Player 0 (Self/East relative to 0) - Bottom
                          if (_updatedPlayers.isNotEmpty)
                            _buildDraggablePosition(0, Alignment.bottomCenter),
                            
                          // Player 3 (Left/North relative to 0) - Left
                          if (_updatedPlayers.length > 3)
                            _buildDraggablePosition(3, Alignment.centerLeft),
                            
                          // Player 1 (Right/South relative to 0) - Right
                          if (_updatedPlayers.length > 1)
                            _buildDraggablePosition(1, Alignment.centerRight),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Bottom action buttons
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.calculate),
                        label: const Text('Calculate'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: _openScoreCalculator,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.close),
                        label: const Text('No Result'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Theme.of(context).brightness == Brightness.dark 
                              ? Colors.white 
                              : Colors.black,
                          side: BorderSide(
                            color: Theme.of(context).brightness == Brightness.dark 
                                ? Colors.grey.shade600 
                                : Colors.grey.shade300,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
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
                    label: const Text('Finish Game'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: _showGameEndDialog,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }
  
  // Build compact player card for table layout
  Widget _buildCompactPlayerCard(Player player, int index) {
    final isDealer = index == _dealerIndex;
    final currentScore = _scoreService.getPlayerScore(player.id.toString());
    
    // Determine wind based on index relative to dealer
    // 0: East
    // 1: South (Right of Dealer)
    // 2: West (Opposite of Dealer)
    // 3: North (Left of Dealer)
    final windIndex = (index - _dealerIndex + 4) % 4;
    final winds = ['East', 'South', 'West', 'North'];
    final windName = winds[windIndex];
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: 110,
      height: 90,
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: isDealer 
            ? Border.all(color: Colors.red, width: 2) 
            : Border.all(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isDealer 
                  ? Colors.red 
                  : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              isDealer ? 'DEALER' : windName,
              style: TextStyle(
                color: isDealer 
                    ? Colors.white 
                    : (isDark ? Colors.grey.shade300 : Colors.black54),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            player.name,
            style: TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: 13,
              color: isDark ? Colors.white : Colors.black,
            ),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          Text(
            '$currentScore',
            style: TextStyle(
              color: currentScore >= 0 ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}