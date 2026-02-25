/// Utility functions for mahjong tile operations.
class TileUtils {
  /// Standard suit types: m (man/characters), p (pin/dots), s (sou/bamboo), z (honor)
  static const List<String> suits = ['m', 'p', 's', 'z'];

  /// Compare two tile codes for sorting.
  /// Tiles are sorted by suit (m < p < s < z) then by number.
  static int compareTiles(String a, String b) {
    String suitA = a.substring(1);
    String suitB = b.substring(1);
    int numA = int.parse(a.substring(0, 1));
    int numB = int.parse(b.substring(0, 1));

    int suitCompare = suits.indexOf(suitA).compareTo(suits.indexOf(suitB));
    if (suitCompare != 0) return suitCompare;
    return numA.compareTo(numB);
  }

  /// Sort a list of tile codes for display.
  static List<String> sortTiles(List<String> tiles) {
    List<String> sorted = List.from(tiles);
    sorted.sort(compareTiles);
    return sorted;
  }

  /// Build a frequency map from a list of tiles.
  static Map<String, int> buildTileCounts(List<String> tiles) {
    Map<String, int> counts = {};
    for (var tile in tiles) {
      counts[tile] = (counts[tile] ?? 0) + 1;
    }
    return counts;
  }

  /// Remove one instance of a tile from a frequency map.
  static void removeTile(Map<String, int> counts, String tile) {
    if (counts.containsKey(tile)) {
      counts[tile] = counts[tile]! - 1;
      if (counts[tile]! <= 0) {
        counts.remove(tile);
      }
    }
  }
}
