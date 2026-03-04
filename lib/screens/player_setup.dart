import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/player_group.dart';
import '../models/game_mode.dart';
import '../services/player_group_service.dart';
import '../services/settings_service.dart';
import '../localization/app_localizations.dart';
import '../routes/app_routes.dart';
import 'group_detail_screen.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';

/// Wind direction colours for each seat (indices 0-3).
const List<Color> _windColors = [
  Color(0xFF4CAF50), // East  – green
  Color(0xFF2196F3), // South – blue
  Color(0xFFF44336), // West  – red
  Color(0xFFFF9800), // North – amber
];

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
  late int _minFan = SettingsService.instance.hkMinFan;
  late int _maxFan = SettingsService.instance.hkMaxFan;
  GameMode _selectedGameMode = GameMode.hongKong;

  /// Per-player TextField controllers for inline editing.
  final List<TextEditingController> _nameControllers = [];
  final List<FocusNode> _focusNodes = [];

  /// Index of the player card currently being edited (null = none).
  int? _editingIndex;

  /// Cached list of unique player names from all saved groups.
  List<String> _recentPlayerNames = [];

  // ── Wind labels (localized at build time) ──
  List<String> get _windLabels => [
    AppLocalizations.east,
    AppLocalizations.south,
    AppLocalizations.west,
    AppLocalizations.north,
  ];

  // ──────────────────────────────────────────────────────────────────
  // Lifecycle
  // ──────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();

    _selectedGameMode = widget.initialGameMode ?? GameMode.hongKong;

    if (widget.existingPlayers != null) {
      players = List.from(widget.existingPlayers!);
      selectedPlayerCount = players.length;
      _isNewGroup = false;
    } else {
      _initializePlayers();
      _isNewGroup = true;
    }

    _selectedDealerIndex = widget.dealerIndex ?? 0;
    if (_selectedDealerIndex >= selectedPlayerCount) {
      _selectedDealerIndex = 0;
    }

    _groupNameController = TextEditingController(text: widget.groupName ?? '');

    // Build per-player controllers & focus nodes
    for (int i = 0; i < 4; i++) {
      _nameControllers.add(TextEditingController(text: players[i].name));
      _focusNodes.add(FocusNode());
    }

    // Load recent player names in background
    _loadRecentPlayerNames();

    if (widget.directStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _startGame());
    }
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    for (final c in _nameControllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  // ──────────────────────────────────────────────────────────────────
  // Helpers
  // ──────────────────────────────────────────────────────────────────

  void _initializePlayers() {
    players = List.generate(
      4,
      (index) => Player(
        id: index,
        name: AppLocalizations.defaultPlayerName(index + 1),
        score: 0,
      ),
    );
  }

  Future<void> _loadRecentPlayerNames() async {
    final groups = await PlayerGroupService.getSavedGroups();
    final nameSet = <String>{};
    for (final g in groups) {
      nameSet.addAll(g.players);
    }
    // Remove default names & current names
    final currentNames = players.map((p) => p.name).toSet();
    nameSet.removeAll(currentNames);
    // Remove generic default names
    for (int i = 1; i <= 4; i++) {
      nameSet.remove(AppLocalizations.defaultPlayerName(i));
    }
    if (mounted) {
      setState(() {
        _recentPlayerNames = nameSet.toList()..sort();
      });
    }
  }

  /// Returns true if any two selected players share the same name.
  bool get _hasDuplicateNames {
    final names = players
        .take(selectedPlayerCount)
        .map((p) => p.name.trim().toLowerCase())
        .toList();
    return names.toSet().length != names.length;
  }

  /// Check if a specific player index has a duplicate.
  bool _isDuplicate(int index) {
    final name = players[index].name.trim().toLowerCase();
    for (int i = 0; i < selectedPlayerCount; i++) {
      if (i != index && players[i].name.trim().toLowerCase() == name) {
        return true;
      }
    }
    return false;
  }

  void _commitEdit(int index) {
    final text = _nameControllers[index].text.trim();
    if (text.isNotEmpty) {
      setState(() {
        players[index] = players[index].copyWith(name: text);
      });
    } else {
      // Revert to previous name
      _nameControllers[index].text = players[index].name;
    }
    setState(() => _editingIndex = null);
  }

  void _startEditing(int index) {
    // Commit any existing edit first
    if (_editingIndex != null && _editingIndex != index) {
      _commitEdit(_editingIndex!);
    }

    // Defensive initialization for hot-reload
    if (_nameControllers.isEmpty) {
      for (int i = 0; i < selectedPlayerCount; i++) {
        _nameControllers.add(TextEditingController(text: players[i].name));
        _focusNodes.add(FocusNode());
      }
    }

    setState(() => _editingIndex = index);
    _nameControllers[index].text = players[index].name;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[index].requestFocus();
      _nameControllers[index].selection = TextSelection(
        baseOffset: 0,
        extentOffset: _nameControllers[index].text.length,
      );
    });
  }

  void _applyRecentName(String name, int index) {
    setState(() {
      players[index] = players[index].copyWith(name: name);
      _nameControllers[index].text = name;
      _editingIndex = null;
    });
  }

  // ──────────────────────────────────────────────────────────────────
  // Game / Save / Delete logic (unchanged business logic)
  // ──────────────────────────────────────────────────────────────────

  Future<void> _startGame() async {
    if (!mounted) return;
    final selectedPlayers = players.take(selectedPlayerCount).toList();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => DealerSelectionDialog(
        players: selectedPlayers.map((p) => p.name).toList(),
        gameMode: _selectedGameMode,
        initialMinFan: _selectedGameMode == GameMode.taiwan
            ? SettingsService.instance.twBaseTai
            : _minFan,
        initialMaxFan: _selectedGameMode == GameMode.taiwan
            ? SettingsService.instance.twTaiValue
            : _maxFan,
        onDealerSelected: (dealerIndex, minFan, maxFan, gameMode) {
          Navigator.pop(context);
          _selectedGameMode = gameMode;
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

    await _savePlayerGroup(incrementGameCount: true);
    if (!mounted) return;

    final selectedPlayers = players.take(selectedPlayerCount).toList();
    final String groupName = _groupNameController.text.trim().isEmpty
        ? 'Group ${DateTime.now().toString().substring(0, 16)}'
        : _groupNameController.text.trim();

    bool dealerChanged = false;
    if (!_isNewGroup &&
        widget.dealerIndex != null &&
        widget.dealerIndex != _selectedDealerIndex) {
      dealerChanged = true;
    }

    Navigator.pushNamed(
      context,
      AppRoutes.scoreRecording,
      arguments: ScoreRecordingArgs(
        players: selectedPlayers,
        currentRound: widget.currentRound ?? 1,
        totalRounds: 0,
        onScoreSubmitted: (Map<String, int> scoreChanges) {},
        groupId: widget.groupId,
        groupName: groupName,
        initialDealerIndex: _selectedDealerIndex,
        initialPrevalentWindIndex: dealerChanged
            ? 0
            : widget.prevalentWindIndex,
        initialDealerGameCount: dealerChanged
            ? 1
            : widget.currentDealerGameCount,
        initialTotalWindRounds: dealerChanged ? 1 : widget.totalWindRounds,
        minFan: _minFan,
        maxFan: _maxFan,
        gameMode: _selectedGameMode,
      ),
    );
  }

  Future<void> _savePlayerGroup({bool incrementGameCount = false}) async {
    final String groupName = _groupNameController.text.trim().isEmpty
        ? AppLocalizations.defaultGroupName(
            DateTime.now().toString().substring(0, 16),
          )
        : _groupNameController.text.trim();

    final List<String> playerNames = players
        .take(selectedPlayerCount)
        .map((p) => p.name)
        .toList();

    PlayerGroup? existingGroup;
    if (!_isNewGroup && widget.groupName != null) {
      existingGroup = await PlayerGroupService.loadGroup(widget.groupName!);
    }

    if (!_isNewGroup &&
        widget.groupName != null &&
        widget.groupName != groupName) {
      await PlayerGroupService.deleteGroup(widget.groupName!);
    }

    PlayerGroup newGroup;
    if (existingGroup != null) {
      Map<String, int> newScores = {};
      for (var player in players.take(selectedPlayerCount)) {
        newScores[player.name] = player.score;
      }

      bool dealerChanged = existingGroup.dealerIndex != _selectedDealerIndex;
      int currentGamesPlayed = existingGroup.totalGamesPlayedInGroup;
      if (incrementGameCount) currentGamesPlayed += 1;

      newGroup = existingGroup.copyWith(
        name: groupName,
        players: playerNames,
        currentScores: newScores,
        dealerIndex: _selectedDealerIndex,
        prevalentWindIndex: dealerChanged
            ? 0
            : existingGroup.prevalentWindIndex,
        currentDealerGameCount: dealerChanged
            ? 1
            : existingGroup.currentDealerGameCount,
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
    setState(() => _hasSavedGroup = true);
  }

  Future<void> _saveAndExit() async {
    await _savePlayerGroup();
    if (mounted) Navigator.pop(context, true);
  }

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
            child: Text(
              AppLocalizations.delete,
              style: const TextStyle(color: AppColors.destructive),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && widget.groupName != null) {
      await PlayerGroupService.deleteGroup(widget.groupName!);
      setState(() => _hasSavedGroup = true);
      if (mounted) Navigator.pop(context, true);
    }
  }

  // ──────────────────────────────────────────────────────────────────
  // Build
  // ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final winds = _windLabels;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pop(context, _hasSavedGroup);
      },
      child: GestureDetector(
        onTap: () {
          // Dismiss editing when tapping outside
          if (_editingIndex != null) {
            _commitEdit(_editingIndex!);
          }
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              widget.existingPlayers != null
                  ? AppLocalizations.editPlayers
                  : AppLocalizations.setupPlayers,
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context, _hasSavedGroup),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                // ── Scrollable content ──
                Expanded(
                  child: ListView(
                    padding: AppDimens.paddingAllLg,
                    children: [
                      // ── Group Name ──
                      TextField(
                        controller: _groupNameController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.groupName,
                          border: const OutlineInputBorder(),
                          hintText: AppLocalizations.enterGroupNameHint,
                          prefixIcon: const Icon(Icons.group),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Game Mode ──
                      DropdownButtonFormField<GameMode>(
                        value: _selectedGameMode,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.gameMode,
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.casino),
                        ),
                        items: GameMode.values.map((mode) {
                          return DropdownMenuItem(
                            value: mode,
                            child: Text(
                              mode == GameMode.hongKong
                                  ? AppLocalizations.hongKongMahjong
                                  : AppLocalizations.taiwaneseMahjong,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            if (value != null) {
                              _selectedGameMode = value;
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

                      // ── Section header ──
                      Row(
                        children: [
                          const Icon(Icons.event_seat, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            AppLocalizations.seatOrder,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.swap_vert,
                            size: 14,
                            color: AppColors.subtitleColor(isDark),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            AppLocalizations.dragToReorder,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.subtitleColor(isDark),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // ── Duplicate warning banner ──
                      if (_hasDuplicateNames)
                        Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.destructiveLight,
                            borderRadius: AppDimens.borderRadiusMd,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                size: 18,
                                color: AppColors.destructive,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                AppLocalizations.duplicateNameWarning,
                                style: const TextStyle(
                                  color: AppColors.destructive,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // ── Reorderable player cards ──
                      ReorderableListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        buildDefaultDragHandles: false,
                        itemCount: selectedPlayerCount,
                        proxyDecorator: (child, index, animation) {
                          return AnimatedBuilder(
                            animation: animation,
                            builder: (context, child) => Material(
                              elevation: 6,
                              borderRadius: AppDimens.borderRadiusLg,
                              child: child,
                            ),
                            child: child,
                          );
                        },
                        onReorder: (oldIndex, newIndex) {
                          setState(() {
                            if (newIndex > oldIndex) newIndex--;
                            final p = players.removeAt(oldIndex);
                            players.insert(newIndex, p);

                            final c = _nameControllers.removeAt(oldIndex);
                            _nameControllers.insert(newIndex, c);

                            final f = _focusNodes.removeAt(oldIndex);
                            _focusNodes.insert(newIndex, f);

                            // Keep dealer index consistent
                            if (_selectedDealerIndex == oldIndex) {
                              _selectedDealerIndex = newIndex;
                            } else if (oldIndex < _selectedDealerIndex &&
                                newIndex >= _selectedDealerIndex) {
                              _selectedDealerIndex--;
                            } else if (oldIndex > _selectedDealerIndex &&
                                newIndex <= _selectedDealerIndex) {
                              _selectedDealerIndex++;
                            }

                            // Adjust editing index
                            if (_editingIndex == oldIndex) {
                              _editingIndex = newIndex;
                            }
                          });
                        },
                        itemBuilder: (context, index) {
                          return _buildPlayerCard(
                            index,
                            winds[index % 4],
                            isDark,
                            key: ValueKey(players[index].id),
                          );
                        },
                      ),

                      // ── Recent players chips ──
                      if (_recentPlayerNames.isNotEmpty &&
                          _editingIndex != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          AppLocalizations.recentPlayers,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.subtitleColor(isDark),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: _recentPlayerNames.map((name) {
                            return ActionChip(
                              visualDensity: VisualDensity.compact,
                              avatar: const Icon(
                                Icons.person_outline,
                                size: 16,
                              ),
                              label: Text(
                                name,
                                style: const TextStyle(fontSize: 12),
                              ),
                              onPressed: () {
                                if (_editingIndex != null) {
                                  _applyRecentName(name, _editingIndex!);
                                }
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),

                // ── Bottom action buttons ──
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      if (!_isNewGroup) ...[
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: AppDimens.paddingVerticalMd,
                              foregroundColor: AppColors.destructive,
                            ),
                            icon: const Icon(Icons.delete_outline, size: 18),
                            onPressed: _deleteGroup,
                            label: Text(AppLocalizations.delete),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: AppDimens.paddingVerticalMd,
                          ),
                          icon: const Icon(Icons.save_outlined, size: 18),
                          onPressed: _saveAndExit,
                          label: Text(AppLocalizations.save),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            padding: AppDimens.paddingVerticalMd,
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                          ),
                          icon: const Icon(Icons.play_arrow, size: 20),
                          onPressed: _hasDuplicateNames ? null : _startGame,
                          label: Text(AppLocalizations.start),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────
  // Player Card
  // ──────────────────────────────────────────────────────────────────

  Widget _buildPlayerCard(
    int index,
    String windLabel,
    bool isDark, {
    required Key key,
  }) {
    final isEditing = _editingIndex == index;
    final duplicate = _isDuplicate(index);
    final windColor = _windColors[index % 4];

    return Padding(
      key: key,
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        elevation: isEditing ? 4 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: AppDimens.borderRadiusLg,
          side: BorderSide(
            color: duplicate
                ? AppColors.destructive
                : isEditing
                ? AppColors.primary
                : AppColors.borderColor(isDark),
            width: duplicate || isEditing ? 1.5 : 0.5,
          ),
        ),
        child: InkWell(
          borderRadius: AppDimens.borderRadiusLg,
          onTap: isEditing ? null : () => _startEditing(index),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                // ── Drag handle ──
                ReorderableDragStartListener(
                  index: index,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Icon(
                      Icons.drag_indicator,
                      color: AppColors.subtitleColor(isDark),
                      size: 20,
                    ),
                  ),
                ),

                // ── Wind badge ──
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: windColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    windLabel,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: windColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // ── Name area ──
                Expanded(
                  child: isEditing
                      ? TextField(
                          controller: _nameControllers[index],
                          focusNode: _focusNodes[index],
                          style: const TextStyle(fontSize: 15),
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: AppDimens.borderRadiusSm,
                            ),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _nameControllers[index].clear();
                                _focusNodes[index].requestFocus();
                              },
                              tooltip: AppLocalizations.clearName,
                            ),
                          ),
                          textInputAction: index < selectedPlayerCount - 1
                              ? TextInputAction.next
                              : TextInputAction.done,
                          onSubmitted: (_) {
                            _commitEdit(index);
                            // Auto-focus next player
                            if (index < selectedPlayerCount - 1) {
                              _startEditing(index + 1);
                            }
                          },
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              players[index].name,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: duplicate ? AppColors.destructive : null,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              AppLocalizations.windSeat(windLabel),
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.subtitleColor(isDark),
                              ),
                            ),
                          ],
                        ),
                ),

                // ── Edit / confirm icon ──
                if (isEditing)
                  IconButton(
                    icon: const Icon(
                      Icons.check_circle,
                      color: AppColors.primary,
                    ),
                    onPressed: () => _commitEdit(index),
                  )
                else
                  Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: AppColors.subtitleColor(isDark),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
