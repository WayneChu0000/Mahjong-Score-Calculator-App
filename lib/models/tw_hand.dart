/// Represents a Taiwan Mahjong hand split into three zones:
/// exposed melds, concealed tiles, and the single winning tile.
///
/// **Exposed melds** are declared sets on the table (chow, pong, kong).
/// **Concealed tiles** are the tiles still hidden in the player's hand.
/// **Winning tile** is the single tile that completes the hand.
///
/// The full hand for validation = all exposed tiles + concealed tiles + winning tile.
library;

/// The type of an exposed meld.
enum MeldType { chow, pong, kong, concealedKong }

/// A single exposed meld declared on the table.
class Meld {
  /// The type: chow (順子), pong (刻子), kong (明槓), or concealedKong (暗槓).
  final MeldType type;

  /// The tiles in this meld (3 for chow/pong, 4 for kong).
  final List<String> tiles;

  const Meld({required this.type, required this.tiles});

  /// Number of tiles in this meld.
  int get tileCount => tiles.length;

  /// Whether this is any kind of kong (明槓 or 暗槓).
  bool get isKong => type == MeldType.kong || type == MeldType.concealedKong;

  @override
  String toString() => '${type.name}($tiles)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Meld &&
          type == other.type &&
          tiles.length == other.tiles.length &&
          _listsEqual(tiles, other.tiles);

  @override
  int get hashCode => Object.hash(type, Object.hashAll(tiles));

  static bool _listsEqual(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// Full Taiwan Mahjong hand with exposed/concealed/winning tile zones.
class TwHand {
  /// Exposed melds on the table.
  final List<Meld> exposedMelds;

  /// Concealed tiles in the hand (not including the winning tile).
  final List<String> concealedTiles;

  /// The single winning tile (胡牌). Null if not yet set.
  final String? winningTile;

  /// Whether 叮 (ding / single-tile wait bonus) applies.
  final bool isDing;

  const TwHand({
    this.exposedMelds = const [],
    this.concealedTiles = const [],
    this.winningTile,
    this.isDing = false,
  });

  /// All exposed tiles flattened.
  List<String> get exposedTiles =>
      exposedMelds.expand((m) => m.tiles).toList();

  /// All tiles combined (exposed + concealed + winning tile).
  List<String> get allTiles => [
        ...exposedTiles,
        ...concealedTiles,
        if (winningTile != null) winningTile!,
      ];

  /// Number of tiles currently in the hand.
  int get totalTileCount => allTiles.length;

  /// Number of kongs declared (affects tile count validation).
  int get kongCount => exposedMelds.where((m) => m.isKong).length;

  /// Expected total tiles: 17 (base) + kongs.
  int get expectedTileCount => 17 + kongCount;

  /// Number of exposed pongs (for concealed-pong counting).
  int get exposedPongCount =>
      exposedMelds.where((m) => m.type == MeldType.pong).length;

  /// Number of exposed chows.
  int get exposedChowCount =>
      exposedMelds.where((m) => m.type == MeldType.chow).length;

  /// Number of exposed kongs (明槓).
  int get exposedKongCount =>
      exposedMelds.where((m) => m.type == MeldType.kong).length;

  /// Number of concealed kongs (暗槓).
  int get concealedKongCount =>
      exposedMelds.where((m) => m.type == MeldType.concealedKong).length;

  /// True if the hand has no exposed melds (門清).
  /// Kongs (both 明槓 and 暗槓) do NOT break 門清.
  bool get isFullyConcealed =>
      exposedMelds.every((m) => m.isKong);

  /// Count of concealed pongs found in concealed tiles + winning tile.
  /// A concealed pong = 3 identical tiles all in the concealed zone
  /// (or 2 in concealed + the winning tile completes the third).
  int get concealedPongCount {
    final tiles = [...concealedTiles, if (winningTile != null) winningTile!];
    final counts = <String, int>{};
    for (final t in tiles) {
      counts[t] = (counts[t] ?? 0) + 1;
    }
    return counts.values.where((c) => c >= 3).length;
  }

  /// True if the hand is complete (correct tile count + winning tile set).
  bool get isComplete =>
      winningTile != null && totalTileCount == expectedTileCount;

  /// Create a copy with modifications.
  TwHand copyWith({
    List<Meld>? exposedMelds,
    List<String>? concealedTiles,
    String? winningTile,
    bool? isDing,
    bool clearWinningTile = false,
  }) {
    return TwHand(
      exposedMelds: exposedMelds ?? this.exposedMelds,
      concealedTiles: concealedTiles ?? this.concealedTiles,
      winningTile: clearWinningTile ? null : (winningTile ?? this.winningTile),
      isDing: isDing ?? this.isDing,
    );
  }
}
