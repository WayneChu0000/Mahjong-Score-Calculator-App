import 'package:flutter/material.dart';
import '../services/player_group_service.dart';
import '../models/player_group.dart';
import '../models/player.dart';
import 'score_recording_screen.dart';
import 'score_calculation_screen.dart';
import 'player_setup.dart';

class SavedGroupsScreen extends StatefulWidget {
  const SavedGroupsScreen({super.key});

  @override
  State<SavedGroupsScreen> createState() => _SavedGroupsScreenState();
}

class _SavedGroupsScreenState extends State<SavedGroupsScreen> {
  List<PlayerGroup> _savedGroups = [];
  bool _isLoading = true;
  int _currentPage = 0;
  static const int _itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _loadSavedGroups();
  }

  Future<void> _loadSavedGroups() async {
    setState(() {
      _isLoading = true;
    });

    final groups = await PlayerGroupService.getSavedGroups();
    // Sort by last played time (descending)
    groups.sort((a, b) {
      final aTime = a.lastPlayedAt ?? a.createdAt;
      final bTime = b.lastPlayedAt ?? b.createdAt;
      return bTime.compareTo(aTime);
    });
    
    setState(() {
      _savedGroups = groups;
      _isLoading = false;
      _currentPage = 0; // Reset to first page on reload
    });
  }

  Future<void> _deleteGroup(String groupName) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete group "$groupName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await PlayerGroupService.deleteGroup(groupName);
      
      if (success) {
        _loadSavedGroups(); // Reload list
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Group "$groupName" deleted'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    }
  }

  // Edit player group
  void _editPlayerGroup(PlayerGroup group) {
    // Map players with their current scores
    final List<Player> playersWithScores = group.players.asMap().entries.map((entry) {
      int score = 0;
      if (group.currentScores != null && group.currentScores!.containsKey(entry.value)) {
        score = group.currentScores![entry.value]!;
      }
      return Player(id: entry.key, name: entry.value, score: score);
    }).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlayerSetupScreen(
          existingPlayers: playersWithScores,
          groupName: group.name,
          groupId: group.name, // Use name as ID for now
          currentRound: group.currentRound,
          dealerIndex: group.dealerIndex,
          prevalentWindIndex: group.prevalentWindIndex,
          currentDealerGameCount: group.currentDealerGameCount,
          totalWindRounds: group.totalWindRounds,
        ),
      ),
    ).then((hasSaved) {
      if (hasSaved == true) {
        _loadSavedGroups();
      }
    });
  }

  void _startGameWithGroup(PlayerGroup group) {
    // Update player group's last played time
    final updatedGroup = group.copyWith(
      lastPlayedAt: DateTime.now(),
    );
    
    // Save updated group
    PlayerGroupService.saveGroup(updatedGroup);
    
    // Convert List<String> to List<Player>
    final List<Player> players = group.players.asMap().entries.map((entry) {
      // Load saved score if available
      int score = 0;
      if (group.currentScores != null && group.currentScores!.containsKey(entry.value)) {
        score = group.currentScores![entry.value]!;
      }
      
      return Player(
        id: entry.key,
        name: entry.value,
        score: score,
      );
    }).toList();

    // Load saved round if available
    final int currentRound = group.currentRound ?? 1;
    final int? dealerIndex = group.dealerIndex;
    final int? prevalentWindIndex = group.prevalentWindIndex;
    final int? currentDealerGameCount = group.currentDealerGameCount;
    final int? totalWindRounds = group.totalWindRounds;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScoreRecordingScreen(
          players: players,
          currentRound: currentRound,
          totalRounds: 0, // 0 means unlimited rounds
          onScoreSubmitted: (Map<String, int> scoreChanges) {
            debugPrint('Round ended, score changes: $scoreChanges');
          },
          groupName: group.name,
          initialDealerIndex: dealerIndex,
          initialPrevalentWindIndex: prevalentWindIndex,
          initialDealerGameCount: currentDealerGameCount,
          initialTotalWindRounds: totalWindRounds,
        ),
      ),
    ).then((_) {
      // When returning from game screen, reload group list to update last played time
      _loadSavedGroups();
    });
  }

  @override
  Widget build(BuildContext context) {
    final int totalPages = (_savedGroups.length / _itemsPerPage).ceil();
    final int startIndex = _currentPage * _itemsPerPage;
    final int endIndex = (_currentPage + 1) * _itemsPerPage;
    final List<PlayerGroup> currentGroups = _savedGroups.isEmpty 
        ? [] 
        : _savedGroups.sublist(startIndex, endIndex > _savedGroups.length ? _savedGroups.length : endIndex);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Player Groups'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _savedGroups.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.group_off, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No saved player groups',
                          style: TextStyle(fontSize: 17, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: _loadSavedGroups,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(8),
                            itemCount: currentGroups.length,
                            itemBuilder: (context, index) {
                              final group = currentGroups[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.red.withOpacity(0.2)
                                        : Colors.red.shade100,
                                    child: Text(
                                      group.players.length.toString(),
                                      style: TextStyle(
                                        color: Theme.of(context).brightness == Brightness.dark
                                            ? Colors.red.shade200
                                            : Colors.red.shade700,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    group.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('Players: ${group.players.join(', ')}'),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Created: ${_formatDateTime(group.createdAt)}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context).brightness == Brightness.dark
                                              ? Colors.grey.shade400
                                              : Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: PopupMenuButton(
                                    itemBuilder: (context) => const [
                                      PopupMenuItem(
                                        value: 'play',
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.play_arrow, color: Colors.green),
                                            SizedBox(width: 8),
                                            Text('Start Game'),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'edit',
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.edit, color: Colors.blue),
                                            SizedBox(width: 8),
                                            Text('Edit Group'),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.delete, color: Colors.red),
                                            SizedBox(width: 8),
                                            Text('Delete Group'),
                                          ],
                                        ),
                                      ),
                                    ],
                                    onSelected: (value) {
                                      if (value == 'play') {
                                        _startGameWithGroup(group);
                                      } else if (value == 'edit') {
                                        _editPlayerGroup(group);
                                      } else if (value == 'delete') {
                                        _deleteGroup(group.name);
                                      }
                                    },
                                  ),
                                  onTap: () => _startGameWithGroup(group),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      if (totalPages > 1)
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, -2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                onPressed: _currentPage > 0
                                    ? () {
                                        setState(() {
                                          _currentPage--;
                                        });
                                      }
                                    : null,
                                icon: const Icon(Icons.chevron_left),
                              ),
                              Text(
                                'Page ${_currentPage + 1} of $totalPages',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                onPressed: _currentPage < totalPages - 1
                                    ? () {
                                        setState(() {
                                          _currentPage++;
                                        });
                                      }
                                    : null,
                                icon: const Icon(Icons.chevron_right),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final localTime = dateTime.toLocal();
    return '${localTime.year}/${localTime.month.toString().padLeft(2, '0')}/${localTime.day.toString().padLeft(2, '0')} '
           '${localTime.hour.toString().padLeft(2, '0')}:'
           '${localTime.minute.toString().padLeft(2, '0')}';
  }
}