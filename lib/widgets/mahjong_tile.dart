import 'package:flutter/material.dart';

class MahjongTile extends StatelessWidget {
  final String tile; // 例如: "1w", "2t", "3s", "east", "zhong"

  const MahjongTile({super.key, required this.tile});

  @override
  Widget build(BuildContext context) {
    String imagePath = _getImagePath(tile);
    return Image.asset(
      imagePath,
      width: 30,
      height: 42,
      errorBuilder: (context, error, stackTrace) {
        // 如果圖片載入失敗，顯示文字代替
        return Container(
          width: 30,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          alignment: Alignment.center,
          child: Text(
            tile,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        );
      },
    );
  }

  String _getImagePath(String tile) {
    // 根據牌的代碼返回對應的圖片路徑
    if (tile.length == 2) {
      String value = tile[0];
      String suit = tile[1];
      
      if (suit == 'w') {
        return 'assets/images/tiles/wan/${value}w.png';
      } else if (suit == 't') {
        return 'assets/images/tiles/tong/${value}t.png';
      } else if (suit == 's') {
        return 'assets/images/tiles/suo/${value}s.png';
      }
    } else if (tile == 'east' || tile == 'south' || tile == 'west' || tile == 'north') {
      return 'assets/images/tiles/feng/$tile.png';
    } else if (tile == 'zhong' || tile == 'fa' || tile == 'bai') {
      return 'assets/images/tiles/jian/$tile.png';
    }
    
    // 如果沒有匹配的圖片路徑，返回一個預設路徑
    return 'assets/images/tiles/default.png';
  }
}