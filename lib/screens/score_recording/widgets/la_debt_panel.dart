import 'package:flutter/material.dart';
import '../../../models/player.dart';
import '../../../utils/la_settlement.dart';
import '../../../localization/app_localizations.dart';

/// A collapsible panel that shows the current La (拉) debt status
/// during an active winning streak in Taiwan Mahjong.
class LaDebtPanel extends StatelessWidget {
  final LaSettlement laSettlement;
  final List<Player> players;
  final void Function(String playerId) onForceSettle;

  const LaDebtPanel({
    super.key,
    required this.laSettlement,
    required this.players,
    required this.onForceSettle,
  });

  String _idToName(String id) {
    final match = players.where((p) => p.id.toString() == id);
    return match.isNotEmpty ? match.first.name : id;
  }

  @override
  Widget build(BuildContext context) {
    if (!laSettlement.hasActiveStreak) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final streakWinnerId = laSettlement.streakWinnerId!;
    final streakWinnerName = _idToName(streakWinnerId);
    final debts = laSettlement.debts;
    final losses = laSettlement.consecutiveLosses;
    final settled = laSettlement.settledPlayers;
    final totalRounds = laSettlement.streakLength;

    // Sort debtors: unsettled first, then by debt descending
    final debtors = debts.keys.toList()
      ..sort((a, b) {
        final aSettled = settled.contains(a);
        final bSettled = settled.contains(b);
        if (aSettled != bSettled) return aSettled ? 1 : -1;
        return (debts[b] ?? 0).compareTo(debts[a] ?? 0);
      });

    return Card(
      elevation: 2,
      color: isDark ? const Color(0xFF2A1A1A) : Colors.red.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: false,
          tilePadding: const EdgeInsets.symmetric(horizontal: 12),
          leading: Icon(Icons.sync, color: Colors.red.shade400, size: 20),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  AppLocalizations.twLaDebtTracker,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isDark ? Colors.red.shade200 : Colors.red.shade800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark ? Colors.red.shade900 : Colors.red.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  AppLocalizations.twLaStreakRounds(totalRounds),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.red.shade200 : Colors.red.shade700,
                  ),
                ),
              ),
            ],
          ),
          subtitle: Text(
            '${AppLocalizations.twLaStreakWinner}: $streakWinnerName',
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
          children: [
            const Divider(height: 1),
            // Header row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                children: [
                  const SizedBox(
                    width: 100,
                    child: Text('', style: TextStyle(fontSize: 11)),
                  ),
                  Expanded(
                    child: Text(
                      AppLocalizations.twLaDebtTotal,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40), // space for button
                ],
              ),
            ),
            // Debtor rows
            ...debtors.map((debtorId) {
              final isSettled = settled.contains(debtorId);
              final debt = debts[debtorId] ?? 0;
              final lossCount = losses[debtorId] ?? 0;
              final name = _idToName(debtorId);

              // Use LaSettlement's built-in threshold+lastAskedAt check
              final canSettle = laSettlement.canForceSettle(debtorId);

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 3,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 100,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isSettled ? Colors.grey : null,
                              decoration: isSettled
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            isSettled
                                ? AppLocalizations.twLaSettled
                                : AppLocalizations.twLaLosses(lossCount),
                            style: TextStyle(
                              fontSize: 9,
                              color: isSettled
                                  ? Colors.grey
                                  : Colors.orange.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Text(
                        isSettled ? '-' : '$debt',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isSettled ? Colors.grey : Colors.red,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 40,
                      child: canSettle
                          ? IconButton(
                              icon: Icon(
                                Icons.gavel,
                                size: 16,
                                color: Colors.orange.shade700,
                              ),
                              tooltip: AppLocalizations.twLaForceSettleAction,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () => onForceSettle(debtorId),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
