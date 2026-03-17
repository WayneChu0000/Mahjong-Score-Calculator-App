/// Tests for 全帶么 (15 tai) and 全帶混么 (10 tai)
/// with exclusion behavior against related terminal-group hands.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/controllers/score_calculation_controller.dart';
import 'package:flutter_application_1/models/player.dart';
import 'package:flutter_application_1/models/game_mode.dart';
import 'package:flutter_application_1/models/tw_hand.dart';
import 'package:flutter_application_1/localization/app_localizations.dart';

void main() {
  AppLocalizations.setLocale('Traditional Chinese');

  final players = [
    Player(id: 0, name: 'A', score: 0),
    Player(id: 1, name: 'B', score: 0),
    Player(id: 2, name: 'C', score: 0),
    Player(id: 3, name: 'D', score: 0),
  ];

  ScoreCalculationController makeCtrl({
    required TwHand hand,
    bool isSelfDraw = false,
    String? discardPlayer,
  }) {
    final ctrl = ScoreCalculationController(
      players: players,
      minFan: 2,
      maxFan: 1,
      gameMode: GameMode.taiwan,
      consecutiveDealerCount: 1,
      dealerIndex: 0,
      roundWindIndex: 0,
    );
    ctrl.winningPlayer = 'B';
    ctrl.isSelfDraw = isSelfDraw;
    if (!isSelfDraw) ctrl.discardPlayer = discardPlayer ?? 'A';
    ctrl.roundWind = 'East';
    ctrl.seatWind = 'South';
    ctrl.selectedSpecialCondition = 'None';
    ctrl.setTwHand(hand);
    return ctrl;
  }

  List<String> ruleNames(ScoreCalculationController c) =>
      c.displayRules.map((r) => r['name'] as String).toList();

  bool has(ScoreCalculationController c, String keyword) =>
      ruleNames(c).any((n) => n.contains(keyword));

  // ═══════════════════════════════════════════════════════════════
  // 全帶么 (15 tai)
  // ═══════════════════════════════════════════════════════════════
  group('全帶么 — Pure Terminal Groups (15 tai)', () {
    test('mixed composition: chows + pongs, all contain 1/9, no honors → 全帶么', () {
      // 1m1m1m (pong) + 1p2p3p (chow) + 7s8s9s (chow) + 9m9m9m (pong) + 1s2s3s (chow) + 9p9p (pair)
      final c = makeCtrl(
        hand: const TwHand(
          exposedMelds: [
            Meld(type: MeldType.pong, tiles: ['1m', '1m', '1m']),
          ],
          concealedTiles: [
            '1p', '2p', '3p',
            '7s', '8s', '9s',
            '9m', '9m', '9m',
            '1s', '2s', '3s',
            '9p',
          ],
          winningTile: '9p',
        ),
      );
      expect(has(c, '全帶么'), true, reason: 'rules=${ruleNames(c)}');
    });

    test('all concealed chows + pong: 1m2m3m + 7p8p9p + 1s1s1s + 7m8m9m + 9s9s → 全帶么', () {
      final c = makeCtrl(
        hand: const TwHand(
          exposedMelds: [],
          concealedTiles: [
            '1m', '2m', '3m',
            '7p', '8p', '9p',
            '1s', '1s', '1s',
            '7m', '8m', '9m',
            '1p', '2p', '3p',
            '9s',
          ],
          winningTile: '9s',
        ),
      );
      expect(has(c, '全帶么'), true, reason: 'rules=${ruleNames(c)}');
    });

    test('has honor tile → NOT 全帶么', () {
      final c = makeCtrl(
        hand: const TwHand(
          exposedMelds: [
            Meld(type: MeldType.pong, tiles: ['1z', '1z', '1z']), // honor
          ],
          concealedTiles: [
            '1m', '2m', '3m',
            '7p', '8p', '9p',
            '1s', '2s', '3s',
            '7m', '8m', '9m',
            '9s',
          ],
          winningTile: '9s',
        ),
      );
      expect(has(c, '全帶么'), false, reason: 'Has honor tiles');
    });

    test('has tile 5m (middle) → NOT 全帶么', () {
      final c = makeCtrl(
        hand: const TwHand(
          exposedMelds: [],
          concealedTiles: [
            '1m', '2m', '3m',
            '4p', '5p', '6p', // contains 4,5,6
            '7s', '8s', '9s',
            '1s', '2s', '3s',
            '9m', '9m', '9m',
            '1p',
          ],
          winningTile: '1p',
        ),
      );
      expect(has(c, '全帶么'), false, reason: 'Has tiles 4-6');
    });

    test('exposed meld without terminal (pong of 2) → NOT 全帶么', () {
      final c = makeCtrl(
        hand: const TwHand(
          exposedMelds: [
            Meld(type: MeldType.pong, tiles: ['2m', '2m', '2m']), // no terminal!
          ],
          concealedTiles: [
            '1p', '2p', '3p',
            '7s', '8s', '9s',
            '1s', '2s', '3s',
            '7m', '8m', '9m',
            '9p',
          ],
          winningTile: '9p',
        ),
      );
      expect(has(c, '全帶么'), false, reason: 'Exposed pong of 2m has no terminal');
    });

    test('pair is 2s (not terminal) → NOT 全帶么', () {
      // If pair must contain terminal, pair of 2 is invalid
      // 1m2m3m + 7p8p9p + 1s1s1s + 7m8m9m + 1p2p3p + 2s2s (pair)
      // The concealed tiles include 2s×2 as pair which doesn't have a terminal
      // BUT the decomposition might find alternative arrangements...
      // Actually: 2s×2 can only be a pair (not enough for pong), and pair of 2 is not terminal
      final c = makeCtrl(
        hand: const TwHand(
          exposedMelds: [
            Meld(type: MeldType.pong, tiles: ['1m', '1m', '1m']),
            Meld(type: MeldType.chow, tiles: ['7p', '8p', '9p']),
            Meld(type: MeldType.chow, tiles: ['1s', '2s', '3s']),
            Meld(type: MeldType.chow, tiles: ['7m', '8m', '9m']),
          ],
          concealedTiles: [
            '1p', '2p', '3p',
            '2s',
          ],
          winningTile: '2s',
        ),
      );
      expect(has(c, '全帶么'), false,
          reason: 'Pair of 2s has no terminal. rules=${ruleNames(c)}');
    });

    test('全帶么 tai = 15', () {
      final c = makeCtrl(
        hand: const TwHand(
          exposedMelds: [
            Meld(type: MeldType.pong, tiles: ['1m', '1m', '1m']),
          ],
          concealedTiles: [
            '1p', '2p', '3p',
            '7s', '8s', '9s',
            '9m', '9m', '9m',
            '1s', '2s', '3s',
            '9p',
          ],
          winningTile: '9p',
        ),
      );
      final rule = c.displayRules.firstWhere(
        (r) => (r['name'] as String).contains('全帶么'),
        orElse: () => {'fan': -1},
      );
      expect(rule['fan'], 15, reason: '全帶么 should be 15 tai');
    });
  });

  // ═══════════════════════════════════════════════════════════════
  // 全帶混么 (10 tai)
  // ═══════════════════════════════════════════════════════════════
  group('全帶混么 — Mixed Terminal Groups (10 tai)', () {
    test('mixed composition with honors: chows + honor pong → 全帶混么', () {
      // 1z1z1z (honor pong) + 1m2m3m (chow) + 7p8p9p (chow) + 9s9s9s (pong) + 1p2p3p (chow) + 9m9m (pair)
      final c = makeCtrl(
        hand: const TwHand(
          exposedMelds: [
            Meld(type: MeldType.pong, tiles: ['1z', '1z', '1z']),
          ],
          concealedTiles: [
            '1m', '2m', '3m',
            '7p', '8p', '9p',
            '9s', '9s', '9s',
            '1p', '2p', '3p',
            '9m',
          ],
          winningTile: '9m',
        ),
      );
      expect(has(c, '全帶混么'), true, reason: 'rules=${ruleNames(c)}');
    });

    test('honor pair: 1m2m3m + 7s8s9s + 9p9p9p + 1s2s3s + 7m8m9m + 5z5z → 全帶混么', () {
      final c = makeCtrl(
        hand: const TwHand(
          exposedMelds: [],
          concealedTiles: [
            '1m', '2m', '3m',
            '7s', '8s', '9s',
            '9p', '9p', '9p',
            '1s', '2s', '3s',
            '7m', '8m', '9m',
            '5z',
          ],
          winningTile: '5z',
        ),
      );
      expect(has(c, '全帶混么'), true, reason: 'rules=${ruleNames(c)}');
    });

    test('no honors → NOT 全帶混么', () {
      final c = makeCtrl(
        hand: const TwHand(
          exposedMelds: [
            Meld(type: MeldType.pong, tiles: ['1m', '1m', '1m']),
          ],
          concealedTiles: [
            '1p', '2p', '3p',
            '7s', '8s', '9s',
            '9m', '9m', '9m',
            '1s', '2s', '3s',
            '9p',
          ],
          winningTile: '9p',
        ),
      );
      expect(has(c, '全帶混么'), false, reason: 'No honors present');
    });

    test('全帶混么 tai = 10', () {
      final c = makeCtrl(
        hand: const TwHand(
          exposedMelds: [
            Meld(type: MeldType.pong, tiles: ['1z', '1z', '1z']),
          ],
          concealedTiles: [
            '1m', '2m', '3m',
            '7p', '8p', '9p',
            '9s', '9s', '9s',
            '1p', '2p', '3p',
            '9m',
          ],
          winningTile: '9m',
        ),
      );
      final rule = c.displayRules.firstWhere(
        (r) => (r['name'] as String).contains('全帶混么'),
        orElse: () => {'fan': -1},
      );
      expect(rule['fan'], 10, reason: '全帶混么 should be 10 tai');
    });
  });

  // ═══════════════════════════════════════════════════════════════
  // Exclusion rules
  // ═══════════════════════════════════════════════════════════════
  group('Exclusion rules', () {
    test('全混么 is excluded by 全帶么', () {
      // All groups contain terminals and no honors.
      // New precedence keeps 全帶么 and hides 全混么.
      final c = makeCtrl(
        hand: const TwHand(
          exposedMelds: [],
          concealedTiles: [
            '1m', '2m', '3m',
            '7p', '8p', '9p',
            '1s', '2s', '3s',
            '7m', '8m', '9m',
            '1p', '2p', '3p',
            '9s',
          ],
          winningTile: '9s',
        ),
      );
      expect(has(c, '全帶么'), true, reason: 'rules=${ruleNames(c)}');
      expect(has(c, '全混么'), false,
          reason: '全混么 should be excluded by 全帶么. rules=${ruleNames(c)}');
    });

    test('半帶混么 is excluded by 全帶混么', () {
      // All groups contain terminals/honors and include honors.
      // New precedence keeps 全帶混么 and hides 半帶混么.
      final c = makeCtrl(
        hand: const TwHand(
          exposedMelds: [],
          concealedTiles: [
            '1m', '2m', '3m',
            '7p', '8p', '9p',
            '1s', '2s', '3s',
            '7m', '8m', '9m',
            '1z', '1z', '1z',
            '9s',
          ],
          winningTile: '9s',
        ),
      );
      expect(has(c, '全帶混么'), true, reason: 'rules=${ruleNames(c)}');
      expect(has(c, '半帶混么'), false,
          reason: '半帶混么 should be excluded by 全帶混么. rules=${ruleNames(c)}');
    });

    test('清么 (80 tai) excludes 全帶么', () {
      // All tiles are 1 and 9 only (all pongs) → 清么 (80) present, 全帶么 excluded
      final c = makeCtrl(
        hand: const TwHand(
          exposedMelds: [
            Meld(type: MeldType.pong, tiles: ['1m', '1m', '1m']),
            Meld(type: MeldType.pong, tiles: ['9p', '9p', '9p']),
            Meld(type: MeldType.pong, tiles: ['1s', '1s', '1s']),
            Meld(type: MeldType.pong, tiles: ['9m', '9m', '9m']),
            Meld(type: MeldType.pong, tiles: ['1p', '1p', '1p']),
          ],
          concealedTiles: ['9s'],
          winningTile: '9s',
        ),
      );
      expect(has(c, '清么'), true, reason: 'rules=${ruleNames(c)}');
      expect(has(c, '全帶么'), false,
          reason: '全帶么 should be excluded by 清么. rules=${ruleNames(c)}');
    });

    test('混么 (30 tai) excludes 全帶混么', () {
      // All pongs of 1/9/honors → 混么 present, 全帶混么 excluded
      final c = makeCtrl(
        hand: const TwHand(
          exposedMelds: [
            Meld(type: MeldType.pong, tiles: ['1m', '1m', '1m']),
            Meld(type: MeldType.pong, tiles: ['9p', '9p', '9p']),
            Meld(type: MeldType.pong, tiles: ['1z', '1z', '1z']),
            Meld(type: MeldType.pong, tiles: ['9m', '9m', '9m']),
            Meld(type: MeldType.pong, tiles: ['5z', '5z', '5z']),
          ],
          concealedTiles: ['9s'],
          winningTile: '9s',
        ),
      );
      expect(has(c, '混么'), true, reason: 'rules=${ruleNames(c)}');
      expect(has(c, '全帶混么'), false,
          reason: '全帶混么 should be excluded by 混么. rules=${ruleNames(c)}');
    });
  });
}
