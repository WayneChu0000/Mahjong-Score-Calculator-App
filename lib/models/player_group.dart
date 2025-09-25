class PlayerGroup {
  final String name;
  final List<String> players;
  final DateTime createdAt;
  final DateTime? lastPlayedAt;

  PlayerGroup({
    required this.name,
    required this.players,
    DateTime? createdAt,
    this.lastPlayedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // 從 JSON 建立 PlayerGroup
  factory PlayerGroup.fromJson(Map<String, dynamic> json) {
    return PlayerGroup(
      name: json['name'],
      players: List<String>.from(json['players']),
      createdAt: DateTime.parse(json['createdAt']),
      lastPlayedAt: json['lastPlayedAt'] != null 
          ? DateTime.parse(json['lastPlayedAt']) 
          : null,
    );
  }

  // 轉換為 JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'players': players,
      'createdAt': createdAt.toIso8601String(),
      'lastPlayedAt': lastPlayedAt?.toIso8601String(),
    };
  }

  // 建立副本
  PlayerGroup copyWith({
    String? name,
    List<String>? players,
    DateTime? createdAt,
    DateTime? lastPlayedAt,
  }) {
    return PlayerGroup(
      name: name ?? this.name,
      players: players ?? this.players,
      createdAt: createdAt ?? this.createdAt,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
    );
  }
}