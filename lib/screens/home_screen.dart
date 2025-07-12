import 'package:flutter/material.dart';
import '../widgets/score_display.dart';
import '../widgets/game_button.dart';
import '../widgets/base_screen.dart';
import 'player_setup.dart';
import 'history.dart';
import 'achievements.dart';
import 'profile.dart';
import 'rules_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Interval(0.0, 0.6, curve: Curves.easeIn))
    );
    
    _slideAnimation = Tween<Offset>(begin: Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Interval(0.2, 1.0, curve: Curves.easeOut))
    );
    
    _controller.forward();
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
                const Text(
                  '選擇操作',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: [
                      GameButton(
                        icon: Icons.play_arrow,
                        label: '開始遊戲',
                        color: Colors.green,
                        backgroundColor: Colors.green.shade50,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const PlayerSetupScreen()),
                          );
                        },
                      ),
                      GameButton(
                        icon: Icons.history,
                        label: '歷史記錄',
                        color: Colors.blue,
                        backgroundColor: Colors.green.shade50,
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const HistoryScreen()),
                          );
                        },
                      ),
                      GameButton(
                        icon: Icons.emoji_events,
                        label: '成就',
                        color: Colors.amber,
                        backgroundColor: Colors.green.shade50,
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const AchievementsScreen()),
                          );
                        },
                      ),
                      GameButton(
                        icon: Icons.person,
                        label: '個人資料',
                        color: Colors.purple,
                        backgroundColor: Colors.green.shade50,
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const ProfileScreen()),
                          );
                        },
                      ),
                      GameButton(
                        icon: Icons.menu_book,
                        label: '規則',
                        color: Colors.teal,
                        backgroundColor: Colors.green.shade50,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const RulesScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}