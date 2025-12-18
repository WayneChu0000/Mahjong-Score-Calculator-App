import 'package:flutter/material.dart';
import '../widgets/base_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'Profile',
      currentIndex: 3,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar and username
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
                    'Default Player',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Joined: July 6, 2025',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Game statistics
            const Text(
              'Game Statistics',
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
                {'label': 'Total Games', 'value': '15'},
                {'label': 'Wins', 'value': '8'},
                {'label': 'Losses', 'value': '7'},
              ],
            ),
            const SizedBox(height: 16),
            _buildStatisticCard(
              context: context,
              stats: [
                {'label': 'Total Score', 'value': '2500'},
                {'label': 'Self-Draws', 'value': '5'},
                {'label': 'Wins', 'value': '12'},
              ],
            ),
            const SizedBox(height: 32),
            // Settings options
            const Text(
              'Settings',
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
                    title: const Text('Edit Profile'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // Edit profile feature
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.color_lens),
                    title: const Text('Theme Settings'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // Theme settings feature
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('Game Settings'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // Game settings feature
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