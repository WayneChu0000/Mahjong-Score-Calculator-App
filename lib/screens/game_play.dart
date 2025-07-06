import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/game_record.dart';
import '../widgets/player_card.dart';

class GamePlayScreen extends StatefulWidget {
  final List<Player> players;

  const GamePlayScreen({super.key, required this.players});

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
  }

  void _recordGame() {
    // 這裡添加記錄遊戲的邏輯
    final gameRecord = GameRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      players: List.from(gamePlayers),
      rounds: currentRound,
    );
    
    // 這裡可以添加保存記錄的代碼
    
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('第 $currentRound 回合'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _recordGame,
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
                      gamePlayers[index].score = newScore;
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
                  label: const Text('自摸'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    // 自摸計分邏輯
                  },
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.person),
                  label: const Text('胡牌'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    // 胡牌計分邏輯
                  },
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.next_plan),
                  label: const Text('下一輪'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      currentRound++;
                    });
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