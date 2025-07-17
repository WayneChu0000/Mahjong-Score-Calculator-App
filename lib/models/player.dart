class Player {
  final int id;
  final String name;
  final int score;

  const Player({
    required this.id,
    required this.name,
    required this.score,
  });

  // 複製並修改玩家數據的方法
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