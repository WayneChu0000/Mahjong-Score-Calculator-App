import 'package:flutter/material.dart';
import '../../../localization/app_localizations.dart';
import '../../../models/game_mode.dart';

/// Card widget for fan/tai count and special winning conditions.
class FanSetupCard extends StatelessWidget {
  final int effectiveFan;
  final GameMode gameMode;
  final String selectedSpecialCondition;
  final List<String> activeSpecialConditions;
  final ValueChanged<int?> onFanChanged;
  final ValueChanged<String?> onSpecialConditionChanged;
  final String Function(String) getLocalizedCondition;

  const FanSetupCard({
    super.key,
    required this.effectiveFan,
    required this.gameMode,
    required this.selectedSpecialCondition,
    required this.activeSpecialConditions,
    required this.onFanChanged,
    required this.onSpecialConditionChanged,
    required this.getLocalizedCondition,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.fanTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Fan count selection
            DropdownButtonFormField<int>(
              decoration: InputDecoration(
                labelText: gameMode == GameMode.taiwan
                    ? AppLocalizations.taiCount(0).replaceAll('0 ', '')
                    : AppLocalizations.fanTitle,
                border: const OutlineInputBorder(),
              ),
              initialValue: effectiveFan,
              items: List.generate(
                gameMode == GameMode.taiwan ? 31 : 14,
                (index) => index,
              ).map((count) {
                return DropdownMenuItem<int>(
                  value: count,
                  child: Text(
                    gameMode == GameMode.taiwan
                        ? AppLocalizations.taiCount(count)
                        : AppLocalizations.fan(count),
                  ),
                );
              }).toList(),
              onChanged: onFanChanged,
            ),

            const SizedBox(height: 16),

            // Special Winning Conditions Dropdown
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: AppLocalizations.specialWinningCondition,
                border: const OutlineInputBorder(),
              ),
              initialValue: selectedSpecialCondition,
              items: activeSpecialConditions.map((condition) {
                return DropdownMenuItem<String>(
                  value: condition,
                  child: Text(getLocalizedCondition(condition)),
                );
              }).toList(),
              onChanged: onSpecialConditionChanged,
            ),
          ],
        ),
      ),
    );
  }
}
