class MahjongLogic {
  // Tile types
  static const List<String> suits = ['m', 'p', 's', 'z'];
  
  // Check if the hand is a winning hand
  static Map<String, dynamic> checkWinningHand(List<String> tiles) {
    // Sort tiles for easier processing
    tiles.sort((a, b) {
      // Extract suit and number
      String suitA = a.substring(1);
      String suitB = b.substring(1);
      int numA = int.parse(a.substring(0, 1));
      int numB = int.parse(b.substring(0, 1));
      
      int suitCompare = suits.indexOf(suitA).compareTo(suits.indexOf(suitB));
      if (suitCompare != 0) {
        return suitCompare;
      }
      return numA.compareTo(numB);
    });

    int count = tiles.length;
    int kongsNeeded = count - 14;
    
    if (kongsNeeded < 0 || kongsNeeded > 4) {
      return {'valid': false, 'message': 'Invalid number of tiles. Must be 14, 15, 16, 17, or 18.'};
    }

    // Frequency map
    Map<String, int> tileCounts = {};
    for (var tile in tiles) {
      tileCounts[tile] = (tileCounts[tile] ?? 0) + 1;
    }

    // Check for Special Hands (13 Orphans, 7 Pairs)
    // Must be exactly 14 tiles
    if (count == 14) {
      // Check for Thirteen Orphans
      Set<String> uniqueTiles = tiles.toSet();
      Set<String> requiredOrphans = {
        '1m', '9m', '1p', '9p', '1s', '9s', 
        '1z', '2z', '3z', '4z', '5z', '6z', '7z'
      };
      
      if (uniqueTiles.length == 13 && uniqueTiles.containsAll(requiredOrphans)) {
         return {'valid': true, 'message': 'Winning Hand (Thirteen Orphans)!'};
      }
    }

    // Try every possible pair as eyes
    for (var tile in tileCounts.keys) {
      if (tileCounts[tile]! >= 2) {
        // Create a copy of counts to modify
        Map<String, int> currentCounts = Map.from(tileCounts);
        
        // Remove eyes
        currentCounts[tile] = currentCounts[tile]! - 2;
        if (currentCounts[tile] == 0) currentCounts.remove(tile);
        
        // Check if remaining can form sets
        if (_checkSets(currentCounts, kongsNeeded)) {
          return {'valid': true, 'message': 'Winning Hand!'};
        }
      }
    }

    return {'valid': false, 'message': 'Cannot form a winning hand (4 sets + 1 pair).'};
  }

  static bool _checkSets(Map<String, int> counts, int kongsNeeded, {bool allowChow = true, bool allowPong = true}) {
    // If no tiles left, we are done
    if (counts.isEmpty) return kongsNeeded == 0;

    // Get the first available tile (smallest)
    List<String> sortedKeys = counts.keys.toList();
    sortedKeys.sort((a, b) {
      String suitA = a.substring(1);
      String suitB = b.substring(1);
      int numA = int.parse(a.substring(0, 1));
      int numB = int.parse(b.substring(0, 1));
      int suitCompare = suits.indexOf(suitA).compareTo(suits.indexOf(suitB));
      if (suitCompare != 0) {
        return suitCompare;
      }
      return numA.compareTo(numB);
    });
    
    String firstTile = sortedKeys.first;
    int firstNum = int.parse(firstTile.substring(0, 1));
    String firstSuit = firstTile.substring(1);

    // 1. Try Kong (if needed)
    if (kongsNeeded > 0 && counts[firstTile]! >= 4) {
      Map<String, int> nextCounts = Map.from(counts);
      nextCounts[firstTile] = nextCounts[firstTile]! - 4;
      if (nextCounts[firstTile] == 0) nextCounts.remove(firstTile);
      
      if (_checkSets(nextCounts, kongsNeeded - 1, allowChow: allowChow, allowPong: allowPong)) {
        return true;
      }
    }

    // 2. Try Pong
    if (allowPong && counts[firstTile]! >= 3) {
      Map<String, int> nextCounts = Map.from(counts);
      nextCounts[firstTile] = nextCounts[firstTile]! - 3;
      if (nextCounts[firstTile] == 0) nextCounts.remove(firstTile);
      
      if (_checkSets(nextCounts, kongsNeeded, allowChow: allowChow, allowPong: allowPong)) {
        return true;
      }
    }

    // 3. Try Chow (only for suits m, p, s)
    if (allowChow && firstSuit != 'z') {
      String secondTile = '${firstNum + 1}$firstSuit';
      String thirdTile = '${firstNum + 2}$firstSuit';
      
      if (counts.containsKey(secondTile) && counts.containsKey(thirdTile)) {
        Map<String, int> nextCounts = Map.from(counts);
        
        _removeTile(nextCounts, firstTile);
        _removeTile(nextCounts, secondTile);
        _removeTile(nextCounts, thirdTile);
        
        if (_checkSets(nextCounts, kongsNeeded, allowChow: allowChow, allowPong: allowPong)) {
          return true;
        }
      }
    }

    return false;
  }

