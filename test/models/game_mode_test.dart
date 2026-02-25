import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/models/game_mode.dart';

void main() {
  group('GameMode', () {
    test('hongKong name', () {
      expect(GameMode.hongKong.name, equals('Hong Kong'));
    });

    test('taiwan name', () {
      expect(GameMode.taiwan.name, equals('Taiwan'));
    });

    test('hongKong label', () {
      expect(GameMode.hongKong.label, contains('Hong Kong'));
      expect(GameMode.hongKong.label, contains('13'));
    });

    test('taiwan label', () {
      expect(GameMode.taiwan.label, contains('Taiwan'));
      expect(GameMode.taiwan.label, contains('16'));
    });

    test('enum values', () {
      expect(GameMode.values.length, equals(2));
      expect(GameMode.values, contains(GameMode.hongKong));
      expect(GameMode.values, contains(GameMode.taiwan));
    });
  });
}
