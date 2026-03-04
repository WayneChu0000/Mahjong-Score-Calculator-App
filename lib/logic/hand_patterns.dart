import 'hand_core.dart';
import 'tile_utils.dart';

/// Pattern recognition for specific mahjong hand types.
class HandPatterns {
  // =============================================
  //  Taiwan-Specific Patterns
  // =============================================

  /// TW: Eye of 2, 5, 8 (將眼)
  /// Returns true if any valid decomposition has a pair of 2, 5, or 8.
  static bool hasEyeOf258(List<String> tiles) {
    Map<String, int> tileCounts = TileUtils.buildTileCounts(tiles);

    int count = tiles.length;
    int kongsNeeded14 = count - 14;
    int kongsNeeded17 = count - 17;

    for (var tile in tileCounts.keys) {
      if (tileCounts[tile]! < 2) continue;
      String suit = tile.substring(1);
      int num = int.parse(tile.substring(0, 1));
      if (suit == 'z') continue; // Honor tiles are not 2/5/8
      if (num != 2 && num != 5 && num != 8) continue;

      Map<String, int> currentCounts = Map.from(tileCounts);
      currentCounts[tile] = currentCounts[tile]! - 2;
      if (currentCounts[tile] == 0) currentCounts.remove(tile);

      if (kongsNeeded14 >= 0 &&
          kongsNeeded14 <= 4 &&
          HandCore.checkSets(Map.from(currentCounts), kongsNeeded14)) {
        return true;
      }
      if (kongsNeeded17 >= 0 &&
          kongsNeeded17 <= 4 &&
          HandCore.checkSets(Map.from(currentCounts), kongsNeeded17)) {
        return true;
      }
    }
    return false;
  }

  /// TW: All Simples (斷么) - no terminals (1,9) and no honors
  static bool isAllSimples(List<String> tiles) {
    for (var tile in tiles) {
      String suit = tile.substring(1);
      int num = int.parse(tile.substring(0, 1));
      if (suit == 'z') return false; // Honor tile
      if (num == 1 || num == 9) return false; // Terminal
    }
    return true;
  }

  /// TW: Concealed Dragon (暗龍) - all 1-9 of one suit concealed in hand
  static bool isConcealedDragon(List<String> tiles) {
    for (String suit in ['m', 'p', 's']) {
      bool hasAll = true;
      for (int n = 1; n <= 9; n++) {
        if (!tiles.contains('$n$suit')) {
          hasAll = false;
          break;
        }
      }
      if (hasAll) return true;
    }
    return false;
  }

  // =============================================
  //  Pair-Based Patterns
  // =============================================

  /// 8 Fan: Seven Pairs (HK - 14 tiles)
  static bool isSevenPairs(List<String> tiles) {
    if (tiles.length != 14) return false;
    Map<String, int> counts = TileUtils.buildTileCounts(tiles);
    int pairs = 0;
    for (var c in counts.values) {
      pairs += c ~/ 2;
    }
    return pairs == 7;
  }

  /// 8 Tai: Migui / Eight Pairs (TW - 17 tiles)
  static bool isEightPairs(List<String> tiles) {
    if (tiles.length != 17) return false;
    Map<String, int> counts = TileUtils.buildTileCounts(tiles);
    int pairs = 0;
    for (var c in counts.values) {
      pairs += c ~/ 2;
    }
    return pairs == 8;
  }

  // =============================================
  //  Basic Hand Patterns
  // =============================================

  /// 1 Fan: Ping Hu (All Chows) - hand formed entirely by chows + one pair
  static bool isPingHu(List<String> tiles) {
    return HandCore.checkSpecificHand(tiles, allowChow: true, allowPong: false);
  }

  /// Taiwan Ping Hu (strict version)
  static bool isTaiwanPingHu(List<String> tiles) {
    return isPingHu(tiles);
  }