  static void _removeTile(Map<String, int> counts, String tile) {
    if (counts.containsKey(tile)) {
      counts[tile] = counts[tile]! - 1;
      if (counts[tile]! <= 0) {
        counts.remove(tile);
      }
    }
  }

  // --- Helper Checkers for Rules ---

  // 1 Fan: Ping Hu (All Chows)
  static bool isPingHu(List<String> tiles) {
    // No Pongs allowed.
    // Usually implies no Honor tiles as well (since honors can't chow).
    // But strictly "All Chows" means 4 chows + 1 pair.
    // If the pair is honor, it's debatable. Standard Ping Hu usually requires non-honor pair.
    // Let's check: No Pongs, No Honors.
    bool hasHonor = tiles.any((t) => t.substring(1) == 'z');
    if (hasHonor) return false;
    return _checkSpecificHand(tiles, allowChow: true, allowPong: false);
  }

  // 3 Fan: Mixed One Suit (Half Flush)
  static bool isMixedOneSuit(List<String> tiles) {
    if (tiles.isEmpty) return false;
    bool hasHonor = tiles.any((t) => t.substring(1) == 'z');
    if (!hasHonor) return false; // Must have honor tiles (otherwise it's Pure)
    
    String? suit;
    for (var tile in tiles) {
      String s = tile.substring(1);
      if (s != 'z') {
        if (suit == null) {
          suit = s;
        } else if (suit != s) {
          return false; // Mixed suits
        }
      }
    }
    return suit != null; // Must have at least one suit
  }

  // 3 Fan: All Pongs (Dui Dui Hu)
  static bool isAllPongs(List<String> tiles) {
    return _checkSpecificHand(tiles, allowChow: false, allowPong: true);
  }

  // 4 Fan: Mixed Terminals (Hua Yao Jiu)
  static bool isMixedTerminals(List<String> tiles) {
    // All Pongs/Pairs are 1/9 or Honors.
    // Must be All Pongs structure.
    if (!isAllPongs(tiles)) return false;
    
    bool hasHonor = false;
    bool hasTerminal = false;

    for (var tile in tiles) {
      String suit = tile.substring(1);
      int num = int.parse(tile.substring(0, 1));
      
      if (suit == 'z') {
        hasHonor = true;
      } else if (num == 1 || num == 9) {
        hasTerminal = true;
      } else {
        return false; // Found a non-terminal non-honor
      }
    }
    // Must have both terminals and honors (otherwise it's All Honors or Pure Terminals)
    return hasHonor && hasTerminal;
  }

  // 5 Fan: Small Three Dragons (Xiao San Yuan)
  static bool isSmallThreeDragons(List<String> tiles) {
    // 2 dragon pongs + 1 dragon pair
    Map<String, int> counts = {};
    for (var t in tiles) {
      if (t == '5z' || t == '6z' || t == '7z') {
        counts[t] = (counts[t] ?? 0) + 1;
      }
    }
    
    int pongs = 0;
    int pairs = 0;
    
    for (var count in counts.values) {
      if (count >= 3) pongs++;
      if (count >= 2) pairs++;
    }
    
    // Total 3 distinct dragons involved.
    // 2 pongs + 1 pair means pongs=2, pairs=3 (since pongs are also pairs).
    // But strictly: 2 counts >= 3, 1 count == 2.
    return pongs == 2 && pairs == 3 && counts.length == 3;
  }

  // 7 Fan: Pure One Suit (Qing Yi Se)
  static bool isPureHand(List<String> tiles) {
    if (tiles.isEmpty) return false;
    String firstSuit = tiles.first.substring(1);
    if (firstSuit == 'z') return false; // Honor tiles cannot form Pure Hand
    return tiles.every((t) => t.substring(1) == firstSuit);
  }

  // 8 Fan: Big Three Dragons (Da San Yuan)
  static bool isBigThreeDragons(List<String> tiles) {
    // 3 dragon pongs (5z, 6z, 7z)
    Map<String, int> counts = {};
    for (var t in tiles) {
      if (t == '5z' || t == '6z' || t == '7z') {
        counts[t] = (counts[t] ?? 0) + 1;
      }
    }
    
    int pongs = 0;
    for (var count in counts.values) {
      if (count >= 3) pongs++;
    }
    
    return pongs == 3;
  }

  // 6 Fan: Small Four Winds (Xiao Si Xi)
  static bool isSmallFourWinds(List<String> tiles) {
    // 3 wind pongs + 1 wind pair
    Map<String, int> counts = {};
    for (var t in tiles) {
      if (t.endsWith('z') && int.parse(t[0]) <= 4) {
        counts[t] = (counts[t] ?? 0) + 1;
      }
    }
    
    int pongs = 0;
    int pairs = 0;
    
    for (var count in counts.values) {
      if (count >= 3) pongs++;
      if (count >= 2) pairs++;
    }
    
    return pongs >= 3 && pairs >= 4 && counts.length == 4;
  }

