class PlayerStats {
  final String playerName;
  final int totalGamesPlayed;
  final int totalWins;
  final int totalLosses;
  final int totalScore; // Cumulative points
  final int totalTsumo; // Self-draw wins
  final int totalRon; // Discard wins
  final int totalDealsIn; // Rate of dealing in (optional, if tracked)

  PlayerStats({
    required this.playerName,
    this.totalGamesPlayed = 0,
    this.totalWins = 0,
    this.totalLosses = 0,
    this.totalScore = 0,
    this.totalTsumo = 0,
    this.totalRon = 0,
    this.totalDealsIn = 0,
  });

  double get winningRate => totalGamesPlayed > 0 ? totalWins / totalGamesPlayed : 0.0;
  double get selfDrawRate => totalWins > 0 ? totalTsumo / totalWins : 0.0;
  double get discardWinRate => totalWins > 0 ? totalRon / totalWins : 0.0;

  // Create copy with updated values
  PlayerStats copyWith({
    String? playerName,
    int? totalGamesPlayed,
    int? totalWins,
    int? totalLosses,
    int? totalScore,
    int? totalTsumo,
    int? totalRon,
    int? totalDealsIn,
  }) {
    return PlayerStats(
      playerName: playerName ?? this.playerName,
      totalGamesPlayed: totalGamesPlayed ?? this.totalGamesPlayed,
      totalWins: totalWins ?? this.totalWins,
      totalLosses: totalLosses ?? this.totalLosses,
      totalScore: totalScore ?? this.totalScore,
      totalTsumo: totalTsumo ?? this.totalTsumo,
      totalRon: totalRon ?? this.totalRon,
      totalDealsIn: totalDealsIn ?? this.totalDealsIn,
    );
  }

  factory PlayerStats.fromJson(Map<String, dynamic> json) {
    return PlayerStats(
      playerName: json['playerName'] ?? '',
      totalGamesPlayed: json['totalGamesPlayed'] ?? 0,
      totalWins: json['totalWins'] ?? 0,
      totalLosses: json['totalLosses'] ?? 0,
      totalScore: json['totalScore'] ?? 0,
      totalTsumo: json['totalTsumo'] ?? 0,
      totalRon: json['totalRon'] ?? 0,
      totalDealsIn: json['totalDealsIn'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'playerName': playerName,
      'totalGamesPlayed': totalGamesPlayed,
      'totalWins': totalWins,
      'totalLosses': totalLosses,
      'totalScore': totalScore,
      'totalTsumo': totalTsumo,
      'totalRon': totalRon,
      'totalDealsIn': totalDealsIn,
    };
  }
}
