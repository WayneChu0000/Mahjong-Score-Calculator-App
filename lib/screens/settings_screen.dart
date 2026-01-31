import 'package:flutter/material.dart';
import '../widgets/base_screen.dart';
import '../services/settings_service.dart';
import '../services/auth_service.dart';
import 'auth_wrapper.dart';
import '../localization/app_localizations.dart';

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
        title: Text(AppLocalizations.logout),
        content: Text(AppLocalizations.confirmLogout),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(AppLocalizations.logout, style: const TextStyle(color: Colors.red)),
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
        title: Text(AppLocalizations.selectLanguage),
        children: [
          _buildLanguageOption(AppLocalizations.langEnglish, 'English'),
          const Divider(),
          _buildLanguageOption(AppLocalizations.langTraditionalChinese, 'Traditional Chinese'),
          /*
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Text('More languages coming soon...', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
          ),
          */
        ],
      ),
    );
  }

  Widget _buildLanguageOption(String label, String value) {
    return SimpleDialogOption(
      onPressed: () {
        _settings.setLanguage(value);
        Navigator.pop(context);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          if (_settings.language == value)
            const Icon(Icons.check, color: Colors.green),
        ],
      ),
    );
  }

  void _showThemeSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(AppLocalizations.themeMode),
        children: [
          _buildThemeOption(AppLocalizations.lightMode, 'Light Mode'),
          _buildThemeOption(AppLocalizations.darkMode, 'Dark Mode'),
          // _buildThemeOption('Follow System'),
        ],
      ),
    );
  }

  Widget _buildThemeOption(String label, String value) {
    return SimpleDialogOption(
      onPressed: () {
        _settings.setTheme(value);
        Navigator.pop(context);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          if (_settings.theme == value)
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
      title: AppLocalizations.settings,
      currentIndex: 2, // Settings page is the third item in bottom navigation
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Language Settings
          _buildSettingCard(
            icon: Icons.language,
            title: AppLocalizations.language,
            subtitle: _settings.language == 'Traditional Chinese' ? AppLocalizations.langTraditionalChinese : AppLocalizations.langEnglish,
            onTap: _showLanguageSelectionDialog,
          ),
          
          const SizedBox(height: 16),
          
          // Theme Mode
          _buildSettingCard(
            icon: Icons.color_lens,
            title: AppLocalizations.themeMode,
            subtitle: _settings.theme == 'Light Mode' ? AppLocalizations.lightMode : AppLocalizations.darkMode,
            onTap: _showThemeSelectionDialog,
          ),
          
          const SizedBox(height: 16),

          /*
          // About Us
          _buildSettingCard(
            icon: Icons.info,
            title: AppLocalizations.about,
            onTap: _showAboutDialog,
          ),

          const SizedBox(height: 16),

          // Feedback
          _buildSettingCard(
            icon: Icons.feedback,
            title: AppLocalizations.feedback,
            onTap: _showFeedbackDialog,
          ),

          const SizedBox(height: 16),

          // Privacy Policy
          _buildSettingCard(
            icon: Icons.privacy_tip,
            title: AppLocalizations.privacyPolicy,
            onTap: _showPrivacyPolicyDialog,
          ),

          const SizedBox(height: 16),
          */

          // Logout
          _buildSettingCard(
            icon: Icons.logout,
            title: AppLocalizations.logout,
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