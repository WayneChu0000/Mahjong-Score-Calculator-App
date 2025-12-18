class Player {
  final int id;
  final String name;
  final int score;

  const Player({
    required this.id,
    required this.name,
    required this.score,
  });

  // Method to copy and modify player data
  Player copyWith({
    int? id,
    String? name,
    int? score,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      score: score ?? this.score,
    );
  }
}