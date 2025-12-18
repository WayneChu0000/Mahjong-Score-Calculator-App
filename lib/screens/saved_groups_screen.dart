import 'package:flutter/material.dart';
import '../services/player_group_service.dart';
import '../models/player_group.dart';
import 'score_calculation_screen.dart';

class SavedGroupsScreen extends StatefulWidget {
  const SavedGroupsScreen({super.key});

  @override
  State<SavedGroupsScreen> createState() => _SavedGroupsScreenState();
}

class _SavedGroupsScreenState extends State<SavedGroupsScreen> {
  List<PlayerGroup> _savedGroups = [];
  bool _isLoading = true;

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
    
    setState(() {
      _savedGroups = groups;
      _isLoading = false;
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

  void _startGameWithGroup(PlayerGroup group) {
    // Update player group's last played time
    final updatedGroup = group.copyWith(
      lastPlayedAt: DateTime.now(),
    );
    
    // Save updated group
    PlayerGroupService.saveGroup(updatedGroup);
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScoreCalculationScreen(
          players: group.players,
          groupName: group.name, // If ScoreCalculationScreen supports group name
        ),
      ),
    ).then((_) {
      // When returning from game screen, reload group list to update last played time
      _loadSavedGroups();
    });
  }

  @override
  Widget build(BuildContext context) {
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
                : RefreshIndicator(
                    onRefresh: _loadSavedGroups,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: _savedGroups.length,
                      itemBuilder: (context, index) {
                        final group = _savedGroups[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.red.shade100,
                              child: Text(
                                group.players.length.toString(),
                                style: TextStyle(
                                  color: Colors.red.shade700,
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
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
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
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}/${dateTime.month}/${dateTime.day} '
           '${dateTime.hour.toString().padLeft(2, '0')}:'
           '${dateTime.minute.toString().padLeft(2, '0')}';
  }
}