import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/player_group.dart';
import '../services/player_group_service.dart';
import 'score_recording_screen.dart';

class PlayerSetupScreen extends StatefulWidget {
  final List<Player>? existingPlayers;
  final String? groupName;
  final String? groupId;
  final bool directStart;
  final int? currentRound;
  final int? dealerIndex;
  final int? prevalentWindIndex;
  final int? currentDealerGameCount;
  final int? totalWindRounds;

  const PlayerSetupScreen({
    super.key, 
    this.existingPlayers,
    this.groupName,
    this.groupId,
    this.directStart = false,
    this.currentRound,
    this.dealerIndex,
    this.prevalentWindIndex,
    this.currentDealerGameCount,
    this.totalWindRounds,
  });

  @override
  State<PlayerSetupScreen> createState() => _PlayerSetupScreenState();
}

class _PlayerSetupScreenState extends State<PlayerSetupScreen> {
  int selectedPlayerCount = 4;
  List<Player> players = [];
  late TextEditingController _groupNameController;
  bool _isNewGroup = true;
  bool _hasSavedGroup = false;
  int _selectedDealerIndex = 0;

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
    
    // Initialize dealer index
    _selectedDealerIndex = widget.dealerIndex ?? 0;
    if (_selectedDealerIndex >= selectedPlayerCount) {
      _selectedDealerIndex = 0;
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
  
  Future<void> _startGame() async {
    // Save player group
    await _savePlayerGroup();
    
    if (!mounted) return;

    // Only keep selected number of players
    final selectedPlayers = players.take(selectedPlayerCount).toList();
    
    final String groupName = _groupNameController.text.trim().isEmpty
        ? 'Group ${DateTime.now().toString().substring(0, 16)}'
        : _groupNameController.text.trim();

    // Check if dealer changed
    bool dealerChanged = false;
    if (!_isNewGroup && widget.dealerIndex != null && widget.dealerIndex != _selectedDealerIndex) {
        dealerChanged = true;
    }

    // Navigate to score recording screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScoreRecordingScreen(
          players: selectedPlayers,
          currentRound: widget.currentRound ?? 1,
          totalRounds: 0, // 0 means unlimited rounds
          onScoreSubmitted: (Map<String, int> scoreChanges) {
            // Can save game records here
            debugPrint('Round ended, score changes: $scoreChanges');
            
            // Note: No extra handling needed here as ScoreRecordingScreen handles round progression
          },
          groupId: widget.groupId,
          groupName: groupName,
          initialDealerIndex: _selectedDealerIndex,
          initialPrevalentWindIndex: dealerChanged ? 0 : widget.prevalentWindIndex,
          initialDealerGameCount: dealerChanged ? 1 : widget.currentDealerGameCount,
          initialTotalWindRounds: dealerChanged ? 1 : widget.totalWindRounds,
        ),
      ),
    );
  }
  
  Future<void> _savePlayerGroup() async {
    final String groupName = _groupNameController.text.trim().isEmpty
        ? 'Group ${DateTime.now().toString().substring(0, 16)}'
        : _groupNameController.text.trim();

    final List<String> playerNames = players
        .take(selectedPlayerCount)
        .map((p) => p.name)
        .toList();

    PlayerGroup? existingGroup;
    // Try to load existing group if we are editing
    if (!_isNewGroup && widget.groupName != null) {
       existingGroup = await PlayerGroupService.loadGroup(widget.groupName!);
    }

    // Handle renaming: if name changed, delete old group
    if (!_isNewGroup && widget.groupName != null && widget.groupName != groupName) {
      await PlayerGroupService.deleteGroup(widget.groupName!);
    }

    PlayerGroup newGroup;
    if (existingGroup != null) {
        // Preserve state, but update names
        // Use current players' scores which are initialized from existingPlayers
        Map<String, int> newScores = {};
        for (var player in players.take(selectedPlayerCount)) {
            newScores[player.name] = player.score;
        }

        // Check if dealer changed
        bool dealerChanged = existingGroup.dealerIndex != _selectedDealerIndex;

        newGroup = existingGroup.copyWith(
            name: groupName,
            players: playerNames,
            currentScores: newScores,
            dealerIndex: _selectedDealerIndex,
            prevalentWindIndex: dealerChanged ? 0 : existingGroup.prevalentWindIndex,
            currentDealerGameCount: dealerChanged ? 1 : existingGroup.currentDealerGameCount,
            totalWindRounds: dealerChanged ? 1 : existingGroup.totalWindRounds,
        );
    } else {
        newGroup = PlayerGroup(
          name: groupName,
          players: playerNames,
          createdAt: DateTime.now(),
          lastPlayedAt: DateTime.now(),
          dealerIndex: _selectedDealerIndex,
          prevalentWindIndex: 0,
          currentDealerGameCount: 1,
          totalWindRounds: 1,
          currentRound: 1,
          currentScores: {for (var name in playerNames) name: 0},
        );
    }

    await PlayerGroupService.saveGroup(newGroup);
    debugPrint('Saved player group: $groupName');
    setState(() {
      _hasSavedGroup = true;
    });
  }

  Future<void> _saveAndExit() async {
    await _savePlayerGroup();
    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _hasSavedGroup);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.existingPlayers != null ? 'Edit Players' : 'Setup Players'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, _hasSavedGroup),
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
            
            const SizedBox(height: 16),

            // Dealer Selection
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(
                labelText: 'Initial Dealer',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              value: _selectedDealerIndex,
              items: List.generate(selectedPlayerCount, (index) {
                return DropdownMenuItem<int>(
                  value: index,
                  child: Text(players[index].name),
                );
              }),
              onChanged: (int? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedDealerIndex = newValue;
                  });
                }
              },
            ),

            const SizedBox(height: 16),
            
            // Bottom buttons
            Row(
              children: [
                if (!_isNewGroup) ...[
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        foregroundColor: Colors.red,
                      ),
                      onPressed: _deleteGroup,
                      child: const Text('Delete'),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                    ),
                    onPressed: _saveAndExit,
                    child: const Text('Save'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _startGame,
                    child: const Text('Start'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ));
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
    
    if (confirmed == true && widget.groupName != null) {
      await PlayerGroupService.deleteGroup(widget.groupName!);
      setState(() {
        _hasSavedGroup = true;
      });
      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }
}