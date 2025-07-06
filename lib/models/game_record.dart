import 'player.dart';

class GameRecord {
  final String id;
  final DateTime date;
  final List<Player> players;
  final int rounds;

  GameRecord({
    required this.id,
    required this.date,
    required this.players,
    required this.rounds,
  });

  // 從JSON創建對象的工廠方法（用於後續數據存儲）
  factory GameRecord.fromJson(Map<String, dynamic> json) {
    return GameRecord(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      players: (json['players'] as List)
          .map((playerJson) => Player(
                id: playerJson['id'] as int,
                name: playerJson['name'] as String,
                score: playerJson['score'] as int,
              ))
          .toList(),
      rounds: json['rounds'] as int,
    );
  }

  // 轉換為JSON的方法（用於後續數據存儲）
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'players': players
          .map((player) => {
                'id': player.id,
                'name': player.name,
                'score': player.score,
              })
          .toList(),
      'rounds': rounds,
    };
  }
}