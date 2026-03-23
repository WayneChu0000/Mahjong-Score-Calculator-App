import 'dart:math' show max;

import '../models/tw_hand.dart';
import 'tile_utils.dart';
import 'hand_core.dart';

/// Result of checking a single TW winning pattern.
class TwPatternMatch {
  /// Internal pattern ID (used for exclusion logic).
  final String id;

  /// Localization key for the pattern name.
  final String nameKey;

  /// Tai value awarded.
  final int tai;

  const TwPatternMatch({
    required this.id,
    required this.nameKey,
    required this.tai,
  });

  @override
  String toString() => '$id ($tai tai)';
}

/// Result of running the full TW hand evaluation.
class TwEvalResult {
  /// All matched patterns before exclusion.
  final List<TwPatternMatch> rawMatches;

  /// Patterns after applying exclusion rules.
  final List<TwPatternMatch> finalMatches;

  /// Total tai after exclusions.
  final int totalTai;

  const TwEvalResult({
    required this.rawMatches,
    required this.finalMatches,
    required this.totalTai,
  });
}

/// Pure-logic TW Mahjong pattern evaluator.
///
/// Takes a [TwHand] (with exposed/concealed/winning tile context)
/// and produces a list of matched patterns with tai values,
/// then applies exclusion rules.
class TwPatternEvaluator {
  TwPatternEvaluator._();

  /// Public: Check TW Thirteen Orphans (十三么) for hand validation.
  static bool isTwThirteenOrphans(TwHand hand) => _isTwThirteenOrphans(hand);

  /// Public: Check Sixteen Non-Matching (十六不搭) for hand validation.
  static bool isSixteenNonMatching(List<String> tiles) => _isSixteenNonMatching(tiles);

