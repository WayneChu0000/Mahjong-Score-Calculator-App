class Player {
  final int id;
  String name;
  int score;

  Player({
    required this.id,
    required this.name,
    this.score = 0,
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