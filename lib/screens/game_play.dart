import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/game_record.dart';
import '../widgets/player_card.dart';
import 'score_recording_screen.dart';

class GamePlayScreen extends StatefulWidget {
  final List<Player> players;
  final String? groupId;
  final String? groupName;
  final int totalRounds;

  const GamePlayScreen({
    super.key, 
    required this.players,
    this.groupId,
    this.groupName,
    this.totalRounds = 16, // 默認16局
  });

  @override
  State<GamePlayScreen> createState() => _GamePlayScreenState();
}

class _GamePlayScreenState extends State<GamePlayScreen> {
  late List<Player> gamePlayers;
  int currentRound = 1;
  
  @override
  void initState() {
    super.initState();
    gamePlayers = List.from(widget.players);
    
    // 初始化後立即打開計分記錄頁面
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openScoreRecordingScreen();
    });
  }

  // 打開計分記錄頁面
  void _openScoreRecordingScreen() {
    // 如果當前回合已超過總回合數，顯示遊戲結束
    if (currentRound > widget.totalRounds) {
      _showGameEndSummary();
      return;
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScoreRecordingScreen(
          players: gamePlayers,
          currentRound: currentRound,
          totalRounds: widget.totalRounds,
          onScoreSubmitted: (Map<String, int> scoreChanges) {
            setState(() {
              // 更新玩家分數
              scoreChanges.forEach((playerId, scoreChange) {
                final index = gamePlayers.indexWhere((p) => p.id.toString() == playerId);
                if (index != -1) {
                  gamePlayers[index] = gamePlayers[index].copyWith(
                    score: gamePlayers[index].score + scoreChange,
                  );
                }
              });
              
              // 增加回合數
              currentRound++;
              
              // 在下一幀打開新的計分記錄頁面
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _openScoreRecordingScreen();
              });
            });
          },
          groupId: widget.groupId,
          groupName: widget.groupName,
        ),
      ),
    );
  }
  
  // 顯示遊戲結束摘要
  void _showGameEndSummary() {
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
            ...gamePlayers.map((player) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(player.name),
                    Text(
                      '${player.score}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: player.score >= 0 ? Colors.green : Colors.red,
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
              // 保存遊戲記錄
              _recordGame();
              
              // 回到主頁
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: const Text('保存並返回'),
          ),
        ],
      ),
    );
  }

  void _recordGame() {
    // 這裡添加記錄遊戲的邏輯
    final gameRecord = GameRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      players: List.from(gamePlayers),
      rounds: currentRound - 1, // 實際完成的回合數
    );
    
    // 這裡可以添加保存記錄的代碼
    // 如果是玩家組合的遊戲，也更新組合的統計數據
    if (widget.groupId != null) {
      _updatePlayerGroupStats();
    }
  }
  
  void _updatePlayerGroupStats() {
    // 實際應用中，這裡應該更新玩家組合的統計數據
    print('更新玩家組合統計數據: ${widget.groupId}');
    // TODO: 實現更新邏輯
  }

  @override
  Widget build(BuildContext context) {
    String title = widget.groupName != null && widget.groupName!.isNotEmpty
        ? '${widget.groupName} - 第 $currentRound 回合'
        : '第 $currentRound 回合';
    
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              _recordGame();
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: gamePlayers.length,
              padding: const EdgeInsets.all(8.0),
              itemBuilder: (context, index) {
                return PlayerCard(
                  player: gamePlayers[index],
                  onScoreChanged: (int newScore) {
                    setState(() {
                      gamePlayers[index] = gamePlayers[index].copyWith(score: newScore);
                    });
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.grey.shade200,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.add_circle),
                  label: const Text('繼續遊戲'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _openScoreRecordingScreen,
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('結束遊戲'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    _recordGame();
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}