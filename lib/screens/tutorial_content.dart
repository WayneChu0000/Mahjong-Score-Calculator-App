import 'package:flutter/material.dart';
import '../widgets/mahjong_tile.dart';

class TutorialContent extends StatelessWidget {
  final int pageIndex;

  const TutorialContent({super.key, required this.pageIndex});

  @override
  Widget build(BuildContext context) {
    switch (pageIndex) {
      case 0:
        return _buildIntroductionPage();
      case 1:
        return _buildTileTypesPage();
      case 2:
        return _buildBasicRulesPage();
      case 3:
        return _buildScoringPage();
      default:
        return _buildIntroductionPage();
    }
  }

  Widget _buildIntroductionPage() {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '歡迎使用麻將計分器',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Text(
            '這個應用程式將幫助你：',
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(height: 8),
          Text('• 學習麻將基本規則'),
          Text('• 計算麻將得分'),
          Text('• 記錄遊戲成績'),
          Text('• 管理玩家群組'),
          SizedBox(height: 16),
          Text(
            '讓我們開始學習麻將吧！',
            style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildTileTypesPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '麻將牌的種類',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          // 萬子牌
          _buildTileSection(
            '萬子牌 (1m-9m)',
            '以萬為單位，從一萬到九萬',
            ['1m', '2m', '3m', '4m', '5m', '6m', '7m', '8m', '9m'],
          ),
          
          const SizedBox(height: 16),
          
          // 筒子牌
          _buildTileSection(
            '筒子牌 (1p-9p)',
            '以筒為單位，從一筒到九筒',
            ['1p', '2p', '3p', '4p', '5p', '6p', '7p', '8p', '9p'],
          ),
          
          const SizedBox(height: 16),
          
          // 索子牌
          _buildTileSection(
            '索子牌 (1s-9s)',
            '以索為單位，從一索到九索',
            ['1s', '2s', '3s', '4s', '5s', '6s', '7s', '8s', '9s'],
          ),
          
          const SizedBox(height: 16),
          
          // 字牌
          _buildTileSection(
            '字牌 (1z-7z)',
            '包括風牌（東南西北）和三元牌（白發中）',
            ['1z', '2z', '3z', '4z', '5z', '6z', '7z'],
          ),
          
          const SizedBox(height: 16),
          
          // 字牌說明
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '字牌說明：',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text('1z = 東風　2z = 南風　3z = 西風　4z = 北風'),
                Text('5z = 白板　6z = 發財　7z = 紅中'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTileSection(String title, String description, List<String> tiles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: tiles.map((tile) => MahjongTile(tile: tile)).toList(),
        ),
      ],
    );
  }

  Widget _buildBasicRulesPage() {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '基本規則',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          
          Text(
            '1. 遊戲目標',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('麻將的目標是湊成一副完整的牌，通常由以下組合構成：'),
          Text('• 4組順子或刻子 + 1對將牌'),
          Text('• 7對子（七對子和牌）'),
          Text('• 特殊牌型（如十三么、國士無雙等）'),
          
          SizedBox(height: 16),
          
          Text(
            '2. 基本術語',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('• 順子：連續的三張牌（如 1m-2m-3m）'),
          Text('• 刻子：三張相同的牌（如 5p-5p-5p）'),
          Text('• 將牌：一對相同的牌作為將'),
          Text('• 自摸：自己摸到胡牌'),
          Text('• 放炮：打出讓別人胡牌的牌'),
          
          SizedBox(height: 16),
          
          Text(
            '3. 遊戲流程',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('• 每人起手13張牌'),
          Text('• 依次摸牌、出牌'),
          Text('• 可以吃、碰、槓別人的牌'),
          Text('• 湊齊完整牌型即可胡牌'),
        ],
      ),
    );
  }

  Widget _buildScoringPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '計分系統',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          const Text(
            '香港麻將計分規則',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('麻將的分數由「番數」決定：'),
          const Text('• 1番 = 1分'),
          const Text('• 2番 = 2分'),
          const Text('• 3番 = 4分'),
          const Text('• 4番 = 8分'),
          const Text('• 5番 = 16分'),
          const Text('• 以此類推...'),
          
          const SizedBox(height: 16),
          
          const Text(
            '常見番數',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          
          _buildScoringExample('平和', '1番', '四組順子加雙將', ['1m', '2m', '3m']),
          _buildScoringExample('碰碰和', '4番', '四組刻子加雙將', ['5p', '5p', '5p']),
          _buildScoringExample('清一色', '7番', '全部同一花色', ['1s', '2s', '3s']),
          _buildScoringExample('大三元', '8番', '中發白三組刻子', ['7z', '7z', '7z']),
          
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '提示：',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text('使用本應用的計分功能可以自動計算番數和得分！'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoringExample(String name, String fan, String description, List<String> exampleTiles) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  fan,
                  style: const TextStyle(fontSize: 12, color: Colors.blue),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 2,
            children: exampleTiles.map((tile) => MahjongTile(tile: tile)).toList(),
          ),
        ],
      ),
    );
  }
}