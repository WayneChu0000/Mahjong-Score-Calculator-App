import 'package:flutter/material.dart';
import '../models/achievement.dart';
import '../services/achievement_service.dart';
import '../utils/achievement_registry.dart';
import '../localization/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';

/// Screen that displays achievement progress for a player within a group.
class AchievementScreen extends StatefulWidget {
  final String groupName;
  final String playerName;

  const AchievementScreen({
    super.key,
    required this.groupName,
    required this.playerName,
  });

  @override
  State<AchievementScreen> createState() => _AchievementScreenState();
}

class _AchievementScreenState extends State<AchievementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, AchievementProgress> _progress = {};
  bool _isLoading = true;

  static const _categories = [
    null, // All
    AchievementCategory.general,
    AchievementCategory.hk,
    AchievementCategory.tw,
    AchievementCategory.milestone,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final data = await AchievementService.loadAll(
      widget.groupName,
      widget.playerName,
    );
    if (mounted) {
      setState(() {
        _progress = data.progress;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final unlockedCount = _progress.values.where((p) => p.isUnlocked).length;
    final totalCount = AchievementRegistry.totalCount;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.achvTitle),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(text: AppLocalizations.achvTabAll),
            Tab(text: AppLocalizations.achvTabGeneral),
            Tab(text: AppLocalizations.achvTabHk),
            Tab(text: AppLocalizations.achvTabTw),
            Tab(text: AppLocalizations.achvTabMilestone),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Summary header
                Padding(
                  padding: AppDimens.paddingAllMd,
                  child: Row(
                    children: [
                      const Icon(Icons.emoji_events, color: Colors.amber),
                      const SizedBox(width: 8),
                      Text(
                        AppLocalizations.achvSummary(
                          unlockedCount.toString(),
                          totalCount.toString(),
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        widget.playerName,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                    ],
                  ),
                ),
                // Progress bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: totalCount > 0 ? unlockedCount / totalCount : 0,
                      minHeight: 8,
                      backgroundColor: AppColors.grey300,
                      color: Colors.amber,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Tab content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: _categories.map((cat) {
                      final defs = cat == null
                          ? AchievementRegistry.all
                          : AchievementRegistry.byCategory(cat);
                      return _buildAchievementList(defs);
                    }).toList(),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildAchievementList(List<AchievementDef> definitions) {
    // Sort: unlocked first, then by tier descending
    final sorted = List<AchievementDef>.from(definitions)
      ..sort((a, b) {
        final aUnlocked = _progress[a.id]?.isUnlocked == true;
        final bUnlocked = _progress[b.id]?.isUnlocked == true;
        if (aUnlocked != bUnlocked) return aUnlocked ? -1 : 1;
        return b.tier.index.compareTo(a.tier.index);
      });

    return ListView.builder(
      padding: AppDimens.paddingAllSm,
      itemCount: sorted.length,
      itemBuilder: (context, index) {
        final def = sorted[index];
        final prog = _progress[def.id];
        return _AchievementCard(def: def, progress: prog);
      },
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final AchievementDef def;
  final AchievementProgress? progress;

  const _AchievementCard({required this.def, this.progress});

  @override
  Widget build(BuildContext context) {
    final isUnlocked = progress?.isUnlocked == true;
    final currentValue = progress?.progress ?? 0;
    final fraction = def.target > 0
        ? (currentValue / def.target).clamp(0.0, 1.0)
        : 0.0;
    final tierColor = AchievementRegistry.tierColor(def.tier);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: isUnlocked ? 2 : 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isUnlocked
            ? BorderSide(color: tierColor, width: 1.5)
            : BorderSide.none,
      ),
      child: Opacity(
        opacity: isUnlocked ? 1.0 : 0.6,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? tierColor.withValues(alpha: 0.15)
                      : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  IconData(def.iconCodePoint, fontFamily: 'MaterialIcons'),
                  color: isUnlocked ? tierColor : Colors.grey,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            AppLocalizations.getString(def.titleKey),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: isUnlocked ? null : Colors.grey,
                            ),
                          ),
                        ),
                        _TierBadge(tier: def.tier, isUnlocked: isUnlocked),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.getString(def.descriptionKey),
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Progress bar
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: fraction,
                              minHeight: 6,
                              backgroundColor: Colors.grey.withValues(
                                alpha: 0.2,
                              ),
                              color: isUnlocked ? tierColor : Colors.grey,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.achvProgress(
                            currentValue.toString(),
                            def.target.toString(),
                          ),
                          style: const TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                    if (isUnlocked && progress?.unlockedAt != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          AppLocalizations.achvUnlockedAt(
                            _formatDate(progress!.unlockedAt!),
                          ),
                          style: TextStyle(fontSize: 11, color: tierColor),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}';
  }
}

class _TierBadge extends StatelessWidget {
  final AchievementTier tier;
  final bool isUnlocked;

  const _TierBadge({required this.tier, required this.isUnlocked});

  @override
  Widget build(BuildContext context) {
    final color = isUnlocked
        ? AchievementRegistry.tierColor(tier)
        : Colors.grey;
    final label = AchievementRegistry.tierKey(tier);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color, width: 0.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
