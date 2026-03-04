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
        return 'assets/images/tiles/characters/${value}m.png';
      case 'p': // Dots tiles
        return 'assets/images/tiles/dots/${value}p.png';
      case 's': // Bamboo tiles
        return 'assets/images/tiles/bamboo/${value}s.png';
      case 'z': // Honor tiles (winds + dragons)
        return 'assets/images/tiles/honors/${value}z.png';
      case 'f': // Flower tiles
        // Based on user request: 1f=Plum, 5f=Spring, etc.
        // Files are named 1f.png, 2f.png... 8f.png
        return 'assets/images/tiles/flowers/${value}f.png';
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
        return '$value萬';
      case 'p':
        return '$value筒';
      case 's':
        return '$value索';
      case 'z':
        switch (value) {
          case '1':
            return '東';
          case '2':
            return '南';
          case '3':
            return '西';
          case '4':
            return '北';
          case '5':
            return '白';
          case '6':
            return '發';
          case '7':
            return '中';
          default:
            return tile;
        }
      case 'f':
        switch (value) {
          case '1':
            return '梅';
          case '2':
            return '蘭';
          case '3':
            return '菊';
          case '4':
            return '竹';
          case '5':
            return '春';
          case '6':
            return '夏';
          case '7':
            return '秋';
          case '8':
            return '冬';
          default:
            return '花';
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
