import 'package:flutter/material.dart';
import '../widgets/base_screen.dart';
import '../services/settings_service.dart';
import '../services/auth_service.dart';
import 'auth_wrapper.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsService _settings = SettingsService.instance;

  @override
  void initState() {
    super.initState();
    // Listen to settings changes
    _settings.addListener(_onSettingsChanged);
  }

  @override
  void dispose() {
    _settings.removeListener(_onSettingsChanged);
    super.dispose();
  }

  void _onSettingsChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _signOut() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await AuthService().signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AuthWrapper()),
          (route) => false,
        );
      }
    }
  }

  void _showLanguageSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Select Language'),
        children: [
          _buildLanguageOption('English'),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Text('More languages coming soon...', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(String language) {
    return SimpleDialogOption(
      onPressed: () {
        _settings.setLanguage(language);
        Navigator.pop(context);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(language),
          if (_settings.language == language)
            const Icon(Icons.check, color: Colors.green),
        ],
      ),
    );
  }

  void _showThemeSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Theme Mode'),
        children: [
          _buildThemeOption('Light Mode'),
          _buildThemeOption('Dark Mode'),
          _buildThemeOption('Follow System'),
        ],
      ),
    );
  }

  Widget _buildThemeOption(String theme) {
    return SimpleDialogOption(
      onPressed: () {
        _settings.setTheme(theme);
        Navigator.pop(context);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(theme),
          if (_settings.theme == theme)
            const Icon(Icons.check, color: Colors.green),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Mahjong Calculator',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.casino, size: 50, color: Colors.green),
      children: [
        const Text('A simple and easy-to-use Mahjong score calculator.'),
        const SizedBox(height: 10),
        const Text('© 2025 Mahjong Calculator Team'),
      ],
    );
  }

  void _showFeedbackDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Feedback'),
        content: const Text('Please send your feedback to support@example.com'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'We respect your privacy. This app stores your game data locally and on Firebase for synchronization purposes. We do not share your personal data with third parties.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'Settings',
      currentIndex: 2, // Settings page is the third item in bottom navigation
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Language Settings
          _buildSettingCard(
            icon: Icons.language,
            title: 'Language',
            subtitle: _settings.language,
            onTap: _showLanguageSelectionDialog,
          ),
          
          const SizedBox(height: 16),
          
          // Theme Mode
          _buildSettingCard(
            icon: Icons.color_lens,
            title: 'Theme Mode',
            subtitle: _settings.theme,
            onTap: _showThemeSelectionDialog,
          ),
          
          const SizedBox(height: 16),

          // About Us
          _buildSettingCard(
            icon: Icons.info,
            title: 'About Us',
            onTap: _showAboutDialog,
          ),

          const SizedBox(height: 16),

          // Feedback
          _buildSettingCard(
            icon: Icons.feedback,
            title: 'Feedback',
            onTap: _showFeedbackDialog,
          ),

          const SizedBox(height: 16),

          // Privacy Policy
          _buildSettingCard(
            icon: Icons.privacy_tip,
            title: 'Privacy Policy',
            onTap: _showPrivacyPolicyDialog,
          ),

          const SizedBox(height: 16),

          // Logout
          _buildSettingCard(
            icon: Icons.logout,
            title: 'Logout',
            titleColor: Colors.red,
            onTap: _signOut,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? titleColor,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: titleColor ?? Colors.green),
        title: Text(
          title,
          style: TextStyle(color: titleColor),
        ),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}