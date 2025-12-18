import 'package:flutter/material.dart';
import 'mahjong_tile.dart';

class TileGroup extends StatelessWidget {
  final List<String> tiles;
  final bool isHighlighted;

  const TileGroup({
    super.key, 
    required this.tiles, 
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isHighlighted ? Colors.yellow.withValues(alpha: 0.3) : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      margin: const EdgeInsets.only(right: 8, bottom: 8),
      // Use Wrap instead of Row for automatic line wrapping
      child: Wrap(
        spacing: 2, // Horizontal spacing between tiles
        runSpacing: 2, // Vertical spacing between rows
        children: tiles.map((tile) => MahjongTile(tile: tile)).toList(),
      ),
    );
  }
}