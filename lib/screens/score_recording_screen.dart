import 'package:flutter/material.dart';
import '../models/player.dart';
import '../services/score_service.dart';
import 'score_calculation_screen.dart';
import 'dart:async';

class ScoreRecordingScreen extends StatefulWidget {
  final List<Player> players;
  final int currentRound;
  final int totalRounds;
  final Function(Map<String, int>) onScoreSubmitted;
  final String? groupId;
  final String? groupName;

  const ScoreRecordingScreen({
    super.key,
    required this.players,
    required this.currentRound,
    required this.totalRounds,
    required this.onScoreSubmitted,
    this.groupId,
    this.groupName,
  });

  @override
  State<ScoreRecordingScreen> createState() => _ScoreRecordingScreenState();
}

class _ScoreRecordingScreenState extends State<ScoreRecordingScreen> {
  // 莊家索引
  int _dealerIndex = 0;
  
  // 使用ScoreService
  final ScoreService _scoreService = ScoreService();
  
  // 記錄分數訂閱
  StreamSubscription? _scoreSubscription;
  
  // 更新後的玩家列表
  late List<Player> _updatedPlayers;

  @override
  void initState() {
    super.initState();
    
    // 初始化玩家列表
    _updatedPlayers = List.from(widget.players);
    
    // 初始化分數服務
    _scoreService.initGame(
      widget.players, 
      initialPublicScore: 0,
      currentRound: widget.currentRound,
      totalRounds: widget.totalRounds
    );
    
    // 安全訂閱分數變化
    try {
      // 訂閱分數變化
      _scoreSubscription = _scoreService.scoreStream.listen((gameData) {
        if (mounted) {
          setState(() {
            // 更新玩家列表以反映最新分數
            _updatedPlayers = widget.players.map((player) {
              return player.copyWith(
                score: gameData[player.id.toString()] ?? player.score
              );
            }).toList();
        });
      }
      });
    } catch (e) {
      print('訂閱分數流時出錯: $e');
    }
    
    // 默認第一個玩家為莊家
    _dealerIndex = 0;
    
    // 檢查是否已超過總回合數
    if (_scoreService.isGameEnd()) {
      // 延遲執行，避免在 initState 中直接導航
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showGameEndDialog();
      });
    }
  }
  
  // 更新玩家列表，反映最新分數
  void _updatePlayerList() {
    _updatedPlayers = widget.players.map((player) {
      int currentScore = _scoreService.getPlayerScore(player.id.toString());
      return player.copyWith(score: currentScore);
    }).toList();
  }
  
  @override
  void dispose() {
    // 安全取消訂閱
    try {
      _scoreSubscription?.cancel();
    } catch (e) {
      print('取消分數訂閱時出錯: $e');
    }
    super.dispose();
  }
  
  // 檢查遊戲是否結束
  void _checkGameEnd() {
    if (widget.currentRound > widget.totalRounds) {
      // 延遲執行，避免在 initState 中直接導航
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showGameEndDialog();
      });
    }
  }
  
  // 顯示遊戲結束對話框
  void _showGameEndDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('遊戲結束'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('已完成所有回合，遊戲結束！'),
            const SizedBox(height: 16),
            const Text('最終分數：', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...widget.players.map((player) {
              final score = _scoreService.getPlayerScore(player.id.toString());
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(player.name),
                    Text(
                      '$score',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: score >= 0 ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // 回到主頁
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: const Text('返回主頁'),
          ),
        ],
      ),
    );
  }

  // 打開高級計分計算器
  void _openScoreCalculator() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScoreCalculationScreen(
          players: _updatedPlayers,
          currentRound: _scoreService.getCurrentRound(),
          scoreService: _scoreService,
          onScoreSubmitted: (Map<String, int> scoreChanges) {
            // 調用原始回調，通知上層組件
            widget.onScoreSubmitted(scoreChanges);
            
            // 注意：在 ScoreCalculationScreen 中已經調用了 scoreService.incrementRound()
            // 所以這裡不需要再次增加回合數
            
            // 開啟下一局
            _startNextRound();
          },
        ),
      ),
    );
  }

  // 無結果結束本回合
  void _endRoundWithNoResult() {
    // 創建一個全零的分數變化映射
    Map<String, int> noChangeScores = {};
    for (var player in widget.players) {
      noChangeScores[player.id.toString()] = 0;
    }
    
    // 調用原始回調，通知上層組件
    widget.onScoreSubmitted(noChangeScores);
    
    // 更新分數（雖然沒有變化，但保持一致的調用方式）
    _scoreService.updateScores(noChangeScores);
    
    // 增加回合數
    _scoreService.incrementRound();
    
    // 檢查遊戲是否結束
    if (_scoreService.isGameEnd()) {
      // 顯示遊戲結束對話框
      _showGameEndDialog();
      return;
    }
    
    // 開啟下一局
    _startNextRound();
  }
  
  // 開始下一局
  void _startNextRound() {
    // 獲取當前回合和總回合數
    final currentRound = _scoreService.getCurrentRound();
    final totalRounds = _scoreService.getTotalRounds();
    
    // 如果已超過總回合數，顯示遊戲結束對話框
    if (currentRound > totalRounds) {
      _showGameEndDialog();
      return;
    }
    
    // 獲取更新後的玩家列表
    final updatedPlayers = widget.players.map((player) {
      return player.copyWith(
        score: _scoreService.getPlayerScore(player.id.toString())
      );
    }).toList();
    
    // 刷新當前頁面
    setState(() {
      _updatedPlayers = updatedPlayers;
    });
    
    // 這裡可以選擇不創建新頁面，而是直接刷新當前頁面
    // 這樣可以避免頁面堆棧過深
  }

  // 選擇莊家
  void _selectDealer() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('選擇莊家'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: widget.players.length,
            itemBuilder: (context, index) {
              return RadioListTile<int>(
                title: Text(widget.players[index].name),
                value: index,
                groupValue: _dealerIndex,
                onChanged: (int? value) {
                  if (value != null) {
                    setState(() {
                      _dealerIndex = value;
                    });
                    Navigator.pop(context);
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 獲取莊家
    final dealer = widget.players[_dealerIndex];
    
    // 從 ScoreService 獲取當前回合和總回合數
    final currentRound = _scoreService.getCurrentRound();
    final totalRounds = _scoreService.getTotalRounds();
    
    // 標題設定
    String title = '麻將計分';
    if (widget.groupName != null && widget.groupName!.isNotEmpty) {
      title = '${widget.groupName} - 第 $currentRound 局'; // 使用 ScoreService 的回合數
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 當前牌局信息
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.casino, color: Colors.green),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '第 $currentRound 局 / 共 $totalRounds 局', // 使用 ScoreService 的回合數
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        // 編輯牌局信息，如修改總局數
                        _selectDealer(); // 這裡僅實現選擇莊家
                      },
                      tooltip: '選擇莊家',
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 玩家分數顯示區域
            Expanded(
              child: ListView(
                children: [
                  // 莊家分數
                  _buildPlayerScoreCard(dealer, isDealer: true),
                  
                  const SizedBox(height: 8),
                  
                  // 其他玩家分數
                  ...widget.players
                      .where((player) => player.id != dealer.id)
                      .map((player) => Column(
                            children: [
                              _buildPlayerScoreCard(player),
                              const SizedBox(height: 8),
                            ],
                          ))
                      .toList(),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 底部操作按鈕
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.calculate),
                    label: const Text('計算得分'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: _openScoreCalculator,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.close),
                    label: const Text('無結果'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: _endRoundWithNoResult,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  // 構建玩家分數卡片
  Widget _buildPlayerScoreCard(Player player, {bool isDealer = false}) {
    // 獲取當前分數
    final currentScore = _scoreService.getPlayerScore(player.id.toString());
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // 莊家標記
            if (isDealer)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '莊',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            
            const SizedBox(width: 8),
            
            // 玩家名稱
            Expanded(
              child: Text(
                isDealer ? '莊家 (${player.name})' : player.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isDealer ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            
            // 分數顯示
            Text(
              '當前分數: $currentScore',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: currentScore >= 0 ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}