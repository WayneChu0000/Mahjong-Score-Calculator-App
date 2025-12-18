import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async'; // Add this line to import StreamSubscription
import 'package:image_picker/image_picker.dart';

class ScoreCalculationScreen extends StatefulWidget {
  final List<String> players;
  final String? groupName;

  const ScoreCalculationScreen({
    super.key,
    required this.players,
    this.groupName,
  });

  @override
  State<ScoreCalculationScreen> createState() => _ScoreCalculationScreenState();
}

class _ScoreCalculationScreenState extends State<ScoreCalculationScreen> {
  // Currently selected player and wind direction
  late String _selectedDealer;
  String _selectedWind = 'East';
  
  // Winning method
  bool _isSelfDraw = true;
  String? _winningPlayer;
  String? _discardPlayer;
  
  // Fan count and score
  int _fanCount = 1;
  int _basePoints = 1;
  bool _selfDrawBonus = false;
  bool _fullHouseBonus = false;
  int _flowerCount = 0;
  
  // Hand preview
  File? _capturedImage;
  
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
    for (String player in widget.players) {
      _playerScores[player] = 0;
    }
    
    // Default select first player as dealer
    _selectedDealer = widget.players.isNotEmpty ? widget.players[0] : "Player 1";
    _winningPlayer = _selectedDealer;
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

  // Calculate score
  void _calculateScore() {
    // Basic score calculation
    int baseScore = _basePoints;
    
    // Calculate fan (power of 2)
    int fanMultiplier = 1;
    for (int i = 0; i < _fanCount; i++) {
      fanMultiplier *= 2;
    }
    
    // Add self-draw bonus
    int selfDrawBonus = _selfDrawBonus ? 1 : 0;
    
    // Add all-claim bonus
    int fullHouseBonus = _fullHouseBonus ? 1 : 0;
    
    // Add flower tile score
    int flowerPoints = _flowerCount;
    
    // Calculate total score
    _totalPoints = baseScore * fanMultiplier + selfDrawBonus + fullHouseBonus + flowerPoints;
    
    setState(() {});
  }

