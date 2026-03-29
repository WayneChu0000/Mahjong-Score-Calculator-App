import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../localization/app_localizations.dart';
import '../../../models/game_mode.dart';

/// Card widget for fan/tai count and special winning conditions.
class FanSetupCard extends StatefulWidget {
  final int effectiveFan;
  final GameMode gameMode;
  final int minFan;
  final int maxFan;
  final String selectedSpecialCondition;
  final List<String> activeSpecialConditions;
  final ValueChanged<int?> onFanChanged;
  final ValueChanged<String?> onSpecialConditionChanged;
  final String Function(String) getLocalizedCondition;

  const FanSetupCard({
    super.key,
    required this.effectiveFan,
    required this.gameMode,
    required this.minFan,
    required this.maxFan,
    required this.selectedSpecialCondition,
    required this.activeSpecialConditions,
    required this.onFanChanged,
    required this.onSpecialConditionChanged,
    required this.getLocalizedCondition,
  });

  @override
  State<FanSetupCard> createState() => _FanSetupCardState();
}

class _FanSetupCardState extends State<FanSetupCard> {
  late TextEditingController _taiController;

  @override
  void initState() {
    super.initState();
    _taiController = TextEditingController(text: '${widget.effectiveFan}');
  }

  @override
  void didUpdateWidget(covariant FanSetupCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync controller when external effectiveFan changes
    // (e.g. due to tile analysis recalculating the fan)
    if (oldWidget.effectiveFan != widget.effectiveFan) {
      final cur = int.tryParse(_taiController.text) ?? -1;
      if (cur != widget.effectiveFan) {
        _taiController.text = '${widget.effectiveFan}';
      }
    }
  }

  @override
  void dispose() {
    _taiController.dispose();
    super.dispose();
  }

  void _applyTypedTai() {
    final parsed = int.tryParse(_taiController.text);
    if (parsed != null && parsed >= 0) {
      widget.onFanChanged(parsed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTW = widget.gameMode == GameMode.taiwan;
    final hkUpperBoundRaw = widget.maxFan == 999
        ? (widget.minFan > 13 ? widget.minFan : 13)
        : widget.maxFan;
    final hkLowerBoundRaw = widget.minFan;
    // Guard against invalid bound order from settings/state sync.
    final hkLowerBound = hkLowerBoundRaw <= hkUpperBoundRaw
      ? hkLowerBoundRaw
      : hkUpperBoundRaw;
    final hkUpperBound = hkLowerBoundRaw <= hkUpperBoundRaw
      ? hkUpperBoundRaw
      : hkLowerBoundRaw;
    final int hkCurrentValue = widget.effectiveFan
      .clamp(hkLowerBound, hkUpperBound)
      .toInt();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.fanTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Fan / Tai input
            if (isTW)
              // ── TW: free-form numeric input ─────────────────────
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: widget.effectiveFan > 0
                        ? () => widget.onFanChanged(widget.effectiveFan - 1)
                        : null,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _taiController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.taiCount(
                          0,
                        ).replaceAll('0 ', ''),
                        border: const OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _applyTypedTai(),
                      onChanged: (val) {
                        final parsed = int.tryParse(val);
                        if (parsed != null && parsed >= 0) {
                          widget.onFanChanged(parsed);
                        }
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () =>
                        widget.onFanChanged(widget.effectiveFan + 1),
                  ),
                ],
              )
            else
              // ── HK: dropdown (0-13) ──────────────────────────────
              DropdownButtonFormField<int>(
                decoration: InputDecoration(
                  labelText: AppLocalizations.fanTitle,
                  border: const OutlineInputBorder(),
                ),
                // ignore: deprecated_member_use
                initialValue: hkCurrentValue,
                items: List.generate(
                  hkUpperBound - hkLowerBound + 1,
                  (index) => hkLowerBound + index,
                ).map((count) {
                  return DropdownMenuItem<int>(
                    value: count,
                    child: Text(AppLocalizations.fan(count)),
                  );
                }).toList(),
                onChanged: widget.onFanChanged,
              ),

            const SizedBox(height: 16),

            // Special Winning Conditions Dropdown
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: AppLocalizations.specialWinningCondition,
                border: const OutlineInputBorder(),
              ),
              // ignore: deprecated_member_use
              initialValue: widget.selectedSpecialCondition,
              items: widget.activeSpecialConditions.map((condition) {
                return DropdownMenuItem<String>(
                  value: condition,
                  child: Text(widget.getLocalizedCondition(condition)),
                );
              }).toList(),
              onChanged: widget.onSpecialConditionChanged,
            ),
          ],
        ),
      ),
    );
  }
}
