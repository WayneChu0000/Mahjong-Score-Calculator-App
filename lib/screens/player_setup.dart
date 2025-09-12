import 'package:flutter/material.dart';
import '../models/player.dart';
import 'score_recording_screen.dart';

class PlayerSetupScreen extends StatefulWidget {
  final List<Player>? existingPlayers;
  final String? groupName;
  final String? groupId;
  final bool directStart;

  const PlayerSetupScreen({
    super.key, 
    this.existingPlayers,
    this.groupName,
    this.groupId,
    this.directStart = false,
  });

  @override
  State<PlayerSetupScreen> createState() => _PlayerSetupScreenState();
}

class _PlayerSetupScreenState extends State<PlayerSetupScreen> {
  int selectedPlayerCount = 4;
  List<Player> players = [];
  late TextEditingController _groupNameController;
  bool _isNewGroup = true;

  @override
  void initState() {
    super.initState();
    
    // 初始化玩家列表
    if (widget.existingPlayers != null) {
      players = List.from(widget.existingPlayers!);
      selectedPlayerCount = players.length;
      _isNewGroup = false;
    } else {
      _initializePlayers();
      _isNewGroup = true;
    }
    
    // 初始化組名控制器
    _groupNameController = TextEditingController(text: widget.groupName ?? '');
    
    // 如果設置為直接開始，則跳過設置直接開始遊戲
    if (widget.directStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startGame();
      });
    }
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    super.dispose();
  }

  void _initializePlayers() {
    players = List.generate(
      4,
      (index) => Player(id: index, name: '玩家 ${index + 1}', score: 0),
    );
  }
  
  void _startGame() {
    // 保存玩家組合（實際應用中應該保存到數據庫或 SharedPreferences）
    _savePlayerGroup();
    
    // 只保留選定數量的玩家
    final selectedPlayers = players.take(selectedPlayerCount).toList();
    
    // 直接進入計分記錄頁面
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScoreRecordingScreen(
          players: selectedPlayers,
          currentRound: 1,
          totalRounds: 16, // 預設16局
          onScoreSubmitted: (Map<String, int> scoreChanges) {
            // 在這裡可以保存遊戲記錄
            print('回合結束，分數變化: $scoreChanges');
            
            // 注意：在這裡不需要額外處理，因為 ScoreRecordingScreen 會處理回合遞增
          },
          groupId: widget.groupId,
          groupName: _groupNameController.text,
        ),
      ),
    );
  }
  
  void _savePlayerGroup() {
    // 實際應用中，這裡應該保存玩家組合到數據庫或 SharedPreferences
    print('保存玩家組合: ${_groupNameController.text}');
    // TODO: 實現保存邏輯
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingPlayers != null ? '編輯玩家' : '設置玩家'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 組名輸入
            TextField(
              controller: _groupNameController,
              decoration: const InputDecoration(
                labelText: '組合名稱',
                border: OutlineInputBorder(),
                hintText: '例如：週末麻將團',
              ),
            ),
            
            const SizedBox(height: 20),
            
            // 玩家數量選擇
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
                          
                          // 如果增加了玩家數量，添加新玩家
                          if (selectedPlayerCount > players.length) {
                            for (int i = players.length; i < selectedPlayerCount; i++) {
                              players.add(Player(id: i, name: '玩家 ${i + 1}', score: 0));
                            }
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // 玩家列表
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
                          _editPlayerName(index);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // 底部按鈕
            Row(
              children: [
                if (!_isNewGroup) 
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                      ),
                      onPressed: () {
                        _deleteGroup();
                      },
                      child: const Text('刪除組合'),
                    ),
                  ),
                if (!_isNewGroup) const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      _startGame();
                    },
                    child: const Text('開始遊戲', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  // 編輯玩家名稱
  Future<void> _editPlayerName(int index) async {
    final TextEditingController controller = TextEditingController(text: players[index].name);
    
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('編輯玩家 ${index + 1}'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: '玩家名稱',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                players[index] = players[index].copyWith(name: controller.text);
              });
              Navigator.pop(context);
            },
            child: const Text('確定'),
          ),
        ],
      ),
    );
  }
  
  // 刪除玩家組合
  Future<void> _deleteGroup() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('確認刪除'),
        content: const Text('確定要刪除這個玩家組合嗎？這個操作不可撤銷。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('刪除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      // 實際應用中，這裡應該從數據庫或 SharedPreferences 中刪除組合
      print('刪除玩家組合: ${widget.groupId}');
      // TODO: 實現刪除邏輯
      
      Navigator.pop(context);
    }
  }
}