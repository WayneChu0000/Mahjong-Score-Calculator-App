import 'package:flutter/material.dart';
import '../widgets/score_display.dart';
import '../widgets/base_screen.dart';
import '../models/player.dart';
import '../models/player_group.dart';
import '../services/player_group_service.dart';
import 'player_setup.dart';
import 'score_recording_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  List<PlayerGroup> _playerGroups = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.easeOut))
    );
    
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.2, 1.0, curve: Curves.easeOut))
    );
    
    _controller.forward();
    
    // Load player groups data
    _loadPlayerGroups();
  }
  
  Future<void> _loadPlayerGroups() async {
    try {
      final groups = await PlayerGroupService.getSavedGroups();
      if (mounted) {
        setState(() {
          _playerGroups = groups;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Failed to load player groups: $e');
      if (mounted) {
        setState(() {
          _playerGroups = [];
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'Mahjong Calculator',
      currentIndex: 0,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Fixed header content
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Welcome card
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Card(
                            elevation: 4,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  const Text(
                                    'Welcome Back!',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ScoreDisplay(gamesPlayed: _playerGroups.length),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Main action buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.add, size: 20),
                              label: const Text('New Group'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const PlayerSetupScreen(),
                                  ),
                                );
                                
                                // Reload list if new group was created
                                if (result == true) {
                                  _loadPlayerGroups();
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.history, size: 20),
                              label: const Text('History'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              onPressed: () {
                                // TODO: Implement history page
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('History feature coming soon...')),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Saved groups header
                      if (_playerGroups.isNotEmpty) ...[
                        Row(
                          children: [
                            const Text(
                              'Saved Player Groups',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: _showAllPlayerGroups,
                              child: const Text('View All'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                    ],
                  ),
                ),
              
                // Scrollable player groups list
                Expanded(
                  child: _playerGroups.isNotEmpty
                      ? RefreshIndicator(
                          onRefresh: _loadPlayerGroups,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _playerGroups.length,
                            itemBuilder: (context, index) {
                              final group = _playerGroups[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: InkWell(
                                  onTap: () => _startGameWithGroup(group),
                                  borderRadius: BorderRadius.circular(8),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                group.name,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              '${group.players.length} players',
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Wrap(
                                          spacing: 6,
                                          runSpacing: 4,
                                          children: group.players.map((player) {
                                            return Chip(
                                              label: Text(
                                                player,
                                                style: const TextStyle(fontSize: 11),
                                              ),
                                              backgroundColor: Colors.green.shade50,
                                              padding: const EdgeInsets.symmetric(horizontal: 4),
                                              visualDensity: VisualDensity.compact,
                                            );
                                          }).toList(),
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Created: ${_formatDateTime(group.createdAt)}',
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 11,
                                              ),
                                            ),
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                TextButton.icon(
                                                  icon: const Icon(Icons.edit, size: 14),
                                                  label: const Text('Edit', style: TextStyle(fontSize: 12)),
                                                  style: TextButton.styleFrom(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                    minimumSize: const Size(60, 32),
                                                  ),
                                                  onPressed: () => _editPlayerGroup(group),
                                                ),
                                                const SizedBox(width: 4),
                                                TextButton.icon(
                                                  icon: const Icon(Icons.play_arrow, size: 14),
                                                  label: const Text('Start', style: TextStyle(fontSize: 12)),
                                                  style: TextButton.styleFrom(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                    minimumSize: const Size(60, 32),
                                                  ),
                                                  onPressed: () => _startGameWithGroup(group),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      : Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.group_add,
                                  size: 64,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'No Saved Player Groups',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Create your first group to get started',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.add),
                                  label: const Text('Create Player Group'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  ),
                                  onPressed: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const PlayerSetupScreen(),
                                      ),
                                    );
                                    
                                    if (result == true) {
                                      _loadPlayerGroups();
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              ],
            ),
    );
  }
  
  // Format date and time
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.day.toString().padLeft(2, '0')} '
           '${dateTime.hour.toString().padLeft(2, '0')}:'
           '${dateTime.minute.toString().padLeft(2, '0')}';
  }
  
  // Show all player groups
  void _showAllPlayerGroups() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'All Player Groups',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _playerGroups.length,
                  itemBuilder: (context, index) {
                    final group = _playerGroups[index];
                    return Card(
                      child: ListTile(
                        title: Text(group.name),
                        subtitle: Text(
                          '${group.players.length} players\nCreated: ${_formatDateTime(group.createdAt)}',
                        ),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              tooltip: 'Edit',
                              onPressed: () {
                                Navigator.pop(context);
                                _editPlayerGroup(group);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.play_arrow),
                              tooltip: 'Start',
                              onPressed: () {
                                Navigator.pop(context);
                                _startGameWithGroup(group);
                              },
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          _startGameWithGroup(group);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  // Edit player group
  void _editPlayerGroup(PlayerGroup group) {
    // TODO: Implement edit functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit group "${group.name}" - Coming soon...')),
    );
  }
  
  // Start game with selected player group
  void _startGameWithGroup(PlayerGroup group) async {
    // Update last played time
    final updatedGroup = group.copyWith(
      lastPlayedAt: DateTime.now(),
    );
    
    await PlayerGroupService.saveGroup(updatedGroup);
    
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ScoreRecordingScreen(
            players: group.players.map((playerName) => 
              Player(id: group.players.indexOf(playerName), name: playerName, score: 0)
            ).toList(),
            currentRound: 1,
            totalRounds: 16, // Standard mahjong rounds
            onScoreSubmitted: (Map<String, int> scoreChanges) {
              debugPrint('Score updated for group "${group.name}"');
            },
            groupName: group.name,
          ),
        ),
      ).then((_) {
        // Reload groups list after game ends
        _loadPlayerGroups();
      });
    }
  }
}
