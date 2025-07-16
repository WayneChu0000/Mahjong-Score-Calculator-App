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
  String _selectedLanguage = '繁體中文';
  String _selectedTheme = '淺色模式';

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
      const SnackBar(content: Text('設定已保存')),
    );
  }

  Future<void> _resetSettings() async {
    await _settings.resetToDefaults();
    await _loadSettings();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已恢復預設設定')),
    );
  }

  Future<void> _showClearDataConfirmDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除所有數據'),
        content: const Text('此操作將刪除所有遊戲記錄和設定，且不可撤銷。確定要繼續嗎？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _clearAllData();
            },
            child: const Text('確定', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _clearAllData() async {
    await _settings.clearAllData();
    
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('所有數據已清除')),
    );
  }

  void _showLanguageSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('選擇語言'),
        children: [
          _buildLanguageOption('繁體中文'),
          _buildLanguageOption('簡體中文'),
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
        title: const Text('主題模式'),
        children: [
          _buildThemeOption('淺色模式'),
          _buildThemeOption('深色模式'),
          _buildThemeOption('跟隨系統'),
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
      title: '設定',
      currentIndex: 3, // 假設設定頁為底部導航第四項
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 語言設定
          _buildSettingCard(
            icon: Icons.language,
            title: '語言設定',
            subtitle: _selectedLanguage,
            onTap: _showLanguageSelectionDialog,
          ),
          
          const SizedBox(height: 16),
          
          // 開始通知
          _buildSwitchCard(
            icon: Icons.notifications,
            title: '開始通知',
            value: _isNotificationsEnabled,
            onChanged: (value) {
              setState(() {
                _isNotificationsEnabled = value;
              });
            },
          ),
          
          const SizedBox(height: 16),
          
          // 音效
          _buildSwitchCard(
            icon: Icons.volume_up,
            title: '音效',
            value: _isSoundEnabled,
            onChanged: (value) {
              setState(() {
                _isSoundEnabled = value;
              });
            },
          ),
          
          const SizedBox(height: 16),
          
          // 主題模式
          _buildSettingCard(
            icon: Icons.color_lens,
            title: '主題模式',
            subtitle: _selectedTheme,
            onTap: _showThemeSelectionDialog,
          ),
          
          const SizedBox(height: 16),
          
          // 清除所有數據
          _buildSettingCard(
            icon: Icons.delete_forever,
            title: '清除所有數據',
            titleColor: Colors.red,
            onTap: _showClearDataConfirmDialog,
          ),
          
          const SizedBox(height: 32),
          
          // 保存設定按鈕
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: _saveSettings,
            child: const Text('保存設定', style: TextStyle(fontSize: 16)),
          ),
          
          const SizedBox(height: 16),
          
          // 恢復預設設定按鈕
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: _resetSettings,
            child: const Text('恢復預設設定', style: TextStyle(fontSize: 16)),
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