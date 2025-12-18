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

  // Factory method to create object from JSON (for future data storage)
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

  // Method to convert to JSON (for future data storage)
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