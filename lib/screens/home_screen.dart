import 'package:flutter/material.dart';
import '../widgets/score_display.dart';
import '../widgets/base_screen.dart';
import '../models/player.dart';
import 'player_setup.dart';
import 'history.dart';
import 'score_recording_screen.dart';
import '../services/firebase_service.dart';

class PlayerGroup {
  final String id;
  final String name;
  final List<Player> players;
  final DateTime lastPlayed;
  final int gamesCount;
  
  PlayerGroup({
    required this.id,
    required this.name,
    required this.players,
    required this.lastPlayed,
    required this.gamesCount,
  });
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // 假設的玩家組合數據 - 在實際應用中，這應該從數據庫或存儲中獲取
  List<PlayerGroup> _playerGroups = [
    PlayerGroup(
      id: '1',
      name: '週末麻將團',
      players: [
        Player(id: 0, name: '張三', score: 0),
        Player(id: 1, name: '李四', score: 0),
        Player(id: 2, name: '王五', score: 0),
        Player(id: 3, name: '趙六', score: 0),
      ],
      lastPlayed: DateTime.now().subtract(const Duration(days: 2)),
      gamesCount: 8,
    ),
    PlayerGroup(
      id: '2',
      name: '家庭麻將',
      players: [
        Player(id: 0, name: '爸爸', score: 0),
        Player(id: 1, name: '媽媽', score: 0),
        Player(id: 2, name: '姐姐', score: 0),
        Player(id: 3, name: '我', score: 0),
      ],
      lastPlayed: DateTime.now().subtract(const Duration(days: 7)),
      gamesCount: 15,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800), // 減少動畫時間
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.easeOut))
    );
    
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.2, 1.0, curve: Curves.easeOut))
    );
    
    _controller.forward();
    
    // 非阻塞地載入玩家組合數據
    _loadPlayerGroups();
  }
  
  // 載入玩家組合數據（非阻塞）
  Future<void> _loadPlayerGroups() async {
    // 使用 Future.microtask 確保不阻塞 UI 初始化
    Future.microtask(() async {
      // 模擬快速載入，實際應用中從 SharedPreferences 讀取
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        setState(() {
          // _playerGroups 已經在上面初始化了
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: '麻將計分器',
      currentIndex: 0,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 歡迎卡片
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          '歡迎回來！',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const ScoreDisplay(totalScore: 2500, gamesPlayed: 15),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // 主要功能按鈕
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('新玩家組合'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const PlayerSetupScreen()),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.history),
                        label: const Text('歷史記錄'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const HistoryScreen()),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),

                // Firebase 連線測試按鈕
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.cloud_done),
                    label: const Text('測試 Firebase'),
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      try {
                        final res = await FirebaseService.instance.ping();
                        messenger.showSnackBar(SnackBar(content: Text('Firebase 正常: $res')));
                      } catch (e) {
                        messenger.showSnackBar(SnackBar(content: Text('Firebase 失敗: $e')));
                      }
                    },
                  ),
                ),
                
                // 已保存的玩家組合
                _playerGroups.isNotEmpty 
                  ? Row(
                      children: [
                        const Text(
                          '已保存的玩家組合',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            // 顯示所有玩家組合
                            _showAllPlayerGroups();
                          },
                          child: const Text('查看全部'),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
                
                const SizedBox(height: 8),
                
                // 玩家組合列表
                _playerGroups.isNotEmpty
                  ? Expanded(
                      child: ListView.builder(
                        itemCount: _playerGroups.length,
                        itemBuilder: (context, index) {
                          final group = _playerGroups[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: InkWell(
                              onTap: () {
                                // 開始使用該玩家組合的遊戲
                                _startGameWithGroup(group);
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          group.name,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          '${group.gamesCount} 場遊戲',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      children: group.players.map((player) {
                                        return Chip(
                                          label: Text(player.name),
                                          backgroundColor: Colors.green.shade50,
                                        );
                                      }).toList(),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        TextButton.icon(
                                          icon: const Icon(Icons.edit, size: 16),
                                          label: const Text('編輯'),
                                          onPressed: () {
                                            _editPlayerGroup(group);
                                          },
                                        ),
                                        const SizedBox(width: 8),
                                        TextButton.icon(
                                          icon: const Icon(Icons.play_arrow, size: 16),
                                          label: const Text('開始遊戲'),
                                          onPressed: () {
                                            _startGameWithGroup(group);
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.group_add,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              '沒有已保存的玩家組合',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.add),
                              label: const Text('創建玩家組合'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const PlayerSetupScreen()),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                
                const SizedBox(height: 16),
                
                // // 底部功能按鈕
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //   children: [
                //     _buildQuickActionButton(
                //       icon: Icons.menu_book,
                //       label: '規則',
                //       onTap: () {
                //         Navigator.push(
                //           context,
                //           MaterialPageRoute(builder: (context) => const RulesScreen()),
                //         );
                //       },
                //     ),
                //     _buildQuickActionButton(
                //       icon: Icons.settings,
                //       label: '設定',
                //       onTap: () {
                //         Navigator.push(
                //           context,
                //           MaterialPageRoute(builder: (context) => const SettingsScreen()),
                //         );
                //       },
                //     ),
                  // ],
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  // 顯示所有玩家組合
  void _showAllPlayerGroups() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '所有玩家組合',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _playerGroups.length,
                  itemBuilder: (context, index) {
                    final group = _playerGroups[index];
                    return Card(
                      child: ListTile(
                        title: Text(group.name),
                        subtitle: Text('${group.players.length} 位玩家，${group.gamesCount} 場遊戲'),
                        trailing: IconButton(
                          icon: const Icon(Icons.play_arrow),
                          onPressed: () {
                            Navigator.pop(context);
                            _startGameWithGroup(group);
                          },
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          _startGameWithGroup(group);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  // 編輯玩家組合
  void _editPlayerGroup(PlayerGroup group) {
    // 跳轉到玩家設置頁面，帶上當前組合的數據
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlayerSetupScreen(
          existingPlayers: group.players,
          groupName: group.name,
          groupId: group.id,
        ),
      ),
    );
  }
  
  // 使用選定的玩家組合開始遊戲
  void _startGameWithGroup(PlayerGroup group) {
    // 直接進入計分記錄頁面
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScoreRecordingScreen(
          players: group.players,
          currentRound: 1,
          totalRounds: 16, // 預設16局
          onScoreSubmitted: (Map<String, int> scoreChanges) {
            // 這個回調只會在遊戲結束或返回主頁時觸發
            print('玩家組合 ${group.id} 分數已更新');
            
            // 注意：在這裡不需要額外處理，因為 ScoreRecordingScreen 會處理回合遞增
          },
          groupId: group.id,
          groupName: group.name,
        ),
      ),
    );
  }
}