import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/player_group.dart';
import '../models/game_mode.dart'; // Import GameMode
import '../services/player_group_service.dart';
import '../localization/app_localizations.dart';
import '../routes/app_routes.dart';
import 'group_detail_screen.dart'; // Import for DealerSelectionDialog
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';

class PlayerSetupScreen extends StatefulWidget {
  final List<Player>? existingPlayers;
// ... (rest of imports)
  final String? groupName;
  final String? groupId;
  final bool directStart;
  final int? currentRound;
  final int? dealerIndex;
  final int? prevalentWindIndex;
  final int? currentDealerGameCount;
  final int? totalWindRounds;
  final GameMode? initialGameMode;

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
    this.initialGameMode,
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
  int _minFan = 3;
  int _maxFan = 13;
  GameMode _selectedGameMode = GameMode.hongKong;

  @override
  void initState() {
    super.initState();
    
    _selectedGameMode = widget.initialGameMode ?? GameMode.hongKong;

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
      (index) => Player(id: index, name: AppLocalizations.defaultPlayerName(index + 1), score: 0),
    );
  }
  
  Future<void> _startGame() async {
    // Show dealer selection dialog first
    if (!mounted) return;
    
    // Only keep selected number of players
    final selectedPlayers = players.take(selectedPlayerCount).toList();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => DealerSelectionDialog(
        players: selectedPlayers.map((p) => p.name).toList(),
        gameMode: _selectedGameMode,
        initialMinFan: _selectedGameMode == GameMode.taiwan ? 10 : _minFan,
        initialMaxFan: _selectedGameMode == GameMode.taiwan ? 5 : _maxFan,
        onDealerSelected: (dealerIndex, minFan, maxFan) {
          Navigator.pop(context);
          _proceedToGame(dealerIndex, minFan, maxFan);
        },
      ),
    );
  }

  Future<void> _proceedToGame(int dealerIndex, int minFan, int maxFan) async {
    setState(() {
      _selectedDealerIndex = dealerIndex;
      _minFan = minFan;
      _maxFan = maxFan;
    });

    // Save player group with the selected dealer and increment game count
    await _savePlayerGroup(incrementGameCount: true);
    
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
    Navigator.pushNamed(
      context,
      AppRoutes.scoreRecording,
      arguments: ScoreRecordingArgs(
        players: selectedPlayers,
        currentRound: widget.currentRound ?? 1,
        totalRounds: 0, // 0 means unlimited rounds
        onScoreSubmitted: (Map<String, int> scoreChanges) {
           // Handle score submission
        },
        groupId: widget.groupId,
        groupName: groupName,
        initialDealerIndex: _selectedDealerIndex,
        initialPrevalentWindIndex: dealerChanged ? 0 : widget.prevalentWindIndex,
        initialDealerGameCount: dealerChanged ? 1 : widget.currentDealerGameCount,
        initialTotalWindRounds: dealerChanged ? 1 : widget.totalWindRounds,
        minFan: _minFan,
        maxFan: _maxFan,
        gameMode: _selectedGameMode,
      ),
    );
  }
  
  Future<void> _savePlayerGroup({bool incrementGameCount = false}) async {
    final String groupName = _groupNameController.text.trim().isEmpty
        ? AppLocalizations.defaultGroupName(DateTime.now().toString().substring(0, 16))
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
        int currentGamesPlayed = existingGroup.totalGamesPlayedInGroup;
        if (incrementGameCount) {
          currentGamesPlayed += 1;
        }

        newGroup = existingGroup.copyWith(
            name: groupName,
            players: playerNames,
            currentScores: newScores,
            dealerIndex: _selectedDealerIndex,
            prevalentWindIndex: dealerChanged ? 0 : existingGroup.prevalentWindIndex,
            currentDealerGameCount: dealerChanged ? 1 : existingGroup.currentDealerGameCount,
            totalGamesPlayedInGroup: currentGamesPlayed,
            minFan: _minFan,
            maxFan: _maxFan,
            gameMode: _selectedGameMode,
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
          totalGamesPlayedInGroup: incrementGameCount ? 1 : 0,
          minFan: _minFan,
          maxFan: _maxFan,
          gameMode: _selectedGameMode,
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pop(context, _hasSavedGroup);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.existingPlayers != null ? AppLocalizations.editPlayers : AppLocalizations.setupPlayers),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, _hasSavedGroup),
          ),
        ),
        body: Padding(
        padding: AppDimens.paddingAllLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Group name input
            TextField(
              controller: _groupNameController,
              decoration: InputDecoration(
                labelText: AppLocalizations.groupName,
                border: const OutlineInputBorder(),
                hintText: AppLocalizations.enterGroupNameHint,
              ),
            ),
            
            const SizedBox(height: 20),

            // Game Mode Selector
                DropdownButtonFormField<GameMode>(
                  value: _selectedGameMode,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.gameMode,
                    border: const OutlineInputBorder(),
                  ),
                  items: GameMode.values.map((mode) {
                    return DropdownMenuItem(
                      value: mode,
                      child: Text(mode == GameMode.hongKong ? AppLocalizations.hongKongMahjong : AppLocalizations.taiwaneseMahjong),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      if (value != null) {
                         _selectedGameMode = value;
                         // Set defaults
                         if (_selectedGameMode == GameMode.taiwan) {
                             _minFan = 10;
                             _maxFan = 5;
                         } else {
                             _minFan = 3;
                             _maxFan = 13;
                         }
                      }
                    });
                  },
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

            // Bottom buttons
            Row(
              children: [
                if (!_isNewGroup) ...[
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: AppDimens.paddingVerticalMd,
                        foregroundColor: AppColors.destructive,
                      ),
                      onPressed: _deleteGroup,
                      child: Text(AppLocalizations.delete),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: AppDimens.paddingVerticalMd,
                    ),
                    onPressed: _saveAndExit,
                    child: Text(AppLocalizations.save),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: AppDimens.paddingVerticalMd,
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                    ),
                    onPressed: _startGame,
                    child: Text(AppLocalizations.start),
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
        title: Text(AppLocalizations.editPlayerTitle(index + 1)),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: AppLocalizations.playerName,
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.cancel),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                players[index] = players[index].copyWith(name: controller.text);
              });
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.ok),
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
        title: Text(AppLocalizations.confirmDelete),
        content: Text(AppLocalizations.deleteGroupWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalizations.delete, style: const TextStyle(color: AppColors.destructive)),
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