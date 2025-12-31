class PlayerGroup {
  final String name;
  final List<String> players;
  final DateTime createdAt;
  final DateTime? lastPlayedAt;
  final Map<String, int>? currentScores;
  final int? currentRound;
  final int? dealerIndex;
  final int? prevalentWindIndex;
  final int? currentDealerGameCount;
  final int? totalWindRounds;

  PlayerGroup({
    required this.name,
    required this.players,
    DateTime? createdAt,
    this.lastPlayedAt,
    this.currentScores,
    this.currentRound,
    this.dealerIndex,
    this.prevalentWindIndex,
    this.currentDealerGameCount,
    this.totalWindRounds,
  }) : createdAt = createdAt ?? DateTime.now();

  // Create PlayerGroup from JSON
  factory PlayerGroup.fromJson(Map<String, dynamic> json) {
    return PlayerGroup(
      name: json['name'],
      players: List<String>.from(json['players']),
      createdAt: DateTime.parse(json['createdAt']).toLocal(),
      lastPlayedAt: json['lastPlayedAt'] != null 
          ? DateTime.parse(json['lastPlayedAt']).toLocal()
          : null,
      currentScores: json['currentScores'] != null
          ? Map<String, int>.from(json['currentScores'])
          : null,
      currentRound: json['currentRound'],
      dealerIndex: json['dealerIndex'],
      prevalentWindIndex: json['prevalentWindIndex'],
      currentDealerGameCount: json['currentDealerGameCount'],
      totalWindRounds: json['totalWindRounds'],
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'players': players,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'lastPlayedAt': lastPlayedAt?.toUtc().toIso8601String(),
      'currentScores': currentScores,
      'currentRound': currentRound,
      'dealerIndex': dealerIndex,
      'prevalentWindIndex': prevalentWindIndex,
      'currentDealerGameCount': currentDealerGameCount,
      'totalWindRounds': totalWindRounds,
    };
  }

  // Create copy
  PlayerGroup copyWith({
    String? name,
    List<String>? players,
    DateTime? createdAt,
    DateTime? lastPlayedAt,
    Map<String, int>? currentScores,
    int? currentRound,
    int? dealerIndex,
    int? prevalentWindIndex,
    int? currentDealerGameCount,
    int? totalWindRounds,
  }) {
    return PlayerGroup(
      name: name ?? this.name,
      players: players ?? this.players,
      createdAt: createdAt ?? this.createdAt,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      currentScores: currentScores ?? this.currentScores,
      currentRound: currentRound ?? this.currentRound,
      dealerIndex: dealerIndex ?? this.dealerIndex,
      prevalentWindIndex: prevalentWindIndex ?? this.prevalentWindIndex,
      currentDealerGameCount: currentDealerGameCount ?? this.currentDealerGameCount,
      totalWindRounds: totalWindRounds ?? this.totalWindRounds,
    );
  }
}