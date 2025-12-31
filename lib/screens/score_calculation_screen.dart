import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async'; // Add this line to import StreamSubscription
import 'package:image_picker/image_picker.dart';
import '../models/player.dart';
import 'tile_selection_screen.dart';
import '../utils/mahjong_logic.dart';
import '../models/rule.dart'; // Import Rule model
import 'rules_screen.dart';

class ScoreCalculationScreen extends StatefulWidget {
  final List<Player> players;
  final String? groupName;
  final int? roundWindIndex;
  final int? dealerIndex;

  const ScoreCalculationScreen({
    super.key,
    required this.players,
    this.groupName,
    this.roundWindIndex,
    this.dealerIndex,
  });

  @override
  State<ScoreCalculationScreen> createState() => _ScoreCalculationScreenState();
}

class _ScoreCalculationScreenState extends State<ScoreCalculationScreen> {
  // Winning method
  bool _isSelfDraw = true;
  String? _winningPlayer;
  String? _discardPlayer;
  
  // Winds
  String _roundWind = 'East';
  String _seatWind = 'East';
  final List<String> _winds = ['East', 'South', 'West', 'North'];
  
  // Fan count and score
  int _fanCount = 1;
  int _effectiveFan = 1; // Total effective fan after bonuses
  int _basePoints = 1;
  bool _selfDrawBonus = false;
  
  // Flower and Special Conditions
  String _selectedFlowerOption = 'No Flower';
  String _selectedSpecialCondition = 'None';

  final List<String> _flowerOptions = [
    'No Flower',
    'Flowers (No Score)',
    '1 Flower',
    '2 Flowers',
    '1 Flower + 1 Flower Platform',
    'Flower Hand',
    'Eight Immortals'
  ];

  final List<String> _specialConditions = [
    'None',
    'Men Qian Qing',
    'Robbing the Kong',
    'Haidilao',
    'Kong on Kong/Flower',
    'Heavenly Hand',
    'Earthly Hand'
  ];
  
  // Hand preview
  File? _capturedImage;
  List<String> _selectedTiles = [];
  List<Map<String, dynamic>> _matchedRulesDetails = []; // Store matched rules for display
  List<Map<String, dynamic>> _displayRules = []; // Final rules for display
  
  // Calculation result
  int _totalPoints = 0;
  
  // Player score mapping
  final Map<String, int> _playerScores = {};
  
  // Listen to score changes
  StreamSubscription? _scoreSubscription;

  @override
  void initState() {
    super.initState();
    // Initialize with passed player list
    for (var player in widget.players) {
      _playerScores[player.name] = 0;
    }
    
    // Default select first player as winner
    _winningPlayer = widget.players.isNotEmpty ? widget.players[0].name : "Player 1";
    
    // Initialize Winds
    if (widget.roundWindIndex != null) {
      _roundWind = _winds[widget.roundWindIndex! % 4];
    }
    
    _updateSeatWind(notify: false);
    _ensureValidDiscardPlayer();
    
    // Initial calculation
    _calculateScoreInternal();
  }
  
  void _updateSeatWind({bool notify = true}) {
    if (widget.dealerIndex != null && _winningPlayer != null) {
      // Find winning player index
      int winnerIndex = widget.players.indexWhere((p) => p.name == _winningPlayer);
      if (winnerIndex != -1) {
        // Calculate seat wind relative to dealer
        // 0: East (Dealer)
        // 1: South (Right)
        // 2: West (Opposite)
        // 3: North (Left)
        // Formula: (Winner - Dealer + 4) % 4
        int windIndex = (winnerIndex - widget.dealerIndex! + 4) % 4;
        if (notify) {
          setState(() {
            _seatWind = _winds[windIndex];
          });
        } else {
          _seatWind = _winds[windIndex];
        }
      }
    }
  }

  void _ensureValidDiscardPlayer() {
    if (_isSelfDraw) {
      _discardPlayer = null;
      return;
    }
    
    if (_discardPlayer == null || _discardPlayer == _winningPlayer) {
       final validPlayers = widget.players.where((p) => p.name != _winningPlayer).toList();
       if (validPlayers.isNotEmpty) {
         _discardPlayer = validPlayers.first.name;
       }
    }
  }
  
  @override
  void dispose() {
    // Ensure safe unsubscribe
    try {
      _scoreSubscription?.cancel();
    } catch (e) {
      print('Error canceling score subscription: $e');
    }
    super.dispose();
  }

