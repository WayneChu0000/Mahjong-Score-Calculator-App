import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/game_record.dart';
import '../widgets/player_card.dart';
import 'score_recording_screen.dart';

class GamePlayScreen extends StatefulWidget {
  final List<Player> players;
  final String? groupId;
  final String? groupName;
  final int totalRounds;

  const GamePlayScreen({
    super.key, 
    required this.players,
    this.groupId,
    this.groupName,
    this.totalRounds = 16, // Default 16 rounds
  });

  @override
  State<GamePlayScreen> createState() => _GamePlayScreenState();
}

class _GamePlayScreenState extends State<GamePlayScreen> {
  late List<Player> gamePlayers;
  int currentRound = 1;
  
  @override
  void initState() {
    super.initState();
    gamePlayers = List.from(widget.players);
    
    // Open score recording screen immediately after initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openScoreRecordingScreen();
    });
  }

  // Open score recording screen
  void _openScoreRecordingScreen() {
    // If current round exceeds total rounds, show game end
    if (currentRound > widget.totalRounds) {
      _showGameEndSummary();
      return;
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScoreRecordingScreen(
          players: gamePlayers,
          currentRound: currentRound,
          totalRounds: widget.totalRounds,
          onScoreSubmitted: (Map<String, int> scoreChanges) {
            setState(() {
              // Update player scores
              scoreChanges.forEach((playerId, scoreChange) {
                final index = gamePlayers.indexWhere((p) => p.id.toString() == playerId);
                if (index != -1) {
                  gamePlayers[index] = gamePlayers[index].copyWith(
                    score: gamePlayers[index].score + scoreChange,
                  );
                }
              });
              
              // Increment round
              currentRound++;
              
              // Open new score recording screen on next frame
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _openScoreRecordingScreen();
              });
            });
          },
          groupId: widget.groupId,
          groupName: widget.groupName,
        ),
      ),
    );
  }
  
  // Show game end summary
  void _showGameEndSummary() {
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
            ...gamePlayers.map((player) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(player.name),
                    Text(
                      '${player.score}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: player.score >= 0 ? Colors.green : Colors.red,
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
              // Save game record
              _recordGame();
              
              // Return to home page
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: const Text('Save & Return'),
          ),
        ],
      ),
    );
  }

  void _recordGame() {
    // Add logic to record game here
    // Create game record but don't save to local variable
    GameRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      players: List.from(gamePlayers),
      rounds: currentRound - 1, // Actual completed rounds
    );
    
    // Can add code to save record here
    // If it's a player group game, also update group statistics
    if (widget.groupId != null) {
      _updatePlayerGroupStats();
    }
  }
  
  void _updatePlayerGroupStats() {
    // In actual application, should update player group statistics here
    print('Update player group statistics: ${widget.groupId}');
    // TODO: Implement update logic
  }

  @override
  Widget build(BuildContext context) {
    String title = widget.groupName != null && widget.groupName!.isNotEmpty
        ? '${widget.groupName} - Round $currentRound'
        : 'Round $currentRound';
    
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              _recordGame();
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: gamePlayers.length,
              padding: const EdgeInsets.all(8.0),
              itemBuilder: (context, index) {
                return PlayerCard(
                  player: gamePlayers[index],
                  onScoreChanged: (int newScore) {
                    setState(() {
                      gamePlayers[index] = gamePlayers[index].copyWith(score: newScore);
                    });
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.grey.shade200,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.add_circle),
                  label: const Text('Continue Game'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _openScoreRecordingScreen,
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('End Game'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    _recordGame();
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}