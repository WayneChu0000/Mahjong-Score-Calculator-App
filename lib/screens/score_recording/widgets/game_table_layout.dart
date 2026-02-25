import 'package:flutter/material.dart';
import '../../../models/player.dart';
import '../../../models/game_mode.dart';
import '../../../localization/app_localizations.dart';
import 'player_table_card.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';

/// The mahjong table layout showing four players around a centre box.
///
/// Handles responsive sizing so cards and gaps scale proportionally.
class GameTableLayout extends StatelessWidget {
  final List<Player> players;
  final int dealerIndex;
  final int prevalentWindIndex;
  final int currentDealerGameCount;
  final GameMode gameMode;
  final int Function(String) getPlayerScore;
  final Future<void> Function(int fromIndex, int toIndex) onSwap;

  const GameTableLayout({
    super.key,
    required this.players,
    required this.dealerIndex,
    required this.prevalentWindIndex,
    required this.currentDealerGameCount,
    required this.gameMode,
    required this.getPlayerScore,
    required this.onSwap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest.shortestSide;
        final double centerSize = size * 0.28;

        const double idealWidth = 100.0;
        const double idealHeight = 90.0;
        double gap = 15.0;

        double finalCardWidth = idealWidth;
        double finalCardHeight = idealHeight;

        // Horizontal check
        if (2 * (idealWidth + gap) + centerSize > size) {
          finalCardWidth = (size - centerSize) / 2 - gap;
          if (finalCardWidth < 0) finalCardWidth = 0;
          finalCardHeight = finalCardWidth * (idealHeight / idealWidth);
        }

        // Vertical check
        if (2 * (finalCardHeight + gap) + centerSize > size) {
          finalCardHeight = (size - centerSize) / 2 - gap;
          if (finalCardHeight < 0) finalCardHeight = 0;
          finalCardWidth = finalCardHeight * (idealWidth / idealHeight);
        }

        final double distFromCenter = centerSize / 2 + gap;

        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // Centre table
              _buildCentreBox(centerSize),

              // Player 2 (Top)
              if (players.length > 2)
                Positioned(
                  top: (size / 2) - distFromCenter - finalCardHeight,
                  child: _draggable(2, finalCardWidth, finalCardHeight),
                ),

              // Player 0 (Bottom)
              if (players.isNotEmpty)
                Positioned(
                  bottom: (size / 2) - distFromCenter - finalCardHeight,
                  child: _draggable(0, finalCardWidth, finalCardHeight),
                ),

              // Player 3 (Left)
              if (players.length > 3)
                Positioned(
                  left: (size / 2) - distFromCenter - finalCardWidth,
                  child: _draggable(3, finalCardWidth, finalCardHeight),
                ),

              // Player 1 (Right)
              if (players.length > 1)
                Positioned(
                  right: (size / 2) - distFromCenter - finalCardWidth,
                  child: _draggable(1, finalCardWidth, finalCardHeight),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _draggable(int index, double w, double h) {
    return DraggablePlayerTarget(
      index: index,
      width: w,
      height: h,
      players: players,
      dealerIndex: dealerIndex,
      getPlayerScore: getPlayerScore,
      onSwap: onSwap,
    );
  }

  Widget _buildCentreBox(double centerSize) {
    final windNames = [
      AppLocalizations.windEast,
      AppLocalizations.windSouth,
      AppLocalizations.windWest,
      AppLocalizations.windNorth,
    ];

    return Container(
      width: centerSize,
      height: centerSize,
      decoration: BoxDecoration(
        color: AppColors.primaryDarker,
        borderRadius: AppDimens.borderRadiusLg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppLocalizations.mahjong,
            style: const TextStyle(color: Colors.white70, fontSize: 10),
          ),
          Text(
            '${windNames[prevalentWindIndex]} ${AppLocalizations.windCircleSuffix}',
            style: const TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Text(
            AppLocalizations.gameCount(currentDealerGameCount),
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          if (gameMode == GameMode.taiwan && currentDealerGameCount > 1)
            Text(
              AppLocalizations.consecutiveDealerCount(
                  currentDealerGameCount - 1),
              style: const TextStyle(
                color: AppColors.accent,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }
}
