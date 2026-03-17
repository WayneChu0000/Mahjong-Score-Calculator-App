import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/base_screen.dart';
import '../services/settings_service.dart';
import '../services/auth_service.dart';
import 'auth_wrapper.dart';
import '../localization/app_localizations.dart';
import '../routes/app_routes.dart';
import '../models/tw_rules.dart';

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
            child: Text(
              AppLocalizations.logout,
              style: const TextStyle(color: Colors.red),
            ),
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
          _buildLanguageOption(
            dialogContext,
            settings,
            AppLocalizations.langEnglish,
            'English',
          ),
          const Divider(),
          _buildLanguageOption(
            dialogContext,
            settings,
            AppLocalizations.langTraditionalChinese,
            'Traditional Chinese',
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    SettingsService settings,
    String label,
    String value,
  ) {
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
          _buildThemeOption(
            dialogContext,
            settings,
            AppLocalizations.lightMode,
            'Light Mode',
          ),
          _buildThemeOption(
            dialogContext,
            settings,
            AppLocalizations.darkMode,
            'Dark Mode',
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    SettingsService settings,
    String label,
    String value,
  ) {
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BaseScreen(
      title: AppLocalizations.settings,
      currentIndex: 2,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Display Settings ────────────────────────────────
          _buildSectionHeader(
            AppLocalizations.displaySettings,
            Icons.palette,
            isDark,
          ),
          const SizedBox(height: 8),

          // Language
          _buildSettingCard(
            icon: Icons.language,
            title: AppLocalizations.language,
            subtitle: settings.language == 'Traditional Chinese'
                ? AppLocalizations.langTraditionalChinese
                : AppLocalizations.langEnglish,
            onTap: () => _showLanguageSelectionDialog(context),
          ),
          const SizedBox(height: 8),

          // Theme Mode
          _buildSettingCard(
            icon: Icons.color_lens,
            title: AppLocalizations.themeMode,
            subtitle: settings.theme == 'Light Mode'
                ? AppLocalizations.lightMode
                : AppLocalizations.darkMode,
            onTap: () => _showThemeSelectionDialog(context),
          ),

          const SizedBox(height: 24),

          // ── HK Game Preferences ────────────────────────────
          _buildSectionHeader(
            AppLocalizations.hkGameSettings,
            Icons.sports_esports,
            isDark,
          ),
          const SizedBox(height: 8),

          // HK Min/Max Fan
          _buildSettingCard(
            icon: Icons.tune,
            title:
                '${AppLocalizations.hkMinFanSetting} / ${AppLocalizations.hkMaxFanSetting}',
            subtitle:
                '${settings.hkMinFan} - ${settings.hkMaxFan == 999 ? AppLocalizations.noLimit : settings.hkMaxFan} ${AppLocalizations.fanTitle}',
            onTap: () => _showHkFanDialog(context),
          ),

          const SizedBox(height: 24),

          // ── TW Game Preferences ────────────────────────────
          _buildSectionHeader(
            AppLocalizations.twGameSettings,
            Icons.sports_esports,
            isDark,
          ),
          const SizedBox(height: 8),

          // TW Base Tai
          _buildSettingCard(
            icon: Icons.monetization_on,
            title: AppLocalizations.twBaseTaiSetting,
            subtitle:
                '${AppLocalizations.twBaseTaiSetting}: ${settings.twBaseTai}',
            onTap: () => _showTwTaiDialog(context),
          ),
          const SizedBox(height: 8),

          // TW Real-time Payments
          _buildSettingCard(
            icon: Icons.payments,
            title: AppLocalizations.twPayments,
            subtitle: settings.twPayments.isEmpty
                ? AppLocalizations.noPayments
                : '${settings.twPayments.length} items',
            onTap: () => _showTwPaymentsSheet(context),
          ),

          const SizedBox(height: 24),

          // ── Advanced Settings ──────────────────────────────
          _buildSectionHeader(
            AppLocalizations.advancedSettings,
            Icons.tune,
            isDark,
          ),
          const SizedBox(height: 8),

          // Custom Fan/Tai Values
          _buildSettingCard(
            icon: Icons.edit_note,
            title: AppLocalizations.customFanValues,
            subtitle: _customFanSubtitle(settings),
            onTap: () =>
                Navigator.pushNamed(context, AppRoutes.customFanEditor),
          ),

          const SizedBox(height: 24),

          // ── Account ────────────────────────────────────────
          _buildSectionHeader(
            AppLocalizations.accountSettings,
            Icons.person,
            isDark,
          ),
          const SizedBox(height: 8),

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

  String _customFanSubtitle(SettingsService settings) {
    final hkCount =
        settings.customHkFan.length +
        settings.customHkRules.length +
        settings.deletedHkRules.length;
    final twCount =
        settings.customTwTai.length +
        settings.customTwRules.length +
        settings.deletedTwRules.length;
    if (hkCount == 0 && twCount == 0) {
      return AppLocalizations.customFanValuesDesc;
    }
    final parts = <String>[];
    if (hkCount > 0) parts.add('HK: $hkCount');
    if (twCount > 0) parts.add('TW: $twCount');
    return '${AppLocalizations.customized} (${parts.join(', ')})';
  }

  Widget _buildSectionHeader(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.green),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.green.shade300 : Colors.green.shade800,
          ),
        ),
      ],
    );
  }

  // ── HK Min/Max Fan Dialog ───────────────────────────────────
  void _showHkFanDialog(BuildContext context) {
    final settings = context.read<SettingsService>();
    int minFan = settings.hkMinFan;
    int maxFan = settings.hkMaxFan;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(AppLocalizations.hkGameSettings),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Min Fan
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppLocalizations.hkMinFanSetting),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: minFan > 0
                            ? () => setDialogState(() => minFan--)
                            : null,
                      ),
                      Text(
                        '$minFan',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: (maxFan == 999 || minFan < maxFan)
                            ? () => setDialogState(() => minFan++)
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
              // Max Fan
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppLocalizations.hkMaxFanSetting),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () => setDialogState(() {
                          if (maxFan == 999) {
                            maxFan = 13;
                          } else if (maxFan > minFan) {
                            maxFan--;
                          }
                        }),
                      ),
                      Text(
                        maxFan == 999 ? AppLocalizations.noLimit : '$maxFan',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () => setDialogState(() {
                          if (maxFan >= 13) {
                            maxFan = 999;
                          } else {
                            maxFan++;
                          }
                        }),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(AppLocalizations.cancel),
            ),
            TextButton(
              onPressed: () async {
                await settings.setHkMinFan(minFan);
                await settings.setHkMaxFan(maxFan);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: Text(
                AppLocalizations.confirm,
                style: const TextStyle(color: Colors.green),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── TW Base Tai Dialog ────────────────────────────────────
  void _showTwTaiDialog(BuildContext context) {
    final settings = context.read<SettingsService>();
    int baseTai = settings.twBaseTai;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(AppLocalizations.twGameSettings),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Base Tai
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(child: Text(AppLocalizations.twBaseTaiSetting)),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: baseTai > 0
                            ? () => setDialogState(() => baseTai--)
                            : null,
                      ),
                      Text(
                        '$baseTai',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () => setDialogState(() => baseTai++),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(AppLocalizations.cancel),
            ),
            TextButton(
              onPressed: () async {
                await settings.setTwBaseTai(baseTai);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: Text(
                AppLocalizations.confirm,
                style: const TextStyle(color: Colors.green),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── TW Real-time Payments Bottom Sheet ──────────────────────
  void _showTwPaymentsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => const _TwPaymentsSheet(),
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
        title: Text(title, style: TextStyle(color: titleColor)),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

/// Bottom sheet widget for TW real-time payment configuration
class _TwPaymentsSheet extends StatefulWidget {
  const _TwPaymentsSheet();

  @override
  State<_TwPaymentsSheet> createState() => _TwPaymentsSheetState();
}

class _TwPaymentsSheetState extends State<_TwPaymentsSheet> {
  /// Default values for each built-in rule (keyed by localization getter name)
  static const Map<String, int> _builtInDefaults = {
    'twChaseRule': 10,
    'twConcealedKongPay': 10,
    'twFlowerSeasonSetPay': 5,
    'twFlowerGroupPay': 10,
    'twFalseWinPay': 10,
    'twCalledPongPenalty': 10,
  };

  /// Maps rule.name → stable key for persistence
  String _keyForBuiltIn(String ruleName) {
    if (ruleName == AppLocalizations.twChaseRule) return 'twChaseRule';
    if (ruleName == AppLocalizations.twConcealedKongPay)
      return 'twConcealedKongPay';
    if (ruleName == AppLocalizations.twFlowerSeasonSetPay)
      return 'twFlowerSeasonSetPay';
    if (ruleName == AppLocalizations.twFlowerGroupPay)
      return 'twFlowerGroupPay';
    if (ruleName == AppLocalizations.twFalseWinPay) return 'twFalseWinPay';
    if (ruleName == AppLocalizations.twCalledPongPenalty)
      return 'twCalledPongPenalty';
    return ruleName;
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsService>();
    final customPayments = settings.twPayments;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final builtInRules = twInstantPayRules
        .where((r) => r.name.isNotEmpty)
        .toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (ctx, scrollController) => Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.twPayments,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.green),
                  onPressed: () => _showCustomPaymentDialog(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Combined list: built-in first, then custom
          Expanded(
            child: ListView(
              controller: scrollController,
              children: [
                // ── Built-in items ──
                ...builtInRules.map((rule) {
                  final key = _keyForBuiltIn(rule.name);
                  final defaultVal = _builtInDefaults[key] ?? 10;
                  final value = settings.getTwBuiltInPayValue(key, defaultVal);
                  return _buildPaymentTile(
                    name: rule.name,
                    value: value,
                    isBuiltIn: true,
                    isDark: isDark,
                    onEdit: () =>
                        _showValueEditDialog(context, rule.name, key, value),
                  );
                }),
                // ── Custom items ──
                if (customPayments.isNotEmpty) ...[
                  ...customPayments.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    final name = item['name'] as String;
                    final value = item['value'] as int;
                    return _buildPaymentTile(
                      name: name,
                      value: value,
                      isBuiltIn: false,
                      isDark: isDark,
                      onEdit: () => _showCustomPaymentDialog(
                        context,
                        editIndex: index,
                        initialName: name,
                        initialValue: value,
                      ),
                      onDelete: () async {
                        await settings.removeTwPayment(index);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(AppLocalizations.paymentDeleted),
                            ),
                          );
                        }
                      },
                    );
                  }),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentTile({
    required String name,
    required int value,
    required bool isBuiltIn,
    required bool isDark,
    required VoidCallback onEdit,
    VoidCallback? onDelete,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isBuiltIn
              ? (isDark ? Colors.orange.shade800 : Colors.orange)
              : (isDark ? Colors.blue.shade800 : Colors.blue),
        ),
        child: Center(
          child: Text(
            '$value',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        isBuiltIn
            ? '${AppLocalizations.builtInPayment} · ${AppLocalizations.paymentValue}: $value'
            : '${AppLocalizations.paymentValue}: $value',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: onEdit),
          if (onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete, size: 20, color: Colors.red),
              onPressed: onDelete,
            ),
        ],
      ),
    );
  }

  /// Edit only the value of a built-in rule
  void _showValueEditDialog(
    BuildContext context,
    String ruleName,
    String ruleKey,
    int currentValue,
  ) {
    final valueController = TextEditingController(text: '$currentValue');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.editPayment),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              ruleName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: valueController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: AppLocalizations.paymentValue,
                hintText: AppLocalizations.enterValue,
                border: const OutlineInputBorder(),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.cancel),
          ),
          TextButton(
            onPressed: () async {
              final value = int.tryParse(valueController.text);
              if (value == null || value < 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppLocalizations.invalidValue)),
                );
                return;
              }
              final settings = context.read<SettingsService>();
              await settings.setTwBuiltInPayValue(ruleKey, value);
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppLocalizations.paymentSaved)),
                );
              }
            },
            child: Text(
              AppLocalizations.confirm,
              style: const TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }

  /// Add or edit a custom payment item
  void _showCustomPaymentDialog(
    BuildContext context, {
    int? editIndex,
    String? initialName,
    int? initialValue,
  }) {
    final isEdit = editIndex != null;
    final nameController = TextEditingController(text: initialName ?? '');
    final valueController = TextEditingController(
      text: '${initialValue ?? 10}',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          isEdit ? AppLocalizations.editPayment : AppLocalizations.addPayment,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: AppLocalizations.paymentName,
                hintText: AppLocalizations.enterRuleName,
                border: const OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: valueController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: AppLocalizations.paymentValue,
                hintText: AppLocalizations.enterValue,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.cancel),
          ),
          TextButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final value = int.tryParse(valueController.text);
              if (name.isEmpty || value == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppLocalizations.invalidValue)),
                );
                return;
              }
              final settings = context.read<SettingsService>();
              if (isEdit) {
                await settings.updateTwPayment(editIndex, name, value);
              } else {
                await settings.addTwPayment(name, value);
              }
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppLocalizations.paymentSaved)),
                );
              }
            },
            child: Text(
              AppLocalizations.confirm,
              style: const TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }
}
