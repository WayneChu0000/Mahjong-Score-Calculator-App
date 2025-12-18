import 'package:flutter/material.dart';
import '../models/player.dart';
import 'score_recording_screen.dart';

class PlayerSetupScreen extends StatefulWidget {
  final List<Player>? existingPlayers;
  final String? groupName;
  final String? groupId;
  final bool directStart;

  const PlayerSetupScreen({
    super.key, 
    this.existingPlayers,
    this.groupName,
    this.groupId,
    this.directStart = false,
  });

  @override
  State<PlayerSetupScreen> createState() => _PlayerSetupScreenState();
}

class _PlayerSetupScreenState extends State<PlayerSetupScreen> {
  int selectedPlayerCount = 4;
  List<Player> players = [];
  late TextEditingController _groupNameController;
  bool _isNewGroup = true;

  @override
  void initState() {
    super.initState();
    
    // Initialize player list
    if (widget.existingPlayers != null) {
      players = List.from(widget.existingPlayers!);
      selectedPlayerCount = players.length;
      _isNewGroup = false;
    } else {
      _initializePlayers();
      _isNewGroup = true;
    }
    
    // Initialize group name controller
    _groupNameController = TextEditingController(text: widget.groupName ?? '');
    
    // If set to direct start, skip setup and start game
    if (widget.directStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startGame();
      });
    }
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    super.dispose();
  }

  void _initializePlayers() {
    players = List.generate(
      4,
      (index) => Player(id: index, name: 'Player ${index + 1}', score: 0),
    );
  }
  
  void _startGame() {
    // Save player group (should save to database or SharedPreferences in production)
    _savePlayerGroup();
    
    // Only keep selected number of players
    final selectedPlayers = players.take(selectedPlayerCount).toList();
    
    // Navigate to score recording screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScoreRecordingScreen(
          players: selectedPlayers,
          currentRound: 1,
          totalRounds: 16, // Default 16 rounds
          onScoreSubmitted: (Map<String, int> scoreChanges) {
            // Can save game records here
            debugPrint('Round ended, score changes: $scoreChanges');
            
            // Note: No extra handling needed here as ScoreRecordingScreen handles round progression
          },
          groupId: widget.groupId,
          groupName: _groupNameController.text,
        ),
      ),
    );
  }
  
  void _savePlayerGroup() {
    // In production, should save player group to database or SharedPreferences
    debugPrint('Saving player group: ${_groupNameController.text}');
    // TODO: Implement save logic
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingPlayers != null ? 'Edit Players' : 'Setup Players'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Group name input
            TextField(
              controller: _groupNameController,
              decoration: const InputDecoration(
                labelText: 'Group Name',
                border: OutlineInputBorder(),
                hintText: 'e.g., Weekend Mahjong Group',
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Player count selection
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Select Number of Players',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    SegmentedButton<int>(
                      segments: const [
                        ButtonSegment<int>(value: 2, label: Text('2 Players')),
                        ButtonSegment<int>(value: 3, label: Text('3 Players')),
                        ButtonSegment<int>(value: 4, label: Text('4 Players')),
                      ],
                      selected: {selectedPlayerCount},
                      onSelectionChanged: (Set<int> newSelection) {
                        setState(() {
                          selectedPlayerCount = newSelection.first;
                          
                          // If player count increased, add new players
                          if (selectedPlayerCount > players.length) {
                            for (int i = players.length; i < selectedPlayerCount; i++) {
                              players.add(Player(id: i, name: 'Player ${i + 1}', score: 0));
                            }
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Player list
            Expanded(
              child: ListView.builder(
                itemCount: selectedPlayerCount,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8.0),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.primaries[index % Colors.primaries.length],
                        child: Text('${index + 1}'),
                      ),
                      title: Text(players[index].name),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          _editPlayerName(index);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Bottom buttons
            Row(
              children: [
                if (!_isNewGroup) 
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                      ),
                      onPressed: () {
                        _deleteGroup();
                      },
                      child: const Text('Delete Group'),
                    ),
                  ),
                if (!_isNewGroup) const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      _startGame();
                    },
                    child: const Text('Start Game', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  // Edit player name
  Future<void> _editPlayerName(int index) async {
    final TextEditingController controller = TextEditingController(text: players[index].name);
    
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Player ${index + 1}'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Player Name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                players[index] = players[index].copyWith(name: controller.text);
              });
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
  // Delete player group
  Future<void> _deleteGroup() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this player group? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      // In production, should delete from database or SharedPreferences
      debugPrint('Deleting player group: ${widget.groupId}');
      // TODO: Implement delete logic
      
      Navigator.pop(context);
    }
  }
}