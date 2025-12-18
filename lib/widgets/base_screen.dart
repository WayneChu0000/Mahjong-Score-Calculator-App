import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/history.dart';
import '../screens/rules_screen.dart';
import '../screens/settings_screen.dart';

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

    // Switch pages based on selected navigation item
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
      // Use replacement instead of push to avoid excessive page stack
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
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Rules',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: widget.currentIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: (index) => _onItemTapped(index, context),
        type: BottomNavigationBarType.fixed, // Fixed display for all items
      ),
    );
  }
}