import 'tile_utils.dart';

/// Core structural hand-checking methods used by both HandValidator and HandPatterns.
class HandCore {
  /// Check if remaining tiles (as frequency map) can form valid sets of melds.
  /// [kongsNeeded] tracks how many kongs must be formed.
  static bool checkSets(Map<String, int> counts, int kongsNeeded,
      {bool allowChow = true, bool allowPong = true}) {
    // If no tiles left, we are done
    if (counts.isEmpty) return kongsNeeded == 0;

    // Get the first available tile (smallest)
    List<String> sortedKeys = counts.keys.toList();
    sortedKeys.sort(TileUtils.compareTiles);

    String firstTile = sortedKeys.first;
    int firstNum = int.parse(firstTile.substring(0, 1));
    String firstSuit = firstTile.substring(1);

    // 1. Try Kong (if needed)
    if (kongsNeeded > 0 && counts[firstTile]! >= 4) {
      Map<String, int> nextCounts = Map.from(counts);
      nextCounts[firstTile] = nextCounts[firstTile]! - 4;
      if (nextCounts[firstTile] == 0) nextCounts.remove(firstTile);

      if (checkSets(nextCounts, kongsNeeded - 1,
          allowChow: allowChow, allowPong: allowPong)) {
        return true;
      }
    }

    // 2. Try Pong
    if (allowPong && counts[firstTile]! >= 3) {
      Map<String, int> nextCounts = Map.from(counts);
      nextCounts[firstTile] = nextCounts[firstTile]! - 3;
      if (nextCounts[firstTile] == 0) nextCounts.remove(firstTile);

      if (checkSets(nextCounts, kongsNeeded,
          allowChow: allowChow, allowPong: allowPong)) {
        return true;
      }
    }

    // 3. Try Chow (only for suits m, p, s)
    if (allowChow && firstSuit != 'z') {
      String secondTile = '${firstNum + 1}$firstSuit';
      String thirdTile = '${firstNum + 2}$firstSuit';

      if (counts.containsKey(secondTile) && counts.containsKey(thirdTile)) {
        Map<String, int> nextCounts = Map.from(counts);

        TileUtils.removeTile(nextCounts, firstTile);
        TileUtils.removeTile(nextCounts, secondTile);
        TileUtils.removeTile(nextCounts, thirdTile);

        if (checkSets(nextCounts, kongsNeeded,
            allowChow: allowChow, allowPong: allowPong)) {
          return true;
        }
      }
    }

    return false;
  }

  /// Check if tiles form a valid hand with specific constraints on allowed set types.
  static bool checkSpecificHand(List<String> tiles,
      {required bool allowChow, required bool allowPong}) {
    int count = tiles.length;

    // Check Base 14 (HK standard)
    int kongsNeeded14 = count - 14;
    if (kongsNeeded14 >= 0 && kongsNeeded14 <= 4) {
      if (validateStructure(tiles, kongsNeeded14, allowChow, allowPong)) {
        return true;
      }
    }

    // Check Base 17 (TW standard)
    int kongsNeeded17 = count - 17;
    if (kongsNeeded17 >= 0 && kongsNeeded17 <= 4) {
      if (validateStructure(tiles, kongsNeeded17, allowChow, allowPong)) {
        return true;
      }
    }

    return false;
  }

  /// Validate that tiles can form a valid pair + melds structure.
  static bool validateStructure(
      List<String> tiles, int kongsNeeded, bool allowChow, bool allowPong) {
    Map<String, int> tileCounts = TileUtils.buildTileCounts(tiles);

    // Try every possible pair as eyes
    for (var tile in tileCounts.keys) {
      if (tileCounts[tile]! >= 2) {
        Map<String, int> currentCounts = Map.from(tileCounts);
        currentCounts[tile] = currentCounts[tile]! - 2;
        if (currentCounts[tile] == 0) currentCounts.remove(tile);

        if (checkSets(currentCounts, kongsNeeded,
            allowChow: allowChow, allowPong: allowPong)) {
          return true;
        }
      }
    }
    return false;
  }
}
