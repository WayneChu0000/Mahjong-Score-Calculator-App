import 'package:flutter/material.dart';

class MahjongTile extends StatelessWidget {
  final String tile;
  final double size;
  final bool isSelected;
  final VoidCallback? onTap;

  const MahjongTile({
    super.key,
    required this.tile,
    this.size = 40,
    this.isSelected = false,
    this.onTap,
  });

  String _getImagePath() {
    // Parse tile face: e.g., '1m' -> value='1', suit='m'
    if (tile.length < 2) return 'assets/images/tiles/back.png';
    
    final value = tile.substring(0, tile.length - 1);
    final suit = tile.substring(tile.length - 1);
    
    switch (suit) {
      case 'm': // Character tiles
        return 'assets/images/tiles/wan/${value}m.png';
      case 'p': // Circle tiles
        return 'assets/images/tiles/tong/${value}p.png';
      case 's': // Bamboo tiles
        return 'assets/images/tiles/suo/${value}s.png';
      case 'z': // Honor tiles (winds + dragons)
        return 'assets/images/tiles/honor/${value}z.png';
      default:
        return 'assets/images/tiles/back.png';
    }
  }

  String _getTileName() {
    if (tile.length < 2) return tile;
    
    final value = tile.substring(0, tile.length - 1);
    final suit = tile.substring(tile.length - 1);
    
    switch (suit) {
      case 'm':
        return '${value}萬';
      case 'p':
        return '${value}筒';
      case 's':
        return '${value}索';
      case 'z':
        switch (value) {
          case '1': return '東';
          case '2': return '南';
          case '3': return '西';
          case '4': return '北';
          case '5': return '白';
          case '6': return '發';
          case '7': return '中';
          default: return tile;
        }
      default:
        return tile;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size * 1.4, // Mahjong tile aspect ratio ~1:1.4
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.red : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(4),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 2,
              offset: const Offset(1, 1),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: Image.asset(
            _getImagePath(),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // If image fails to load, display text
              return Container(
                color: Colors.grey.shade100,
                child: Center(
                  child: Text(
                    _getTileName(),
                    style: TextStyle(
                      fontSize: size * 0.25,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}