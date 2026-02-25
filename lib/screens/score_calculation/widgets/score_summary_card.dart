import 'package:flutter/material.dart';
import '../../../localization/app_localizations.dart';
import '../../../models/game_mode.dart';

/// Card widget displaying the score breakdown and total.
class ScoreSummaryCard extends StatelessWidget {
  final List<Map<String, dynamic>> displayRules;
  final int effectiveFan;
  final int totalPoints;
  final bool isSelfDraw;
  final int playerCount;
  final GameMode gameMode;
  final int maxFan;

  const ScoreSummaryCard({
    super.key,
    required this.displayRules,
    required this.effectiveFan,
    required this.totalPoints,
    required this.isSelfDraw,
    required this.playerCount,
    required this.gameMode,
    required this.maxFan,
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
              AppLocalizations.scoreCalculation,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Score details table
            DataTable(
              columns: [
                DataColumn(label: Text(AppLocalizations.item)),
                DataColumn(label: Text(AppLocalizations.value)),
              ],
              rows: [
                // Matched Rules
                ...displayRules.map((rule) => DataRow(cells: [
                      DataCell(Text(rule['name'])),
                      DataCell(Text(gameMode == GameMode.taiwan
                          ? AppLocalizations.taiCount(rule['fan'] as int)
                          : AppLocalizations.fan(rule['fan'] as int))),
                    ])),

                // Total Fan/Tai
                DataRow(cells: [
                  DataCell(Text(
                    gameMode == GameMode.taiwan
                        ? AppLocalizations.totalTai
                        : AppLocalizations.totalFan,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  )),
                  DataCell(Text(
                    gameMode == GameMode.taiwan
                        ? AppLocalizations.taiCount(effectiveFan)
                        : AppLocalizations.fan(effectiveFan) +
                            ((maxFan != 999 && effectiveFan >= maxFan) ||
                                    effectiveFan >= 13
                                ? ' (${AppLocalizations.limit})'
                                : ''),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  )),
                ]),

                // Total Score
                DataRow(cells: [
                  DataCell(Text(AppLocalizations.totalScore,
                      style: const TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(
                    Container(
                      constraints: const BoxConstraints(maxWidth: 180),
                      child: Text(
                        isSelfDraw
                            ? '$totalPoints${AppLocalizations.perPerson} ${AppLocalizations.totalWin(totalPoints * (playerCount - 1))}'
                            : '$totalPoints ${AppLocalizations.points}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.green),
                        softWrap: true,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                  ),
                ]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
