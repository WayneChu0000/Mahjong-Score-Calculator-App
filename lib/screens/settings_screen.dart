import 'package:flutter/material.dart';
import '../widgets/base_screen.dart';
import '../services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsService _settings = SettingsService.instance;
  bool _isNotificationsEnabled = true;
  bool _isSoundEnabled = false;
  String _selectedLanguage = 'Traditional Chinese';
  String _selectedTheme = 'Light Mode';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isNotificationsEnabled = _settings.isNotificationsEnabled;
      _isSoundEnabled = _settings.isSoundEnabled;
      _selectedLanguage = _settings.language;
      _selectedTheme = _settings.theme;
    });
  }

  Future<void> _saveSettings() async {
    await _settings.setNotificationsEnabled(_isNotificationsEnabled);
    await _settings.setSoundEnabled(_isSoundEnabled);
    await _settings.setLanguage(_selectedLanguage);
    await _settings.setTheme(_selectedTheme);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings saved')),
    );
  }

  Future<void> _resetSettings() async {
    await _settings.resetToDefaults();
    await _loadSettings();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings reset to defaults')),
    );
  }

  Future<void> _showClearDataConfirmDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text('This will delete all game records and settings permanently. Are you sure you want to continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _clearAllData();
            },
            child: const Text('OK', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _clearAllData() async {
    await _settings.clearAllData();
    
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All data cleared')),
    );
  }

  void _showLanguageSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Select Language'),
        children: [
          _buildLanguageOption('Traditional Chinese'),
          _buildLanguageOption('Simplified Chinese'),
          _buildLanguageOption('English'),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(String language) {
    return SimpleDialogOption(
      onPressed: () {
        setState(() {
          _selectedLanguage = language;
        });
        Navigator.pop(context);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(language),
          if (_selectedLanguage == language)
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
        setState(() {
          _selectedTheme = theme;
        });
        Navigator.pop(context);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(theme),
          if (_selectedTheme == theme)
            const Icon(Icons.check, color: Colors.green),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'Settings',
      currentIndex: 3, // Settings page is the fourth item in bottom navigation
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Language Settings
          _buildSettingCard(
            icon: Icons.language,
            title: 'Language Settings',
            subtitle: _selectedLanguage,
            onTap: _showLanguageSelectionDialog,
          ),
          
          const SizedBox(height: 16),
          
          // Notifications
          _buildSwitchCard(
            icon: Icons.notifications,
            title: 'Notifications',
            value: _isNotificationsEnabled,
            onChanged: (value) {
              setState(() {
                _isNotificationsEnabled = value;
              });
            },
          ),
          
          const SizedBox(height: 16),
          
          // Sound Effects
          _buildSwitchCard(
            icon: Icons.volume_up,
            title: 'Sound Effects',
            value: _isSoundEnabled,
            onChanged: (value) {
              setState(() {
                _isSoundEnabled = value;
              });
            },
          ),
          
          const SizedBox(height: 16),
          
          // Theme Mode
          _buildSettingCard(
            icon: Icons.color_lens,
            title: 'Theme Mode',
            subtitle: _selectedTheme,
            onTap: _showThemeSelectionDialog,
          ),
          
          const SizedBox(height: 16),
          
          // Clear All Data
          _buildSettingCard(
            icon: Icons.delete_forever,
            title: 'Clear All Data',
            titleColor: Colors.red,
            onTap: _showClearDataConfirmDialog,
          ),
          
          const SizedBox(height: 32),
          
          // Save Settings Button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: _saveSettings,
            child: const Text('Save Settings', style: TextStyle(fontSize: 16)),
          ),
          
          const SizedBox(height: 16),
          
          // Reset to Defaults Button
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: _resetSettings,
            child: const Text('Reset to Defaults', style: TextStyle(fontSize: 16)),
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

  Widget _buildSwitchCard({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      child: SwitchListTile(
        secondary: Icon(icon, color: Colors.green),
        title: Text(title),
        value: value,
        activeColor: Colors.amber,
        onChanged: onChanged,
      ),
    );
  }
}