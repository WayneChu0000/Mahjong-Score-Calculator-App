import 'package:flutter/material.dart';
import '../models/player.dart';
import '../services/score_service.dart';
import '../services/player_group_service.dart';
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

  @override
  void initState() {
    super.initState();
    
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
            }).toList(),
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
            onPressed: () {
              // Return to home page
              Navigator.popUntil(context, (route) => route.isFirst);
            },
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
      if (result != null && result is Map<String, int>) {
        // Call original callback to notify parent component
        widget.onScoreSubmitted(result);
        
        // Update score service
        _scoreService.updateScores(result);
        
        // Determine winner and rotate dealer if necessary
        // If dealer has positive score change, dealer stays (Renchan)
        // Otherwise, dealer rotates to next player
        final dealerId = widget.players[_dealerIndex].id.toString();
        bool dealerWon = false;
        
        if (result.containsKey(dealerId) && result[dealerId]! > 0) {
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
            itemCount: widget.players.length,
            itemBuilder: (context, index) {
              return RadioListTile<int>(
                title: Text(widget.players[index].name),
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
      );
      
      await PlayerGroupService.saveGroup(updatedGroup);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get dealer
    final dealer = widget.players[_dealerIndex];
    
    // Get current round and total rounds from ScoreService
    final currentRound = _scoreService.getCurrentRound();
    final totalRounds = _scoreService.getTotalRounds();
    
    // Title setting
    String title = 'Mahjong Scoring';
    final windName = ['East', 'South', 'West', 'North'][_prevalentWindIndex];
    if (widget.groupName != null && widget.groupName!.isNotEmpty) {
      title = '${widget.groupName} - $windName Round - Game $_currentDealerGameCount';
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
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
                        totalRounds > 0 
                            ? '$windName Round - Game $_currentDealerGameCount / Total $totalRounds' 
                            : '$windName Round - Game $_currentDealerGameCount',
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
                          if (widget.players.length > 2)
                            Align(
                              alignment: Alignment.topCenter,
                              child: _buildCompactPlayerCard(widget.players[2], 2),
                            ),
                            
                          // Player 0 (Self/East relative to 0) - Bottom
                          if (widget.players.isNotEmpty)
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: _buildCompactPlayerCard(widget.players[0], 0),
                            ),
                            
                          // Player 3 (Left/North relative to 0) - Left
                          if (widget.players.length > 3)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: _buildCompactPlayerCard(widget.players[3], 3),
                            ),
                            
                          // Player 1 (Right/South relative to 0) - Right
                          if (widget.players.length > 1)
                            Align(
                              alignment: Alignment.centerRight,
                              child: _buildCompactPlayerCard(widget.players[1], 1),
                            ),
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