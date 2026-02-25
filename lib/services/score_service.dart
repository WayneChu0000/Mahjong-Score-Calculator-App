import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/player.dart';

/// Score service — manages player scores, rounds, and public score.
///
/// Extends [ChangeNotifier] so it can be provided via `Provider` /
/// `ChangeNotifierProvider` and rebuild widgets reactively.
///
/// Also exposes a legacy [scoreStream] for backward-compatibility with
/// stream-based listeners.
class ScoreService extends ChangeNotifier {
  // Singleton instance
  static final ScoreService _instance = ScoreService._internal();
  
  factory ScoreService() => _instance;
  
  ScoreService._internal();
  
  // Player score map
  final Map<String, int> _playerScores = {};
  
  // Public score
  int _publicScore = 0;
  
  // Current round and total rounds
  int _currentRound = 1;
  int _totalRounds = 16;
  
  // Score stream controller
  final _scoreController = StreamController<Map<String, dynamic>>.broadcast();
  
  // Public score stream
  Stream<Map<String, dynamic>> get scoreStream => _scoreController.stream;
  
  // Initialize game data
  void initGame(List<Player> players, {int initialPublicScore = 0, int currentRound = 1, int totalRounds = 16}) {
    // Initialize scores
    for (var player in players) {
      _playerScores[player.id.toString()] = player.score;
    }
    
    // Set public score and round numbers
    _publicScore = initialPublicScore;
    _currentRound = currentRound;
    _totalRounds = totalRounds;
    
    // Notify listeners
    _notifyListeners();
  }
  
  // Get player score
  int getPlayerScore(String playerId) {
    return _playerScores[playerId] ?? 0;
  }
  
  // Get public score
  int getPublicScore() {
    return _publicScore;
  }
  
  // Get current round
  int getCurrentRound() {
    return _currentRound;
  }
  
  // Get total rounds
  int getTotalRounds() {
    return _totalRounds;
  }
  
  // 增加回合數
  void incrementRound() {
    _currentRound++;
    _notifyListeners();
  }
  
  // 獲取所有遊戲數據
  Map<String, dynamic> getGameData() {
    Map<String, dynamic> data = Map.from(_playerScores);
    data['publicScore'] = _publicScore;
    data['currentRound'] = _currentRound;
    data['totalRounds'] = _totalRounds;
    return data;
  }
  
  // 更新多個玩家分數
  void updateScores(Map<String, int> scoreChanges, {int? publicScoreChange}) {
    scoreChanges.forEach((playerId, scoreChange) {
      _playerScores[playerId] = (_playerScores[playerId] ?? 0) + scoreChange;
    });
    
    if (publicScoreChange != null) {
      _publicScore += publicScoreChange;
    }
    
    _notifyListeners();
  }
  
  // Notify both stream listeners and Provider listeners
  void _notifyListeners() {
    if (!_scoreController.isClosed) {
      _scoreController.add(getGameData());
    }
    notifyListeners();
  }
  
  // 檢查遊戲是否結束
  bool isGameEnd() {
    if (_totalRounds == 0) return false; // Unlimited rounds
    return _currentRound > _totalRounds;
  }
}