  // Take photo to get hand pattern
  Future<void> _captureImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    
    if (image != null) {
      setState(() {
        _capturedImage = File(image.path);
        // In actual application, should have image recognition logic to parse mahjong tiles
        // Image processing and hand recognition will be implemented in future versions
      });
    }
  }

  // Submit score
  void _submitScore() {
    Map<String, int> scoreChanges = {};
    
    // Calculate score changes based on self-draw or discard
    if (_isSelfDraw && _winningPlayer != null) {
      // Self-draw: all other players lose points
      for (var player in widget.players) {
        if (player != _winningPlayer) {
          // When self-draw, all other players lose same points
          scoreChanges[player] = -_totalPoints;
        }
      }
      // Winner gets all points
      scoreChanges[_winningPlayer!] = _totalPoints * (widget.players.length - 1);
    } else if (!_isSelfDraw && _winningPlayer != null && _discardPlayer != null) {
      // Discard: only the discarder loses points
      scoreChanges[_discardPlayer!] = -_totalPoints;
      scoreChanges[_winningPlayer!] = _totalPoints;
    }
    
    // Update scores in score service
    // widget.scoreService.updateScores(scoreChanges);
    
    // Increase round count
    // widget.scoreService.incrementRound();
    
    // Call callback function to update score
    // widget.onScoreSubmitted(scoreChanges);
    
    // Show successful submission message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Score updated, next round')),
    );
    
    // Return to previous page
    Navigator.pop(context);
  }

  // Get player's current score
  int _getPlayerCurrentScore(String player) {
    return _playerScores[player] ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupName ?? 'Mahjong Scoring'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Player selection area
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dealer Setup',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Dealer selection dropdown
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Dealer',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedDealer,
                      items: widget.players.map((player) {
                        return DropdownMenuItem<String>(
                          value: player,
                          child: Text('$player (Current: ${_getPlayerCurrentScore(player)} pts)'),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedDealer = newValue;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    // Wind direction selection
                    const Text('Wind'),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Radio<String>(
                            value: 'East',
                            groupValue: _selectedWind,
                            onChanged: (String? value) {
                              if (value != null) {
                                setState(() {
                                  _selectedWind = value;
                                });
                              }
                            },
                          ),
                          const Text('East'),
                          Radio<String>(
                            value: 'South',
                            groupValue: _selectedWind,
                            onChanged: (String? value) {
                              if (value != null) {
                                setState(() {
                                  _selectedWind = value;
                                });
                              }
                            },
                          ),
                          const Text('South'),
                          Radio<String>(
                            value: 'West',
                            groupValue: _selectedWind,
                            onChanged: (String? value) {
                              if (value != null) {
                                setState(() {
                                  _selectedWind = value;
                                });
                              }
                            },
                          ),
                          const Text('West'),
                          Radio<String>(
                            value: 'North',
                            groupValue: _selectedWind,
                            onChanged: (String? value) {
                              if (value != null) {
                                setState(() {
                                  _selectedWind = value;
                                });
                              }
                            },
                          ),
                          const Text('North'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
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
                            if (value != null) {
                              setState(() {
                                _isSelfDraw = value;
                              });
                            }
                          },
                        ),
                        const Text('Self-Draw'),
                        const SizedBox(width: 24),
                        Radio<bool>(
                          value: false,
                          groupValue: _isSelfDraw,
                          onChanged: (bool? value) {
                            if (value != null) {
                              setState(() {
                                _isSelfDraw = value;
                              });
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
                          value: player,
                          child: Text('$player (Current: ${_getPlayerCurrentScore(player)} pts)'),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _winningPlayer = newValue;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    // Discard player selection (only show when discard is selected)
                    if (!_isSelfDraw)
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Discard Player',
                          border: OutlineInputBorder(),
                        ),
                        value: _discardPlayer ?? (_winningPlayer == widget.players[0] ? widget.players.length > 1 ? widget.players[1] : null : widget.players[0]),
                        items: widget.players
                            .where((player) => player != _winningPlayer)
                            .map((player) {
                          return DropdownMenuItem<String>(
                            value: player,
                            child: Text('$player (Current: ${_getPlayerCurrentScore(player)} pts)'),
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
                      items: List.generate(13, (index) => index + 1).map((fan) {
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
                    // Base score setup
                    const Text('Base Score:'),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SegmentedButton<int>(
                        segments: const [
                          ButtonSegment<int>(value: 1, label: Text('1 pt')),
                          ButtonSegment<int>(value: 2, label: Text('2 pt')),
                          ButtonSegment<int>(value: 4, label: Text('4 pt')),
                        ],
                        selected: {_basePoints},
                        onSelectionChanged: (Set<int> newSelection) {
                          setState(() {
                            _basePoints = newSelection.first;
                            _calculateScore();
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Additional bonus options
                    CheckboxListTile(
                      title: const Text('Self-Draw (+1)'),
                      value: _selfDrawBonus,
                      onChanged: (bool? value) {
                        setState(() {
                          _selfDrawBonus = value ?? false;
                          _calculateScore();
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    CheckboxListTile(
                      title: const Text('All-Claim (+1)'),
                      value: _fullHouseBonus,
                      onChanged: (bool? value) {
                        setState(() {
                          _fullHouseBonus = value ?? false;
                          _calculateScore();
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    // Flower tile count selection
                    const Text('Flower Tiles:'),
                    const SizedBox(height: 8),
                    // Use Wrap to solve overflow issue
                    Wrap(
                      spacing: 8,
                      children: [0, 1, 2, 3, 4].map((count) {
                        final isSelected = _flowerCount == count;
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _flowerCount = count;
                              _calculateScore();
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.green : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '$count',
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Take photo to get hand pattern button
            ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text('Scan Tiles'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: _captureImage,
            ),
            
            const SizedBox(height: 16),
            
            // Hand preview area
            Card(
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
                    else
                      Container(
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            'Take photo or select hand pattern to show preview',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                  ],
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
                        DataColumn(label: Text('Score')),
                      ],
                      rows: [
                        DataRow(cells: [
                          const DataCell(Text('Base Fan')),
                          DataCell(Text('$_basePoints')),
                        ]),
                        if (_fullHouseBonus)
                          const DataRow(cells: [
                            DataCell(Text('All-Claim')),
                            DataCell(Text('1')),
                          ]),
                        if (_selfDrawBonus)
                          const DataRow(cells: [
                            DataCell(Text('Self-Draw')),
                            DataCell(Text('1')),
                          ]),
                        if (_flowerCount > 0)
                          DataRow(cells: [
                            const DataCell(Text('Flowers')),
                            DataCell(Text('$_flowerCount')),
                          ]),
                        DataRow(cells: [
                          const DataCell(Text('Total', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataCell(Text('$_totalPoints points', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red))),
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
                      foregroundColor: Colors.black,
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