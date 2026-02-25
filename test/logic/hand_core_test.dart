import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/logic/hand_core.dart';

void main() {
  group('HandCore.checkSets', () {
    test('empty map with 0 kongs → true', () {
      expect(HandCore.checkSets({}, 0), isTrue);
    });

    test('empty map with 1 kong needed → false', () {
      expect(HandCore.checkSets({}, 1), isFalse);
    });

    // 3 consecutive tiles (chow)
    test('single chow → valid', () {
      final counts = {'1m': 1, '2m': 1, '3m': 1};
      expect(HandCore.checkSets(counts, 0), isTrue);
    });

    // 3 identical tiles (pong)
    test('single pong → valid', () {
      final counts = {'5p': 3};
      expect(HandCore.checkSets(counts, 0), isTrue);
    });

    // 4 identical tiles when kong needed
    test('single kong when kong needed → valid', () {
      final counts = {'9s': 4};
      expect(HandCore.checkSets(counts, 1), isTrue);
    });

    test('kong tiles but 0 kongs needed → try pong first, fail', () {
      // 4 tiles can't form 1 pong + 1 remaining
      final counts = {'9s': 4};
      expect(HandCore.checkSets(counts, 0), isFalse);
    });

    // Two chows
    test('two chows of different suits → valid', () {
      final counts = {'1m': 1, '2m': 1, '3m': 1, '4p': 1, '5p': 1, '6p': 1};
      expect(HandCore.checkSets(counts, 0), isTrue);
    });

    // Honor tiles cannot form chow
    test('honor tiles as sequence → invalid', () {
      final counts = {'1z': 1, '2z': 1, '3z': 1};
      expect(HandCore.checkSets(counts, 0), isFalse);
    });

    test('honor tiles as pong → valid', () {
      final counts = {'5z': 3};
      expect(HandCore.checkSets(counts, 0), isTrue);
    });

    // chow disabled
    test('allowChow=false rejects chow', () {
      final counts = {'1m': 1, '2m': 1, '3m': 1};
      expect(
        HandCore.checkSets(counts, 0, allowChow: false),
        isFalse,
      );
    });

    // pong disabled
    test('allowPong=false rejects pong', () {
      final counts = {'5p': 3};
      expect(
        HandCore.checkSets(counts, 0, allowPong: false),
        isFalse,
      );
    });

    // Complex: mix of chows and pongs
    test('pong + chow → valid', () {
      // 1m 1m 1m + 2p 3p 4p
      final counts = {'1m': 3, '2p': 1, '3p': 1, '4p': 1};
      expect(HandCore.checkSets(counts, 0), isTrue);
    });

    test('cannot form valid sets → false', () {
      final counts = {'1m': 1, '3m': 1, '5m': 1};
      expect(HandCore.checkSets(counts, 0), isFalse);
    });
  });

  group('HandCore.checkSpecificHand', () {
    // 14-tile pinghu hand (all chows + pair)
    test('valid all-chow hand (14 tiles) with allowPong=false', () {
      // 1m2m3m 4m5m6m 7m8m9m 1p2p3p + 5s5s (pair)
      final tiles = [
        '1m', '2m', '3m', '4m', '5m', '6m', '7m', '8m', '9m',
        '1p', '2p', '3p', '5s', '5s',
      ];
      expect(
        HandCore.checkSpecificHand(tiles, allowChow: true, allowPong: false),
        isTrue,
      );
    });

    // 14-tile all-pong hand
    test('valid all-pong hand (14 tiles) with allowChow=false', () {
      // 1m×3 5p×3 9s×3 3z×3 + 7z×2 (pair)
      final tiles = [
        '1m', '1m', '1m', '5p', '5p', '5p', '9s', '9s', '9s',
        '3z', '3z', '3z', '7z', '7z',
      ];
      expect(
        HandCore.checkSpecificHand(tiles, allowChow: false, allowPong: true),
        isTrue,
      );
    });

    test('only 10 tiles → too few for either base, returns false', () {
      final tiles = ['1m', '2m', '3m', '4m', '5m', '6m', '7m', '8m', '9m', '1p'];
      expect(
        HandCore.checkSpecificHand(tiles, allowChow: true, allowPong: true),
        isFalse,
      );
    });
  });

  group('HandCore.validateStructure', () {
    test('valid 4-meld + pair structure (14 tiles, 0 kongs)', () {
      // 1m2m3m 4m5m6m 7m8m9m 1p1p1p + 5z5z
      final tiles = [
        '1m', '2m', '3m', '4m', '5m', '6m', '7m', '8m', '9m',
        '1p', '1p', '1p', '5z', '5z',
      ];
      expect(HandCore.validateStructure(tiles, 0, true, true), isTrue);
    });

    test('invalid grouping → false', () {
      final tiles = [
        '1m', '1m', '2m', '3m', '5m', '6m', '7m', '8m', '9m',
        '1p', '2p', '3p', '5z', '5z',
      ];
      expect(HandCore.validateStructure(tiles, 0, true, true), isFalse);
    });
  });
}
