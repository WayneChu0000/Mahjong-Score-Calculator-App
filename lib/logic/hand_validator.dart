import '../localization/app_localizations.dart';
import '../models/game_mode.dart';
import '../logic/tw_pattern_evaluator.dart';
import 'hand_core.dart';
import 'hand_patterns.dart';
import 'tile_utils.dart';
import '../models/tw_hand.dart';

/// Validates whether a hand of tiles is a winning hand.
class HandValidator {
  /// Check if the hand is a winning hand.
  /// Returns a map with 'valid' (bool) and 'message' (String).
  static Map<String, dynamic> checkWinningHand(
    List<String> tiles, {
    GameMode gameMode = GameMode.hongKong,
  }) {
    // Sort tiles for easier processing
    tiles.sort(TileUtils.compareTiles);

    int count = tiles.length;
    int standardCount = gameMode == GameMode.taiwan ? 17 : 14;
    int kongsNeeded = count - standardCount;

    // Check range logic
    // HK: 14 (0 kongs) -> 18 (4 kongs)
    // TW: 17 (0 kongs) -> 21 (4 kongs)
    if (kongsNeeded < 0 || kongsNeeded > 4) {
      return {'valid': false, 'message': AppLocalizations.invalidTileCount};
    }

    // Frequency map
    Map<String, int> tileCounts = TileUtils.buildTileCounts(tiles);

    // Check for Special Hands (13 Orphans, 7 Pairs)
    // Must be exactly standardCount tiles
    if (count == standardCount) {
      // Check for Thirteen Orphans (HK only, 14 tiles)
      if (standardCount == 14) {
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

        if (uniqueTiles.length == 13 &&
            uniqueTiles.containsAll(requiredOrphans)) {
          return {
            'valid': true,
            'message': AppLocalizations.winningHandThirteenOrphans,
          };
        }
      }

      // TW special hands (17 tiles)
      if (gameMode == GameMode.taiwan) {
        // TW Thirteen Orphans (十三么): 13 orphans + pair + chow/pong
        final twHand = TwHand(concealedTiles: tiles.sublist(0, tiles.length - 1), winningTile: tiles.last);
        if (TwPatternEvaluator.isTwThirteenOrphans(twHand)) {
          return {'valid': true, 'message': AppLocalizations.winningHandThirteenOrphans};
        }

        // Sixteen Non-Matching (十六不搭)
        if (TwPatternEvaluator.isSixteenNonMatching(tiles)) {
          return {'valid': true, 'message': AppLocalizations.winningHandSixteenNonMatching};
        }
      }

      // Seven Pairs (HK) / Eight Pairs (TW)
      if (gameMode == GameMode.taiwan && HandPatterns.isEightPairs(tiles)) {
        return {'valid': true, 'message': AppLocalizations.ruleMigui};
      } else if (gameMode == GameMode.hongKong &&
          HandPatterns.isSevenPairs(tiles)) {
        return {'valid': true, 'message': AppLocalizations.ruleSevenPairs};
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
        if (HandCore.checkSets(currentCounts, kongsNeeded)) {
          return {'valid': true, 'message': AppLocalizations.winningHand};
        }
      }
    }

    return {'valid': false, 'message': AppLocalizations.winningHandInvalid};
  }
}
