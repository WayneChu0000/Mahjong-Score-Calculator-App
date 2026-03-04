import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/services/score_service.dart';
import 'package:flutter_application_1/models/player.dart';

void main() {
  late ScoreService service;

  setUp(() {
    service = ScoreService();
    // Reset state by re-initialising with fresh players
    service.initGame(
      [
        Player(id: 0, name: 'Alice', score: 100),
        Player(id: 1, name: 'Bob', score: 200),
      ],
      initialPublicScore: 0,
      currentRound: 1,
      totalRounds: 8,
    );
  });

  group('ScoreService', () {
    test('initGame sets player scores correctly', () {
      expect(service.getPlayerScore('0'), equals(100));
      expect(service.getPlayerScore('1'), equals(200));
    });

    test('initGame sets public score and rounds', () {
      expect(service.getPublicScore(), equals(0));
      expect(service.getCurrentRound(), equals(1));
      expect(service.getTotalRounds(), equals(8));
    });

    test('getPlayerScore returns 0 for unknown player', () {
      expect(service.getPlayerScore('99'), equals(0));
    });

    test('updateScores adjusts player scores', () {
      service.updateScores({'0': 50, '1': -50});
      expect(service.getPlayerScore('0'), equals(150));
      expect(service.getPlayerScore('1'), equals(150));
    });

    test('updateScores adjusts public score', () {
      service.updateScores({}, publicScoreChange: 10);
      expect(service.getPublicScore(), equals(10));
    });

    test('incrementRound advances round by 1', () {
      service.incrementRound();
      expect(service.getCurrentRound(), equals(2));
    });

    test('isGameEnd returns false before completing all rounds', () {
      expect(service.isGameEnd(), isFalse);
    });

    test('isGameEnd returns true after all rounds complete', () {
      for (int i = 0; i < 8; i++) {
        service.incrementRound();
      }
      expect(service.isGameEnd(), isTrue);
    });

    test('isGameEnd returns false for unlimited rounds (totalRounds=0)', () {
      service.initGame([
        Player(id: 0, name: 'Alice', score: 0),
      ], totalRounds: 0);
      for (int i = 0; i < 100; i++) {
        service.incrementRound();
      }
      expect(service.isGameEnd(), isFalse);
    });

    test('getGameData returns all state', () {
      final data = service.getGameData();
      expect(data['0'], equals(100));
      expect(data['1'], equals(200));
      expect(data['publicScore'], equals(0));
      expect(data['currentRound'], equals(1));
      expect(data['totalRounds'], equals(8));
    });

    test('scoreStream emits on updateScores', () {
      expectLater(service.scoreStream, emits(isA<Map<String, dynamic>>()));
      service.updateScores({'0': 10});
    });
  });
}