  // Get player current score
  int _getPlayerCurrentScore(String playerName) {
    try {
      return widget.players.firstWhere((p) => p.name == playerName).score;
    } catch (e) {
      return 0;
    }
  }

  // Auto calculate fan from tiles
  void _calculateFanFromTiles() {
    if (_selectedTiles.isEmpty) return;
    
    int calculatedFan = 0;
    List<Map<String, dynamic>> matchedRules = [];
    
    for (var rule in rules) {
      if (rule.validator != null) {
        if (rule.validator!(_selectedTiles)) {
          // Parse fan string "X fan"
          int fan = int.tryParse(rule.fan.split(' ')[0]) ?? 0;
          calculatedFan += fan;
          matchedRules.add({'name': rule.name, 'fan': fan});
        }
      }
    }

    // Check for Dragon Pongs (if not Big/Small Three Dragons)
    bool hasBigThreeDragons = matchedRules.any((r) => r['name'] == 'Big Three Dragons');
    bool hasSmallThreeDragons = matchedRules.any((r) => r['name'] == 'Small Three Dragons');

    if (!hasBigThreeDragons && !hasSmallThreeDragons) {
       // Count dragon pongs
       Map<String, int> counts = {};
       for (var t in _selectedTiles) {
         if (t == '5z' || t == '6z' || t == '7z') {
           counts[t] = (counts[t] ?? 0) + 1;
         }
       }
       
       for (var entry in counts.entries) {
         if (entry.value >= 3) {
           String dragonName = '';
           if (entry.key == '5z') dragonName = 'White Dragon';
           if (entry.key == '6z') dragonName = 'Green Dragon';
           if (entry.key == '7z') dragonName = 'Red Dragon';
           
           calculatedFan += 1;
           matchedRules.add({'name': 'Pong of $dragonName', 'fan': 1});
         }
       }
    }

    // Check for Wind Pongs (Round Wind / Seat Wind)
    // Only if not Big/Small Four Winds
    bool hasBigFourWinds = matchedRules.any((r) => r['name'] == 'Big Four Winds');
    bool hasSmallFourWinds = matchedRules.any((r) => r['name'] == 'Small Four Winds');

    if (!hasBigFourWinds && !hasSmallFourWinds) {
      Map<String, int> windCounts = {};
      for (var t in _selectedTiles) {
        if (t.endsWith('z') && int.parse(t[0]) <= 4) {
          windCounts[t] = (windCounts[t] ?? 0) + 1;
        }
      }

      // Map wind names to tile codes
      Map<String, String> windMap = {
        'East': '1z',
        'South': '2z',
        'West': '3z',
        'North': '4z',
      };

      String roundWindTile = windMap[_roundWind]!;
      String seatWindTile = windMap[_seatWind]!;

      // Check Round Wind
      if ((windCounts[roundWindTile] ?? 0) >= 3) {
        calculatedFan += 1;
        matchedRules.add({'name': 'Round Wind ($_roundWind)', 'fan': 1});
      }

      // Check Seat Wind
      if ((windCounts[seatWindTile] ?? 0) >= 3) {
        calculatedFan += 1;
        matchedRules.add({'name': 'Seat Wind ($_seatWind)', 'fan': 1});
      }
    }

    // Add Self-Draw fan if applicable
    if (_isSelfDraw) {
      // Only add self-draw fan if NOT a special instant win hand that includes self-draw
      bool isSpecialHand = _selectedFlowerOption == 'Flower Hand' || 
                           _selectedFlowerOption == 'Eight Immortals' || 
                           _selectedSpecialCondition == 'Heavenly Hand';
      
      if (!isSpecialHand) {
        calculatedFan += 1;
        matchedRules.add({'name': 'Self-Draw', 'fan': 1});
      }
    }
    
    // Cap at 13 fan
    if (calculatedFan > 13) calculatedFan = 13;

    setState(() {
      _fanCount = calculatedFan;
      _matchedRulesDetails = matchedRules;
      // Reset manual bonuses that are now auto-calculated to avoid double counting
      if (_isSelfDraw) _selfDrawBonus = false; 
    });
    
    // Recalculate score with new fan count
    _calculateScore();
  }

  // Calculate score
  void _calculateScore() {
    _calculateScoreInternal();
    setState(() {});
  }

