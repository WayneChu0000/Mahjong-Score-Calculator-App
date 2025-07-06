import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '麻將計分器',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..forward();
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[800],
      body: SafeArea(
        child: FadeTransition(
          opacity: _animation,
          child: Column(
            children: [
              // Status Bar Time
              _buildStatusBar(),
              
              // Welcome Card
              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(-1, 0),
                  end: Offset.zero,
                ).animate(_animation),
                child: _buildWelcomeCard(),
              ),
              
              // Score Display
              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, -1),
                  end: Offset.zero,
                ).animate(_animation),
                child: _buildScoreDisplay(),
              ),
              
              // Main Buttons Grid
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ScaleTransition(
                    scale: _animation,
                    child: GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16.0,
                      crossAxisSpacing: 16.0,
                      children: [
                        _buildMainButton(
                          '開始新局',
                          Icons.casino,
                          Colors.amber,
                          Colors.black,
                          onTap: () {
                            // 轉至遊戲設置頁面
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const PlayerSetupScreen()),
                            );
                          },
                        ),
                        _buildMainButton(
                          '查看規則',
                          Icons.book,
                          Colors.green,
                          Colors.white,
                          onTap: () {
                            // 顯示規則對話框
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('遊戲規則'),
                                content: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: const [
                                      Text('1. 遊戲開始時，每位玩家獲得13張牌'),
                                      Text('2. 輪流抽牌並丟棄一張牌'),
                                      Text('3. 目標是集齊特定組合，如順子、刻子等'),
                                      Text('4. 第一個完成組合的玩家獲勝'),
                                      // 更多規則...
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('關閉'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        _buildMainButton(
                          '歷史記錄',
                          Icons.history,
                          Colors.grey[700]!,
                          Colors.white,
                          onTap: () {
                            // 轉至歷史記錄頁面
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const HistoryScreen()),
                            );
                          },
                        ),
                        _buildMainButton(
                          '成就展示',
                          Icons.emoji_events,
                          Colors.blue,
                          Colors.white,
                          onTap: () {
                            // 轉至成就頁面
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) => 
                                  const AchievementsScreen(),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  const begin = Offset(0.0, 1.0);
                                  const end = Offset.zero;
                                  const curve = Curves.easeInOut;
                                  var tween = Tween(begin: begin, end: end).chain(
                                    CurveTween(curve: curve));
                                  return SlideTransition(
                                    position: animation.drive(tween),
                                    child: child,
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildStatusBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: Colors.black.withOpacity(0.2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            DateFormat('HH:mm').format(DateTime.now()),
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.signal_cellular_alt, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          const Icon(Icons.battery_full, color: Colors.white, size: 16),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 25,
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, size: 30, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '歡迎，John！',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '2025/07/02 14:30',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '+12',
                style: TextStyle(
                  color: Colors.green[700],
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Handle details
                },
                child: Text(
                  '查看詳情',
                  style: TextStyle(
                    color: Colors.green[700],
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreDisplay() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.brightness_1, size: 12, color: Colors.white),
              SizedBox(width: 8),
              Text(
                '總得分：+150',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '完成10局',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainButton(
    String text,
    IconData icon,
    Color color,
    Color textColor, {
    required VoidCallback onTap,
  }) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: textColor),
              const SizedBox(height: 12),
              Text(
                text,
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.grey[900],
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.grey,
      currentIndex: 0, // 當前選中的索引
      onTap: (index) {
        // 根據索引切換頁面
        switch (index) {
          case 0:
            // 已在首頁，不需處理
            break;
          case 1:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
            break;
          case 2:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HistoryScreen()),
            );
            break;
          case 3:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AchievementsScreen()),
            );
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: '首頁'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: '玩家資料'),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: '歷史記錄'),
        BottomNavigationBarItem(icon: Icon(Icons.emoji_events), label: '成就'),
      ],
    );
  }
}


// 在檔案底部添加這些新的頁面類別

