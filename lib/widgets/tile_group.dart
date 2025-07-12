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
        color: isHighlighted ? Colors.yellow.withOpacity(0.3) : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      margin: const EdgeInsets.only(right: 8, bottom: 8),
      // 使用 Wrap 代替 Row，可以自動換行
      child: Wrap(
        spacing: 2, // 牌之間的水平間距
        runSpacing: 2, // 行之間的垂直間距
        children: tiles.map((tile) => MahjongTile(tile: tile)).toList(),
      ),
    );
  }
}