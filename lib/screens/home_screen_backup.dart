import 'package:flutter/material.dart';
import '../widgets/score_display.dart';
import '../widgets/base_screen.dart';
import '../models/player.dart';
import '../models/player_group.dart';
import '../services/player_group_service.dart';
import '../localization/app_localizations.dart';
import 'player_setup.dart';
import 'score_recording_screen.dart';
import '../services/firebase_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  List<PlayerGroup> _playerGroups = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.easeOut))
    );
    
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.2, 1.0, curve: Curves.easeOut))
    );
    
    _controller.forward();
    
    // 載入玩家組合數據
    _loadPlayerGroups();
  }
  
  Future<void> _loadPlayerGroups() async {
    try {
      final groups = await PlayerGroupService.getSavedGroups();
      if (mounted) {
        setState(() {
          _playerGroups = groups;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('載入玩家組合失敗: $e');
      if (mounted) {
        setState(() {
          _playerGroups = [];
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'Mahjong Calculator',
      currentIndex: 0,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Fixed header content
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Welcome card
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Card(
                            elevation: 4,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  const Text(
                                    'Welcome Back!',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const ScoreDisplay(gamesPlayed: 15),
                                ],
                              ),
                            ),
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
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const PlayerSetupScreen(),
                                  ),
                                );
                                
                                // 如果有新的群組被創建，重新載入列表
                                if (result == true) {
                                  _loadPlayerGroups();
                                }
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
                                // TODO: 實現歷史記錄頁面
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('歷史記錄功能開發中...')),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),

                      // // Firebase 連線測試按鈕
                      // Align(
                      //   alignment: Alignment.centerRight,
                      //   child: OutlinedButton.icon(
                      //     icon: const Icon(Icons.cloud_done),
                      //     label: const Text('測試 Firebase'),
                      //     onPressed: () async {
                      //       final messenger = ScaffoldMessenger.of(context);
                      //       try {
                      //         final res = await FirebaseService.instance.ping();
                      //         messenger.showSnackBar(
                      //           SnackBar(content: Text('Firebase 正常: $res')),
                      //         );
                      //       } catch (e) {
                      //         messenger.showSnackBar(
                      //           SnackBar(content: Text('Firebase 失敗: $e')),
                      //         );
                      //       }
                      //     },
                      //   ),
                      // ),
                      
                      // 已保存的玩家組合標題
                      if (_playerGroups.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Text(
                              '已保存的玩家組合',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: _showAllPlayerGroups,
                              child: const Text('查看全部'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                    ],
                  ),
                ),
              
                // 可滾動的玩家組合列表
                Expanded(
                  child: _playerGroups.isNotEmpty
                      ? RefreshIndicator(
                          onRefresh: _loadPlayerGroups,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _playerGroups.length,
                            itemBuilder: (context, index) {
                              final group = _playerGroups[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: InkWell(
                                  onTap: () => _startGameWithGroup(group),
                                  borderRadius: BorderRadius.circular(8),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                group.name,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              '${group.players.length} 位玩家',
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
                                              label: Text(player),
                                              backgroundColor: Colors.green.shade50,
                                              labelStyle: const TextStyle(fontSize: 12),
                                            );
                                          }).toList(),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '建立時間: ${_formatDateTime(group.createdAt)}',
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 12,
                                              ),
                                            ),
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                TextButton.icon(
                                                  icon: const Icon(Icons.edit, size: 16),
                                                  label: const Text('編輯'),
                                                  onPressed: () => _editPlayerGroup(group),
                                                ),
                                                TextButton.icon(
                                                  icon: const Icon(Icons.play_arrow, size: 16),
                                                  label: const Text('開始'),
                                                  onPressed: () => _startGameWithGroup(group),
                                                ),
                                              ],
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
                      : Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
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
                                  onPressed: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const PlayerSetupScreen(),
                                      ),
                                    );
                                    
                                    if (result == true) {
                                      _loadPlayerGroups();
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              ],
            ),
    );
  }
  
  // 格式化日期時間
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}/${dateTime.month}/${dateTime.day} '
           '${dateTime.hour.toString().padLeft(2, '0')}:'
           '${dateTime.minute.toString().padLeft(2, '0')}';
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
              Row(
                children: [
                  const Text(
                    '所有玩家組合',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
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
                        subtitle: Text(
                          '${group.players.length} 位玩家\n建立於 ${_formatDateTime(group.createdAt)}',
                        ),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                Navigator.pop(context);
                                _editPlayerGroup(group);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.play_arrow),
                              onPressed: () {
                                Navigator.pop(context);
                                _startGameWithGroup(group);
                              },
                            ),
                          ],
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
    // TODO: 實現編輯功能
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('編輯群組「${group.name}」功能開發中...')),
    );
  }
  
  // 使用選定的玩家組合開始遊戲
  void _startGameWithGroup(PlayerGroup group) async {
    // 更新最後遊戲時間
    final updatedGroup = group.copyWith(
      lastPlayedAt: DateTime.now(),
    );
    
    await PlayerGroupService.saveGroup(updatedGroup);
    
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ScoreRecordingScreen(
            players: group.players.map((playerName) => 
              Player(id: group.players.indexOf(playerName), name: playerName, score: 0)
            ).toList(),
            currentRound: 1,
            totalRounds: 16, // 標準麻將局數
            onScoreSubmitted: (Map<String, int> scoreChanges) {
              print('玩家組合「${group.name}」分數已更新');
            },
            groupName: group.name,
          ),
        ),
      ).then((_) {
        // 遊戲結束後重新載入群組列表
        _loadPlayerGroups();
      });
    }
  }
}