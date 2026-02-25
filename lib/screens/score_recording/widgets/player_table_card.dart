import 'package:flutter/material.dart';
import '../../../models/player.dart';
import '../../../localization/app_localizations.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';

/// Compact player card displayed in the mahjong table layout.
///
/// Shows player name, score, wind/dealer badge, and supports
/// drag-and-drop seat swapping via [LongPressDraggable] / [DragTarget].
class PlayerTableCard extends StatelessWidget {
  final Player player;
  final int playerIndex;
  final int dealerIndex;
  final int Function(String) getPlayerScore;

  const PlayerTableCard({
    super.key,
    required this.player,
    required this.playerIndex,
    required this.dealerIndex,
    required this.getPlayerScore,
  });

  @override
  Widget build(BuildContext context) {
    final isDealer = playerIndex == dealerIndex;
    final currentScore = getPlayerScore(player.id.toString());

    // Wind based on seat relative to dealer
    final windIndex = (playerIndex - dealerIndex + 4) % 4;
    final winds = [
      AppLocalizations.windEast,
      AppLocalizations.windSouth,
      AppLocalizations.windWest,
      AppLocalizations.windNorth,
    ];
    final windName = winds[windIndex];

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        borderRadius: AppDimens.borderRadiusMd,
        border: isDealer
            ? Border.all(color: AppColors.destructive, width: 2)
            : Border.all(
                color: isDark ? AppColors.grey700 : AppColors.grey300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isDealer
                  ? AppColors.destructive
                  : (isDark ? AppColors.grey800 : AppColors.grey200),
              borderRadius: AppDimens.borderRadiusSm,
            ),
            child: Text(
              isDealer ? AppLocalizations.dealer : windName,
              style: TextStyle(
                color: isDealer
                    ? AppColors.white
                    : (isDark ? AppColors.grey300 : Colors.black54),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            player.name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: isDark ? AppColors.white : AppColors.black,
            ),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          Text(
            '$currentScore',
            style: TextStyle(
              color: AppColors.scoreColor(currentScore),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}

/// Wraps a [PlayerTableCard] with drag-and-drop behaviour for seat swapping.
class DraggablePlayerTarget extends StatelessWidget {
  final int index;
  final double width;
  final double height;
  final List<Player> players;
  final int dealerIndex;
  final int Function(String) getPlayerScore;
  final Future<void> Function(int fromIndex, int toIndex) onSwap;

  const DraggablePlayerTarget({
    super.key,
    required this.index,
    required this.width,
    required this.height,
    required this.players,
    required this.dealerIndex,
    required this.getPlayerScore,
    required this.onSwap,
  });

  @override
  Widget build(BuildContext context) {
    if (index >= players.length) return const SizedBox.shrink();

    Widget card = SizedBox(
      width: width,
      height: height,
      child: PlayerTableCard(
        player: players[index],
        playerIndex: index,
        dealerIndex: dealerIndex,
        getPlayerScore: getPlayerScore,
      ),
    );

    return DragTarget<int>(
      onWillAcceptWithDetails: (details) => details.data != index,
      onAcceptWithDetails: (details) => onSwap(details.data, index),
      builder: (context, candidateData, rejectedData) {
        return LongPressDraggable<int>(
          data: index,
          feedback: Material(
            color: Colors.transparent,
            child: Opacity(opacity: 0.7, child: card),
          ),
          childWhenDragging: Opacity(opacity: 0.3, child: card),
          child: card,
        );
      },
    );
  }
}
