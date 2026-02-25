import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/logic/tile_utils.dart';

void main() {
  group('TileUtils', () {
    group('compareTiles', () {
      test('same suit, different number — sorts ascending', () {
        expect(TileUtils.compareTiles('3m', '7m'), isNegative);
        expect(TileUtils.compareTiles('9s', '1s'), isPositive);
      });

      test('different suit — sorts m < p < s < z', () {
        expect(TileUtils.compareTiles('1m', '1p'), isNegative);
        expect(TileUtils.compareTiles('1p', '1s'), isNegative);
        expect(TileUtils.compareTiles('1s', '1z'), isNegative);
        expect(TileUtils.compareTiles('9z', '1m'), isPositive);
      });

      test('identical tiles return 0', () {
        expect(TileUtils.compareTiles('5p', '5p'), equals(0));
      });
    });

    group('sortTiles', () {
      test('returns tiles in canonical order', () {
        final unsorted = ['3s', '1z', '9m', '1m', '5p'];
        final sorted = TileUtils.sortTiles(unsorted);
        expect(sorted, equals(['1m', '9m', '5p', '3s', '1z']));
      });

      test('does not mutate original list', () {
        final original = ['5p', '1m'];
        TileUtils.sortTiles(original);
        expect(original, equals(['5p', '1m']));
      });
    });

    group('buildTileCounts', () {
      test('counts each tile correctly', () {
        final tiles = ['1m', '1m', '1m', '2m', '2m'];
        final counts = TileUtils.buildTileCounts(tiles);
        expect(counts, equals({'1m': 3, '2m': 2}));
      });

      test('empty list → empty map', () {
        expect(TileUtils.buildTileCounts([]), isEmpty);
      });
    });

    group('removeTile', () {
      test('decrements count', () {
        final counts = {'1m': 3, '2m': 1};
        TileUtils.removeTile(counts, '1m');
        expect(counts['1m'], equals(2));
      });

      test('removes key when count reaches 0', () {
        final counts = {'1m': 1};
        TileUtils.removeTile(counts, '1m');
        expect(counts.containsKey('1m'), isFalse);
      });

      test('no-op for missing tile', () {
        final counts = {'1m': 1};
        TileUtils.removeTile(counts, '9s');
        expect(counts, equals({'1m': 1}));
      });
    });
  });
}
