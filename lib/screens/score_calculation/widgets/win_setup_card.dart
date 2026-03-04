import 'package:flutter/material.dart';
import '../../../models/player.dart';
import '../../../localization/app_localizations.dart';

/// Card widget for configuring the winning setup:
/// self-draw/discard toggle, winning player, wind selection, discard player.
class WinSetupCard extends StatelessWidget {
  final bool isSelfDraw;
  final String? winningPlayer;
  final String? discardPlayer;
  final String roundWind;
  final String seatWind;
  final List<Player> players;
  final List<String> winds;
  final ValueChanged<bool> onSelfDrawChanged;
  final ValueChanged<String?> onWinningPlayerChanged;
  final ValueChanged<String?> onDiscardPlayerChanged;
  final ValueChanged<String?> onRoundWindChanged;
  final ValueChanged<String?> onSeatWindChanged;
  final int Function(String) getPlayerCurrentScore;

  const WinSetupCard({
    super.key,
    required this.isSelfDraw,
    required this.winningPlayer,
    required this.discardPlayer,
    required this.roundWind,
    required this.seatWind,
    required this.players,
    required this.winds,
    required this.onSelfDrawChanged,
    required this.onWinningPlayerChanged,
    required this.onDiscardPlayerChanged,
    required this.onRoundWindChanged,
    required this.onSeatWindChanged,
    required this.getPlayerCurrentScore,
  });

  String _getWindText(String wind) {
    switch (wind) {
      case 'East':
        return AppLocalizations.east;
      case 'South':
        return AppLocalizations.south;
      case 'West':
        return AppLocalizations.west;
      case 'North':
        return AppLocalizations.north;
      default:
        return wind;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.win,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Self-draw or discard selection
            Row(
              children: [
                Radio<bool>(
                  value: true,
                  // ignore: deprecated_member_use
                  groupValue: isSelfDraw,
                  // ignore: deprecated_member_use
                  onChanged: (bool? value) {
                    if (value != null) onSelfDrawChanged(value);
                  },
                ),
                Text(AppLocalizations.selfDraw),
                const SizedBox(width: 24),
                Radio<bool>(
                  value: false,
                  // ignore: deprecated_member_use
                  groupValue: isSelfDraw,
                  // ignore: deprecated_member_use
                  onChanged: (bool? value) {
                    if (value != null) onSelfDrawChanged(value);
                  },
                ),
                Text(AppLocalizations.discard),
              ],
            ),
            const SizedBox(height: 16),
            // Winning player selection
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: AppLocalizations.winningPlayer,
                border: const OutlineInputBorder(),
              ),
              initialValue: winningPlayer,
              items: players.map((player) {
                return DropdownMenuItem<String>(
                  value: player.name,
                  child: Text(
                    '${player.name} ${AppLocalizations.currentScore(getPlayerCurrentScore(player.name))}',
                  ),
                );
              }).toList(),
              onChanged: onWinningPlayerChanged,
            ),
            const SizedBox(height: 16),

            // Wind Selection Row
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: AppLocalizations.roundWind,
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    initialValue: roundWind,
                    items: winds.map((wind) {
                      return DropdownMenuItem<String>(
                        value: wind,
                        child: Text(_getWindText(wind)),
                      );
                    }).toList(),
                    onChanged: onRoundWindChanged,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: AppLocalizations.seatWind,
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    initialValue: seatWind,
                    items: winds.map((wind) {
                      return DropdownMenuItem<String>(
                        value: wind,
                        child: Text(_getWindText(wind)),
                      );
                    }).toList(),
                    onChanged: onSeatWindChanged,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Discard player selection (only show when discard is selected)
            if (!isSelfDraw)
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: AppLocalizations.discardPlayer,
                  border: const OutlineInputBorder(),
                ),
                initialValue: discardPlayer,
                items: players.where((player) => player.name != winningPlayer).map((
                  player,
                ) {
                  return DropdownMenuItem<String>(
                    value: player.name,
                    child: Text(
                      '${player.name} ${AppLocalizations.currentScore(getPlayerCurrentScore(player.name))}',
                    ),
                  );
                }).toList(),
                onChanged: onDiscardPlayerChanged,
              ),
          ],
        ),
      ),
    );
  }
}
