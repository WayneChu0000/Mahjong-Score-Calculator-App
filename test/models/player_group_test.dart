import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/models/player_group.dart';
import 'package:flutter_application_1/models/game_mode.dart';

void main() {
  group('PlayerGroup', () {
    test('constructor sets defaults', () {
      final g = PlayerGroup(name: 'Test', players: ['Alice', 'Bob']);
      expect(g.name, equals('Test'));
      expect(g.players, equals(['Alice', 'Bob']));
      expect(g.minFan, equals(3));
      expect(g.maxFan, equals(13));
      expect(g.gameMode, equals(GameMode.hongKong));
      expect(g.totalGamesPlayedInGroup, equals(0));
      expect(g.createdAt, isNotNull);
    });

    test('constructor with custom minFan/maxFan', () {
      final g = PlayerGroup(
        name: 'TW',
        players: ['A', 'B', 'C', 'D'],
        minFan: 10,
        maxFan: 5,
        gameMode: GameMode.taiwan,
      );
      expect(g.minFan, equals(10));
      expect(g.maxFan, equals(5));
      expect(g.gameMode, equals(GameMode.taiwan));
    });

    test('toJson contains all essential fields', () {
      final g = PlayerGroup(
        name: 'Test',
        players: ['Alice', 'Bob', 'Charlie', 'Diana'],
        minFan: 3,
        maxFan: 13,
        gameMode: GameMode.hongKong,
      );
      final json = g.toJson();
      expect(json['name'], equals('Test'));
      expect(json['players'], equals(['Alice', 'Bob', 'Charlie', 'Diana']));
      expect(json['minFan'], equals(3));
      expect(json['maxFan'], equals(13));
      expect(json['gameMode'], equals('GameMode.hongKong'));
      expect(json['createdAt'], isA<String>());
    });

    test('fromJson parses all fields', () {
      final json = {
        'name': 'Parsed',
        'players': ['X', 'Y'],
        'createdAt': '2025-01-15T10:00:00.000Z',
        'minFan': 5,
        'maxFan': 10,
        'gameMode': 'GameMode.taiwan',
        'totalGamesPlayedInGroup': 7,
        'currentRound': 3,
        'dealerIndex': 1,
      };
      final g = PlayerGroup.fromJson(json);
      expect(g.name, equals('Parsed'));
      expect(g.players, equals(['X', 'Y']));
      expect(g.minFan, equals(5));
      expect(g.maxFan, equals(10));
      expect(g.gameMode, equals(GameMode.taiwan));
      expect(g.totalGamesPlayedInGroup, equals(7));
      expect(g.currentRound, equals(3));
      expect(g.dealerIndex, equals(1));
    });

    test('fromJson with missing optional fields uses defaults', () {
      final json = {
        'name': 'Min',
        'players': ['A'],
        'createdAt': '2025-06-01T00:00:00.000Z',
      };
      final g = PlayerGroup.fromJson(json);
      expect(g.minFan, equals(3));
      expect(g.maxFan, equals(13));
      expect(g.gameMode, equals(GameMode.hongKong));
      expect(g.totalGamesPlayedInGroup, equals(0));
      expect(g.currentScores, isNull);
      expect(g.dealerIndex, isNull);
    });

    test('toJson → fromJson round-trip preserves data', () {
      final original = PlayerGroup(
        name: 'Round-trip',
        players: ['A', 'B', 'C', 'D'],
        minFan: 1,
        maxFan: 999,
        gameMode: GameMode.hongKong,
        currentRound: 5,
        dealerIndex: 2,
        prevalentWindIndex: 1,
        currentDealerGameCount: 3,
        totalWindRounds: 4,
        totalGamesPlayedInGroup: 12,
        currentScores: {'A': 100, 'B': -50, 'C': 0, 'D': -50},
        roundHistory: [
          {'round': 1, 'winner': 'A'},
        ],
      );

      final json = original.toJson();
      final restored = PlayerGroup.fromJson(json);

      expect(restored.name, equals(original.name));
      expect(restored.players, equals(original.players));
      expect(restored.minFan, equals(original.minFan));
      expect(restored.maxFan, equals(original.maxFan));
      expect(restored.gameMode, equals(original.gameMode));
      expect(restored.currentRound, equals(original.currentRound));
      expect(restored.dealerIndex, equals(original.dealerIndex));
      expect(restored.prevalentWindIndex, equals(original.prevalentWindIndex));
      expect(
        restored.currentDealerGameCount,
        equals(original.currentDealerGameCount),
      );
      expect(restored.totalWindRounds, equals(original.totalWindRounds));
      expect(
        restored.totalGamesPlayedInGroup,
        equals(original.totalGamesPlayedInGroup),
      );
      expect(restored.currentScores, equals(original.currentScores));
    });

    test('fromJson with playerStats parses correctly', () {
      final json = {
        'name': 'StatsGroup',
        'players': ['Alice'],
        'createdAt': '2025-01-01T00:00:00.000Z',
        'playerStats': {
          'Alice': {
            'playerName': 'Alice',
            'totalGamesPlayed': 10,
            'totalWins': 4,
            'totalLosses': 6,
            'totalScore': 50,
            'totalTsumo': 2,
            'totalRon': 2,
            'totalDealsIn': 1,
          },
        },
      };
      final g = PlayerGroup.fromJson(json);
      expect(g.playerStats, isNotNull);
      expect(g.playerStats!['Alice']!.totalWins, equals(4));
      expect(g.playerStats!['Alice']!.winningRate, closeTo(0.4, 0.001));
    });

    test('copyWith overrides selected fields', () {
      final g = PlayerGroup(name: 'A', players: ['X']);
      final g2 = g.copyWith(name: 'B', minFan: 1);
      expect(g2.name, equals('B'));
      expect(g2.minFan, equals(1));
      expect(g2.players, equals(['X'])); // unchanged
    });

    test('copyWith with no args returns equivalent group', () {
      final g = PlayerGroup(name: 'A', players: ['X'], minFan: 5, maxFan: 10);
      final g2 = g.copyWith();
      expect(g2.name, equals(g.name));
      expect(g2.minFan, equals(g.minFan));
      expect(g2.maxFan, equals(g.maxFan));
      expect(g2.players, equals(g.players));
    });

    test('createdAt defaults to now if not provided', () {
      final before = DateTime.now();
      final g = PlayerGroup(name: 'T', players: []);
      final after = DateTime.now();
      expect(
        g.createdAt.isAfter(before.subtract(const Duration(seconds: 1))),
        isTrue,
      );
      expect(
        g.createdAt.isBefore(after.add(const Duration(seconds: 1))),
        isTrue,
      );
    });
  });
}
