import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/models/player_stats.dart';

void main() {
  group('PlayerStats', () {
    test('default constructor values', () {
      final s = PlayerStats(playerName: 'Alice');
      expect(s.playerName, equals('Alice'));
      expect(s.totalGamesPlayed, equals(0));
      expect(s.totalWins, equals(0));
      expect(s.totalLosses, equals(0));
      expect(s.totalScore, equals(0));
      expect(s.totalTsumo, equals(0));
      expect(s.totalRon, equals(0));
      expect(s.totalDealsIn, equals(0));
    });

    test('winningRate is 0 when no games played', () {
      final s = PlayerStats(playerName: 'Alice');
      expect(s.winningRate, equals(0.0));
    });

    test('winningRate calculated correctly', () {
      final s = PlayerStats(playerName: 'Alice', totalGamesPlayed: 10, totalWins: 3);
      expect(s.winningRate, closeTo(0.3, 0.001));
    });

    test('selfDrawRate is 0 when no wins', () {
      final s = PlayerStats(playerName: 'Alice', totalWins: 0, totalTsumo: 0);
      expect(s.selfDrawRate, equals(0.0));
    });

    test('selfDrawRate calculated correctly', () {
      final s = PlayerStats(playerName: 'Alice', totalWins: 4, totalTsumo: 3);
      expect(s.selfDrawRate, closeTo(0.75, 0.001));
    });

    test('discardWinRate calculated correctly', () {
      final s = PlayerStats(playerName: 'Alice', totalWins: 4, totalRon: 1);
      expect(s.discardWinRate, closeTo(0.25, 0.001));
    });

    test('copyWith overrides selected fields', () {
      final s = PlayerStats(playerName: 'Alice', totalWins: 5, totalScore: 100);
      final s2 = s.copyWith(totalWins: 10);
      expect(s2.totalWins, equals(10));
      expect(s2.playerName, equals('Alice'));
      expect(s2.totalScore, equals(100));
    });

    test('copyWith with no args returns equivalent', () {
      final s = PlayerStats(playerName: 'Alice', totalWins: 5);
      final s2 = s.copyWith();
      expect(s2.playerName, equals(s.playerName));
      expect(s2.totalWins, equals(s.totalWins));
    });

    test('fromJson parses all fields', () {
      final json = {
        'playerName': 'Bob',
        'totalGamesPlayed': 20,
        'totalWins': 8,
        'totalLosses': 12,
        'totalScore': 300,
        'totalTsumo': 3,
        'totalRon': 5,
        'totalDealsIn': 4,
      };
      final s = PlayerStats.fromJson(json);
      expect(s.playerName, equals('Bob'));
      expect(s.totalGamesPlayed, equals(20));
      expect(s.totalWins, equals(8));
      expect(s.totalLosses, equals(12));
      expect(s.totalScore, equals(300));
      expect(s.totalTsumo, equals(3));
      expect(s.totalRon, equals(5));
      expect(s.totalDealsIn, equals(4));
    });

    test('fromJson with missing keys uses defaults', () {
      final s = PlayerStats.fromJson({});
      expect(s.playerName, equals(''));
      expect(s.totalGamesPlayed, equals(0));
      expect(s.totalWins, equals(0));
    });

    test('toJson round-trip preserves data', () {
      final original = PlayerStats(
        playerName: 'Charlie',
        totalGamesPlayed: 15,
        totalWins: 6,
        totalLosses: 9,
        totalScore: -50,
        totalTsumo: 2,
        totalRon: 4,
        totalDealsIn: 3,
      );
      final json = original.toJson();
      final restored = PlayerStats.fromJson(json);
      expect(restored.playerName, equals(original.playerName));
      expect(restored.totalGamesPlayed, equals(original.totalGamesPlayed));
      expect(restored.totalWins, equals(original.totalWins));
      expect(restored.totalLosses, equals(original.totalLosses));
      expect(restored.totalScore, equals(original.totalScore));
      expect(restored.totalTsumo, equals(original.totalTsumo));
      expect(restored.totalRon, equals(original.totalRon));
      expect(restored.totalDealsIn, equals(original.totalDealsIn));
    });

    test('negative totalScore handled correctly', () {
      final s = PlayerStats(playerName: 'Alice', totalScore: -500);
      expect(s.totalScore, equals(-500));
      final json = s.toJson();
      expect(json['totalScore'], equals(-500));
    });
  });
}
