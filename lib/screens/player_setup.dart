import 'package:flutter/material.dart';
import '../models/player.dart';
import 'game_play.dart';

class PlayerSetupScreen extends StatefulWidget {
  const PlayerSetupScreen({super.key});

  @override
  State<PlayerSetupScreen> createState() => _PlayerSetupScreenState();
}

class _PlayerSetupScreenState extends State<PlayerSetupScreen> {
  int selectedPlayerCount = 4;
  List<Player> players = [];

  @override
  void initState() {
    super.initState();
    _initializePlayers();
  }

  void _initializePlayers() {
    players = List.generate(
      4,
      (index) => Player(id: index, name: '玩家 ${index + 1}', score: 0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('設置玩家'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      '選擇玩家數量',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    SegmentedButton<int>(
                      segments: const [
                        ButtonSegment<int>(value: 2, label: Text('2人')),
                        ButtonSegment<int>(value: 3, label: Text('3人')),
                        ButtonSegment<int>(value: 4, label: Text('4人')),
                      ],
                      selected: {selectedPlayerCount},
                      onSelectionChanged: (Set<int> newSelection) {
                        setState(() {
                          selectedPlayerCount = newSelection.first;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: selectedPlayerCount,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8.0),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.primaries[index % Colors.primaries.length],
                        child: Text('${index + 1}'),
                      ),
                      title: Text(players[index].name),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          // 編輯玩家名稱的功能
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
              ),
              onPressed: () {
                // 只保留選定數量的玩家
                final selectedPlayers = players.take(selectedPlayerCount).toList();
                
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GamePlayScreen(players: selectedPlayers),
                  ),
                );
              },
              child: const Text('開始遊戲', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}