  /// 3 Fan: Mixed One Suit / Half Flush (混一色)
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
    return suit != null; // Must have at least one suit tile
  }

  /// 3 Fan: All Pongs / Dui Dui Hu (對對胡)
  static bool isAllPongs(List<String> tiles) {
    return HandCore.checkSpecificHand(tiles, allowChow: false, allowPong: true);
  }

  /// 4 Fan: Mixed Terminals / Hua Yao Jiu (花么九)
  static bool isMixedTerminals(List<String> tiles) {
    // Must be All Pongs structure
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
    // Must have both terminals and honors
    return hasHonor && hasTerminal;
  }

  // =============================================
  //  Dragon Patterns
  // =============================================

  /// 5 Fan: Small Three Dragons (小三元)
  static bool isSmallThreeDragons(List<String> tiles) {
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

    return pongs == 2 && pairs == 3 && counts.length == 3;
  }

  /// 8 Fan: Big Three Dragons (大三元)
  static bool isBigThreeDragons(List<String> tiles) {
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

  // =============================================
  //  Flush Patterns
  // =============================================

  /// 7 Fan: Pure One Suit / Qing Yi Se (清一色)
  static bool isPureHand(List<String> tiles) {
    if (tiles.isEmpty) return false;
    String firstSuit = tiles.first.substring(1);
    if (firstSuit == 'z') return false; // Honor tiles cannot form Pure Hand
    return tiles.every((t) => t.substring(1) == firstSuit);
  }

  // =============================================
  //  Wind Patterns
  // =============================================

  /// 6 Fan: Small Four Winds (小四喜)
  static bool isSmallFourWinds(List<String> tiles) {
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

  /// 13 Fan: Big Four Winds (大四喜)
  static bool isBigFourWinds(List<String> tiles) {
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

  // =============================================
  //  Honor / Terminal Patterns
  // =============================================

  /// 10 Fan: All Honors (字一色)
  static bool isAllHonors(List<String> tiles) {
    if (!tiles.every((t) => t.endsWith('z'))) return false;
    return true;
  }

  /// 10 Fan: Pure Terminals (清么九)
  static bool isPureTerminals(List<String> tiles) {
    for (var tile in tiles) {
      if (tile.endsWith('z')) return false;
      int num = int.parse(tile.substring(0, 1));
      if (num != 1 && num != 9) return false;
    }
    return true;
  }

  // =============================================
  //  Limit Hands
  // =============================================

  /// 10 Fan: Nine Gates (九蓮寶燈)
  static bool isNineGates(List<String> tiles) {
    if (!isPureHand(tiles)) return false;

    // Count distribution
    Map<int, int> counts = {};
    for (var t in tiles) {
      int num = int.parse(t.substring(0, 1));
      counts[num] = (counts[num] ?? 0) + 1;
    }

    // Check base requirements: 1×3, 9×3, and one of each 2-8
    if ((counts[1] ?? 0) < 3) return false;
    if ((counts[9] ?? 0) < 3) return false;
    for (int i = 2; i <= 8; i++) {
      if ((counts[i] ?? 0) < 1) return false;
    }

    // HK (14 tiles) or TW (17 tiles)
    if (tiles.length == 14 || tiles.length == 17) {
      return true;
    }
    return false;
  }

  /// 13 Fan: Thirteen Orphans (十三么)
  static bool isThirteenOrphans(List<String> tiles) {
    if (tiles.length != 14) return false;
    Set<String> uniqueTiles = tiles.toSet();
    Set<String> requiredOrphans = {
      '1m',
      '9m',
      '1p',
      '9p',
      '1s',
      '9s',
      '1z',
      '2z',
      '3z',
      '4z',
      '5z',
      '6z',
      '7z',
    };
    return uniqueTiles.length == 13 && uniqueTiles.containsAll(requiredOrphans);
  }

  /// 13 Fan: Eighteen Arhats (十八羅漢) - 4 Kongs + 1 Pair
  static bool isEighteenArhats(List<String> tiles) {
    // HK: 18 tiles, TW: 21 tiles
    if (tiles.length == 18 || tiles.length == 21) {
      return true;
    }
    return false;
  }
}