class PlayerSetupScreen extends StatelessWidget {
  const PlayerSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[800],
      appBar: AppBar(
        title: const Text('設置玩家'),
        backgroundColor: Colors.green[900],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '選擇玩家數量',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [2, 3, 4].map((count) => 
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24, 
                      vertical: 12
                    ),
                  ),
                  onPressed: () {
                    // 處理玩家數量選擇
                  },
                  child: Text('$count 位玩家'),
                )
              ).toList(),
            ),
            const SizedBox(height: 32),
            // 這裡可以添加更多設置選項
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () {
                // 開始遊戲
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GamePlayScreen()
                  ),
                );
              },
              child: const Text(
                '開始遊戲',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[800],
      appBar: AppBar(
        title: const Text('歷史記錄'),
        backgroundColor: Colors.green[900],
      ),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey[300],
                child: Text('${index + 1}'),
              ),
              title: Text('遊戲 #${1000 + index}'),
              subtitle: Text(
                '${DateFormat('yyyy/MM/dd HH:mm').format(
                  DateTime.now().subtract(Duration(days: index))
                )} - 4位玩家'
              ),
              trailing: Text(
                '+${(index * 5) + 10}',
                style: TextStyle(
                  color: Colors.green[700], 
                  fontWeight: FontWeight.bold
                ),
              ),
              onTap: () {
                // 查看遊戲詳情
              },
            ),
          );
        },
      ),
    );
  }
}

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[800],
      appBar: AppBar(
        title: const Text('成就展示'),
        backgroundColor: Colors.green[900],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        childAspectRatio: 0.8,
        children: [
          _buildAchievementCard(
            '初試啼聲',
            '完成第一局遊戲',
            Icons.play_circle,
            Colors.blue,
            true,
          ),
          _buildAchievementCard(
            '麻將高手',
            '贏得10局遊戲',
            Icons.emoji_events,
            Colors.amber,
            false,
          ),
          _buildAchievementCard(
            '連勝王者',
            '連續贏得3局遊戲',
            Icons.local_fire_department,
            Colors.deepOrange,
            false,
          ),
          _buildAchievementCard(
            '無敵鐵金剛',
            '單局得分超過100',
            Icons.bolt,
            Colors.purple,
            false,
          ),
        ],
      ),
    );
  }
  
  Widget _buildAchievementCard(
    String title, 
    String description, 
    IconData icon, 
    Color color, 
    bool unlocked
  ) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 50,
              color: unlocked ? color : Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: unlocked ? Colors.black : Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: unlocked ? Colors.black87 : Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            if (unlocked)
              const Icon(Icons.check_circle, color: Colors.green)
            else
              const Icon(Icons.lock, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[800],
      appBar: AppBar(
        title: const Text('玩家資料'),
        backgroundColor: Colors.green[900],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text(
              'John',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '註冊日期: ${DateFormat('yyyy/MM/dd').format(DateTime.now().subtract(const Duration(days: 30)))}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '遊戲統計',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildStatRow('總局數', '15'),
                    _buildStatRow('勝率', '60%'),
                    _buildStatRow('總得分', '+150'),
                    _buildStatRow('平均得分', '+10'),
                    _buildStatRow('最高單局', '+45'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class GamePlayScreen extends StatelessWidget {
  const GamePlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[800],
      appBar: AppBar(
        title: const Text('遊戲進行中'),
        backgroundColor: Colors.green[900],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPlayerScore('玩家 1', '+5'),
                _buildPlayerScore('玩家 2', '-10'),
                _buildPlayerScore('玩家 3', '+15'),
                _buildPlayerScore('玩家 4', '-10'),
              ],
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                '這裡是遊戲主畫面',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('贏'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24, 
                      vertical: 12
                    ),
                  ),
                  onPressed: () {
                    // 處理贏的情況
                  },
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.remove),
                  label: const Text('輸'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24, 
                      vertical: 12
                    ),
                  ),
                  onPressed: () {
                    // 處理輸的情況
                  },
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('結束'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24, 
                      vertical: 12
                    ),
                  ),
                  onPressed: () {
                    // 結束遊戲
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPlayerScore(String name, String score) {
    final isPositive = score.startsWith('+');
    return Column(
      children: [
        Text(
          name,
          style: const TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 4),
        Text(
          score,
          style: TextStyle(
            color: isPositive ? Colors.green[300] : Colors.red[300],
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ],
    );
  }
}