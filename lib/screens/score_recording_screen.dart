import 'package:flutter/material.dart';
import '../models/player.dart';
import '../services/score_service.dart';
import 'score_calculation_screen.dart';
import 'dart:async';

class ScoreRecordingScreen extends StatefulWidget {
  final List<Player> players;
  final int currentRound;
  final int totalRounds;
  final Function(Map<String, int>) onScoreSubmitted;
  final String? groupId;
  final String? groupName;

  const ScoreRecordingScreen({
    super.key,
    required this.players,
    required this.currentRound,
    required this.totalRounds,
    required this.onScoreSubmitted,
    this.groupId,
    this.groupName,
  });

  @override
  State<ScoreRecordingScreen> createState() => _ScoreRecordingScreenState();
}

class _ScoreRecordingScreenState extends State<ScoreRecordingScreen> {
  // Dealer index
  int _dealerIndex = 0;
  
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
      }
      });
    } catch (e) {
      print('Error subscribing to score stream: $e');
    }
    
    // Default first player as dealer
    _dealerIndex = 0;
    
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
            const Text('All rounds completed, game over!'),
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
              // Return to home page
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: const Text('Back to Home'),
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
          players: _updatedPlayers.map((player) => player.name).toList(),
        ),
      ),
    ).then((result) {
      // Handle result when returning from score calculation screen
      if (result != null && result is Map<String, int>) {
        // Call original callback to notify parent component
        widget.onScoreSubmitted(result);
        
        // Update score service
        _scoreService.updateScores(result);
        
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
    if (currentRound > totalRounds) {
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

  @override
  Widget build(BuildContext context) {
    // Get dealer
    final dealer = widget.players[_dealerIndex];
    
    // Get current round and total rounds from ScoreService
    final currentRound = _scoreService.getCurrentRound();
    final totalRounds = _scoreService.getTotalRounds();
    
    // Title setting
    String title = 'Mahjong Scoring';
    if (widget.groupName != null && widget.groupName!.isNotEmpty) {
      title = '${widget.groupName} - Round $currentRound'; // Use ScoreService's round number
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
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
                        'Round $currentRound / Total $totalRounds', // Use ScoreService's round number
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        // Edit round info, such as modifying total rounds
                        _selectDealer(); // Only implement dealer selection here
                      },
                      tooltip: 'Select Dealer',
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Player scores display area
            Expanded(
              child: ListView(
                children: [
                  // Dealer score
                  _buildPlayerScoreCard(dealer, isDealer: true),
                  
                  const SizedBox(height: 8),
                  
                  // Other player scores
                  ...widget.players
                      .where((player) => player.id != dealer.id)
                      .map((player) => Column(
                            children: [
                              _buildPlayerScoreCard(player),
                              const SizedBox(height: 8),
                            ],
                          ))
                      .toList(),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Bottom action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.calculate),
                    label: const Text('Calculate Score'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: _openScoreCalculator,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.close),
                    label: const Text('No Result'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: _endRoundWithNoResult,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  // Build player score card
  Widget _buildPlayerScoreCard(Player player, {bool isDealer = false}) {
    // Get current score
    final currentScore = _scoreService.getPlayerScore(player.id.toString());
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Dealer indicator
            if (isDealer)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'D',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            
            const SizedBox(width: 8),
            
            // Player name
            Expanded(
              child: Text(
                isDealer ? 'Dealer (${player.name})' : player.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isDealer ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            
            // Score display
            Text(
              'Score: $currentScore',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: currentScore >= 0 ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}