  void _calculateScoreInternal() {
    // Calculate effective fan count
    int effectiveFan = _fanCount;
    
    // Initialize display rules from matched rules
    _displayRules = List.from(_matchedRulesDetails);

    // Check for Hidden Treasure combination (All Pongs + Men Qian Qing)
    bool hasAllPongs = _displayRules.any((r) => r['name'] == 'All Pongs (Dui Dui Hu)');
    bool isMenQianQing = _selectedSpecialCondition == 'Men Qian Qing';

    if (hasAllPongs && isMenQianQing) {
      // Remove All Pongs (3 fan)
      _displayRules.removeWhere((r) => r['name'] == 'All Pongs (Dui Dui Hu)');
      // Add Hidden Treasure (8 fan)
      _displayRules.add({'name': 'Hidden Treasure', 'fan': 8});
      
      // Adjust effective fan: Remove 3 (All Pongs), Add 8 (Hidden Treasure)
      // Note: _fanCount includes All Pongs (3).
      // We do NOT add Men Qian Qing (+1) because it's merged into Hidden Treasure.
      effectiveFan = effectiveFan - 3 + 8;
    } else {
      // Normal logic
      // Handle Special Conditions
      if (_selectedSpecialCondition == 'Men Qian Qing') {
        effectiveFan += 1;
      } else if (_selectedSpecialCondition == 'Robbing the Kong') {
        effectiveFan += 1;
      } else if (_selectedSpecialCondition == 'Haidilao') {
        effectiveFan += 1;
      } else if (_selectedSpecialCondition == 'Kong on Kong/Flower') {
        effectiveFan += 2;
      } else if (_selectedSpecialCondition == 'Heavenly Hand') {
        effectiveFan = 13;
      } else if (_selectedSpecialCondition == 'Earthly Hand') {
        effectiveFan = 13;
      }
    }
    
    // Add self-draw bonus (usually +1 fan)
    if (_selfDrawBonus) effectiveFan += 1;
    
    // Handle Flower Options
    if (_selectedFlowerOption == 'No Flower') {
      effectiveFan += 1;
    } else if (_selectedFlowerOption == 'Flowers (No Score)') {
      // 0 fan, and no "No Flower" bonus
    } else if (_selectedFlowerOption == '1 Flower') {
      effectiveFan += 1;
    } else if (_selectedFlowerOption == '2 Flowers') {
      effectiveFan += 2;
    } else if (_selectedFlowerOption == '1 Flower + 1 Flower Platform') {
      effectiveFan += 3; // 1 (Own) + 2 (Platform)
    } else if (_selectedFlowerOption == 'Flower Hand') {
      effectiveFan = 3; // Fixed 3 fan
      // Instant win, no extra self-draw bonus usually added on top of fixed fan unless specified
    } else if (_selectedFlowerOption == 'Eight Immortals') {
      effectiveFan = 8; // Fixed 8 fan
    }

    // Cap at 13 fan
    if (effectiveFan > 13) effectiveFan = 13;

    _effectiveFan = effectiveFan; // Store for display

    // Lookup score from table
    int discardScore = _getScoreFromFan(effectiveFan);
    
    // Determine if it counts as self-draw for scoring purposes
    bool countsAsSelfDraw = _isSelfDraw;
    if (_selectedFlowerOption == 'Flower Hand' || _selectedFlowerOption == 'Eight Immortals' || _selectedSpecialCondition == 'Heavenly Hand') {
      countsAsSelfDraw = true;
    }
    
    if (countsAsSelfDraw) {
      // For self-draw, each player pays half of the discard score
      // If effective fan is 0, self-draw is invalid/min 1 fan, handled by table logic or clamped
      if (effectiveFan < 1) {
         // Handle min 1 fan for self draw rule if needed, 
         // but based on table 0 fan discard is 1. 
         // If 0 fan self draw is not allowed, maybe clamp to 1?
         // Table says "Self-Draw Min 1 Fan". 
         // If user has 0 fan and self draw, effectiveFan might be 0 if no bonus checked.
         // But usually self draw implies +1 fan bonus is checked or inherent.
         // If we strictly follow table:
         // Fan 0 -> Discard 1. Self Draw N/A.
         // Fan 1 -> Discard 2. Self Draw 3 (1x3).
         // So if effectiveFan is 0, and self draw, maybe we should treat as Fan 1?
         // Or just use the formula: DiscardScore / 2.
         // Discard 1 / 2 = 0.5 -> 0?
         // Let's assume effectiveFan >= 1 for self draw.
         _totalPoints = 1; // Minimum 1 point for self draw even if fan is low
      } else {
         _totalPoints = discardScore ~/ 2;
      }
    } else {
      _totalPoints = discardScore;
    }
  }

