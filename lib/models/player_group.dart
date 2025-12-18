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

  // Create PlayerGroup from JSON
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

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'players': players,
      'createdAt': createdAt.toIso8601String(),
      'lastPlayedAt': lastPlayedAt?.toIso8601String(),
    };
  }

  // Create copy
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