import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async'; // Add this line to import StreamSubscription
import 'package:image_picker/image_picker.dart';
import '../models/player.dart';
import 'tile_selection_screen.dart';
import '../utils/mahjong_logic.dart';
import '../models/rule.dart'; // Import Rule model
import 'rules_screen.dart';
import '../services/vision_service.dart'; // Import Vision Service
import '../localization/app_localizations.dart';

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
  final int _basePoints = 1;
  bool _selfDrawBonus = false;
  
  // Flower and Special Conditions
  // Use a map to track selected flowers. Keys are '1f'...'8f'. Values are true/false.
  final Map<String, bool> _selectedFlowers = {};
  String _selectedSpecialCondition = 'None';

/*
  final List<String> _flowerOptions = [
    'No Flower',
    'Flowers (No Score)',
    '1 Flower',
    '2 Flowers',
    '1 Flower + 1 Flower Platform',
    'Flower Hand',
    'Eight Immortals'
  ];
*/

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
  bool _isAnalyzing = false;
  List<String> _selectedTiles = [];
  List<Map<String, dynamic>> _matchedRulesDetails = []; // Store matched rules for display
  List<Map<String, dynamic>> _displayRules = []; // Final rules for display
  
  // Calculation result
  int _totalPoints = 0;
  
  // Player score mapping
  final Map<String, int> _playerScores = {};
  
  // Listen to score changes
  StreamSubscription? _scoreSubscription;

  String _getWindText(String wind) {
    switch (wind) {
      case 'East': return AppLocalizations.east;
      case 'South': return AppLocalizations.south;
      case 'West': return AppLocalizations.west;
      case 'North': return AppLocalizations.north;
      default: return wind;
    }
  }

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

  String _getLocalizedCondition(String condition) {
    switch (condition) {
      case 'None': return AppLocalizations.ruleNone;
      case 'Men Qian Qing': return AppLocalizations.ruleMenQianQing;
      case 'Robbing the Kong': return AppLocalizations.ruleRobbingKong;
      case 'Haidilao': return AppLocalizations.ruleHaidilao;
      case 'Kong on Kong/Flower': return AppLocalizations.ruleKongOnKong;
      case 'Heavenly Hand': return AppLocalizations.ruleHeavenlyHand;
      case 'Earthly Hand': return AppLocalizations.ruleEarthlyHand;
      default: return condition;
    }
  }

  String _getLocalizedWind(String wind) {
    switch (wind) {
      case 'East': return AppLocalizations.east;
      case 'South': return AppLocalizations.south;
      case 'West': return AppLocalizations.west;
      case 'North': return AppLocalizations.north;
      default: return wind;
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
    bool hasBigThreeDragons = matchedRules.any((r) => r['name'].toString().startsWith('Big Three Dragons'));
    bool hasSmallThreeDragons = matchedRules.any((r) => r['name'].toString().startsWith('Small Three Dragons'));

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
           String ruleName = '';
           if (entry.key == '5z') ruleName = AppLocalizations.rulePongOfWhite;
           if (entry.key == '6z') ruleName = AppLocalizations.rulePongOfGreen;
           if (entry.key == '7z') ruleName = AppLocalizations.rulePongOfRed;
           
           calculatedFan += 1;
           matchedRules.add({'name': ruleName, 'fan': 1});
         }
       }
    }

    // Check for Wind Pongs (Round Wind / Seat Wind)
    // Only if not Big/Small Four Winds
    bool hasBigFourWinds = matchedRules.any((r) => r['name'].toString().startsWith('Big Four Winds'));
    bool hasSmallFourWinds = matchedRules.any((r) => r['name'].toString().startsWith('Small Four Winds'));

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
        matchedRules.add({'name': '${AppLocalizations.ruleRoundWind} (${_getLocalizedWind(_roundWind)})', 'fan': 1});
      }

      // Check Seat Wind
      if ((windCounts[seatWindTile] ?? 0) >= 3) {
        calculatedFan += 1;
        matchedRules.add({'name': '${AppLocalizations.ruleSeatWind} (${_getLocalizedWind(_seatWind)})', 'fan': 1});
      }
    }

    // Add Self-Draw fan if applicable
    if (_isSelfDraw) {
      // Only add self-draw fan if NOT a special instant win hand that includes self-draw
      bool isSpecialHand = _selectedFlowers.values.where((v) => v).length >= 7 || 
                           _selectedSpecialCondition == 'Heavenly Hand';
      
      if (!isSpecialHand) {
        calculatedFan += 1;
        matchedRules.add({'name': AppLocalizations.ruleSelfDraw, 'fan': 1});
      }
    }
    
    // Calculate Flower Fan for "Auto Fan Calculation" mode (when tiles are selected)
    // Note: This logic is also duplicated/used in _calculateScoreInternal for final display
    // But we include it here to update _fanCount if in pure auto mode.
    // Actually, usually Flowers are added ON TOP of the hand's fan.
    // Let's assume _fanCount tracks the Hand patterns only?
    // Current design: _fanCount is the base. _calculateScore adds extras.
    // But if we are in auto-calculate mode, we might want to include them in _fanCount directly.
    // However, keeping them separate (Base Fan vs Bonus Fan) is safer.
    // So we will NOT add flower fan here to _fanCount unless we want to merge them.
    // Let's follow existing pattern: _fanCount is primarily from _calculateFanFromTiles (Hand Patterns).
    // The previous code reset _fanCount entirely here.
    
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
    bool hasAllPongs = _displayRules.any((r) => r['name'] == AppLocalizations.ruleAllPongs);
    bool isMenQianQing = _selectedSpecialCondition == 'Men Qian Qing'; // Selected value, check if this is localized in dropdown or internal value
    // Actually _selectedSpecialCondition values are hardcoded English in the list definition above:
    // final List<String> _specialConditions = ['None', 'Men Qian Qing', ...];
    // So checking against 'Men Qian Qing' string literal is CORRECT.

    if (hasAllPongs && isMenQianQing) {
      // Remove All Pongs (3 fan)
      _displayRules.removeWhere((r) => r['name'] == AppLocalizations.ruleAllPongs);
      // Add Hidden Treasure (8 fan)
      _displayRules.add({'name': AppLocalizations.ruleHiddenTreasure, 'fan': 8});
      
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
        _displayRules.add({'name': AppLocalizations.ruleHeavenlyHand, 'fan': 13});
      } else if (_selectedSpecialCondition == 'Earthly Hand') {
        effectiveFan = 13;
        _displayRules.add({'name': AppLocalizations.ruleEarthlyHand, 'fan': 13});
      }
    }
    
    // Add self-draw bonus (usually +1 fan)
    if (_selfDrawBonus) effectiveFan += 1;
    
    // Handle Flower Logic (New)
    int flowerFan = 0;
    List<String> flowerDisplayNames = [];
    
    int flowerCount = _selectedFlowers.values.where((v) => v).length;
    
    if (flowerCount == 0) {
       // "No Flowers" rule (1 Fan)
       // Usually only valid if the hand has NO flowers at all
       flowerFan += 1;
       flowerDisplayNames.add("No Flowers");
       effectiveFan += flowerFan;
    } else if (flowerCount == 7) {
       // Flower Hand (3 Fan / Instant Win)
       // Overrides normal flower counting
       // Let's assume it sets the base.
       _displayRules = [{'name': AppLocalizations.ruleSevenFlowers, 'fan': 3}];
       effectiveFan = 3;
       flowerFan = 0; // Handled
    } else if (flowerCount == 8) {
       // Eight Immortals (8 Fan / Limit)
       _displayRules = [{'name': AppLocalizations.ruleEightImmortals, 'fan': 8}];
       effectiveFan = 8;
       flowerFan = 0; // Handled
    } else {
       // Check "Own Flower"
       // Seat Wind: East(1z), South(2z), West(3z), North(4z)
       int seatIndex = 0; // 1-based index (1..4)
       if (_seatWind == 'East') seatIndex = 1;
       else if (_seatWind == 'South') seatIndex = 2;
       else if (_seatWind == 'West') seatIndex = 3;
       else if (_seatWind == 'North') seatIndex = 4;
       
       String ownFlower = '${seatIndex}f'; // 1f..4f corresponds to winds implicitly in numbering
       String ownSeason = '${seatIndex + 4}f'; // 5f..8f
       
       // Handle Flower Set (1-4)
       // Check "Flower Platform" (All 1-4)
       bool hasFlowers1to4 = true;
       for (int i=1; i<=4; i++) {
           if (_selectedFlowers['${i}f'] != true) hasFlowers1to4 = false;
       }
       
       if (hasFlowers1to4) {
           flowerFan += 2;
           flowerDisplayNames.add("Flower Platform (1-4)");
       } else {
           // Only count Own Flower if Platform condition is NOT met
           if (_selectedFlowers[ownFlower] == true) {
               flowerFan += 1;
               flowerDisplayNames.add("Own Flower");
           }
       }

       // Handle Season Set (5-8)
       bool hasSeasons1to4 = true;
       for (int i=5; i<=8; i++) {
           if (_selectedFlowers['${i}f'] != true) hasSeasons1to4 = false;
       }
       
       if (hasSeasons1to4) {
           flowerFan += 2;
           flowerDisplayNames.add("Flower Platform (5-8)");
       } else {
           // Only count Own Season if Platform condition is NOT met
           if (_selectedFlowers[ownSeason] == true) {
               flowerFan += 1;
               flowerDisplayNames.add("Own Season");
           }
       }
       
       // Add specific flower fan to effective fan
       effectiveFan += flowerFan;
    }

    // Cap at 13 fan
    if (effectiveFan > 13) effectiveFan = 13;

    _effectiveFan = effectiveFan; // Store for display

    // Lookup score from table
    int discardScore = _getScoreFromFan(effectiveFan);
    
    // Determine if it counts as self-draw for scoring purposes
    bool countsAsSelfDraw = _isSelfDraw;
    if (flowerCount >= 7 || _selectedSpecialCondition == 'Heavenly Hand') {
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
      case 'Men Qian Qing': return '+${AppLocalizations.fan(1)}';
      case 'Robbing the Kong': return '+${AppLocalizations.fan(1)}';
      case 'Haidilao': return '+${AppLocalizations.fan(1)}';
      case 'Kong on Kong/Flower': return '+${AppLocalizations.fan(2)}';
      case 'Heavenly Hand': return '${AppLocalizations.fan(13)} (${AppLocalizations.limit})';
      case 'Earthly Hand': return '${AppLocalizations.fan(13)} (${AppLocalizations.limit})';
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
        _isAnalyzing = true;
      });

      try {
        final detectedTiles = await VisionService.analyzeImage(_capturedImage!);
        
        // Sort tiles: suit (m, p, s, z, f) then value
        detectedTiles.sort((a, b) {
          if (a.length < 2 || b.length < 2) return a.compareTo(b);
          final suitA = a.substring(a.length - 1);
          final suitB = b.substring(b.length - 1);
          final valA = a.substring(0, a.length - 1);
          final valB = b.substring(0, b.length - 1);
          
          if (suitA != suitB) {
            const order = ['m', 'p', 's', 'z', 'f'];
            int idxA = order.indexOf(suitA);
            int idxB = order.indexOf(suitB);
            if (idxA == -1) idxA = 99;
            if (idxB == -1) idxB = 99;
            return idxA.compareTo(idxB);
          }
          return valA.compareTo(valB);
        });

        if (mounted) {
          setState(() {
            _selectedTiles = detectedTiles;
            _isAnalyzing = false;
          });
          _calculateFanFromTiles();
          _calculateScore();
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isAnalyzing = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to analyze tiles: $e')),
          );
        }
      }
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
      case 'm': folder = 'characters'; break;
      case 'p': folder = 'dots'; break;
      case 's': folder = 'bamboo'; break;
      case 'z': folder = 'honors'; break;
      case 'f': folder = 'flowers'; break;
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
    Navigator.pop(context, {
      'scores': scoreChanges,
      'winningPlayer': _winningPlayer,
      'isSelfDraw': _isSelfDraw,
      'discardPlayer': _isSelfDraw ? null : _discardPlayer,
      'totalPoints': _totalPoints,
    });
  }

  // // Get player's current score
  // int _getPlayerCurrentScore(String player) {
  //   return _playerScores[player] ?? 0;
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupName ?? AppLocalizations.scoreCalculation),
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
                    Text(
                      AppLocalizations.win,
                      style: const TextStyle(
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
                        Text(AppLocalizations.selfDraw),
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
                        Text(AppLocalizations.discard),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Winning player selection
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: AppLocalizations.winningPlayer,
                        border: const OutlineInputBorder(),
                      ),
                      initialValue: _winningPlayer,
                      items: widget.players.map((player) {
                        return DropdownMenuItem<String>(
                          value: player.name,
                          child: Text('${player.name} ${AppLocalizations.currentScore(_getPlayerCurrentScore(player.name))}'),
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
                            decoration: InputDecoration(
                              labelText: AppLocalizations.roundWind,
                              border: const OutlineInputBorder(),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            ),
                            initialValue: _roundWind,
                            items: _winds.map((wind) {
                              return DropdownMenuItem<String>(
                                value: wind,
                                child: Text(_getWindText(wind)),
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
                            decoration: InputDecoration(
                              labelText: AppLocalizations.seatWind,
                              border: const OutlineInputBorder(),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            ),
                            initialValue: _seatWind,
                            items: _winds.map((wind) {
                              return DropdownMenuItem<String>(
                                value: wind,
                                child: Text(_getWindText(wind)),
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
                    
// Flower selection moved to Hand Preview area
                    // Discard player selection (only show when discard is selected)
                    if (!_isSelfDraw)
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: AppLocalizations.discardPlayer,
                          border: const OutlineInputBorder(),
                        ),
                        initialValue: _discardPlayer,
                        items: widget.players
                            .where((player) => player.name != _winningPlayer)
                            .map((player) {
                          return DropdownMenuItem<String>(
                            value: player.name,
                            child: Text('${player.name} ${AppLocalizations.currentScore(_getPlayerCurrentScore(player.name))}'),
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
                     Text(
                      AppLocalizations.fanTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Fan count selection
                    DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        labelText: AppLocalizations.fanTitle,
                        border: const OutlineInputBorder(),
                      ),
                      value: _effectiveFan,
                      items: List.generate(14, (index) => index).map((fan) {
                        return DropdownMenuItem<int>(
                          value: fan,
                          child: Text(AppLocalizations.fan(fan)),
                        );
                      }).toList(),
                      onChanged: (int? newValue) {
                        if (newValue != null) {
                          setState(() {
                            // Adjust base fan to reach target total
                            int diff = newValue - _effectiveFan;
                            _fanCount = _fanCount + diff;
                            if (_fanCount < 0) _fanCount = 0;
                            _calculateScore();
                          });
                        }
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    /* Removed old Flower Options Dropdown
                    // Flower Options Dropdown
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Flower Score',
                        border: OutlineInputBorder(),
                      ),
                      initialValue: _selectedFlowerOption,
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
                    */

                    // Special Winning Conditions Dropdown
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: AppLocalizations.specialWinningCondition,
                        border: const OutlineInputBorder(),
                      ),
                      initialValue: _selectedSpecialCondition,
                      items: _specialConditions.map((condition) {
                        return DropdownMenuItem<String>(
                          value: condition,
                          child: Text(_getLocalizedCondition(condition)),
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
                    label: Text(AppLocalizations.scanTiles),
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
                    label: Text(AppLocalizations.selectHand),
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
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Text(
                      AppLocalizations.handPreviewArea,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: _selectHand,
                      child: _isAnalyzing
                        ? Container(
                            height: 120,
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const CircularProgressIndicator(),
                                const SizedBox(height: 16),
                                Text(AppLocalizations.analyzingTiles),
                              ],
                            ),
                          )
                        : _capturedImage != null
                          ? Container(
                              height: 120,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: FileImage(_capturedImage!),
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            )
                          : _selectedTiles.isNotEmpty
                            ? Container(
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
                                  children: [
                                    ..._selectedTiles.map((tile) {
                                      return Image.asset(
                                        _getAssetPath(tile),
                                        width: 30,
                                        height: 42,
                                        fit: BoxFit.contain,
                                      );
                                    }), 
                                    // Display selected flowers as visuals (not counted in tiles validator usually)
                                    ..._selectedFlowers.entries.where((e) => e.value).map((e) {
                                      return Image.asset(
                                        _getAssetPath(e.key), // Using 1f..8f
                                        width: 30,
                                        height: 42,
                                        fit: BoxFit.contain,
                                      );
                                    })
                                  ].toList(),
                                ),
                              )
                            : Container(
                                height: 120,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    AppLocalizations.takePhotoHint,
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ),
                              ),
                    ),

                    const SizedBox(height: 24),
                     Text(
                      AppLocalizations.selectFlowers,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Flowers 1-4
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(4, (index) {
                         int id = index + 1;
                         String key = '${id}f';
                         bool isSelected = _selectedFlowers[key] == true;
                         
                         return GestureDetector(
                           onTap: () {
                             setState(() {
                               _selectedFlowers[key] = !isSelected;
                               _calculateScore();
                             });
                           },
                           child: Container(
                             decoration: BoxDecoration(
                               border: isSelected 
                                  ? Border.all(color: Colors.amber, width: 3) 
                                  : Border.all(color: Colors.transparent, width: 3),
                               borderRadius: BorderRadius.circular(8),
                             ),
                             child: Opacity(
                               opacity: isSelected ? 1.0 : 0.5,
                               child: Image.asset(
                                 _getAssetPath(key),
                                 width: 45,
                                 height: 60,
                                 fit: BoxFit.contain,
                               ),
                             ),
                           ),
                         );
                      }),
                    ),
                    const SizedBox(height: 12),
                    // Flowers 5-8
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(4, (index) {
                         int id = index + 5;
                         String key = '${id}f';
                         bool isSelected = _selectedFlowers[key] == true;
                         
                         return GestureDetector(
                           onTap: () {
                             setState(() {
                               _selectedFlowers[key] = !isSelected;
                               _calculateScore();
                             });
                           },
                           child: Container(
                             decoration: BoxDecoration(
                               border: isSelected 
                                  ? Border.all(color: Colors.amber, width: 3) 
                                  : Border.all(color: Colors.transparent, width: 3),
                               borderRadius: BorderRadius.circular(8),
                             ),
                             child: Opacity(
                               opacity: isSelected ? 1.0 : 0.5,
                               child: Image.asset(
                                 _getAssetPath(key),
                                 width: 45,
                                 height: 60,
                                 fit: BoxFit.contain,
                               ),
                             ),
                           ),
                         );
                      }),
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
                     Text(
                      AppLocalizations.scoreCalculation,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Score details list
                    DataTable(
                      columns: [
                        DataColumn(label: Text(AppLocalizations.item)),
                        DataColumn(label: Text(AppLocalizations.value)),
                      ],
                      rows: [
                        // Matched Rules (Use _displayRules instead of _matchedRulesDetails)
                        ..._displayRules.map((rule) => DataRow(cells: [
                          DataCell(Text(rule['name'])),
                          DataCell(Text(AppLocalizations.fan(rule['fan'] as int))),
                        ])),
                        
                        // Self-Draw (Manual mode or not captured in matched rules)
                        if (_isSelfDraw && 
                            !_displayRules.any((r) => r['name'] == AppLocalizations.ruleSelfDraw) &&
                            _selectedFlowers.values.where((v) => v).length < 7 && // Not instant win flower hand
                            _selectedSpecialCondition != 'Heavenly Hand')
                           DataRow(cells: [
                            DataCell(Text(AppLocalizations.ruleSelfDraw)),
                            DataCell(Text('+ ${AppLocalizations.fan(1)}')), // Use fan format? +1 Fan
                          ]),

                        // Flower Display Logic (New)
                        // Iterate through the logic defined in _calculateScoreInternal implicitly or explicitly
                        // Actually, _calculateScoreInternal stores total fan in _effectiveFan but doesn't fill _displayRules for flowers.
                        // Let's add them here for display based on current selection state
                        
                        // We check the conditions again for display purposes solely in build method or update _displayRules
                        // Better to update _displayRules in _calculateScoreInternal but since we can't easily change that method output 
                        // without major refactor of this view logic (as it relies on _displayRules for table),
                        // let's add rows here based on state.
                        
                        // Display Own Flower (Only if not part of a platform)
                         if (() {
                             int seatIndex = 0;
                             if (_seatWind == 'East') seatIndex = 1; else if (_seatWind == 'South') seatIndex = 2;
                             else if (_seatWind == 'West') seatIndex = 3; else if (_seatWind == 'North') seatIndex = 4;
                             
                             // Check Platform 1-4
                             bool has1to4 = true;
                             for(int i=1;i<=4;i++) if(_selectedFlowers['${i}f']!=true) has1to4=false;
                             
                             // Check Own Flower (1-4)
                             bool hasOwnFlower = _selectedFlowers['${seatIndex}f'] == true;
                             
                             return hasOwnFlower && !has1to4 && _selectedFlowers.values.where((v) => v).length < 7;
                         }())
                           DataRow(cells: [
                            DataCell(Text(AppLocalizations.ruleOwnFlower)),
                            DataCell(Text(AppLocalizations.fan(1))),
                          ]),

                         // Display Own Season (Only if not part of a platform)
                         if (() {
                             int seatIndex = 0;
                             if (_seatWind == 'East') seatIndex = 1; else if (_seatWind == 'South') seatIndex = 2;
                             else if (_seatWind == 'West') seatIndex = 3; else if (_seatWind == 'North') seatIndex = 4;
                             
                             // Check Platform 5-8
                             bool has5to8 = true;
                             for(int i=5;i<=8;i++) if(_selectedFlowers['${i}f']!=true) has5to8=false;
                             
                             // Check Own Season (5-8) (East=5, South=6, West=7, North=8)
                             bool hasOwnSeason = _selectedFlowers['${seatIndex+4}f'] == true;
                             
                             return hasOwnSeason && !has5to8 && _selectedFlowers.values.where((v) => v).length < 7;
                         }())
                           DataRow(cells: [
                            DataCell(Text(AppLocalizations.ruleOwnSeason)),
                            DataCell(Text(AppLocalizations.fan(1))),
                          ]),

                        // Display No Flowers
                        if (_selectedFlowers.values.where((v) => v).isEmpty)
                           DataRow(cells: [
                            DataCell(Text(AppLocalizations.ruleNoFlowers)),
                            DataCell(Text(AppLocalizations.fan(1))),
                          ]),
                        
                        // Display Flower Platforms
                        if (() {
                           bool has1to4 = true;
                           for(int i=1;i<=4;i++) if(_selectedFlowers['${i}f']!=true) has1to4=false;
                           return has1to4 && _selectedFlowers.values.where((v) => v).length < 7;
                        }())
                            DataRow(cells: [
                            DataCell(Text(AppLocalizations.ruleFlowerPlatform14)),
                            DataCell(Text(AppLocalizations.fan(2))),
                          ]),

                        if (() {
                           bool has5to8 = true;
                           for(int i=5;i<=8;i++) if(_selectedFlowers['${i}f']!=true) has5to8=false;
                           return has5to8 && _selectedFlowers.values.where((v) => v).length < 7;
                        }())
                            DataRow(cells: [
                            DataCell(Text(AppLocalizations.ruleFlowerPlatform58)),
                            DataCell(Text(AppLocalizations.fan(2))),
                          ]),
                          
                        /* Removed old Flower Option Display
                        // Flower Option Display
                        if (_selectedFlowerOption != 'Flowers (No Score)')
                          DataRow(cells: [
                            DataCell(Text(_selectedFlowerOption)),
                            DataCell(Text(_getFlowerFanText(_selectedFlowerOption))),
                          ]),
                        */

                        // Special Condition Display
                        // Hide Men Qian Qing if it was merged into Hidden Treasure
                        if (_selectedSpecialCondition != 'None' && 
                            !(_selectedSpecialCondition == 'Men Qian Qing' && _displayRules.any((r) => r['name'] == AppLocalizations.ruleHiddenTreasure)))
                          DataRow(cells: [
                            DataCell(Text(_getLocalizedCondition(_selectedSpecialCondition))),
                            DataCell(Text(_getSpecialConditionFanText(_selectedSpecialCondition))),
                          ]),
                          
                        // Total Fan
                        DataRow(cells: [
                          DataCell(Text(AppLocalizations.totalFan, style: const TextStyle(fontWeight: FontWeight.bold))),
                          DataCell(Text(
                            AppLocalizations.fan(_effectiveFan) + (_effectiveFan >= 13 ? ' (${AppLocalizations.limit})' : ''), 
                            style: const TextStyle(fontWeight: FontWeight.bold)
                          )),
                        ]),
                        
                        // Total Score
                        DataRow(cells: [
                          DataCell(Text(AppLocalizations.totalScore, style: const TextStyle(fontWeight: FontWeight.bold))),
                          DataCell(
                            Container(
                              constraints: const BoxConstraints(maxWidth: 180), // Constrain width to ensure it doesn't overflow screen
                              child: Text(
                                _isSelfDraw 
                                  ? '$_totalPoints${AppLocalizations.perPerson} ${AppLocalizations.totalWin(_totalPoints * (widget.players.length - 1))}' 
                                  : '$_totalPoints ${AppLocalizations.points}', 
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                                softWrap: true,
                                overflow: TextOverflow.visible, 
                              ),
                            )
                          ),
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
                    child: Text(AppLocalizations.nextRound, style: const TextStyle(fontSize: 15)),
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
                    child: Text(AppLocalizations.cancel, style: const TextStyle(fontSize: 15)),
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