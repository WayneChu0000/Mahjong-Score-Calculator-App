import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/base_screen.dart';
import '../services/settings_service.dart';
import '../services/auth_service.dart';
import 'auth_wrapper.dart';
import '../localization/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
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
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AuthWrapper()),
          (route) => false,
        );
      }
    }
  }

  void _showLanguageSelectionDialog(BuildContext context) {
    final settings = context.read<SettingsService>();
    showDialog(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(AppLocalizations.selectLanguage),
        children: [
          _buildLanguageOption(dialogContext, settings, AppLocalizations.langEnglish, 'English'),
          const Divider(),
          _buildLanguageOption(dialogContext, settings, AppLocalizations.langTraditionalChinese, 'Traditional Chinese'),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(BuildContext context, SettingsService settings, String label, String value) {
    return SimpleDialogOption(
      onPressed: () {
        settings.setLanguage(value);
        Navigator.pop(context);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          if (settings.language == value)
            const Icon(Icons.check, color: Colors.green),
        ],
      ),
    );
  }

  void _showThemeSelectionDialog(BuildContext context) {
    final settings = context.read<SettingsService>();
    showDialog(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(AppLocalizations.themeMode),
        children: [
          _buildThemeOption(dialogContext, settings, AppLocalizations.lightMode, 'Light Mode'),
          _buildThemeOption(dialogContext, settings, AppLocalizations.darkMode, 'Dark Mode'),
        ],
      ),
    );
  }

  Widget _buildThemeOption(BuildContext context, SettingsService settings, String label, String value) {
    return SimpleDialogOption(
      onPressed: () {
        settings.setTheme(value);
        Navigator.pop(context);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          if (settings.theme == value)
            const Icon(Icons.check, color: Colors.green),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsService>();
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
            subtitle: settings.language == 'Traditional Chinese' ? AppLocalizations.langTraditionalChinese : AppLocalizations.langEnglish,
            onTap: () => _showLanguageSelectionDialog(context),
          ),
          
          const SizedBox(height: 16),
          
          // Theme Mode
          _buildSettingCard(
            icon: Icons.color_lens,
            title: AppLocalizations.themeMode,
            subtitle: settings.theme == 'Light Mode' ? AppLocalizations.lightMode : AppLocalizations.darkMode,
            onTap: () => _showThemeSelectionDialog(context),
          ),
          
          const SizedBox(height: 16),

          // Logout
          _buildSettingCard(
            icon: Icons.logout,
            title: AppLocalizations.logout,
            titleColor: Colors.red,
            onTap: () => _signOut(context),
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