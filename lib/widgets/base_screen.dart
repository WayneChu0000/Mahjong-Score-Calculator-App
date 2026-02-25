import 'package:flutter/material.dart';
import '../routes/app_routes.dart';
import '../localization/app_localizations.dart';
import '../theme/app_colors.dart';

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

    String? route;
    switch (index) {
      case 0:
        route = AppRoutes.home;
        break;
      case 1:
        route = AppRoutes.rules;
        break;
      case 2:
        route = AppRoutes.settings;
        break;
    }

    if (route != null) {
      Navigator.pushReplacementNamed(context, route);
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
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: AppLocalizations.home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.menu_book),
            label: AppLocalizations.rules,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: AppLocalizations.settings,
          ),
        ],
        currentIndex: widget.currentIndex,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        onTap: (index) => _onItemTapped(index, context),
        type: BottomNavigationBarType.fixed, // Fixed display for all items
      ),
    );
  }
}