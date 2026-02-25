import 'package:flutter/material.dart';
import '../widgets/score_display.dart';
import '../widgets/base_screen.dart';
import '../models/player.dart';
import '../models/player_group.dart';
import '../services/player_group_service.dart';
import '../routes/app_routes.dart';
import '../localization/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_dimens.dart';

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
      // Sort by last played time (descending)
      groups.sort((a, b) {
        final aTime = a.lastPlayedAt ?? a.createdAt;
        final bTime = b.lastPlayedAt ?? b.createdAt;
        return bTime.compareTo(aTime);
      });
      
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
      title: AppLocalizations.homeTitle,
      currentIndex: 0,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Fixed header content
                Container(
                  padding: AppDimens.paddingAllLg,
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
                              padding: AppDimens.paddingAllLg,
                              child: Column(
                                children: [
                                  Text(
                                    AppLocalizations.welcomeBack,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ScoreDisplay(
                                    gamesPlayed: _playerGroups.fold(0, (sum, group) => sum + ((group.currentRound ?? 1) - 1))
                                  ),
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
                              label: Text(AppLocalizations.newGroup),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              onPressed: () async {
                                final result = await Navigator.pushNamed(
                                  context,
                                  AppRoutes.playerSetup,
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
                              label: Text(AppLocalizations.history),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: AppColors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.savedGroups,
                                ).then((_) => _loadPlayerGroups());
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
                            Text(
                              AppLocalizations.recentGroups,
                              style: AppTextStyles.heading3,
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.savedGroups,
                                ).then((_) => _loadPlayerGroups());
                              },
                              child: Text(AppLocalizations.viewAll),
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
                                  borderRadius: AppDimens.borderRadiusMd,
                                  child: Padding(
                                    padding: AppDimens.paddingAllLg,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                group.name,
                                                style: AppTextStyles.heading3,
                                                overflow: TextOverflow.ellipsis,
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
                                              backgroundColor: AppColors.primaryCardBackground(Theme.of(context).brightness == Brightness.dark),
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
                                              '${AppLocalizations.createdPrefix}${_formatDateTime(group.createdAt)}',
                                              style: TextStyle(
                                                color: AppColors.subtitleColor(Theme.of(context).brightness == Brightness.dark),
                                                fontSize: 11,
                                              ),
                                            ),
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                TextButton.icon(
                                                  icon: const Icon(Icons.edit, size: 14),
                                                  label: Text(AppLocalizations.edit, style: AppTextStyles.footnote),
                                                  style: TextButton.styleFrom(
                                                    padding: AppDimens.paddingHorizontalSm,
                                                    minimumSize: const Size(60, 32),
                                                  ),
                                                  onPressed: () => _editPlayerGroup(group),
                                                ),
                                                TextButton.icon(
                                                  icon: const Icon(Icons.delete, size: 14, color: AppColors.destructive),
                                                  label: Text(AppLocalizations.delete, style: const TextStyle(fontSize: 12, color: AppColors.destructive)),
                                                  style: TextButton.styleFrom(
                                                    padding: AppDimens.paddingHorizontalSm,
                                                    minimumSize: const Size(60, 32),
                                                  ),
                                                  onPressed: () => _deleteGroup(group.name),
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
                                  color: AppColors.grey400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  AppLocalizations.noSavedGroups,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  AppLocalizations.createFirstGroupHint,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.add),
                                  label: Text(AppLocalizations.createGroup),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: AppColors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  ),
                                  onPressed: () async {
                                    final result = await Navigator.pushNamed(
                                      context,
                                      AppRoutes.playerSetup,
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
    final localTime = dateTime.toLocal();
    return '${localTime.year}/${localTime.month.toString().padLeft(2, '0')}/${localTime.day.toString().padLeft(2, '0')} '
           '${localTime.hour.toString().padLeft(2, '0')}:'
           '${localTime.minute.toString().padLeft(2, '0')}';
  }
  
  // Show all player groups
  // ignore: unused_element
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
          padding: AppDimens.paddingAllLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'All Player Groups',
                    style: AppTextStyles.heading2,
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
    // Map players with their current scores
    final List<Player> playersWithScores = group.players.asMap().entries.map((entry) {
      int score = 0;
      if (group.currentScores != null && group.currentScores!.containsKey(entry.value)) {
        score = group.currentScores![entry.value]!;
      }
      return Player(id: entry.key, name: entry.value, score: score);
    }).toList();

    Navigator.pushNamed(
      context,
      AppRoutes.playerSetup,
      arguments: PlayerSetupArgs(
        existingPlayers: playersWithScores,
        groupName: group.name,
        groupId: group.name,
        currentRound: group.currentRound,
        dealerIndex: group.dealerIndex,
        prevalentWindIndex: group.prevalentWindIndex,
        currentDealerGameCount: group.currentDealerGameCount,
        totalWindRounds: group.totalWindRounds,
      ),
    ).then((hasSaved) {
      if (hasSaved == true) {
        _loadPlayerGroups();
      }
    });
  }

  // Delete player group
  Future<void> _deleteGroup(String groupName) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.confirmDeleteTitle),
        content: Text(AppLocalizations.confirmDeleteContent(groupName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(AppLocalizations.delete, style: AppTextStyles.destructive),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await PlayerGroupService.deleteGroup(groupName);
      
      if (success) {
        _loadPlayerGroups(); // Reload list
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.groupDeleted(groupName)),
              backgroundColor: AppColors.primary,
            ),
          );
        }
      }
    }
  }
  
  // Start game with selected player group
  void _startGameWithGroup(PlayerGroup group) {
    Navigator.pushNamed(
      context,
      AppRoutes.groupDetail,
      arguments: GroupDetailArgs(group: group),
    ).then((_) {
      // Reload groups list after returning from detail
      _loadPlayerGroups();
    });
  }
}
