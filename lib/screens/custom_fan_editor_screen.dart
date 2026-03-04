import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/rule.dart';
import '../models/game_mode.dart';
import '../services/settings_service.dart';
import '../localization/app_localizations.dart';

class CustomFanEditorScreen extends StatefulWidget {
  const CustomFanEditorScreen({super.key});

  @override
  State<CustomFanEditorScreen> createState() => _CustomFanEditorScreenState();
}

class _CustomFanEditorScreenState extends State<CustomFanEditorScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.customFanValues),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.green,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: AppLocalizations.customHkFan),
            Tab(text: AppLocalizations.customTwTai),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(value),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'resetHk',
                child: Text('${AppLocalizations.resetToDefault} (HK)'),
              ),
              PopupMenuItem(
                value: 'resetTw',
                child: Text('${AppLocalizations.resetToDefault} (TW)'),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'deletedHk',
                child: Text('${AppLocalizations.deletedRules} (HK)'),
              ),
              PopupMenuItem(
                value: 'deletedTw',
                child: Text('${AppLocalizations.deletedRules} (TW)'),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddRuleDialog(),
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRuleList(GameMode.hongKong),
          _buildRuleList(GameMode.taiwan),
        ],
      ),
    );
  }

  void _handleMenuAction(String action) {
    final settings = context.read<SettingsService>();

    if (action == 'deletedHk' || action == 'deletedTw') {
      _showDeletedRulesDialog(
        action == 'deletedHk' ? GameMode.hongKong : GameMode.taiwan,
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.resetToDefault),
        content: Text(AppLocalizations.resetFanConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.cancel),
          ),
          TextButton(
            onPressed: () async {
              if (action == 'resetHk') {
                await settings.resetCustomHkFan();
              } else {
                await settings.resetCustomTwTai();
              }
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppLocalizations.allReset)),
                );
              }
            },
            child: Text(
              AppLocalizations.confirm,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeletedRulesDialog(GameMode mode) {
    final settings = context.read<SettingsService>();
    final isHk = mode == GameMode.hongKong;
    final deletedSet = isHk ? settings.deletedHkRules : settings.deletedTwRules;
    final allRules = getRules(mode);

    if (deletedSet.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppLocalizations.deletedRules}: 0')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.deletedRules),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: deletedSet.map((idx) {
              if (idx >= allRules.length) return const SizedBox.shrink();
              final rule = allRules[idx];
              return ListTile(
                title: Text(rule.name),
                subtitle: Text(
                  '${isHk ? AppLocalizations.fanValueLabel : AppLocalizations.taiValueLabel}: ${rule.fanValue}',
                ),
                trailing: TextButton(
                  onPressed: () async {
                    if (isHk) {
                      await settings.restoreBuiltInHkRule(idx);
                    } else {
                      await settings.restoreBuiltInTwRule(idx);
                    }
                    if (ctx.mounted) Navigator.pop(ctx);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(AppLocalizations.ruleRestored)),
                      );
                    }
                  },
                  child: Text(
                    AppLocalizations.restore,
                    style: const TextStyle(color: Colors.green),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.close),
          ),
        ],
      ),
    );
  }

  Widget _buildRuleList(GameMode mode) {
    final settings = context.watch<SettingsService>();
    final builtInRules = getRules(mode);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isHk = mode == GameMode.hongKong;
    final customMap = isHk ? settings.customHkFan : settings.customTwTai;
    final deletedSet = isHk ? settings.deletedHkRules : settings.deletedTwRules;
    final customRulesList = isHk
        ? settings.customHkRules
        : settings.customTwRules;

    // Filter out deleted rules and group by fan/tai value
    final Map<int, List<MapEntry<int, Rule>>> grouped = {};
    for (int i = 0; i < builtInRules.length; i++) {
      if (deletedSet.contains(i)) continue;
      final rule = builtInRules[i];
      final effectiveFan = customMap[i.toString()] ?? rule.fanValue;
      grouped.putIfAbsent(effectiveFan, () => []);
      grouped[effectiveFan]!.add(MapEntry(i, rule));
    }
    final sortedKeys = grouped.keys.toList()..sort();

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        // Custom rules section
        if (customRulesList.isNotEmpty) ...[
          _buildSectionLabel(
            AppLocalizations.customRules,
            Colors.green,
            isDark,
          ),
          ...customRulesList.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;
            final name = item['name'] as String;
            final value = isHk
                ? (item['fanValue'] as int)
                : (item['taiValue'] as int);

            return _buildCustomRuleCard(
              name: name,
              value: value,
              isHk: isHk,
              isDark: isDark,
              onDelete: () => _confirmDeleteCustomRule(isHk, idx),
            );
          }),
          const Divider(height: 24),
        ],

        // Built-in rules by fan group
        if (sortedKeys.isNotEmpty)
          _buildSectionLabel(
            AppLocalizations.builtInRules,
            isHk ? Colors.red : Colors.blue,
            isDark,
          ),
        ...sortedKeys.map((fanValue) {
          final rulesInGroup = grouped[fanValue]!;
          final unitLabel = isHk
              ? AppLocalizations.fan(fanValue)
              : AppLocalizations.taiCount(fanValue);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section header
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isHk ? Colors.red : Colors.blue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        unitLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${rulesInGroup.length} rules',
                      style: TextStyle(
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Rule cards in this group
              ...rulesInGroup.map((entry) {
                final ruleIndex = entry.key;
                final rule = entry.value;
                final customValue = customMap[ruleIndex.toString()];
                final hasCustom = customValue != null;

                return Dismissible(
                  key: Key('${isHk ? "hk" : "tw"}_$ruleIndex'),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (_) =>
                      _confirmDeleteBuiltInRule(isHk, ruleIndex, rule.name),
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    color: Colors.red,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 6),
                    child: ListTile(
                      title: Text(
                        rule.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: hasCustom
                              ? (isDark
                                    ? Colors.amber.shade300
                                    : Colors.amber.shade800)
                              : null,
                        ),
                      ),
                      subtitle: hasCustom
                          ? Text(
                              AppLocalizations.defaultValue(rule.fanValue),
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? Colors.grey.shade500
                                    : Colors.grey.shade600,
                              ),
                            )
                          : null,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (hasCustom)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.amber.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                AppLocalizations.customized,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isDark
                                      ? Colors.amber.shade300
                                      : Colors.amber.shade800,
                                ),
                              ),
                            ),
                          const SizedBox(width: 8),
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: hasCustom
                                  ? Colors.amber
                                  : (isHk ? Colors.red : Colors.blue),
                            ),
                            child: Center(
                              child: Text(
                                '${customValue ?? rule.fanValue}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      onTap: () => _showEditDialog(
                        ruleIndex: ruleIndex,
                        rule: rule,
                        mode: mode,
                        currentCustom: customValue,
                      ),
                    ),
                  ),
                );
              }),
            ],
          );
        }),
        const SizedBox(height: 80), // Space for FAB
      ],
    );
  }

  Widget _buildSectionLabel(String text, Color color, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Row(
        children: [
          Icon(Icons.label, size: 18, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDark ? color.withValues(alpha: 0.8) : color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomRuleCard({
    required String name,
    required int value,
    required bool isHk,
    required bool isDark,
    required VoidCallback onDelete,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      color: isDark ? const Color(0xFF2A3A2A) : Colors.green.shade50,
      child: ListTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.green,
          ),
          child: Center(
            child: Text(
              '$value',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Text(
          '${AppLocalizations.customRules} · ${isHk ? AppLocalizations.fanValueLabel : AppLocalizations.taiValueLabel}: $value',
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: onDelete,
        ),
      ),
    );
  }

  Future<bool> _confirmDeleteBuiltInRule(
    bool isHk,
    int ruleIndex,
    String ruleName,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.deleteRule),
        content: Text('${AppLocalizations.deleteConfirm}\n\n$ruleName'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppLocalizations.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              AppLocalizations.confirm,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final settings = context.read<SettingsService>();
      if (isHk) {
        await settings.deleteBuiltInHkRule(ruleIndex);
      } else {
        await settings.deleteBuiltInTwRule(ruleIndex);
      }
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(AppLocalizations.ruleDeleted)));
      }
      return true;
    }
    return false;
  }

  void _confirmDeleteCustomRule(bool isHk, int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.deleteRule),
        content: Text(AppLocalizations.deleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.cancel),
          ),
          TextButton(
            onPressed: () async {
              final settings = context.read<SettingsService>();
              if (isHk) {
                await settings.removeCustomHkRule(index);
              } else {
                await settings.removeCustomTwRule(index);
              }
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppLocalizations.ruleDeleted)),
                );
              }
            },
            child: Text(
              AppLocalizations.confirm,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddRuleDialog() {
    final isHk = _tabController.index == 0;
    final nameController = TextEditingController();
    final valueController = TextEditingController(text: '1');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.addCustomRule),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: AppLocalizations.ruleName,
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
                labelText: isHk
                    ? AppLocalizations.fanValueLabel
                    : AppLocalizations.taiValueLabel,
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
              if (name.isEmpty || value == null || value < 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppLocalizations.invalidValue)),
                );
                return;
              }
              final settings = context.read<SettingsService>();
              if (isHk) {
                await settings.addCustomHkRule(name, value);
              } else {
                await settings.addCustomTwRule(name, value);
              }
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppLocalizations.ruleAdded)),
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

  void _showEditDialog({
    required int ruleIndex,
    required Rule rule,
    required GameMode mode,
    int? currentCustom,
  }) {
    final isHk = mode == GameMode.hongKong;
    final controller = TextEditingController(
      text: '${currentCustom ?? rule.fanValue}',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          isHk ? AppLocalizations.editFanValue : AppLocalizations.editTaiValue,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              rule.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              rule.description,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.defaultValue(rule.fanValue),
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: isHk
                    ? AppLocalizations.enterNewValue
                    : AppLocalizations.enterNewTaiValue,
                border: const OutlineInputBorder(),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          if (currentCustom != null)
            TextButton(
              onPressed: () async {
                final settings = context.read<SettingsService>();
                if (isHk) {
                  await settings.setCustomHkFan(ruleIndex, null);
                } else {
                  await settings.setCustomTwTai(ruleIndex, null);
                }
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: Text(AppLocalizations.resetToDefault),
            ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.cancel),
          ),
          TextButton(
            onPressed: () async {
              final value = int.tryParse(controller.text);
              if (value == null || value < 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppLocalizations.invalidValue)),
                );
                return;
              }
              final settings = context.read<SettingsService>();
              if (value == rule.fanValue) {
                if (isHk) {
                  await settings.setCustomHkFan(ruleIndex, null);
                } else {
                  await settings.setCustomTwTai(ruleIndex, null);
                }
              } else {
                if (isHk) {
                  await settings.setCustomHkFan(ruleIndex, value);
                } else {
                  await settings.setCustomTwTai(ruleIndex, value);
                }
              }
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppLocalizations.customFanSaved)),
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