  // 10 Fan: All Honors (Zi Yi Se)
  static bool isAllHonors(List<String> tiles) {
    // All tiles are honors
    if (!tiles.every((t) => t.endsWith('z'))) return false;
    // Must be All Pongs (since honors can't chow)
    // But checkWinningHand handles structure.
    // If it's a winning hand and all honors, it's All Honors.
    // (Except 7 pairs all honors? Yes, still All Honors).
    return true; 
  }

  // 10 Fan: Pure Terminals (Qing Yao Jiu)
  static bool isPureTerminals(List<String> tiles) {
    // All tiles are 1 or 9. No honors.
    for (var tile in tiles) {
      if (tile.endsWith('z')) return false;
      int num = int.parse(tile.substring(0, 1));
      if (num != 1 && num != 9) return false;
    }
    // Must be All Pongs structure (since 1-9 can't chow without 2-8)
    return true;
  }

  // 10 Fan: Nine Gates (Jiu Lian Bao Deng)
  static bool isNineGates(List<String> tiles) {
    // Must be Pure One Suit
    if (!isPureHand(tiles)) return false;
    
    // Must be 1112345678999 + X
    // Count distribution
    Map<int, int> counts = {};
    for (var t in tiles) {
      int num = int.parse(t.substring(0, 1));
      counts[num] = (counts[num] ?? 0) + 1;
    }
    
    // Check base requirements
    if ((counts[1] ?? 0) < 3) return false;
    if ((counts[9] ?? 0) < 3) return false;
    for (int i = 2; i <= 8; i++) {
      if ((counts[i] ?? 0) < 1) return false;
    }
    
    // If we have 111, 999, and 2-8, that's 13 tiles.
    // The 14th tile can be anything 1-9.
    // So total length is 14.
    return tiles.length == 14;
  }

  // 13 Fan: Big Four Winds (Da Si Xi)
  static bool isBigFourWinds(List<String> tiles) {
    // 4 wind pongs
    Map<String, int> counts = {};
    for (var t in tiles) {
      if (t.endsWith('z') && int.parse(t[0]) <= 4) {
        counts[t] = (counts[t] ?? 0) + 1;
      }
    }
    
    int pongs = 0;
    for (var count in counts.values) {
      if (count >= 3) pongs++;
    }
    
    return pongs == 4;
  }

  // 13 Fan: Thirteen Orphans (Shi San Yao)
  static bool isThirteenOrphans(List<String> tiles) {
    if (tiles.length != 14) return false;
    Set<String> uniqueTiles = tiles.toSet();
    Set<String> requiredOrphans = {
      '1m', '9m', '1p', '9p', '1s', '9s', 
      '1z', '2z', '3z', '4z', '5z', '6z', '7z'
    };
    return uniqueTiles.length == 13 && uniqueTiles.containsAll(requiredOrphans);
  }

  // 13 Fan: Eighteen Arhats (Shi Ba Luo Han)
  static bool isEighteenArhats(List<String> tiles) {
    // Requires 4 Kongs + 1 Pair = 18 tiles
    if (tiles.length != 18) return false;
    // Must be 4 sets + pair.
    // Since we have 18 tiles, checkWinningHand logic handles structure if we pass kongsNeeded=4.
    // But here we just check if we have 4 kongs?
    // Actually, the input `tiles` usually contains the full hand.
    // If the user selected 18 tiles, it implies 4 kongs.
    // We just need to check if it's a valid hand.
    // But `checkWinningHand` handles the structure.
    // We can just check length here.
    return true;
  }

  static bool _checkSpecificHand(List<String> tiles, {required bool allowChow, required bool allowPong}) {
    // Similar to checkWinningHand but with constraints
    int count = tiles.length;
    int kongsNeeded = count - 14;
    if (kongsNeeded < 0 || kongsNeeded > 4) return false;

    Map<String, int> tileCounts = {};
    for (var tile in tiles) tileCounts[tile] = (tileCounts[tile] ?? 0) + 1;

    // Try every possible pair as eyes
    for (var tile in tileCounts.keys) {
      if (tileCounts[tile]! >= 2) {
        Map<String, int> currentCounts = Map.from(tileCounts);
        currentCounts[tile] = currentCounts[tile]! - 2;
        if (currentCounts[tile] == 0) currentCounts.remove(tile);
        
        if (_checkSets(currentCounts, kongsNeeded, allowChow: allowChow, allowPong: allowPong)) {
          return true;
        }
      }
    }
    return false;
  }

  
  // Helper to sort tiles for display
  static List<String> sortTiles(List<String> tiles) {
    List<String> sorted = List.from(tiles);
    sorted.sort((a, b) {
      String suitA = a.substring(1);
      String suitB = b.substring(1);
      int numA = int.parse(a.substring(0, 1));
      int numB = int.parse(b.substring(0, 1));
      
      int suitCompare = suits.indexOf(suitA).compareTo(suits.indexOf(suitB));
      if (suitCompare != 0) return suitCompare;
      return numA.compareTo(numB);
    });
    return sorted;
  }
}
