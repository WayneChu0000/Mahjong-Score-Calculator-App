import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/models/player.dart';

void main() {
  group('Player', () {
    test('constructor stores all fields', () {
      const p = Player(id: 1, name: 'Alice', score: 100);
      expect(p.id, equals(1));
      expect(p.name, equals('Alice'));
      expect(p.score, equals(100));
    });

    test('copyWith overrides id', () {
      const p = Player(id: 1, name: 'Alice', score: 100);
      final p2 = p.copyWith(id: 99);
      expect(p2.id, equals(99));
      expect(p2.name, equals('Alice'));
      expect(p2.score, equals(100));
    });

    test('copyWith overrides name', () {
      const p = Player(id: 1, name: 'Alice', score: 100);
      final p2 = p.copyWith(name: 'Bob');
      expect(p2.name, equals('Bob'));
      expect(p2.id, equals(1));
    });

    test('copyWith overrides score', () {
      const p = Player(id: 1, name: 'Alice', score: 100);
      final p2 = p.copyWith(score: 200);
      expect(p2.score, equals(200));
      expect(p2.name, equals('Alice'));
    });

    test('copyWith with no args returns equivalent player', () {
      const p = Player(id: 1, name: 'Alice', score: 100);
      final p2 = p.copyWith();
      expect(p2.id, equals(p.id));
      expect(p2.name, equals(p.name));
      expect(p2.score, equals(p.score));
    });

    test('const players with same values are identical', () {
      const p1 = Player(id: 1, name: 'Alice', score: 0);
      const p2 = Player(id: 1, name: 'Alice', score: 0);
      expect(identical(p1, p2), isTrue);
    });
  });
}