  // Helper for display text
  String _getFlowerFanText(String option) {
    switch (option) {
      case 'No Flower': return '+1 Fan';
      case 'Flowers (No Score)': return '0 Fan';
      case '1 Flower': return '+1 Fan';
      case '2 Flowers': return '+2 Fan';
      case '1 Flower + 1 Flower Platform': return '+3 Fan';
      case 'Flower Hand': return '3 Fan (Limit)';
      case 'Eight Immortals': return '8 Fan (Limit)';
      default: return '';
    }
  }

  String _getSpecialConditionFanText(String condition) {
    switch (condition) {
      case 'Men Qian Qing': return '+1 Fan';
      case 'Robbing the Kong': return '+1 Fan';
      case 'Haidilao': return '+1 Fan';
      case 'Kong on Kong/Flower': return '+2 Fan';
      case 'Heavenly Hand': return '13 Fan (Limit)';
      case 'Earthly Hand': return '13 Fan (Limit)';
      default: return '';
    }
  }

  // Lookup score based on fan count
  int _getScoreFromFan(int fan) {
    if (fan <= 0) return 1;
    if (fan == 1) return 2;
    if (fan == 2) return 4;
    if (fan == 3) return 8;
    if (fan == 4) return 16;
    if (fan == 5) return 24;
    if (fan == 6) return 32;
    if (fan == 7) return 48;
    if (fan == 8) return 64;
    if (fan == 9) return 96;
    if (fan == 10) return 128;
    if (fan == 11) return 192;
    if (fan == 12) return 256;
    if (fan >= 13) return 384; // 13 fan limit
    return 1; // Fallback
  }

