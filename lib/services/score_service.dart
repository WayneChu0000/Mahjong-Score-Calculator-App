import 'dart:async';
import '../models/player.dart';

// 單例模式實現的分數服務
class ScoreService {
  // 單例實例
  static final ScoreService _instance = ScoreService._internal();
  
  // 工廠建構函數
  factory ScoreService() {
    return _instance;
  }
  
  // 私有建構函數
  ScoreService._internal();
  
  // 玩家分數映射表
  final Map<String, int> _playerScores = {};
  
  // 公共分數
  int _publicScore = 0;
  
  // 當前回合和總回合
  int _currentRound = 1;
  int _totalRounds = 16;
  
  // 分數流控制器
  final _scoreController = StreamController<Map<String, dynamic>>.broadcast();
  
  // 公開分數流
  Stream<Map<String, dynamic>> get scoreStream => _scoreController.stream;
  
  // 初始化遊戲數據
  void initGame(List<Player> players, {int initialPublicScore = 0, int currentRound = 1, int totalRounds = 16}) {
    // 初始化分數
    for (var player in players) {
      _playerScores[player.id.toString()] = player.score;
    }
    
    // 設置公共分數和回合數
    _publicScore = initialPublicScore;
    _currentRound = currentRound;
    _totalRounds = totalRounds;
    
    // 通知監聽器
    _notifyListeners();
  }
  
  // 獲取玩家分數
  int getPlayerScore(String playerId) {
    return _playerScores[playerId] ?? 0;
  }
  
  // 獲取公共分數
  int getPublicScore() {
    return _publicScore;
  }
  
  // 獲取當前回合
  int getCurrentRound() {
    return _currentRound;
  }
  
  // 獲取總回合數
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
  
  // 通知監聽器
  void _notifyListeners() {
    if (!_scoreController.isClosed) {
      _scoreController.add(getGameData());
    }
  }
  
  // 檢查遊戲是否結束
  bool isGameEnd() {
    return _currentRound > _totalRounds;
  }
}