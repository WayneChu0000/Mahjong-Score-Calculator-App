import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/history.dart';
import '../screens/rules_screen.dart'; // 添加規則頁面
import '../screens/settings_screen.dart'; // 添加設定頁面

class BaseScreen extends StatefulWidget {
  final Widget body;
  final String title;
  final int currentIndex;

  const BaseScreen({
    super.key,
    required this.body,
    required this.title,
    required this.currentIndex,
  });

  @override
  State<BaseScreen> createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  void _onItemTapped(int index, BuildContext context) {
    if (index == widget.currentIndex) return;

    // 根據選擇的導航項目切換頁面
    Widget? nextScreen;
    switch (index) {
      case 0:
        nextScreen = const HomePage();
        break;
      case 1:
        nextScreen = const HistoryScreen();
        break;
      case 2:
        nextScreen = const RulesScreen();
        break;
      case 3:
        nextScreen = const SettingsScreen();
        break;
    }

    if (nextScreen != null) {
      // 使用替換而不是推入，以避免頁面堆疊過多
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => nextScreen!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: widget.body,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '首頁',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: '歷史記錄',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: '規則',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '設定',
          ),
        ],
        currentIndex: widget.currentIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: (index) => _onItemTapped(index, context),
        type: BottomNavigationBarType.fixed, // 固定顯示所有項目
      ),
    );
  }
}