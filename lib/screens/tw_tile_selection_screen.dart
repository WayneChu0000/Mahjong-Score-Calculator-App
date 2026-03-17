import 'package:flutter/material.dart';
import '../models/tw_hand.dart';
import '../logic/hand_validator.dart';
import '../localization/app_localizations.dart';
import '../models/game_mode.dart';

/// Three-column tile selection screen for Taiwan Mahjong.
///
/// Zones:
///   1. **Exposed melds (明)** — chow (順子), pong (刻子), kong (槓子).
///   2. **Concealed tiles (暗)** — free-form tiles in hand.
///   3. **Winning tile (胡牌)** — exactly one tile.
///
/// Also provides a 叮 (ding) toggle for single-tile wait bonus.
class TwTileSelectionScreen extends StatefulWidget {
  /// Pre-existing hand (for editing an already-entered hand).
  final TwHand? initialHand;

  const TwTileSelectionScreen({super.key, this.initialHand});

  @override
  State<TwTileSelectionScreen> createState() => _TwTileSelectionScreenState();
}

class _TwTileSelectionScreenState extends State<TwTileSelectionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Hand state
  final List<Meld> _exposedMelds = [];
  final List<String> _concealedTiles = [];
  String? _winningTile;
  bool _isDing = false;

  // Meld builder state
  MeldType _meldType = MeldType.pong;
  final List<String> _meldBuffer = [];

  // Which zone is receiving tiles
  _InputTarget _target = _InputTarget.concealed;

  // Validation
  String? _validationMessage;
  bool _isValid = false;

  // Tile catalog
  final Map<String, List<String>> _tileCategories = {
    'Characters': List.generate(9, (i) => '${i + 1}m'),
    'Dots': List.generate(9, (i) => '${i + 1}p'),
    'Bamboo': List.generate(9, (i) => '${i + 1}s'),
    'Honors': List.generate(7, (i) => '${i + 1}z'),
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    if (widget.initialHand != null) {
      _exposedMelds.addAll(widget.initialHand!.exposedMelds);
      _concealedTiles.addAll(widget.initialHand!.concealedTiles);
      _winningTile = widget.initialHand!.winningTile;
      _isDing = widget.initialHand!.isDing;
    }
    _validate();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── Build current TwHand ───────────────────────────────────────

  TwHand get _currentHand => TwHand(
        exposedMelds: List.unmodifiable(_exposedMelds),
        concealedTiles: List.unmodifiable(_concealedTiles),
        winningTile: _winningTile,
        isDing: _isDing,
      );

  // ── Tile count helpers ─────────────────────────────────────────

  int get _totalTileCount {
    int count = 0;
    for (final m in _exposedMelds) {
      count += m.tileCount;
    }
    count += _concealedTiles.length;
    if (_winningTile != null) count += 1;
    return count;
  }

  int get _expectedTileCount {
    final kongs = _exposedMelds.where((m) => m.isKong).length;
    return 17 + kongs;
  }

  int _countTileUsage(String tile) {
    int c = 0;
    for (final m in _exposedMelds) {
      c += m.tiles.where((t) => t == tile).length;
    }
    c += _concealedTiles.where((t) => t == tile).length;
    if (_winningTile == tile) c += 1;
    return c;
  }

  // ── Validation ─────────────────────────────────────────────────

  void _validate() {
    if (_totalTileCount < 17 || _winningTile == null) {
      _isValid = false;
      if (_winningTile == null && _totalTileCount >= 16) {
        _validationMessage = AppLocalizations.selectWinningTileMsg;
      } else {
        _validationMessage =
            '${AppLocalizations.selectAtLeastTilesMsg} ($_totalTileCount/$_expectedTileCount)';
      }
    } else if (_totalTileCount != _expectedTileCount) {
      _isValid = false;
      _validationMessage =
          AppLocalizations.needTilesMsg(_expectedTileCount, _totalTileCount);
    } else {
      // Structural validation
      final allTiles = _currentHand.allTiles;
      final result = HandValidator.checkWinningHand(
        allTiles,
        gameMode: GameMode.taiwan,
      );
      _isValid = result['valid'];
      _validationMessage = result['message'];
    }
    setState(() {});
  }

  // ── Add tile to the current target ─────────────────────────────

  void _addTile(String tile) {
    if (_countTileUsage(tile) >= 4) {
      _showSnack(AppLocalizations.maxTilesAlert);
      return;
    }

    setState(() {
      switch (_target) {
        case _InputTarget.concealed:
          if (_totalTileCount >= 21) {
            _showSnack(AppLocalizations.maxTotalTilesAlert);
            return;
          }
          _concealedTiles.add(tile);
          _concealedTiles.sort(_compareTiles);
          break;

        case _InputTarget.winningTile:
          _winningTile = tile;
          // Auto switch back to concealed
          _target = _InputTarget.concealed;
          break;

        case _InputTarget.meld:
          _meldBuffer.add(tile);
          final neededCount = (_meldType == MeldType.kong || _meldType == MeldType.concealedKong) ? 4 : 3;
          if (_meldBuffer.length >= neededCount) {
            _finalizeMeld();
          }
          break;
      }
      _validate();
    });
  }

  // ── Meld management ────────────────────────────────────────────

  void _startMeldInput(MeldType type) {
    setState(() {
      _meldType = type;
      _meldBuffer.clear();
      _target = _InputTarget.meld;
    });
  }

  void _cancelMeldInput() {
    setState(() {
      _meldBuffer.clear();
      _target = _InputTarget.concealed;
    });
  }

  void _finalizeMeld() {
    if (_meldBuffer.isEmpty) return;

    // Validate the meld
    bool valid = true;
    final sorted = List<String>.from(_meldBuffer)..sort(_compareTiles);

    switch (_meldType) {
      case MeldType.pong:
        // All 3 tiles must be the same
        valid = sorted.length == 3 &&
            sorted[0] == sorted[1] && sorted[1] == sorted[2];
        break;
      case MeldType.kong:
      case MeldType.concealedKong:
        // All 4 tiles must be the same
        valid = sorted.length == 4 &&
            sorted.toSet().length == 1;
        break;
      case MeldType.chow:
        // Must be 3 consecutive tiles of the same suit
        valid = sorted.length == 3 && _isValidChow(sorted);
        break;
    }

    if (!valid) {
      _showSnack(AppLocalizations.invalidMeld);
      _meldBuffer.clear();
      return;
    }

    setState(() {
      _exposedMelds.add(Meld(type: _meldType, tiles: sorted));
      _meldBuffer.clear();
      _target = _InputTarget.concealed;
      _validate();
    });
  }

  bool _isValidChow(List<String> sorted) {
    if (sorted.length != 3) return false;
    final suit = sorted[0].substring(1);
    if (suit == 'z') return false; // No honor chows
    if (!sorted.every((t) => t.substring(1) == suit)) return false;
    final nums = sorted.map((t) => int.parse(t.substring(0, 1))).toList()
      ..sort();
    return nums[1] == nums[0] + 1 && nums[2] == nums[1] + 1;
  }

  void _removeMeld(int index) {
    setState(() {
      _exposedMelds.removeAt(index);
      _validate();
    });
  }

  void _removeConcealedTile(int index) {
    setState(() {
      _concealedTiles.removeAt(index);
      _validate();
    });
  }

  void _clearWinningTile() {
    setState(() {
      _winningTile = null;
      _validate();
    });
  }

  void _clearAll() {
    setState(() {
      _exposedMelds.clear();
      _concealedTiles.clear();
      _winningTile = null;
      _isDing = false;
      _meldBuffer.clear();
      _target = _InputTarget.concealed;
      _validate();
    });
  }

  // ── helpers ────────────────────────────────────────────────────

  int _compareTiles(String a, String b) {
    const suits = ['m', 'p', 's', 'z'];
    final suitA = a.substring(1), suitB = b.substring(1);
    final numA = int.parse(a.substring(0, 1));
    final numB = int.parse(b.substring(0, 1));
    final cmp = suits.indexOf(suitA).compareTo(suits.indexOf(suitB));
    return cmp != 0 ? cmp : numA.compareTo(numB);
  }

  String _getAssetPath(String tile) {
    final suit = tile.substring(1);
    final folder = {
      'm': 'characters',
      'p': 'dots',
      's': 'bamboo',
      'z': 'honors',
    }[suit]!;
    return 'assets/images/tiles/$folder/$tile.png';
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontFamily: "Traditional Chinese")),
      ),
    );
  }

  String _meldTypeName(MeldType t) {
    switch (t) {
      case MeldType.chow:
        return AppLocalizations.chowName;
      case MeldType.pong:
        return AppLocalizations.pongName;
      case MeldType.kong:
        return AppLocalizations.exposedKongName;
      case MeldType.concealedKong:
        return AppLocalizations.concealedKongName;
    }
  }

  // ── Build ──────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.tileSelectionTitle),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: AppLocalizations.charactersTab),
            Tab(text: AppLocalizations.dotsTab),
            Tab(text: AppLocalizations.bambooTab),
            Tab(text: AppLocalizations.honorsTab),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _isValid ? () => Navigator.pop(context, _currentHand) : null,
            child: Text(
              AppLocalizations.confirm,
              style: TextStyle(
                color: _isValid ? Colors.white : Colors.white30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Target selector & meld buttons ─────────────────────
          _buildTargetBar(isDark),

          // ── Meld builder indicator ─────────────────────────────
          if (_target == _InputTarget.meld) _buildMeldBuilderBar(isDark),

          // ── Tile picker grid ───────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _tileCategories.entries.map((entry) {
                return GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: entry.value.length,
                  itemBuilder: (context, index) {
                    final tile = entry.value[index];
                    final count = _countTileUsage(tile);
                    return InkWell(
                      onTap: () => _addTile(tile),
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Image.asset(
                              _getAssetPath(tile),
                              fit: BoxFit.contain,
                            ),
                          ),
                          if (count > 0)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '$count',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ),

          // ── Hand preview (3 columns) ──────────────────────────
          _buildHandPreview(isDark),
        ],
      ),
    );
  }

  // ── Target selector toolbar ────────────────────────────────────

  Widget _buildTargetBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Concealed target
            _targetChip(
              label: AppLocalizations.concealedTarget,
              isActive: _target == _InputTarget.concealed,
              onTap: () => setState(() {
                _target = _InputTarget.concealed;
                _meldBuffer.clear();
              }),
            ),
            const SizedBox(width: 6),
            // Winning tile target
            _targetChip(
              label: AppLocalizations.winTarget,
              isActive: _target == _InputTarget.winningTile,
              onTap: () => setState(() {
                _target = _InputTarget.winningTile;
                _meldBuffer.clear();
              }),
            ),
            const SizedBox(width: 6),
            const VerticalDivider(width: 1, thickness: 1),
            const SizedBox(width: 6),
            // Add exposed meld buttons
            // Ding toggle
            FilterChip(
              label: Text(
                AppLocalizations.dingLabel,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _isDing ? Colors.white : null,
                ),
              ),
              selected: _isDing,
              selectedColor: Colors.orange.shade700,
              onSelected: (v) => setState(() { _isDing = v; }),
            ),
            const SizedBox(width: 8),
            _meldButton(AppLocalizations.chowButton, MeldType.chow),
            const SizedBox(width: 4),
            _meldButton(AppLocalizations.pongButton, MeldType.pong),
            const SizedBox(width: 4),
            _meldButton(AppLocalizations.exposedKongButton, MeldType.kong),
            const SizedBox(width: 4),
            _meldButton(AppLocalizations.concealedKongButton, MeldType.concealedKong),
            const SizedBox(width: 8),
            // Clear all
            TextButton(
              onPressed: _clearAll,
              child: Text(AppLocalizations.clear),
            ),
          ],
        ),
      ),
    );
  }

  Widget _targetChip({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          color: isActive ? Colors.white : null,
        ),
      ),
      selected: isActive,
      selectedColor: Colors.green.shade700,
      onSelected: (_) => onTap(),
    );
  }

  Widget _meldButton(String label, MeldType type) {
    final isActive = _target == _InputTarget.meld && _meldType == type;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = isDark ? Colors.blue.shade900 : Colors.blue.shade700;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? activeColor : null,
        foregroundColor: isActive ? Colors.white : null,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: () => _startMeldInput(type),
      child: Text(label, style: const TextStyle(fontSize: 13)),
    );
  }

  // ── Meld builder indicator ─────────────────────────────────────

  Widget _buildMeldBuilderBar(bool isDark) {
    final needed = (_meldType == MeldType.kong || _meldType == MeldType.concealedKong) ? 4 : 3;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: Colors.blue.shade100,
      child: Row(
        children: [
          Text(
            AppLocalizations.buildingMeld(_meldTypeName(_meldType), _meldBuffer.length, needed),
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const SizedBox(width: 8),
          // Show buffer tiles
          ..._meldBuffer.map(
            (t) => Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Image.asset(_getAssetPath(t), width: 28, fit: BoxFit.contain),
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: _cancelMeldInput,
            child: Text(AppLocalizations.cancel),
          ),
        ],
      ),
    );
  }

  // ── Hand preview (bottom panel) ────────────────────────────────

  Widget _buildHandPreview(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tiles: $_totalTileCount / $_expectedTileCount'
                '${_isDing ? "  |  ${AppLocalizations.dingLabel}" : ""}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    _validationMessage ?? '',
                    style: TextStyle(
                      color: _isValid ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // ── Exposed melds row ──────────────────────────────────
          _buildZoneLabel(AppLocalizations.exposedZoneLabel, Colors.orange),
          SizedBox(
            height: 46,
            child: _exposedMelds.isEmpty
                ? Center(
                    child: Text(AppLocalizations.noExposedMelds,
                        style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _exposedMelds.length,
                    itemBuilder: (_, i) {
                      final meld = _exposedMelds[i];
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: InkWell(
                          onTap: () => _removeMeld(i),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 2, vertical: 1),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.orange.shade300,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  children: meld.tiles.map((t) {
                                    return Padding(
                                      padding:
                                          const EdgeInsets.symmetric(horizontal: 1),
                                      child: Image.asset(
                                        _getAssetPath(t),
                                        width: 30,
                                        fit: BoxFit.contain,
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                              const SizedBox(width: 2),
                              Text(
                                _meldTypeName(meld.type),
                                style: const TextStyle(
                                    fontSize: 9, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 4),

          // ── Concealed tiles row ────────────────────────────────
          _buildZoneLabel(AppLocalizations.concealedZoneLabel, Colors.blue),
          SizedBox(
            height: 46,
            child: _concealedTiles.isEmpty
                ? Center(
                    child: Text(AppLocalizations.noConcealedTiles,
                        style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _concealedTiles.length,
                    itemBuilder: (_, i) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: InkWell(
                          onTap: () => _removeConcealedTile(i),
                          child: Image.asset(
                            _getAssetPath(_concealedTiles[i]),
                            width: 32,
                            fit: BoxFit.contain,
                          ),
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 4),

          // ── Winning tile row ───────────────────────────────────
          _buildZoneLabel(AppLocalizations.winningTileZoneLabel, Colors.red),
          SizedBox(
            height: 46,
            child: _winningTile == null
                ? Center(
                    child: Text(AppLocalizations.tapWinToPickTile,
                        style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  )
                : InkWell(
                    onTap: _clearWinningTile,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.red.shade300, width: 2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Image.asset(
                        _getAssetPath(_winningTile!),
                        width: 36,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildZoneLabel(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

enum _InputTarget { concealed, winningTile, meld }