  /// Evaluate a TW hand and return all matched patterns with exclusions.
  ///
  /// [hand] — the hand zones (exposed, concealed, winning tile).
  /// [isSelfDraw] — whether the win was by self-draw.
  /// [seatWind] — player's seat wind ('East','South','West','North').
  /// [roundWind] — the round wind.
  /// [flowerCount] — number of flower tiles held (0–8).
  /// [properFlowerCount] — number of proper (正) flowers.
  /// [wrongFlowerCount] — number of wrong (爛) flowers.
  /// [hasOneFlowerSet] — player has collected one complete set (春夏秋冬 or 梅蘭竹菊).
  /// [hasTwoFlowerSets] — player has collected both complete sets.
  /// [specialCondition] — e.g. 'Declared Ready', 'Under the Sea', etc.
  /// [concealedKongCount] — number of concealed kongs (暗槓).
  /// [exposedKongCount] — number of exposed kongs (明槓).
  static TwEvalResult evaluate({
    required TwHand hand,
    required bool isSelfDraw,
    String seatWind = 'East',
    String roundWind = 'East',
    int flowerCount = 0,
    int properFlowerCount = 0,
    int wrongFlowerCount = 0,
    bool hasOneFlowerSet = false,
    bool hasTwoFlowerSets = false,
    String specialCondition = 'None',
    int concealedKongCount = 0,
  }) {
    final matches = <TwPatternMatch>[];
    final allTiles = hand.allTiles;
    final concealedPlusWin = [
      ...hand.concealedTiles,
      if (hand.winningTile != null) hand.winningTile!,
    ];

    // ─── 1. Flowers & Honors ────────────────────────────────────

    // 無花 – No Flowers (1 Tai)
    if (flowerCount == 0) {
      matches.add(const TwPatternMatch(
        id: 'noFlowers',
        nameKey: 'ruleNoFlowers',
        tai: 1,
      ));
    }

    // 正花 – Proper Flower (2 Tai each)
    for (int i = 0; i < properFlowerCount; i++) {
      matches.add(const TwPatternMatch(
        id: 'properFlower',
        nameKey: 'twProperFlower',
        tai: 2,
      ));
    }

    // 爛花 – Wrong Flower (1 Tai each)
    for (int i = 0; i < wrongFlowerCount; i++) {
      matches.add(const TwPatternMatch(
        id: 'wrongFlower',
        nameKey: 'twWrongFlower',
        tai: 1,
      ));
    }

    // 一台花 – One Flower Set (10 Tai)
    if (hasOneFlowerSet && !hasTwoFlowerSets) {
      matches.add(const TwPatternMatch(
        id: 'oneFlowerSet',
        nameKey: 'twOneFlowerSet',
        tai: 10,
      ));
    }

    // 兩台花 – Two Flower Sets (30 Tai)
    if (hasTwoFlowerSets) {
      matches.add(const TwPatternMatch(
        id: 'twoFlowerSets',
        nameKey: 'twTwoFlowerSets',
        tai: 30,
      ));
    }

    // Honour checks on allTiles
    final allCounts = TileUtils.buildTileCounts(allTiles);
    final hasAnyHonor = allTiles.any((t) => t.endsWith('z'));

    // Dragon Pongs (中發白刻 – 2 Tai each)
    for (final dragon in ['5z', '6z', '7z']) {
      if ((allCounts[dragon] ?? 0) >= 3) {
        matches.add(TwPatternMatch(
          id: 'dragonPong_$dragon',
          nameKey: 'twDragonPong',
          tai: 2,
        ));
      }
    }

    // Wind Pongs
    final windMap = {'East': '1z', 'South': '2z', 'West': '3z', 'North': '4z'};
    final roundWindTile = windMap[roundWind];
    final seatWindTile = windMap[seatWind];

    for (final entry in windMap.entries) {
      final tile = entry.value;
      if ((allCounts[tile] ?? 0) >= 3) {
        if (tile == roundWindTile || tile == seatWindTile) {
          // 正風牌 – Proper Wind Pong (2 Tai)
          matches.add(TwPatternMatch(
            id: 'properWind_$tile',
            nameKey: 'twProperWind',
            tai: 2,
          ));
        } else {
          // 非正風 – Ordinary Wind Pong (1 Tai)
          matches.add(TwPatternMatch(
            id: 'ordinaryWind_$tile',
            nameKey: 'twOrdinaryWind',
            tai: 1,
          ));
        }
      }
    }

    // 無字 – No Honors (1 Tai)
    if (!hasAnyHonor) {
      matches.add(const TwPatternMatch(
        id: 'noHonors',
        nameKey: 'twNoHonors',
        tai: 1,
      ));
    }

    // 無字花 – No Honors No Flowers (5 Tai)
    if (!hasAnyHonor && flowerCount == 0) {
      matches.add(const TwPatternMatch(
        id: 'noHonorsNoFlowers',
        nameKey: 'twNoHonorsNoFlowers',
        tai: 5,
      ));
    }

    // ─── 2. Basic Patterns & Win Methods ─────────────────────────

    // 自摸 – Self-Draw (1 Tai)
    if (isSelfDraw) {
      matches.add(const TwPatternMatch(
        id: 'selfDraw',
        nameKey: 'ruleSelfDraw',
        tai: 1,
      ));
    }

    // 門清 – Concealed Hand (3 Tai)
    // Concealed kongs (暗槓) do NOT break 門清.
    if (hand.isFullyConcealed) {
      matches.add(const TwPatternMatch(
        id: 'concealedHand',
        nameKey: 'ruleMenQianQing',
        tai: 3,
      ));
    }

    // 門清自摸 – Concealed Self-Draw (5 Tai) — replaces 門清 + 自摸
    if (hand.isFullyConcealed && isSelfDraw) {
      matches.add(const TwPatternMatch(
        id: 'concealedSelfDraw',
        nameKey: 'twConcealedSelfDraw',
        tai: 5,
      ));
    }

    // 平胡 – All Chows / Ping Hu (3 Tai)
    if (_isPingHu(allTiles)) {
      matches.add(const TwPatternMatch(
        id: 'pingHu',
        nameKey: 'ruleAllChows',
        tai: 3,
      ));
    }

    // 大平胡 – Grand Ping Hu (15 Tai)
    // All chows + no honors + no flowers + concealed hand
    if (_isPingHu(allTiles) && !hasAnyHonor && flowerCount == 0 &&
        hand.isFullyConcealed) {
      matches.add(const TwPatternMatch(
        id: 'grandPingHu',
        nameKey: 'twNoHonorsNoFlowersPingHu',
        tai: 15,
      ));
    }

    // 將眼 – Eye of 2/5/8 (1 Tai)
    if (_hasEyeOf258(allTiles)) {
      matches.add(const TwPatternMatch(
        id: 'eyeOf258',
        nameKey: 'twEyeOf258',
        tai: 1,
      ));
    }

    // 對碰 – Double Pong Wait (2 Tai)
    // When the winning tile completes a pong and another pair was possible
    if (_isDoublePongWait(hand)) {
      matches.add(const TwPatternMatch(
        id: 'doublePongWait',
        nameKey: 'twDoublePong',
        tai: 2,
      ));
    }

    // 獨獨 / 假獨
    if (hand.winningTile != null) {
      final winningTiles = _getWinningTiles(hand);
      final win = hand.winningTile!;
      if (winningTiles.contains(win) && _isSingleWaitInterpretation(hand, win)) {
        if (winningTiles.length == 1) {
          matches.add(const TwPatternMatch(
            id: 'trueSingleWait',
            nameKey: 'twTrueSingle',
            tai: 2,
          ));
        } else {
          final hasNonSingleAlt = winningTiles.any(
            (t) => t != win && !_isSingleWaitInterpretation(hand, t),
          );
          if (hasNonSingleAlt) {
            matches.add(const TwPatternMatch(
              id: 'fakeSingleWait',
              nameKey: 'twFakeSingle',
              tai: 1,
            ));
          }
        }
      }
    }

    // 叮 (Ding) bonus — flat 5 Tai when declared ready
    if (hand.isDing) {
      matches.add(const TwPatternMatch(
        id: 'dingBonus',
        nameKey: 'twDingBonus',
        tai: 5,
      ));
    }

    // 明槓 – Exposed Kong (1 Tai each)
    final expKongs = hand.exposedMelds.where((m) => m.type == MeldType.kong).length;
    for (int i = 0; i < expKongs; i++) {
      matches.add(const TwPatternMatch(
        id: 'exposedKong',
        nameKey: 'twExposedKong',
        tai: 1,
      ));
    }

    // 暗槓 – Concealed Kong (2 Tai each)
    for (int i = 0; i < concealedKongCount; i++) {
      matches.add(const TwPatternMatch(
        id: 'concealedKongTai',
        nameKey: 'twConcealedKongTai',
        tai: 2,
      ));
    }

    // ─── 3. Concealed Pongs (暗刻) ───────────────────────────────

    // Count concealed pongs: pongs formed entirely within concealed tiles
    // (A concealed pong uses tiles in the concealed zone only.
    //  The winning tile may complete a pong if it matches 2 concealed tiles.)
    final concealedPongs = _countConcealedPongs(hand, isSelfDraw);

    if (concealedPongs >= 5) {
      matches.add(const TwPatternMatch(
        id: 'fiveConcealedPongs',
        nameKey: 'twFiveConcealedPongs',
        tai: 80,
      ));
    } else if (concealedPongs >= 4) {
      matches.add(const TwPatternMatch(
        id: 'fourConcealedPongs',
        nameKey: 'twFourConcealedPongs',
        tai: 30,
      ));
    } else if (concealedPongs >= 3) {
      matches.add(const TwPatternMatch(
        id: 'threeConcealedPongs',
        nameKey: 'twThreeConcealedPongs',
        tai: 10,
      ));
    } else if (concealedPongs >= 2) {
      matches.add(const TwPatternMatch(
        id: 'twoConcealedPongs',
        nameKey: 'twTwoConcealedPongs',
        tai: 3,
      ));
    }

    // ─── 4. Sequence combos (般高, 相逢, 兄弟, 姊妹) ────────────

    _checkSequenceCombos(hand, matches);

    // ─── 5. Four-to-X (四歸一/二/四) ────────────────────────────

    _checkFourToX(allTiles, hand, matches);

    // ─── 6. Dragon/Flush patterns ────────────────────────────────

    // 明龍 – Exposed Dragon (10 Tai) — 1-9 of one suit with at least some exposed
    // 暗龍 – Concealed Dragon (20 Tai) — 1-9 of one suit all concealed
    _checkDragon(hand, matches);

    // 明雜龍 – Exposed Mixed Dragon (8 Tai)
    // 暗雜龍 – Concealed Mixed Dragon (15 Tai)
    _checkMixedDragon(hand, matches);

    // ─── 7. Suit patterns ────────────────────────────────────────

    final suits = _getSuits(allTiles);

    // 五門齊 – Five Gates (5 Tai): m + p + s + winds + dragons
    if (_hasFiveGates(allTiles)) {
      matches.add(const TwPatternMatch(
        id: 'fiveGates',
        nameKey: 'twFiveGates',
        tai: 5,
      ));
    }

    // 缺一門 – Missing One Suit (3 Tai)
    if (_isMissingOneSuit(allTiles)) {
      matches.add(const TwPatternMatch(
        id: 'missingOneSuit',
        nameKey: 'twMissingOneSuit',
        tai: 3,
      ));
    }

    // 混一色 – Mixed One Suit (30 Tai)
    if (_isMixedOneSuit(allTiles)) {
      matches.add(const TwPatternMatch(
        id: 'mixedOneSuit',
        nameKey: 'ruleMixedOneSuit',
        tai: 30,
      ));
    }

    // 清一色 – Pure One Suit (80 Tai)
    if (_isPureOneSuit(allTiles)) {
      matches.add(const TwPatternMatch(
        id: 'pureOneSuit',
        nameKey: 'rulePureOneSuit',
        tai: 80,
      ));
    }

    // 對對胡 – All Pongs (30 Tai)
    if (_isAllPongs(allTiles)) {
      matches.add(const TwPatternMatch(
        id: 'allPongs',
        nameKey: 'ruleAllPongs',
        tai: 30,
      ));
    }

    // ─── 8. Terminal / Honor patterns ────────────────────────────

    // 斷么 – All Simples (5 Tai)
    if (_isAllSimples(allTiles)) {
      matches.add(const TwPatternMatch(
        id: 'allSimples',
        nameKey: 'twAllSimples',
        tai: 5,
      ));
    }

    // 全帶混么 – Mixed Terminal Chows (10 Tai)
    if (_isMixedTerminalChows(hand)) {
      matches.add(const TwPatternMatch(
        id: 'mixedTerminalChows',
        nameKey: 'twMixedTerminalChows',
        tai: 10,
      ));
    }

    // 全帶么 – Pure Terminal Chows (15 Tai)
    if (_isPureTerminalChows(hand)) {
      matches.add(const TwPatternMatch(
        id: 'pureTerminalChows',
        nameKey: 'twPureTerminalChows',
        tai: 15,
      ));
    }

    // 混么 – Mixed Terminals Pongs (30 Tai)
    if (_isMixedTerminalsPongs(allTiles)) {
      matches.add(const TwPatternMatch(
        id: 'mixedTerminalsPongs',
        nameKey: 'twMixedTerminalsPongs',
        tai: 30,
      ));
    }

    // 清么 – Pure Terminals (80 Tai)
    if (_isPureTerminals(allTiles)) {
      matches.add(const TwPatternMatch(
        id: 'pureTerminals',
        nameKey: 'twPureTerminalsTw',
        tai: 80,
      ));
    }

    // 全混么 – Pure Terminal Groups (15 Tai)
    // Every group (meld/pair) contains a terminal (1 or 9). No honors.
    // Any composition (not limited to all-chows or all-pongs).
    if (_isEveryGroupTerminal(hand, allowHonors: false)) {
      matches.add(const TwPatternMatch(
        id: 'quanHunYao',
        nameKey: 'twQuanHunYao',
        tai: 15,
      ));
    }

    // 半帶混么 – Mixed Terminal Groups (10 Tai)
    // Every group (meld/pair) contains a terminal (1/9) or is an honor group.
    // Must have at least one honor tile.
    if (_isEveryGroupTerminal(hand, allowHonors: true)) {
      matches.add(const TwPatternMatch(
        id: 'banDaiHunYao',
        nameKey: 'twBanDaiHunYao',
        tai: 10,
      ));
    }

    // 字一色 – All Honors (16 Tai)
    if (_isAllHonors(allTiles)) {
      matches.add(const TwPatternMatch(
        id: 'allHonors',
        nameKey: 'ruleAllHonors',
        tai: 16,
      ));
    }

    // ─── 9. Wind combos ──────────────────────────────────────────

    final windPongs = _countWindPongs(allCounts);

    if (windPongs == 4) {
      // 大四喜 – Big Four Winds (80 Tai)
      matches.add(const TwPatternMatch(
        id: 'bigFourWinds',
        nameKey: 'ruleBigFourWinds',
        tai: 80,
      ));
    } else if (windPongs == 3) {
      // Check small vs big
      final hasWindPair = windMap.values.any((t) =>
          (allCounts[t] ?? 0) >= 2 && (allCounts[t] ?? 0) < 3);
      final allFourWindsPresent = windMap.values.every(
          (t) => (allCounts[t] ?? 0) >= 2);
      if (allFourWindsPresent && hasWindPair) {
        // 小四喜 – Small Four Winds (60 Tai)
        matches.add(const TwPatternMatch(
          id: 'smallFourWinds',
          nameKey: 'ruleSmallFourWinds',
          tai: 60,
        ));
      } else {
        // 大三風 – Big Three Winds (30 Tai)
        matches.add(const TwPatternMatch(
          id: 'bigThreeWinds',
          nameKey: 'twBigThreeWinds',
          tai: 30,
        ));
      }
    } else if (windPongs == 2) {
      // Check if a third wind has a pair → small three winds
      int windPairCount = windMap.values
          .where((t) => (allCounts[t] ?? 0) >= 2)
          .length;
      if (windPairCount >= 3) {
        // 小三風 – Small Three Winds (15 Tai)
        matches.add(const TwPatternMatch(
          id: 'smallThreeWinds',
          nameKey: 'twSmallThreeWinds',
          tai: 15,
        ));
      }
    }

    // ─── 10. Dragon combos ───────────────────────────────────────

    final dragonPongs = ['5z', '6z', '7z']
        .where((d) => (allCounts[d] ?? 0) >= 3)
        .length;
    final dragonPairs = ['5z', '6z', '7z']
        .where((d) => (allCounts[d] ?? 0) >= 2)
        .length;

    if (dragonPongs == 3) {
      // 大三元 – Big Three Dragons (40 Tai)
      matches.add(const TwPatternMatch(
        id: 'bigThreeDragons',
        nameKey: 'ruleBigThreeDragons',
        tai: 40,
      ));
    } else if (dragonPongs == 2 && dragonPairs == 3) {
      // 小三元 – Small Three Dragons (20 Tai)
      matches.add(const TwPatternMatch(
        id: 'smallThreeDragons',
        nameKey: 'ruleSmallThreeDragons',
        tai: 20,
      ));
    }

    // ─── 11. Pair-based patterns ─────────────────────────────────

    // 嚦咕嚦咕 – Eight Pairs / Migui (40 Tai)
    if (_isEightPairs(allTiles)) {
      matches.add(const TwPatternMatch(
        id: 'eightPairs',
        nameKey: 'twMiguiTw',
        tai: 40,
      ));
    }

    // ─── 12. Limit hands ─────────────────────────────────────────

    // 九子連環 – Nine Gates (16 Tai)
    if (_isNineGates(allTiles)) {
      matches.add(const TwPatternMatch(
        id: 'nineGates',
        nameKey: 'ruleNineGates',
        tai: 16,
      ));
    }

    // 十八羅漢 – Eighteen Arhats (16 Tai)
    if (hand.kongCount == 4) {
      // 4 kongs → only pair remains
      matches.add(const TwPatternMatch(
        id: 'eighteenArhats',
        nameKey: 'ruleEighteenArhats',
        tai: 16,
      ));
    }

    // 間間胡 – Concealed All Pongs Self-Draw (100 Tai)
    // Requires: self-draw + concealed hand + all pongs
    if (isSelfDraw && hand.isFullyConcealed && _isAllPongs(allTiles)) {
      matches.add(const TwPatternMatch(
        id: 'jianJianHu',
        nameKey: 'twJianJianHu',
        tai: 100,
      ));
    }

    // 十三么 – Thirteen Orphans (80 Tai) — TW doesn't normally have this
    // but included for completeness
    // 十三么 – Thirteen Orphans TW (80 Tai)
    // TW version: 13 orphan tiles + 1 pair + 3-tile concealed meld (chow or pong)
    if (_isTwThirteenOrphans(hand)) {
      matches.add(const TwPatternMatch(
        id: 'thirteenOrphans',
        nameKey: 'ruleThirteenOrphans',
        tai: 80,
      ));
    }

    // 十六不搭 – Sixteen Non-Matching (50 Tai)
    if (_isSixteenNonMatching(allTiles)) {
      matches.add(const TwPatternMatch(
        id: 'sixteenNonMatching',
        nameKey: 'twSixteenNonMatching',
        tai: 50,
      ));
    }

    // ─── 13. Brothers & Sisters ──────────────────────────────────

    _checkBrothersAndSisters(hand, allCounts, matches);

    // ─── 14. Exposed/Concealed specific ──────────────────────────

    // 全求人 – All Revealed (15 Tai) — win by discard
    if (!isSelfDraw && _isAllRevealed(hand)) {
      matches.add(const TwPatternMatch(
        id: 'allRevealed',
        nameKey: 'twAllRevealed',
        tai: 15,
      ));
    }

    // 半求人 – Half Revealed (8 Tai) — win by self-draw
    if (isSelfDraw && _isHalfRevealed(hand)) {
      matches.add(const TwPatternMatch(
        id: 'halfRevealed',
        nameKey: 'twHalfRevealed',
        tai: 8,
      ));
    }

    // 老少 – Old & Young (2 Tai per suit)
    final oldYoungCount = _countOldYoung(hand);
    for (int i = 0; i < oldYoungCount; i++) {
      matches.add(const TwPatternMatch(
        id: 'oldYoung',
        nameKey: 'twOldYoung',
        tai: 3,
      ));
    }

    // ─── Apply exclusion rules ───────────────────────────────────

    final finalMatches = _applyExclusions(matches);
    final totalTai = finalMatches.fold<int>(0, (sum, m) => sum + m.tai);

    return TwEvalResult(
      rawMatches: matches,
      finalMatches: finalMatches,
      totalTai: totalTai,
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  Pattern detection helpers
  // ═══════════════════════════════════════════════════════════════

  static bool _isPingHu(List<String> tiles) {
    return HandCore.checkSpecificHand(tiles, allowChow: true, allowPong: false);
  }

  static bool _hasEyeOf258(List<String> tiles) {
    final counts = TileUtils.buildTileCounts(tiles);
    final count = tiles.length;
    final kongsNeeded17 = count - 17;

    for (final tile in counts.keys) {
      if (counts[tile]! < 2) continue;
      final suit = tile.substring(1);
      final num = int.parse(tile.substring(0, 1));
      if (suit == 'z') continue;
      if (num != 2 && num != 5 && num != 8) continue;

      final currentCounts = Map<String, int>.from(counts);
      currentCounts[tile] = currentCounts[tile]! - 2;
      if (currentCounts[tile] == 0) currentCounts.remove(tile);

      if (kongsNeeded17 >= 0 && kongsNeeded17 <= 4 &&
          HandCore.checkSets(Map.from(currentCounts), kongsNeeded17)) {
        return true;
      }
    }
    return false;
  }

  static bool _isDoublePongWait(TwHand hand) {
    if (hand.winningTile == null) return false;
    final win = hand.winningTile!;
    // Count wins in concealed zone (before winning tile added)
    final concealedCounts = TileUtils.buildTileCounts(hand.concealedTiles);
    // The winning tile completes a pong if there are 2 of it in concealed
    if ((concealedCounts[win] ?? 0) != 2) return false;
    // And there's another pair that could serve as the eye
    // Remove the pong and check if remaining forms valid sets + pair
    final afterPong = Map<String, int>.from(concealedCounts);
    afterPong[win] = (afterPong[win] ?? 0) - 2;
    if ((afterPong[win] ?? 0) <= 0) afterPong.remove(win);
    // Check if there's at least one other pair
    return afterPong.values.any((c) => c >= 2);
  }

  static const List<String> _allTileTypes = [
    '1m', '2m', '3m', '4m', '5m', '6m', '7m', '8m', '9m',
    '1p', '2p', '3p', '4p', '5p', '6p', '7p', '8p', '9p',
    '1s', '2s', '3s', '4s', '5s', '6s', '7s', '8s', '9s',
    '1z', '2z', '3z', '4z', '5z', '6z', '7z',
  ];

  static int _concealedMeldsNeeded(TwHand hand) {
    final needed = 5 - hand.exposedMelds.length;
    return needed < 0 ? 0 : needed;
  }

  static int _countTileBeforeWin(TwHand hand, String tile) {
    int count = hand.concealedTiles.where((t) => t == tile).length;
    for (final meld in hand.exposedMelds) {
      count += meld.tiles.where((t) => t == tile).length;
    }
    return count;
  }

  static bool _removeOneTile(Map<String, int> counts, String tile) {
    final c = counts[tile] ?? 0;
    if (c <= 0) return false;
    if (c == 1) {
      counts.remove(tile);
    } else {
      counts[tile] = c - 1;
    }
    return true;
  }

  static bool _canFormMeldsOnlyFromCounts(
    Map<String, int> counts,
    int meldsNeeded,
  ) {
    if (meldsNeeded < 0) return false;
    final tileCount = counts.values.fold<int>(0, (s, c) => s + c);
    if (tileCount != meldsNeeded * 3) return false;
    return HandCore.checkSets(Map<String, int>.from(counts), 0);
  }

  static bool _canFormMeldsAndPairFromCounts(
    Map<String, int> counts,
    int meldsNeeded,
  ) {
    if (meldsNeeded < 0) return false;
    final tileCount = counts.values.fold<int>(0, (s, c) => s + c);
    if (tileCount != meldsNeeded * 3 + 2) return false;

    for (final tile in counts.keys.toList()) {
      if ((counts[tile] ?? 0) < 2) continue;
      final next = Map<String, int>.from(counts);
      _removeOneTile(next, tile);
      _removeOneTile(next, tile);
      if (_canFormMeldsOnlyFromCounts(next, meldsNeeded)) return true;
    }
    return false;
  }

  static bool _canWinWithTile(TwHand hand, String tile) {
    if (_countTileBeforeWin(hand, tile) >= 4) return false;
    final concealedWithWin = [...hand.concealedTiles, tile];
    return _canFormMeldsAndPairFromCounts(
      TileUtils.buildTileCounts(concealedWithWin),
      _concealedMeldsNeeded(hand),
    );
  }

  static List<String> _getWinningTiles(TwHand hand) {
    return _allTileTypes.where((t) => _canWinWithTile(hand, t)).toList();
  }

  static bool _isSingleWaitInterpretation(TwHand hand, String winningTile) {
    final meldsNeeded = _concealedMeldsNeeded(hand);
    final concealedWithWin = [...hand.concealedTiles, winningTile];
    final counts = TileUtils.buildTileCounts(concealedWithWin);

    if (!_canFormMeldsAndPairFromCounts(counts, meldsNeeded)) return false;

    // 單釣: winning tile forms the pair.
    if ((counts[winningTile] ?? 0) >= 2) {
      final next = Map<String, int>.from(counts);
      _removeOneTile(next, winningTile);
      _removeOneTile(next, winningTile);
      if (_canFormMeldsOnlyFromCounts(next, meldsNeeded)) return true;
    }

    final suit = winningTile.substring(1);
    if (suit == 'z') return false;

    final num = int.parse(winningTile.substring(0, 1));

    // 中洞: x (win) z where win is middle tile.
    if (num >= 2 && num <= 8) {
      final t1 = '${num - 1}$suit';
      final t2 = '${num + 1}$suit';
      final next = Map<String, int>.from(counts);
      if (_removeOneTile(next, winningTile) &&
          _removeOneTile(next, t1) &&
          _removeOneTile(next, t2) &&
          _canFormMeldsAndPairFromCounts(next, meldsNeeded - 1)) {
        return true;
      }
    }

    // 邊張: 1-2 waiting 3, or 8-9 waiting 7.
    if (num == 3 || num == 7) {
      final t1 = num == 3 ? '1$suit' : '8$suit';
      final t2 = num == 3 ? '2$suit' : '9$suit';
      final next = Map<String, int>.from(counts);
      if (_removeOneTile(next, winningTile) &&
          _removeOneTile(next, t1) &&
          _removeOneTile(next, t2) &&
          _canFormMeldsAndPairFromCounts(next, meldsNeeded - 1)) {
        return true;
      }
    }

    return false;
  }

  static int _countConcealedPongs(TwHand hand, bool isSelfDraw) {
    // Concealed pongs = pongs in valid hand decomposition that are
    // formed entirely from concealed tiles. The winning tile can
    // complete a concealed pong ONLY on self-draw.
    // All kongs count as concealed pongs.
    int count = hand.kongCount;

    final allConcealed = [
      ...hand.concealedTiles,
      if (hand.winningTile != null) hand.winningTile!,
    ];

    if (allConcealed.length < 5) return count;

    final allCounts = TileUtils.buildTileCounts(allConcealed);
    final concealedOnly = TileUtils.buildTileCounts(hand.concealedTiles);

    // Find the valid decomposition (pair + melds) that maximises
    // the number of concealed pongs.
    int maxConcealedPongs = 0;

    for (final tile in allCounts.keys.toList()) {
      if (allCounts[tile]! < 2) continue;
      final afterPair = Map<String, int>.from(allCounts);
      afterPair[tile] = afterPair[tile]! - 2;
      if (afterPair[tile] == 0) afterPair.remove(tile);

      final pongTiles = _bestPongDecomposition(afterPair);
      if (pongTiles == null) continue;

      int cp = 0;
      for (final pTile in pongTiles) {
        final cc = concealedOnly[pTile] ?? 0;
        if (cc >= 3) {
          cp++;
        } else if (cc >= 2 && isSelfDraw && pTile == hand.winningTile) {
          cp++;
        }
      }
      maxConcealedPongs = max(maxConcealedPongs, cp);
    }

    return count + maxConcealedPongs;
  }

  /// Decompose [counts] into melds, maximising the pong count.
  /// Returns the list of tile types that form pongs in the best
  /// valid decomposition, or null if no valid decomposition exists.
  static List<String>? _bestPongDecomposition(Map<String, int> counts) {
    if (counts.isEmpty) return [];

    final sortedKeys = counts.keys.toList()..sort(TileUtils.compareTiles);
    final first = sortedKeys.first;
    final suit = first.substring(1);
    final num = int.parse(first.substring(0, 1));

    List<String>? best;

    // Try pong
    if (counts[first]! >= 3) {
      final next = Map<String, int>.from(counts);
      next[first] = next[first]! - 3;
      if (next[first] == 0) next.remove(first);
      final sub = _bestPongDecomposition(next);
      if (sub != null) {
        final candidate = [first, ...sub];
        if (best == null || candidate.length > best.length) best = candidate;
      }
    }

    // Try chow
    if (suit != 'z' && num <= 7) {
      final t2 = '${num + 1}$suit';
      final t3 = '${num + 2}$suit';
      if ((counts[t2] ?? 0) > 0 && (counts[t3] ?? 0) > 0) {
        final next = Map<String, int>.from(counts);
        next[first] = next[first]! - 1;
        if (next[first] == 0) next.remove(first);
        next[t2] = next[t2]! - 1;
        if (next[t2] == 0) next.remove(t2);
        next[t3] = next[t3]! - 1;
        if (next[t3] == 0) next.remove(t3);
        final sub = _bestPongDecomposition(next);
        if (sub != null) {
          if (best == null || sub.length > best.length) best = sub;
        }
      }
    }

    return best;
  }

  static void _checkSequenceCombos(TwHand hand, List<TwPatternMatch> matches) {
    // Extract all chow sequences from exposed + concealed and keep
    // origin info to support exposed/concealed value differences.
    final seqCounts = <String, int>{};
    final seqExposedCounts = <String, int>{};

    void addSequence(String startTile, {required bool isExposed}) {
      seqCounts[startTile] = (seqCounts[startTile] ?? 0) + 1;
      if (isExposed) {
        seqExposedCounts[startTile] = (seqExposedCounts[startTile] ?? 0) + 1;
      }
    }

    // From exposed melds
    for (final meld in hand.exposedMelds) {
      if (meld.type == MeldType.chow) {
        final sorted = List<String>.from(meld.tiles)..sort(TileUtils.compareTiles);
        addSequence(sorted.first, isExposed: true);
      }
    }

    // From concealed tiles, find sequences
    final concealedWithWin = [
      ...hand.concealedTiles,
      if (hand.winningTile != null) hand.winningTile!,
    ];
    final remaining = Map<String, int>.from(TileUtils.buildTileCounts(concealedWithWin));

    // Remove tiles already used in exposed pongs/kongs from consideration
    // (exposed melds are separate, concealed sequences come from concealed tiles)

    // Find sequences in concealed area
    final sortedKeys = remaining.keys.toList()..sort(TileUtils.compareTiles);
    for (final tile in sortedKeys) {
      final suit = tile.substring(1);
      if (suit == 'z') continue;
      final num = int.parse(tile.substring(0, 1));
      if (num > 7) continue;

      final t2 = '${num + 1}$suit';
      final t3 = '${num + 2}$suit';

      while ((remaining[tile] ?? 0) > 0 &&
             (remaining[t2] ?? 0) > 0 &&
             (remaining[t3] ?? 0) > 0) {
        addSequence(tile, isExposed: false);
        remaining[tile] = (remaining[tile] ?? 0) - 1;
        remaining[t2] = (remaining[t2] ?? 0) - 1;
        remaining[t3] = (remaining[t3] ?? 0) - 1;
      }
    }

    // Count identical sequences (一般高, 三般高, 四般高)
    for (final entry in seqCounts.entries) {
      final key = entry.key;
      final count = entry.value;
      if (count >= 4) {
        matches.add(const TwPatternMatch(
          id: 'fourIdenticalSeq',
          nameKey: 'twIdenticalSequenceFour',
          tai: 30,
        ));
      } else if (count >= 3) {
        final allConcealed = (seqExposedCounts[key] ?? 0) == 0;
        matches.add(TwPatternMatch(
          id: 'threeIdenticalSeq',
          nameKey: 'twIdenticalSequenceThree',
          tai: allConcealed ? 20 : 15,
        ));
      } else if (count >= 2) {
        matches.add(const TwPatternMatch(
          id: 'twoIdenticalSeq',
          nameKey: 'twIdenticalSequenceTwo',
          tai: 3,
        ));
      }
    }

    // 五同順 / 二相逢 / 三相逢 — same number range, cross-suit combos
    final byRange = <String, Map<String, bool>>{}; // "1" -> {suit: hasExposed}
    final byRangeTotal = <String, int>{}; // "1" -> total sequence count across suits
    for (final key in seqCounts.keys) {
      final num = key.substring(0, 1);
      final suit = key.substring(1);
      final hasExposed = (seqExposedCounts[key] ?? 0) > 0;
      byRangeTotal[num] = (byRangeTotal[num] ?? 0) + (seqCounts[key] ?? 0);
      final suitMap = byRange.putIfAbsent(num, () => <String, bool>{});
      suitMap[suit] = (suitMap[suit] ?? false) || hasExposed;
    }

    // 五同順: five same-number sequences across suits.
    for (final total in byRangeTotal.values) {
      if (total >= 5) {
        matches.add(const TwPatternMatch(
          id: 'fiveIdenticalSeq',
          nameKey: 'twFiveIdenticalSeq',
          tai: 45,
        ));
      }
    }

    for (final entry in byRange.entries) {
      final suitMap = entry.value;
      if (suitMap.length >= 3) {
        final allConcealed = suitMap.values.every((v) => !v);
        matches.add(TwPatternMatch(
          id: 'mixedTripleSeq',
          nameKey: 'twMixedTripleSeq',
          tai: allConcealed ? 20 : 15,
        ));
      } else if (suitMap.length >= 2) {
        matches.add(const TwPatternMatch(
          id: 'mixedDoubleSeq',
          nameKey: 'twMixedDoubleSeq',
          tai: 1,
        ));
      }
    }
  }

  static void _checkFourToX(
      List<String> allTiles, TwHand hand, List<TwPatternMatch> matches) {
    // 四歸一/二/四: detect non-kong four-of-a-kind groups.
    // Priority: 四歸四 > 四歸二 > 四歸一.
    final allCounts = TileUtils.buildTileCounts(allTiles);
    int quadGroupCount = 0;

    for (final entry in allCounts.entries) {
      if (entry.value == 4) {
        // Exclude declared kongs.
        final isKong = hand.exposedMelds.any(
            (m) => m.isKong && m.tiles.contains(entry.key));
        if (!isKong) {
          quadGroupCount++;
        }
      }
    }

    if (quadGroupCount >= 4) {
      matches.add(const TwPatternMatch(
        id: 'fourToFour',
        nameKey: 'twFourToFour',
        tai: 20,
      ));
      return;
    }

    if (quadGroupCount >= 2) {
      matches.add(const TwPatternMatch(
        id: 'fourToTwo',
        nameKey: 'twFourToTwo',
        tai: 10,
      ));
      return;
    }

    if (quadGroupCount == 1) {
      final isConcealed = hand.isFullyConcealed;
      matches.add(TwPatternMatch(
        id: 'fourToOne',
        nameKey: 'twFourToOne',
        tai: isConcealed ? 5 : 3,
      ));
    }
  }

  static void _checkDragon(TwHand hand, List<TwPatternMatch> matches) {
    // Pure dragon multi-count:
    // count combinations of (123) x (456) x (789) per suit.
    // This allows repeated dragons when one segment can be replaced
    // by another duplicate segment.
    final allTiles = hand.allTiles;
    final concealedWithWin = [
      ...hand.concealedTiles,
      if (hand.winningTile != null) hand.winningTile!,
    ];

    int segmentCount(List<String> tiles, String suit, List<int> nums) {
      int minC = 99;
      for (final n in nums) {
        final c = tiles.where((t) => t == '$n$suit').length;
        if (c < minC) minC = c;
      }
      return minC;
    }

    for (final suit in ['m', 'p', 's']) {
      final all123 = segmentCount(allTiles, suit, [1, 2, 3]);
      final all456 = segmentCount(allTiles, suit, [4, 5, 6]);
      final all789 = segmentCount(allTiles, suit, [7, 8, 9]);

      final concealed123 = segmentCount(concealedWithWin, suit, [1, 2, 3]);
      final concealed456 = segmentCount(concealedWithWin, suit, [4, 5, 6]);
      final concealed789 = segmentCount(concealedWithWin, suit, [7, 8, 9]);

      final totalCombos = all123 * all456 * all789;
      if (totalCombos <= 0) continue;

      final concealedCombos = concealed123 * concealed456 * concealed789;
      final exposedCombos = totalCombos - concealedCombos;

      for (int i = 0; i < concealedCombos; i++) {
        matches.add(const TwPatternMatch(
          id: 'concealedDragon',
          nameKey: 'twConcealedDragon',
          tai: 20,
        ));
      }

      for (int i = 0; i < exposedCombos; i++) {
        matches.add(const TwPatternMatch(
          id: 'exposedDragon',
          nameKey: 'twExposedDragon',
          tai: 10,
        ));
      }
    }
  }

  static void _checkMixedDragon(TwHand hand, List<TwPatternMatch> matches) {
    // Mixed dragon: 1-2-3 of one suit + 4-5-6 of one suit + 7-8-9 of one suit,
    // where the three groups are NOT all the same suit.
    // Uses segment-count approach to support multiple instances
    // when tile duplicates are available.
    final allTiles = hand.allTiles;
    final concealedWithWin = [
      ...hand.concealedTiles,
      if (hand.winningTile != null) hand.winningTile!,
    ];

    const suits = ['m', 'p', 's'];
    const ranges = [
      [1, 2, 3],
      [4, 5, 6],
      [7, 8, 9],
    ];

    // Count complete segments per (range, suit)
    final segAll = List.generate(3, (r) {
      final m = <String, int>{};
      for (final suit in suits) {
        int minC = 99;
        for (final n in ranges[r]) {
          final c = allTiles.where((t) => t == '$n$suit').length;
          if (c < minC) minC = c;
        }
        m[suit] = minC;
      }
      return m;
    });

    final segConcealed = List.generate(3, (r) {
      final m = <String, int>{};
      for (final suit in suits) {
        int minC = 99;
        for (final n in ranges[r]) {
          final c = concealedWithWin.where((t) => t == '$n$suit').length;
          if (c < minC) minC = c;
        }
        m[suit] = minC;
      }
      return m;
    });

    int concealedMixed = 0;
    int exposedMixed = 0;

    for (final s1 in suits) {
      for (final s2 in suits) {
        for (final s3 in suits) {
          // Skip pure dragons (handled by _checkDragon)
          if (s1 == s2 && s2 == s3) continue;

          final allCount = [segAll[0][s1]!, segAll[1][s2]!, segAll[2][s3]!]
              .reduce((a, b) => a < b ? a : b);
          if (allCount <= 0) continue;

          for (int i = 0; i < allCount; i++) {
            final isConcealed = segConcealed[0][s1]! > i &&
                segConcealed[1][s2]! > i &&
                segConcealed[2][s3]! > i;
            if (isConcealed) {
              concealedMixed++;
            } else {
              exposedMixed++;
            }
          }
        }
      }
    }

    for (int i = 0; i < concealedMixed; i++) {
      matches.add(const TwPatternMatch(
        id: 'concealedMixedDragon',
        nameKey: 'twConcealedMixedDragon',
        tai: 10,
      ));
    }
    for (int i = 0; i < exposedMixed; i++) {
      matches.add(const TwPatternMatch(
        id: 'exposedMixedDragon',
        nameKey: 'twExposedMixedDragon',
        tai: 5,
      ));
    }
  }

  static List<List<int>> _permutations3() {
    return [
      [0, 1, 2], [0, 2, 1], [1, 0, 2],
      [1, 2, 0], [2, 0, 1], [2, 1, 0],
    ];
  }

  static Set<String> _getSuits(List<String> tiles) {
    return tiles.map((t) => t.substring(1)).toSet();
  }

  static bool _hasFiveGates(List<String> tiles) {
    bool hasM = false, hasP = false, hasS = false;
    bool hasWind = false, hasDragon = false;
    for (final t in tiles) {
      final suit = t.substring(1);
      final num = int.parse(t.substring(0, 1));
      if (suit == 'm') hasM = true;
      if (suit == 'p') hasP = true;
      if (suit == 's') hasS = true;
      if (suit == 'z' && num <= 4) hasWind = true;
      if (suit == 'z' && num >= 5) hasDragon = true;
    }
    return hasM && hasP && hasS && hasWind && hasDragon;
  }

  static bool _isMissingOneSuit(List<String> tiles) {
    bool hasM = false, hasP = false, hasS = false;
    for (final t in tiles) {
      final suit = t.substring(1);
      if (suit == 'm') hasM = true;
      if (suit == 'p') hasP = true;
      if (suit == 's') hasS = true;
    }
    // Exactly one numbered suit is missing (honor tiles not required)
    final count = [hasM, hasP, hasS].where((b) => b).length;
    return count == 2;
  }

  static bool _isMixedOneSuit(List<String> tiles) {
    if (tiles.isEmpty) return false;
    bool hasHonor = tiles.any((t) => t.endsWith('z'));
    if (!hasHonor) return false;
    String? suit;
    for (final t in tiles) {
      final s = t.substring(1);
      if (s != 'z') {
        if (suit == null) {
          suit = s;
        } else if (suit != s) {
          return false;
        }
      }
    }
    return suit != null;
  }

  static bool _isPureOneSuit(List<String> tiles) {
    if (tiles.isEmpty) return false;
    final firstSuit = tiles.first.substring(1);
    if (firstSuit == 'z') return false;
    return tiles.every((t) => t.substring(1) == firstSuit);
  }

  static bool _isAllPongs(List<String> tiles) {
    return HandCore.checkSpecificHand(tiles, allowChow: false, allowPong: true);
  }

  static bool _isAllSimples(List<String> tiles) {
    for (final t in tiles) {
      final suit = t.substring(1);
      final num = int.parse(t.substring(0, 1));
      if (suit == 'z') return false;
      if (num == 1 || num == 9) return false;
    }
    return true;
  }

  static bool _isMixedTerminalChows(TwHand hand) {
    // Fixed logic: every group contains terminal or honor, and honors exist.
    final hasHonor = hand.allTiles.any((t) => t.endsWith('z'));
    if (!hasHonor) return false;
    return _isEveryGroupTerminal(hand, allowHonors: true);
  }

  static bool _isPureTerminalChows(TwHand hand) {
    // Fixed logic: every group contains terminal, no honors.
    if (hand.allTiles.any((t) => t.endsWith('z'))) return false;
    return _isEveryGroupTerminal(hand, allowHonors: false);
  }

  static bool _isMixedTerminalsPongs(List<String> tiles) {
    if (!_isAllPongs(tiles)) return false;
    bool hasHonor = false, hasTerminal = false;
    for (final t in tiles) {
      final suit = t.substring(1);
      final num = int.parse(t.substring(0, 1));
      if (suit == 'z') {
        hasHonor = true;
      } else if (num == 1 || num == 9) {
        hasTerminal = true;
      } else {
        return false;
      }
    }
    return hasHonor && hasTerminal;
  }

  static bool _isPureTerminals(List<String> tiles) {
    for (final t in tiles) {
      if (t.endsWith('z')) return false;
      final num = int.parse(t.substring(0, 1));
      if (num != 1 && num != 9) return false;
    }
    return true;
  }

  static bool _isAllHonors(List<String> tiles) {
    return tiles.every((t) => t.endsWith('z'));
  }

  // ─── Every-group-terminal helpers (全混么 / 半帶混么) ─────────

  /// Checks if every group (chow, pong, kong, pair) in the hand
  /// contains at least one terminal (1 or 9).
  ///
  /// [allowHonors] = false → 全混么 (no honor tiles).
  /// [allowHonors] = true  → 半帶混么 (must have honors).
  static bool _isEveryGroupTerminal(
    TwHand hand, {
    required bool allowHonors,
  }) {
    final allTiles = hand.allTiles;
    final hasHonor = allTiles.any((t) => t.endsWith('z'));

    if (!allowHonors && hasHonor) return false;
    if (allowHonors && !hasHonor) return false;

    // Quick reject: no numbered tile may be 4-6
    for (final t in allTiles) {
      if (t.endsWith('z')) continue;
      final num = int.parse(t.substring(0, 1));
      if (num >= 4 && num <= 6) return false;
    }

    // Verify every exposed meld contains a terminal (or is honor)
    for (final meld in hand.exposedMelds) {
      bool hasTerm = false;
      for (final t in meld.tiles) {
        if (t.endsWith('z')) {
          hasTerm = true;
          break;
        }
        final num = int.parse(t.substring(0, 1));
        if (num == 1 || num == 9) {
          hasTerm = true;
          break;
        }
      }
      if (!hasTerm) return false;
    }

    // Decompose concealed tiles + winning tile into melds + pair,
    // ensuring every group contains a terminal.
    final concealedAll = [
      ...hand.concealedTiles,
      if (hand.winningTile != null) hand.winningTile!,
    ];
    if (concealedAll.isEmpty) return true;

    return _canDecomposeTerminalGroups(concealedAll, allowHonors);
  }

  /// Tries to decompose [tiles] into 1 pair + melds where every group
  /// contains at least one terminal (1 or 9) or honor.
  static bool _canDecomposeTerminalGroups(
    List<String> tiles,
    bool allowHonors,
  ) {
    final counts = TileUtils.buildTileCounts(tiles);
    for (final tile in counts.keys.toList()) {
      final suit = tile.substring(1);
      final num = int.parse(tile.substring(0, 1));

      // Pair must be terminal or honor
      final validPair =
          (suit == 'z' && allowHonors) || num == 1 || num == 9;
      if (!validPair || counts[tile]! < 2) continue;

      final remaining = Map<String, int>.from(counts);
      remaining[tile] = remaining[tile]! - 2;
      if (remaining[tile] == 0) remaining.remove(tile);

      if (_checkTerminalSetsOnly(remaining, allowHonors)) return true;
    }
    return false;
  }

  /// Recursively decomposes [counts] into melds where each contains
  /// a terminal (1/9) or is an honor pong.
  ///
  /// Allowed melds:
  ///   Chow: 1-2-3, 7-8-9 (contain 1 or 9)
  ///   Pong: 1-1-1, 9-9-9, or honor pong
  static bool _checkTerminalSetsOnly(
    Map<String, int> counts,
    bool allowHonors,
  ) {
    if (counts.isEmpty) return true;

    final sortedKeys = counts.keys.toList()..sort(TileUtils.compareTiles);
    final first = sortedKeys.first;
    final suit = first.substring(1);
    final num = int.parse(first.substring(0, 1));

    // Try pong (only terminal: 1, 9, or honor)
    if (counts[first]! >= 3) {
      final isValidPong =
          (suit == 'z' && allowHonors) || num == 1 || num == 9;
      if (isValidPong) {
        final next = Map<String, int>.from(counts);
        next[first] = next[first]! - 3;
        if (next[first] == 0) next.remove(first);
        if (_checkTerminalSetsOnly(next, allowHonors)) return true;
      }
    }

    // Try chow (only 1-2-3 or 7-8-9)
    if (suit != 'z' && (num == 1 || num == 7)) {
      final t2 = '${num + 1}$suit';
      final t3 = '${num + 2}$suit';
      if (counts.containsKey(t2) && counts.containsKey(t3)) {
        final next = Map<String, int>.from(counts);
        TileUtils.removeTile(next, first);
        TileUtils.removeTile(next, t2);
        TileUtils.removeTile(next, t3);
        if (_checkTerminalSetsOnly(next, allowHonors)) return true;
      }
    }

    return false;
  }

  static int _countWindPongs(Map<String, int> counts) {
    int c = 0;
    for (final w in ['1z', '2z', '3z', '4z']) {
      if ((counts[w] ?? 0) >= 3) c++;
    }
    return c;
  }

  static bool _isEightPairs(List<String> tiles) {
    if (tiles.length != 17) return false;
    final counts = TileUtils.buildTileCounts(tiles);
    // Must be exactly 1 pong (triplet) + 7 pairs = 3 + 14 = 17
    for (final entry in counts.entries) {
      if (entry.value >= 3) {
        final remaining = Map<String, int>.from(counts);
        remaining[entry.key] = remaining[entry.key]! - 3;
        if (remaining[entry.key] == 0) remaining.remove(entry.key);
        bool allPairs = true;
        int pairCount = 0;
        for (final c in remaining.values) {
          if (c % 2 != 0) {
            allPairs = false;
            break;
          }
          pairCount += c ~/ 2;
        }
        if (allPairs && pairCount == 7) return true;
      }
    }
    return false;
  }

  static bool _isNineGates(List<String> tiles) {
    if (!_isPureOneSuit(tiles)) return false;
    final counts = <int, int>{};
    for (final t in tiles) {
      final num = int.parse(t.substring(0, 1));
      counts[num] = (counts[num] ?? 0) + 1;
    }
    if ((counts[1] ?? 0) < 3) return false;
    if ((counts[9] ?? 0) < 3) return false;
    for (int i = 2; i <= 8; i++) {
      if ((counts[i] ?? 0) < 1) return false;
    }
    return tiles.length == 17;
  }

  static bool _isTwThirteenOrphans(TwHand hand) {
    // TW Thirteen Orphans (十三么):
    // Must have all 13 orphan tiles (1m,9m,1p,9p,1s,9s,1z-7z)
    // Plus one pair (eye) from those 13 types = 14 tiles
    // Plus a concealed 3-tile meld (chow or pong) = 17 tiles total
    // Must be fully concealed (no exposed melds)
    if (!hand.isFullyConcealed || hand.exposedMelds.isNotEmpty) return false;
    final allTiles = hand.allTiles;
    if (allTiles.length != 17) return false;

    const required = {
      '1m', '9m', '1p', '9p', '1s', '9s',
      '1z', '2z', '3z', '4z', '5z', '6z', '7z',
    };

    final counts = TileUtils.buildTileCounts(allTiles);

    // Must contain all 13 required tiles at least once
    for (final r in required) {
      if ((counts[r] ?? 0) < 1) return false;
    }

    // Subtract the 13 required tiles
    final remaining = Map<String, int>.from(counts);
    for (final r in required) {
      remaining[r] = remaining[r]! - 1;
      if (remaining[r] == 0) remaining.remove(r);
    }

    // Remaining = 4 tiles = 1 pair (from the 13 types) + 3-tile meld (chow or pong)
    // The pair must be one of the 13 required tiles
    for (final tile in remaining.keys.toList()) {
      if (!required.contains(tile)) continue;
      if ((remaining[tile] ?? 0) < 1) continue;

      // Try this tile as the pair eye
      final afterPair = Map<String, int>.from(remaining);
      afterPair[tile] = afterPair[tile]! - 1;
      if (afterPair[tile] == 0) afterPair.remove(tile);

      // The remaining 3 tiles must form exactly one meld (chow or pong)
      final leftTiles = <String>[];
      for (final e in afterPair.entries) {
        for (int i = 0; i < e.value; i++) {
          leftTiles.add(e.key);
        }
      }
      if (leftTiles.length != 3) continue;

      // Check pong (all 3 same)
      if (leftTiles[0] == leftTiles[1] && leftTiles[1] == leftTiles[2]) {
        return true;
      }

      // Check chow (3 consecutive same suit, non-honor)
      leftTiles.sort(TileUtils.compareTiles);
      final s0 = leftTiles[0].substring(1);
      final s1 = leftTiles[1].substring(1);
      final s2 = leftTiles[2].substring(1);
      if (s0 == s1 && s1 == s2 && s0 != 'z') {
        final n0 = int.parse(leftTiles[0].substring(0, 1));
        final n1 = int.parse(leftTiles[1].substring(0, 1));
        final n2 = int.parse(leftTiles[2].substring(0, 1));
        if (n1 == n0 + 1 && n2 == n1 + 1) {
          return true;
        }
      }
    }
    return false;
  }

  /// 十六不搭 (Sixteen Non-Matching) — 50 Tai
  /// 17 tiles: all 7 honors + 3 tiles from each of 3 suits (m, p, s).
  /// Numbered tiles in each suit must be from separate non-adjacent groups:
  /// Groups: {1,4,7}, {2,5,8}, {3,6,9}. No two tiles in same suit can
  /// be adjacent or equal, and one tile is duplicated as the eye (pair).
  static bool _isSixteenNonMatching(List<String> tiles) {
    if (tiles.length != 17) return false;

    final counts = TileUtils.buildTileCounts(tiles);

    // Must have all 7 honor tiles at least once
    for (final h in ['1z', '2z', '3z', '4z', '5z', '6z', '7z']) {
      if ((counts[h] ?? 0) < 1) return false;
    }

    // Count total honor tiles (7 base + possibly 1 pair)
    final honorCount = ['1z', '2z', '3z', '4z', '5z', '6z', '7z']
        .fold<int>(0, (s, h) => s + (counts[h] ?? 0));
    // Honor count must be 7 (no honor pair) or 8 (one honor duplicated as pair)
    if (honorCount < 7 || honorCount > 8) return false;

    // No honor tile can appear more than 2 times
    for (final h in ['1z', '2z', '3z', '4z', '5z', '6z', '7z']) {
      if ((counts[h] ?? 0) > 2) return false;
    }

    final bool honorPair = honorCount == 8;

    // Collect numbered tiles per suit
    final suitTiles = <String, List<int>>{'m': [], 'p': [], 's': []};
    for (final e in counts.entries) {
      final tile = e.key;
      final suit = tile.substring(1);
      if (suit == 'z') continue;
      final num = int.parse(tile.substring(0, 1));
      for (int i = 0; i < e.value; i++) {
        suitTiles[suit]!.add(num);
      }
    }

    // Numbered tiles: 9 if honor pair, 10 if numbered pair
    final totalNumbered = suitTiles.values.fold<int>(0, (s, l) => s + l.length);
    final expectedNumbered = honorPair ? 9 : 10;
    if (totalNumbered != expectedNumbered) return false;

    // Each suit distribution
    final suitCounts = suitTiles.values.map((l) => l.length).toList()..sort();
    if (honorPair) {
      // All 3 suits must have exactly 3 tiles
      if (!(suitCounts[0] == 3 && suitCounts[1] == 3 && suitCounts[2] == 3)) {
        return false;
      }
    } else {
      // One suit has 4 tiles (includes pair), others have 3
      if (!(suitCounts[0] == 3 && suitCounts[1] == 3 && suitCounts[2] == 4)) {
        return false;
      }
    }

    // Check non-adjacency: no two tiles in same suit can be adjacent or equal
    for (final entry in suitTiles.entries) {
      final nums = entry.value;
      final uniqueNums = nums.toSet().toList()..sort();
      // No tile more than 2x (pair)
      final numCounts = <int, int>{};
      for (final n in nums) {
        numCounts[n] = (numCounts[n] ?? 0) + 1;
      }
      for (final c in numCounts.values) {
        if (c > 2) return false;
      }
      // At most one tile can be duplicated (the pair)
      final dupeCount = numCounts.values.where((c) => c == 2).length;
      if (dupeCount > 1) return false;
      // Check no two unique numbers are adjacent (diff must be > 1)
      for (int i = 0; i < uniqueNums.length; i++) {
        for (int j = i + 1; j < uniqueNums.length; j++) {
          if ((uniqueNums[j] - uniqueNums[i]).abs() <= 1) return false;
        }
      }
    }

    return true;
  }

  static void _checkBrothersAndSisters(
      TwHand hand, Map<String, int> allCounts,
      List<TwPatternMatch> matches) {
    // Brothers (兄弟): same NUMBER, different SUITS  (e.g. 1s×3 + 1p×3)
    // Sisters (姊妹): consecutive NUMBERS, same SUIT (e.g. 1s×3 + 2s×3)

    // Find all pong tiles (≥3 of same tile, non-honor)
    final pongTiles = allCounts.entries
        .where((e) => e.value >= 3 && !e.key.endsWith('z'))
        .map((e) => e.key)
        .toList();

    // ── Brothers — same number, different suits ──────────────────
    final byNum = <int, List<String>>{};
    for (final t in pongTiles) {
      final suit = t.substring(1);
      final num = int.parse(t.substring(0, 1));
      byNum.putIfAbsent(num, () => []).add(suit);
    }
    for (final entry in byNum.entries) {
      final num = entry.key;
      final suits = entry.value;
      if (suits.length >= 3) {
        // 大三兄弟 (15 Tai) — three pongs of same number, all 3 suits
        matches.add(const TwPatternMatch(
          id: 'bigThreeBrothers',
          nameKey: 'twBigThreeBrothers',
          tai: 15,
        ));
      } else if (suits.length == 2) {
        // 二兄弟 (3 Tai) — two pongs of same number, different suits
        matches.add(const TwPatternMatch(
          id: 'twoBrothers',
          nameKey: 'twTwoBrothers',
          tai: 3,
        ));
        // Check for 小三兄弟 (10 Tai) — 2 pongs + pair of 3rd suit same number
        final allSuits = ['m', 'p', 's'];
        for (final s in allSuits) {
          if (!suits.contains(s)) {
            final tile = '$num$s';
            if ((allCounts[tile] ?? 0) >= 2) {
              matches.add(const TwPatternMatch(
                id: 'smallThreeBrothers',
                nameKey: 'twSmallThreeBrothers',
                tai: 10,
              ));
            }
            break; // only one missing suit possible
          }
        }
      }
    }

    // ── Sisters — consecutive numbers, same suit ─────────────────
    final bySuit = <String, List<int>>{};
    for (final t in pongTiles) {
      final suit = t.substring(1);
      final num = int.parse(t.substring(0, 1));
      bySuit.putIfAbsent(suit, () => []).add(num);
    }
    for (final entry in bySuit.entries) {
      final suit = entry.key;
      final nums = entry.value;
      if (nums.length < 2) continue;
      nums.sort();

      // Find consecutive runs
      final runs = <List<int>>[];
      var currentRun = <int>[nums[0]];
      for (int i = 1; i < nums.length; i++) {
        if (nums[i] == nums[i - 1] + 1) {
          currentRun.add(nums[i]);
        } else {
          runs.add(currentRun);
          currentRun = [nums[i]];
        }
      }
      runs.add(currentRun);

      for (final run in runs) {
        if (run.length >= 3) {
          // 大三姊妹 (15 Tai) — three consecutive pongs, same suit
          matches.add(const TwPatternMatch(
            id: 'bigThreeSisters',
            nameKey: 'twBigThreeSisters',
            tai: 15,
          ));
        } else if (run.length == 2) {
          // Check for 小三姊妹 (8 Tai) — 2 consecutive pongs + adjacent pair
          final below = '${run[0] - 1}$suit';
          final above = '${run[1] + 1}$suit';
          if ((allCounts[below] ?? 0) >= 2 || (allCounts[above] ?? 0) >= 2) {
            matches.add(const TwPatternMatch(
              id: 'smallThreeSisters',
              nameKey: 'twSmallThreeSisters',
              tai: 8,
            ));
          }
        }
      }
    }
  }

  /// 全求人 / 半求人 shared check:
  /// All melds are exposed (上、碰、明槓), only 1 concealed tile remains
  /// (the eye / pair tile). The winning tile completes the pair.
  /// Concealed kongs (暗槓) do NOT count — must be open calls only.
  static bool _isRevealedHand(TwHand hand) {
    // Must have no concealed kongs — only open calls
    if (hand.concealedKongCount > 0) return false;
    // Only 1 tile left concealed (part of the pair/eye)
    if (hand.concealedTiles.length != 1) return false;
    // Must have exposed melds (at least 4 non-kong or 5 total depending on kongs)
    if (hand.exposedMelds.isEmpty) return false;
    return true;
  }

  static bool _isAllRevealed(TwHand hand) {
    // 全求人: revealed hand + win by discard (checked at call site via !isSelfDraw)
    return _isRevealedHand(hand);
  }

  static bool _isHalfRevealed(TwHand hand) {
    // 半求人: revealed hand + win by self-draw (checked at call site via isSelfDraw)
    return _isRevealedHand(hand);
  }

  static int _countOldYoung(TwHand hand) {
    // Old & Young: per suit, only these two forms are valid:
    // 1) chow 1-2-3 + chow 7-8-9
    // 2) pong 1 + pong 9
    // Mixed form (pong 1 + chow 789) or (chow 123 + pong 9) is NOT valid.
    final allTiles = hand.allTiles;
    final allCounts = TileUtils.buildTileCounts(allTiles);
    int count = 0;
    for (final suit in ['m', 'p', 's']) {
      final hasChow123 = allTiles.contains('1$suit') &&
          allTiles.contains('2$suit') &&
          allTiles.contains('3$suit');
      final hasChow789 = allTiles.contains('7$suit') &&
          allTiles.contains('8$suit') &&
          allTiles.contains('9$suit');
      final hasPong1 = (allCounts['1$suit'] ?? 0) >= 3;
      final hasPong9 = (allCounts['9$suit'] ?? 0) >= 3;

      if ((hasChow123 && hasChow789) || (hasPong1 && hasPong9)) {
        count++;
      }
    }
    return count;
  }

  // ═══════════════════════════════════════════════════════════════
  //  Exclusion rules
  // ═══════════════════════════════════════════════════════════════

  /// Apply TW Mahjong fan exclusion rules.
  ///
  /// Key rules:
  /// 1. 大平胡 does NOT count 無字花 (already included in its tai)
  /// 2. 四暗刻 does NOT count 三暗刻 or 二暗刻 (subsumed)
  /// 3. 五暗刻 does NOT count 四暗刻/三暗刻/二暗刻
  /// 4. 門清自摸 replaces 門清 + 自摸
  /// 5. 大三元 does NOT count individual dragon pongs
  /// 6. 小三元 does NOT count individual dragon pongs
  /// 7. 大四喜 does NOT count 小四喜 / 大三風 / 小三風 / individual winds
  /// 8. 小四喜 does NOT count 大三風 / 小三風 / individual winds
  /// 9. 大三風 does NOT count 小三風 / individual winds
  /// 10. 清一色 does NOT count 混一色 / 缺一門
  /// 11. 混一色 does NOT count 缺一門
  /// 12. 清么 does NOT count 混么 / 對對胡
  /// 13. 混么 does NOT count 對對胡
  /// 27. 五暗刻 does NOT count 對對胡
  /// 28. 間間胡 does NOT count 自摸/門清/門清自摸/對對胡/五暗刻
  /// 14. 兩台花 does NOT count 一台花
  /// 15. 四歸四 does NOT count 四歸二/四歸一
  /// 16. 四歸二 does NOT count 四歸一
  /// 17. 四般高 does NOT count 三般高/一般高
  /// 17b. 五同順 does NOT count 相逢與般高系列
  /// 18. 三般高 does NOT count 一般高
  /// 19. 暗龍 does NOT count 明龍
  /// 20. 暗雜龍 does NOT count 明雜龍
  /// 21. 大三兄弟 does NOT count 小三兄弟/二兄弟
  /// 22. 小三兄弟 does NOT count 二兄弟
  /// 23. 大三姊妹 does NOT count 小三姊妹
  /// 24. 全求人 does NOT count 半求人
  /// 25. 無字花 does NOT count 無字 + 無花
  /// 26. 全帶么 does NOT count 全帶混么
  static List<TwPatternMatch> _applyExclusions(List<TwPatternMatch> raw) {
    final ids = raw.map((m) => m.id).toSet();
    final result = <TwPatternMatch>[];

    for (final m in raw) {
      if (_shouldExclude(m.id, ids)) continue;
      result.add(m);
    }

    return result;
  }

  static bool _shouldExclude(String id, Set<String> allIds) {
    switch (id) {
      // 1. 大平胡 excludes 無字花, 無花, 無字, 平胡, 門清
      case 'noHonorsNoFlowers':
        return allIds.contains('grandPingHu');
      case 'noHonors':
        return allIds.contains('noHonorsNoFlowers') ||
            allIds.contains('grandPingHu');
      case 'noFlowers':
        return allIds.contains('noHonorsNoFlowers') ||
            allIds.contains('grandPingHu');
      case 'pingHu':
        return allIds.contains('grandPingHu');
      case 'concealedHand':
        // Excluded by 門清自摸 or 大平胡 or 間間胡
        return allIds.contains('concealedSelfDraw') ||
            allIds.contains('grandPingHu') ||
            allIds.contains('jianJianHu');

      // 2–3. Concealed pong exclusions
      case 'twoConcealedPongs':
        return allIds.contains('threeConcealedPongs') ||
            allIds.contains('fourConcealedPongs') ||
            allIds.contains('fiveConcealedPongs');
      case 'threeConcealedPongs':
        return allIds.contains('fourConcealedPongs') ||
            allIds.contains('fiveConcealedPongs');
      case 'fourConcealedPongs':
        return allIds.contains('fiveConcealedPongs');

      // 4. 門清自摸 replaces 門清 + 自摸
      case 'selfDraw':
        return allIds.contains('concealedSelfDraw') ||
            allIds.contains('jianJianHu');

      // 5–6. Dragon combo exclusions
      case 'dragonPong_5z':
      case 'dragonPong_6z':
      case 'dragonPong_7z':
        return allIds.contains('bigThreeDragons') ||
            allIds.contains('smallThreeDragons');

      // 7–9. Wind combo exclusions
      case 'properWind_1z':
      case 'properWind_2z':
      case 'properWind_3z':
      case 'properWind_4z':
      case 'ordinaryWind_1z':
      case 'ordinaryWind_2z':
      case 'ordinaryWind_3z':
      case 'ordinaryWind_4z':
        return allIds.contains('bigFourWinds') ||
            allIds.contains('smallFourWinds') ||
            allIds.contains('bigThreeWinds') ||
            allIds.contains('smallThreeWinds');
      case 'smallThreeWinds':
        return allIds.contains('bigThreeWinds') ||
            allIds.contains('smallFourWinds') ||
            allIds.contains('bigFourWinds');
      case 'bigThreeWinds':
        return allIds.contains('smallFourWinds') ||
            allIds.contains('bigFourWinds');
      case 'smallFourWinds':
        return allIds.contains('bigFourWinds');

      // 10–11. Suit exclusions
      case 'mixedOneSuit':
        return allIds.contains('pureOneSuit');
      case 'missingOneSuit':
        return allIds.contains('pureOneSuit') ||
            allIds.contains('mixedOneSuit');

      // 12–13. Terminal exclusions
      case 'mixedTerminalsPongs':
        return allIds.contains('pureTerminals');
      case 'allPongs':
        return allIds.contains('pureTerminals') ||
            allIds.contains('mixedTerminalsPongs') ||
            allIds.contains('fiveConcealedPongs') ||
            allIds.contains('jianJianHu');

      // 27–28. 間間胡 exclusions
      case 'fiveConcealedPongs':
        return allIds.contains('jianJianHu');
      case 'concealedSelfDraw':
        return allIds.contains('jianJianHu');

      // 14. Flower set exclusions
      case 'oneFlowerSet':
        return allIds.contains('twoFlowerSets');

      // 15–16. Four-to-X exclusions
      case 'fourToOne':
        return allIds.contains('fourToTwo') || allIds.contains('fourToFour');
      case 'fourToTwo':
        return allIds.contains('fourToFour');

      // 17–18. Identical sequence exclusions
      case 'twoIdenticalSeq':
        return allIds.contains('threeIdenticalSeq') ||
            allIds.contains('fourIdenticalSeq') ||
            allIds.contains('fiveIdenticalSeq');
      case 'threeIdenticalSeq':
        return allIds.contains('fourIdenticalSeq') ||
            allIds.contains('fiveIdenticalSeq');
      case 'fourIdenticalSeq':
        return allIds.contains('fiveIdenticalSeq');

      // 19–20. Dragon pattern exclusions
      case 'oldYoung':
        return allIds.contains('concealedDragon');
      case 'exposedDragon':
        return allIds.contains('concealedDragon');
      case 'exposedMixedDragon':
        return allIds.contains('concealedMixedDragon');

      // 21–22. Brother exclusions
      case 'twoBrothers':
        return allIds.contains('smallThreeBrothers') ||
            allIds.contains('bigThreeBrothers');
      case 'smallThreeBrothers':
        return allIds.contains('bigThreeBrothers');

      // 23. Sister exclusions
      case 'smallThreeSisters':
        return allIds.contains('bigThreeSisters');

      // 24. Revealed exclusions
      case 'halfRevealed':
        return allIds.contains('allRevealed');

      // 25. 無字花 replaces individual 無字 + 無花
      // Already handled above through noHonors and noFlowers exclusions

      // 26. Terminal chow exclusions
      case 'mixedTerminalChows':
        return allIds.contains('pureTerminalChows') ||
            allIds.contains('mixedTerminalsPongs');

      case 'pureTerminalChows':
        return allIds.contains('pureTerminals');

      // 27b. 全混么 / 半帶混么 exclusions
      case 'quanHunYao':
        return allIds.contains('pureTerminals') ||
            allIds.contains('pureTerminalChows');
      case 'banDaiHunYao':
        return allIds.contains('mixedTerminalsPongs') ||
            allIds.contains('quanHunYao') ||
            allIds.contains('mixedTerminalChows');

      // Mixed double seq excluded by triple
      case 'mixedDoubleSeq':
        return allIds.contains('fiveIdenticalSeq');
      case 'mixedTripleSeq':
        return allIds.contains('fiveIdenticalSeq');

      default:
        return false;
    }
  }
}
