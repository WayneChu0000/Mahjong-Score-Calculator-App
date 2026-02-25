import 'package:flutter/material.dart';
import '../../../models/player.dart';
import '../../../localization/app_localizations.dart';

/// Displays per-player statistics for the current game session.
///
/// Shows win rate, self-draw / ron / deal-in counts for each player,
/// plus a global no-result rate.
void showStatsDialog({
  required BuildContext context,
  required List<Player> players,
  required List<Map<String, dynamic>> roundHistory,
}) {
  final int totalRounds = roundHistory.length;

  int noResultCount = 0;
  for (var round in roundHistory) {
    if (round['winningPlayer'] == null) {
      noResultCount++;
    }
  }
  final double noResultRate =
      totalRounds > 0 ? noResultCount / totalRounds : 0;

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.currentGameStats),
          if (totalRounds > 0)
            Text(
              '${AppLocalizations.noResultRate} ${(noResultRate * 100).toStringAsFixed(2)}%',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: totalRounds == 0
            ? Text(AppLocalizations.noRoundsPlayed)
            : ListView.builder(
                shrinkWrap: true,
                itemCount: players.length,
                itemBuilder: (context, index) {
                  final player = players[index];
                  int wins = 0;
                  int tsumos = 0;
                  int rons = 0;
                  int dealsIn = 0;

                  for (var round in roundHistory) {
                    if (round['winningPlayer'] == player.name) {
                      wins++;
                      if (round['isSelfDraw'] == true) {
                        tsumos++;
                      } else {
                        rons++;
                      }
                    }
                    if (round['discardPlayer'] == player.name) {
                      dealsIn++;
                    }
                  }

                  final double winRate =
                      totalRounds > 0 ? wins / totalRounds : 0;

                  return ListTile(
                    title: Text(player.name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            '${AppLocalizations.statsWinRate}: ${(winRate * 100).toStringAsFixed(2)}%'),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${AppLocalizations.statsSelfDraw}: $tsumos',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                '${AppLocalizations.statsRon}: $rons',
                                style: const TextStyle(fontSize: 12),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                '${AppLocalizations.statsDealIn}: $dealsIn',
                                style: const TextStyle(fontSize: 12),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.close),
        ),
      ],
    ),
  );
}
