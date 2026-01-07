import 'package:flutter/material.dart';
import '../utils/mahjong_logic.dart';

class TileSelectionScreen extends StatefulWidget {
  final List<String> initialTiles;

  const TileSelectionScreen({
    super.key,
    this.initialTiles = const [],
  });

  @override
  State<TileSelectionScreen> createState() => _TileSelectionScreenState();
}

class _TileSelectionScreenState extends State<TileSelectionScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _selectedTiles = [];
  String? _validationMessage;
  bool _isValid = false;

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
    _selectedTiles.addAll(widget.initialTiles);
    _validateHand();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _addTile(String tile) {
    // Count occurrences of this tile
    int count = _selectedTiles.where((t) => t == tile).length;
    if (count >= 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot select more than 4 of the same tile', style: TextStyle(fontFamily: "Traditional Chinese"))),
      );
      return;
    }

    // Check total limit
    // Max possible is 18 (4 Kongs + Pair)
    if (_selectedTiles.length >= 18) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 18 tiles allowed', style: TextStyle(fontFamily: "Traditional Chinese"))),
      );
      return;
    }

    setState(() {
      _selectedTiles.add(tile);
      // Auto sort
      _selectedTiles.sort((a, b) => _compareTiles(a, b));
      _validateHand();
    });
  }

  void _removeTile(int index) {
    setState(() {
      _selectedTiles.removeAt(index);
      _validateHand();
    });
  }

  int _compareTiles(String a, String b) {
    List<String> suits = ['m', 'p', 's', 'z'];
    String suitA = a.substring(1);
    String suitB = b.substring(1);
    int numA = int.parse(a.substring(0, 1));
    int numB = int.parse(b.substring(0, 1));
    
    int suitCompare = suits.indexOf(suitA).compareTo(suits.indexOf(suitB));
    if (suitCompare != 0) return suitCompare;
    return numA.compareTo(numB);
  }

  void _validateHand() {
    if (_selectedTiles.length < 14) {
      setState(() {
        _isValid = false;
        _validationMessage = 'Select at least 14 tiles';
      });
      return;
    }

    var result = MahjongLogic.checkWinningHand(_selectedTiles);
    setState(() {
      _isValid = result['valid'];
      _validationMessage = result['message'];
    });
  }

  String _getAssetPath(String tile) {
    String suit = tile.substring(1);
    String folder = '';
    switch (suit) {
      case 'm': folder = 'characters'; break;
      case 'p': folder = 'dots'; break;
      case 's': folder = 'bamboo'; break;
      case 'z': folder = 'honors'; break;
    }
    return 'assets/images/tiles/$folder/$tile.png';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Winning Hand'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Characters'),
            Tab(text: 'Dots'),
            Tab(text: 'Bamboo'),
            Tab(text: 'Honors'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _isValid ? () {
              Navigator.pop(context, _selectedTiles);
            } : null,
            child: Text(
              'Confirm',
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
          // Tile Grid
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
                    String tile = entry.value[index];
                    int count = _selectedTiles.where((t) => t == tile).length;
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
          
          // Selected Tiles Area
          Container(
            height: 160,
            padding: const EdgeInsets.all(12),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Selected: ${_selectedTiles.length}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          _validationMessage ?? '',
                          style: TextStyle(
                            color: _isValid ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedTiles.clear();
                          _validateHand();
                        });
                      },
                      child: const Text('Clear'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedTiles.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: InkWell(
                          onTap: () => _removeTile(index),
                          child: Image.asset(
                            _getAssetPath(_selectedTiles[index]),
                            width: 40,
                            fit: BoxFit.contain,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
