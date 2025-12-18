import 'package:flutter/material.dart';
import '../widgets/base_screen.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final bool isUnlocked;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.isUnlocked = false,
  });
}

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample achievements list
    final achievements = [
      Achievement(
        id: '1',
        title: 'Beginner',
        description: 'Complete your first game',
        icon: Icons.stars,
        isUnlocked: true,
      ),
      Achievement(
        id: '2',
        title: 'Winning Streak',
        description: 'Win 3 games in a row',
        icon: Icons.whatshot,
        isUnlocked: true,
      ),
      Achievement(
        id: '3',
        title: 'Mahjong Master',
        description: 'Reach total score of 10000',
        icon: Icons.emoji_events,
        isUnlocked: false,
      ),
      Achievement(
        id: '4',
        title: 'Regular Player',
        description: 'Play 20 rounds',
        icon: Icons.history,
        isUnlocked: false,
      ),
      Achievement(
        id: '5',
        title: 'Self-Draw King',
        description: 'Self-draw 10 times',
        icon: Icons.gavel,
        isUnlocked: false,
      ),
      Achievement(
        id: '6',
        title: 'Undefeated',
        description: 'Complete a game without losing',
        icon: Icons.shield,
        isUnlocked: false,
      ),
    ];

    return BaseScreen(
      title: 'Achievements',
      currentIndex: 2,
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: achievements.length,
        itemBuilder: (context, index) {
          final achievement = achievements[index];
          return Card(
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    achievement.icon,
                    size: 40,
                    color: achievement.isUnlocked
                        ? Colors.amber
                        : Colors.grey.shade400,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    achievement.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: achievement.isUnlocked
                          ? Colors.black
                          : Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    achievement.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: achievement.isUnlocked
                          ? Colors.black54
                          : Colors.grey.shade500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  if (achievement.isUnlocked)
                    const Icon(Icons.lock_open, color: Colors.green)
                  else
                    const Icon(Icons.lock, color: Colors.grey),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}