import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/logic/hand_validator.dart';
import 'package:flutter_application_1/models/game_mode.dart';

void main() {
  group('HandValidator.checkWinningHand — Hong Kong mode', () {
    test('valid standard hand (4 melds + pair) → valid', () {
      // 1m2m3m 4m5m6m 7m8m9m 1p1p1p + 5z5z
      final tiles = [
        '1m',
        '2m',
        '3m',
        '4m',
        '5m',
        '6m',
        '7m',
        '8m',
        '9m',
        '1p',
        '1p',
        '1p',
        '5z',
        '5z',
      ];
      final result = HandValidator.checkWinningHand(tiles);
      expect(result['valid'], isTrue);
    });

    test('thirteen orphans → valid', () {
      final tiles = [
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
        '1m',
      ];
      final result = HandValidator.checkWinningHand(tiles);
      expect(result['valid'], isTrue);
    });

    test('seven pairs → valid', () {
      final tiles = [
        '1m',
        '1m',
        '3m',
        '3m',
        '5p',
        '5p',
        '9p',
        '9p',
        '2s',
        '2s',
        '7s',
        '7s',
        '1z',
        '1z',
      ];
      final result = HandValidator.checkWinningHand(tiles);
      expect(result['valid'], isTrue);
    });

    test('invalid hand → not valid', () {
      final tiles = [
        '1m',
        '2m',
        '4m',
        '5m',
        '7m',
        '8m',
        '1p',
        '3p',
        '5p',
        '7p',
        '9p',
        '1z',
        '3z',
        '5z',
      ];
      final result = HandValidator.checkWinningHand(tiles);
      expect(result['valid'], isFalse);
    });

    test('too few tiles → invalid', () {
      final tiles = ['1m', '2m', '3m'];
      final result = HandValidator.checkWinningHand(tiles);
      expect(result['valid'], isFalse);
    });

    test('too many tiles → invalid', () {
      final tiles = List.filled(22, '1m');
      final result = HandValidator.checkWinningHand(tiles);
      expect(result['valid'], isFalse);
    });

    test('15 tiles with 1 kong → valid', () {
      // 1m×4 (kong) + 4m5m6m 7m8m9m 1p2p3p + 5z5z
      final tiles = [
        '1m',
        '1m',
        '1m',
        '1m',
        '4m',
        '5m',
        '6m',
        '7m',
        '8m',
        '9m',
        '1p',
        '2p',
        '3p',
        '5z',
        '5z',
      ];
      final result = HandValidator.checkWinningHand(tiles);
      expect(result['valid'], isTrue);
    });

    test('all pong hand → valid', () {
      final tiles = [
        '1m',
        '1m',
        '1m',
        '5p',
        '5p',
        '5p',
        '9s',
        '9s',
        '9s',
        '3z',
        '3z',
        '3z',
        '7z',
        '7z',
      ];
      final result = HandValidator.checkWinningHand(tiles);
      expect(result['valid'], isTrue);
    });
  });

  group('HandValidator.checkWinningHand — Taiwan mode', () {
    test('valid 17-tile TW hand (5 melds + pair) → valid', () {
      // 1m2m3m 4m5m6m 7m8m9m 1p2p3p 4p5p6p + 5z5z
      final tiles = [
        '1m',
        '2m',
        '3m',
        '4m',
        '5m',
        '6m',
        '7m',
        '8m',
        '9m',
        '1p',
        '2p',
        '3p',
        '4p',
        '5p',
        '6p',
        '5z',
        '5z',
      ];
      final result = HandValidator.checkWinningHand(
        tiles,
        gameMode: GameMode.taiwan,
      );
      expect(result['valid'], isTrue);
    });

    test('eight pairs (17 tiles) → valid', () {
      // 8 pairs needs 16 tiles, 17-tile form: one triple counts as a pair + extra
      final tiles = [
        '1m',
        '1m',
        '1m',
        '3m',
        '3m',
        '5p',
        '5p',
        '9p',
        '9p',
        '2s',
        '2s',
        '7s',
        '7s',
        '1z',
        '1z',
        '3z',
        '3z',
      ];
      final result = HandValidator.checkWinningHand(
        tiles,
        gameMode: GameMode.taiwan,
      );
      expect(result['valid'], isTrue);
    });

    test('14-tile hand in TW mode → invalid (need 17)', () {
      final tiles = [
        '1m',
        '2m',
        '3m',
        '4m',
        '5m',
        '6m',
        '7m',
        '8m',
        '9m',
        '1p',
        '1p',
        '1p',
        '5z',
        '5z',
      ];
      final result = HandValidator.checkWinningHand(
        tiles,
        gameMode: GameMode.taiwan,
      );
      expect(result['valid'], isFalse);
    });
  });
}
