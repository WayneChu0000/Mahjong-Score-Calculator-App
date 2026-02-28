import 'package:flutter/material.dart';
import '../widgets/base_screen.dart';
import '../models/player.dart';
import '../models/player_group.dart';
import '../models/game_mode.dart';
import '../services/player_group_service.dart';
import '../routes/app_routes.dart';
import '../localization/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_dimens.dart';
import '../utils/daily_tips.dart';

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
      // Sort by most played (totalGamesPlayedInGroup descending),
      // then by last played time as tiebreaker.
      groups.sort((a, b) {
        final cmp = b.totalGamesPlayedInGroup.compareTo(a.totalGamesPlayedInGroup);
        if (cmp != 0) return cmp;
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lastGroup = _findLastPlayedGroup();

    return BaseScreen(
      title: AppLocalizations.homeTitle,
      currentIndex: 0,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadPlayerGroups,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // ── Hero Banner ──────────────────────────────────
                  _buildHeroBanner(isDark, lastGroup),

                  const SizedBox(height: 16),

                  // ── Quick Start Shortcuts ────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildQuickStartRow(),
                  ),

                  const SizedBox(height: 16),

                  // ── Daily Tip ────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildDailyTipCard(isDark),
                  ),

                  const SizedBox(height: 20),

                  // ── Most Played Groups header ────────────────────
                  if (_playerGroups.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Text(
                            AppLocalizations.mostPlayedGroups,
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
                    ),
                    const SizedBox(height: 8),
                  ],

                  // ── Group list (or empty state) ──────────────────
                  if (_playerGroups.isNotEmpty)
                    ...List.generate(_playerGroups.length, (index) {
                      final group = _playerGroups[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Card(
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
                              ),
                        );
                      })
                  else
                    Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
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

                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  // ── Helper: find the most recently played group ────────────────────
  PlayerGroup? _findLastPlayedGroup() {
    if (_playerGroups.isEmpty) return null;
    PlayerGroup? best;
    for (final g in _playerGroups) {
      final t = g.lastPlayedAt ?? g.createdAt;
      if (best == null || t.isAfter(best.lastPlayedAt ?? best.createdAt)) {
        best = g;
      }
    }
    return best;
  }

  // ── Hero Banner ────────────────────────────────────────────────────
  Widget _buildHeroBanner(bool isDark, PlayerGroup? lastGroup) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [const Color(0xFF1B5E20), const Color(0xFF004D40)]
                  : [Colors.green.shade700, Colors.teal.shade600],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting
                Text(
                  AppLocalizations.welcomeBack,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _buildGreetingSubtitle(),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),

                // Continue previous game button
                if (lastGroup != null) ...[
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.play_arrow_rounded, size: 22),
                      label: Text(
                        '${AppLocalizations.continueLastGame}  —  ${lastGroup.name}',
                        overflow: TextOverflow.ellipsis,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.green.shade800,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () => _startGameWithGroup(lastGroup),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _buildGreetingSubtitle() {
    final hour = DateTime.now().hour;
    if (hour < 12) return AppLocalizations.greetingMorning;
    if (hour < 18) return AppLocalizations.greetingAfternoon;
    return AppLocalizations.greetingEvening;
  }

  // ── Quick Start Shortcuts ──────────────────────────────────────────
  Widget _buildQuickStartRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.quickStart, style: AppTextStyles.heading4),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _quickStartButton(
                icon: Icons.grid_view_rounded,
                label: AppLocalizations.hkQuickStart,
                color: Colors.green,
                onTap: () => _startQuickGame(GameMode.hongKong),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _quickStartButton(
                icon: Icons.grid_view_rounded,
                label: AppLocalizations.twQuickStart,
                color: Colors.orange,
                onTap: () => _startQuickGame(GameMode.taiwan),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _quickStartButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startQuickGame(GameMode mode) async {
    final result = await Navigator.pushNamed(
      context,
      AppRoutes.playerSetup,
      arguments: PlayerSetupArgs(initialGameMode: mode),
    );
    if (result == true) {
      _loadPlayerGroups();
    }
  }

  // ── Daily Tip Card ─────────────────────────────────────────────────
  Widget _buildDailyTipCard(bool isDark) {
    final tip = getTodayTip();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.amber.withValues(alpha: 0.12)
            : Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.amber.withValues(alpha: 0.3)
              : Colors.amber.shade200,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline, color: Colors.amber.shade700, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${AppLocalizations.dailyTipLabel}  ${tip.title()}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.amber.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tip.content(),
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white70 : Colors.grey.shade700,
                  ),
                ),
              ],
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
        initialGameMode: group.gameMode,
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
