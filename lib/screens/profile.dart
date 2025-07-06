import 'package:flutter/material.dart';
import '../widgets/base_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: '個人資料',
      currentIndex: 3,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 頭像和用戶名
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.green.shade100,
                    child: const Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '預設玩家',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '加入時間: 2025年7月6日',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // 遊戲統計
            const Text(
              '遊戲統計',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 12),
            _buildStatisticCard(
              context: context,
              stats: [
                {'label': '總場次', 'value': '15'},
                {'label': '勝場', 'value': '8'},
                {'label': '敗場', 'value': '7'},
              ],
            ),
            const SizedBox(height: 16),
            _buildStatisticCard(
              context: context,
              stats: [
                {'label': '總得分', 'value': '2500'},
                {'label': '自摸次數', 'value': '5'},
                {'label': '胡牌次數', 'value': '12'},
              ],
            ),
            const SizedBox(height: 32),
            // 設置選項
            const Text(
              '設置',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: const Text('編輯資料'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // 編輯資料功能
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.color_lens),
                    title: const Text('主題設置'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // 主題設置功能
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('遊戲設置'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // 遊戲設置功能
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticCard({
    required BuildContext context,
    required List<Map<String, String>> stats,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: stats.map((stat) {
            return Column(
              children: [
                Text(
                  stat['value']!,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stat['label']!,
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}