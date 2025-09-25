import 'package:flutter/material.dart';
import '../services/player_group_service.dart';
import '../models/player_group.dart';
import 'score_calculation_screen.dart';

class SavedGroupsScreen extends StatefulWidget {
  const SavedGroupsScreen({super.key});

  @override
  State<SavedGroupsScreen> createState() => _SavedGroupsScreenState();
}

class _SavedGroupsScreenState extends State<SavedGroupsScreen> {
  List<PlayerGroup> _savedGroups = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedGroups();
  }

  Future<void> _loadSavedGroups() async {
    setState(() {
      _isLoading = true;
    });

    final groups = await PlayerGroupService.getSavedGroups();
    
    setState(() {
      _savedGroups = groups;
      _isLoading = false;
    });
  }

  Future<void> _deleteGroup(String groupName) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('確認刪除'),
        content: Text('確定要刪除群組「$groupName」嗎？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('刪除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await PlayerGroupService.deleteGroup(groupName);
      
      if (success) {
        _loadSavedGroups(); // 重新載入列表
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('群組「$groupName」已刪除'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    }
  }

  void _startGameWithGroup(PlayerGroup group) {
    // 更新玩家群組的最後遊戲時間
    final updatedGroup = group.copyWith(
      lastPlayedAt: DateTime.now(),
    );
    
    // 儲存更新後的群組
    PlayerGroupService.saveGroup(updatedGroup);
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScoreCalculationScreen(
          players: group.players,
          groupName: group.name, // 如果 ScoreCalculationScreen 支援群組名稱
        ),
      ),
    ).then((_) {
      // 當從遊戲畫面返回時，重新載入群組列表以更新最後遊戲時間
      _loadSavedGroups();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('已儲存的玩家群組'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _savedGroups.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min, // 重要：限制 Column 大小
                      children: [
                        Icon(Icons.group_off, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          '尚未儲存任何玩家群組',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadSavedGroups,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8), // 添加內邊距
                      itemCount: _savedGroups.length,
                      itemBuilder: (context, index) {
                        final group = _savedGroups[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.red.shade100,
                              child: Text(
                                group.players.length.toString(),
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              group.name,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min, // 限制 Column 大小
                              children: [
                                Text('玩家: ${group.players.join(', ')}'),
                                const SizedBox(height: 4),
                                Text(
                                  '建立時間: ${_formatDateTime(group.createdAt)}',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                            trailing: PopupMenuButton(
                              itemBuilder: (context) => const [
                                PopupMenuItem(
                                  value: 'play',
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min, // 限制 Row 大小
                                    children: [
                                      Icon(Icons.play_arrow, color: Colors.green),
                                      SizedBox(width: 8),
                                      Text('開始遊戲'),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min, // 限制 Row 大小
                                    children: [
                                      Icon(Icons.delete, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text('刪除群組'),
                                    ],
                                  ),
                                ),
                              ],
                              onSelected: (value) {
                                if (value == 'play') {
                                  _startGameWithGroup(group);
                                } else if (value == 'delete') {
                                  _deleteGroup(group.name);
                                }
                              },
                            ),
                            onTap: () => _startGameWithGroup(group),
                          ),
                        );
                      },
                    ),
                  ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}/${dateTime.month}/${dateTime.day} '
           '${dateTime.hour.toString().padLeft(2, '0')}:'
           '${dateTime.minute.toString().padLeft(2, '0')}';
  }
}