  // Take photo to get hand pattern
  Future<void> _captureImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    
    if (image != null) {
      setState(() {
        _capturedImage = File(image.path);
        _selectedTiles.clear(); // Clear manual selection if photo taken
      });
    }
  }

  // Select hand manually
  Future<void> _selectHand() async {
    final result = await Navigator.push<List<String>>(
      context,
      MaterialPageRoute(
        builder: (context) => TileSelectionScreen(initialTiles: _selectedTiles),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedTiles = result;
        _capturedImage = null; // Clear photo if manual selection used
      });
      _calculateFanFromTiles();
      _calculateScore();
    }
  }

  String _getAssetPath(String tile) {
    String suit = tile.substring(1);
    String folder = '';
    switch (suit) {
      case 'm': folder = 'wan'; break;
      case 'p': folder = 'tong'; break;
      case 's': folder = 'suo'; break;
      case 'z': folder = 'honor'; break;
    }
    return 'assets/images/tiles/$folder/$tile.png';
  }

  // Submit score
  void _submitScore() {
    Map<String, int> scoreChanges = {};
    
    // Helper to get ID by name
    String getId(String name) {
      return widget.players.firstWhere((p) => p.name == name).id.toString();
    }
    
    // Calculate score changes based on self-draw or discard
    if (_isSelfDraw && _winningPlayer != null) {
      // Self-draw: all other players lose points
      for (var player in widget.players) {
        if (player.name != _winningPlayer) {
          // When self-draw, all other players lose same points
          scoreChanges[getId(player.name)] = -_totalPoints;
        }
      }
      // Winner gets all points
      scoreChanges[getId(_winningPlayer!)] = _totalPoints * (widget.players.length - 1);
    } else if (!_isSelfDraw && _winningPlayer != null && _discardPlayer != null) {
      // Discard: only the discarder loses points
      scoreChanges[getId(_discardPlayer!)] = -_totalPoints;
      scoreChanges[getId(_winningPlayer!)] = _totalPoints;
    }
    
    // Show successful submission message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Score updated, next round')),
    );
    
    // Return to previous page with result
    Navigator.pop(context, scoreChanges);
  }

  // // Get player's current score
  // int _getPlayerCurrentScore(String player) {
  //   return _playerScores[player] ?? 0;
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupName ?? 'Mahjong Scoring'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.menu_book),
            tooltip: 'Rules Reference',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RulesScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Win setup
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Win',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Self-draw or discard selection
                    Row(
                      children: [
                        Radio<bool>(
                          value: true,
                          groupValue: _isSelfDraw,
                          onChanged: (bool? value) {
                            if (value != null && !_isSelfDraw) {
                              setState(() {
                                _isSelfDraw = value;
                                _ensureValidDiscardPlayer();
                                // If manual mode (no tiles selected), adjust fan count
                                if (_selectedTiles.isEmpty) {
                                  _fanCount = (_fanCount + 1).clamp(0, 13);
                                }
                              });
                              _calculateFanFromTiles(); // Recalculate if tiles selected
                              _calculateScore();
                            }
                          },
                        ),
                        const Text('Self-Draw'),
                        const SizedBox(width: 24),
                        Radio<bool>(
                          value: false,
                          groupValue: _isSelfDraw,
                          onChanged: (bool? value) {
                            if (value != null && _isSelfDraw) {
                              setState(() {
                                _isSelfDraw = value;
                                _ensureValidDiscardPlayer();
                                // If manual mode (no tiles selected), adjust fan count
                                if (_selectedTiles.isEmpty) {
                                  _fanCount = (_fanCount - 1).clamp(0, 13);
                                }
                              });
                              _calculateFanFromTiles(); // Recalculate if tiles selected
                              _calculateScore();
                            }
                          },
                        ),
                        const Text('Discard'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Winning player selection
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Winning Player',
                        border: OutlineInputBorder(),
                      ),
                      value: _winningPlayer,
                      items: widget.players.map((player) {
                        return DropdownMenuItem<String>(
                          value: player.name,
                          child: Text('${player.name} (Current: ${_getPlayerCurrentScore(player.name)} pts)'),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _winningPlayer = newValue;
                            _updateSeatWind(notify: false);
                            _ensureValidDiscardPlayer();
                          });
                          _calculateFanFromTiles();
                          _calculateScore();
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Wind Selection Row
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Round Wind',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            ),
                            value: _roundWind,
                            items: _winds.map((wind) {
                              return DropdownMenuItem<String>(
                                value: wind,
                                child: Text(wind),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _roundWind = newValue;
                                  _calculateFanFromTiles(); // Recalculate fan
                                  _calculateScore();
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Seat Wind',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            ),
                            value: _seatWind,
                            items: _winds.map((wind) {
                              return DropdownMenuItem<String>(
                                value: wind,
                                child: Text(wind),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _seatWind = newValue;
                                  _calculateFanFromTiles(); // Recalculate fan
                                  _calculateScore();
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    // Discard player selection (only show when discard is selected)
                    if (!_isSelfDraw)
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Discard Player',
                          border: OutlineInputBorder(),
                        ),
                        value: _discardPlayer,
                        items: widget.players
                            .where((player) => player.name != _winningPlayer)
                            .map((player) {
                          return DropdownMenuItem<String>(
                            value: player.name,
                            child: Text('${player.name} (Current: ${_getPlayerCurrentScore(player.name)} pts)'),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _discardPlayer = newValue;
                            });
                          }
                        },
                      ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Fan count and score setup
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Fan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Fan count selection
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'Fan',
                        border: OutlineInputBorder(),
                      ),
                      value: _fanCount,
                      items: List.generate(14, (index) => index).map((fan) {
                        return DropdownMenuItem<int>(
                          value: fan,
                          child: Text('$fan fan'),
                        );
                      }).toList(),
                      onChanged: (int? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _fanCount = newValue;
                            _calculateScore();
                          });
                        }
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Flower Options Dropdown
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Flower Score',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedFlowerOption,
                      items: _flowerOptions.map((option) {
                        return DropdownMenuItem<String>(
                          value: option,
                          child: Text(option),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedFlowerOption = newValue;
                            // Auto-set self-draw for instant win hands
                            if (newValue == 'Flower Hand' || newValue == 'Eight Immortals') {
                              _isSelfDraw = true;
                            }
                            _calculateScore();
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 16),

                    // Special Winning Conditions Dropdown
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Special Winning Condition',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedSpecialCondition,
                      items: _specialConditions.map((condition) {
                        return DropdownMenuItem<String>(
                          value: condition,
                          child: Text(condition),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedSpecialCondition = newValue;
                            // Enforce constraints
                            if (newValue == 'Heavenly Hand') {
                              _isSelfDraw = true;
                            } else if (newValue == 'Earthly Hand') {
                              _isSelfDraw = false;
                            }
                            _calculateScore();
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Take photo to get hand pattern button
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Scan Tiles'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: _captureImage,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.grid_view),
                    label: const Text('Select Hand'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: _selectHand,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Hand preview area
            Card(
              child: InkWell(
                onTap: _selectHand,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hand Preview Area',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_capturedImage != null)
                        Container(
                          height: 120,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: FileImage(_capturedImage!),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        )
                      else if (_selectedTiles.isNotEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 67, 125, 49),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green.shade900, width: 2),
                          ),
                          child: Wrap(
                            spacing: 4,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children: _selectedTiles.map((tile) {
                              return Image.asset(
                                _getAssetPath(tile),
                                width: 30,
                                height: 42,
                                fit: BoxFit.contain,
                              );
                            }).toList(),
                          ),
                        )
                      else
                        Container(
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text(
                              'Take photo or click to select hand pattern',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Score summary area
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Score Calculation',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Score details list
                    DataTable(
                      columns: const [
                        DataColumn(label: Text('Item')),
                        DataColumn(label: Text('Value')),
                      ],
                      rows: [
                        // Matched Rules (Use _displayRules instead of _matchedRulesDetails)
                        ..._displayRules.map((rule) => DataRow(cells: [
                          DataCell(Text(rule['name'])),
                          DataCell(Text('${rule['fan']} fan')),
                        ])),
                        
                        // Self-Draw (Manual mode or not captured in matched rules)
                        if (_isSelfDraw && 
                            !_displayRules.any((r) => r['name'] == 'Self-Draw') &&
                            !['Flower Hand', 'Eight Immortals'].contains(_selectedFlowerOption) &&
                            _selectedSpecialCondition != 'Heavenly Hand')
                          const DataRow(cells: [
                            DataCell(Text('Self-Draw')),
                            DataCell(Text('+1 Fan')),
                          ]),

                        // Flower Option Display
                        if (_selectedFlowerOption != 'Flowers (No Score)')
                          DataRow(cells: [
                            DataCell(Text(_selectedFlowerOption)),
                            DataCell(Text(_getFlowerFanText(_selectedFlowerOption))),
                          ]),

                        // Special Condition Display
                        // Hide Men Qian Qing if it was merged into Hidden Treasure
                        if (_selectedSpecialCondition != 'None' && 
                            !(_selectedSpecialCondition == 'Men Qian Qing' && _displayRules.any((r) => r['name'] == 'Hidden Treasure')))
                          DataRow(cells: [
                            DataCell(Text(_selectedSpecialCondition)),
                            DataCell(Text(_getSpecialConditionFanText(_selectedSpecialCondition))),
                          ]),
                          
                        // Total Fan
                        DataRow(cells: [
                          const DataCell(Text('Total Fan', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataCell(Text(
                            '$_effectiveFan fan${_effectiveFan >= 13 ? ' (Limit)' : ''}', 
                            style: const TextStyle(fontWeight: FontWeight.bold)
                          )),
                        ]),
                        
                        // Total Score
                        DataRow(cells: [
                          const DataCell(Text('Total Score', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataCell(Text(
                            _isSelfDraw 
                              ? '$_totalPoints / person (Total ${_totalPoints * 3})' 
                              : '$_totalPoints points', 
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)
                          )),
                        ]),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Bottom action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: _submitScore,
                    child: const Text('Next Round', style: TextStyle(fontSize: 15)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.white 
                          : Colors.black,
                      side: BorderSide(
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? Colors.grey.shade600 
                            : Colors.grey.shade300,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () {
                      // Cancel calculation and return to previous page
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel', style: TextStyle(fontSize: 15)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Show help dialog
  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Scoring Guide'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text('1. Select dealer and wind'),
              SizedBox(height: 8),
              Text('2. Select winning method (self-draw or discard)'),
              SizedBox(height: 8),
              Text('3. Enter fan count and base score'),
              SizedBox(height: 8),
              Text('4. Select bonus items (self-draw, all-claim, etc.)'),
              SizedBox(height: 8),
              Text('5. Scan tiles or select manually'),
              SizedBox(height: 8),
              Text('6. Confirm score calculation'),
              SizedBox(height: 8),
              Text('7. Click "Next Round" to save and proceed to next round'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}