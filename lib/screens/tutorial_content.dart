import 'package:flutter/material.dart';
import '../widgets/mahjong_tile.dart';

class TutorialContent extends StatelessWidget {
  final int pageIndex;
  final Function(String)? onRuleTap;

  const TutorialContent({
    super.key, 
    required this.pageIndex,
    this.onRuleTap,
  });

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
        return _buildScoringPage(context);
      default:
        return _buildIntroductionPage();
    }
  }

  Widget _buildIntroductionPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome to Mahjong Score Calculator',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'Your all-in-one companion for Hong Kong Mahjong!',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          
          const Text(
            'Key Features:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          _buildFeatureItem(Icons.calculate, 'Smart Calculator', 'Instantly calculate Fan and Score. Supports special hands like Thirteen Orphans and Nine Gates.'),
          _buildFeatureItem(Icons.history, 'Game Recording', 'Track scores round-by-round. Auto-manages Dealer rotation and Round Winds.'),
          _buildFeatureItem(Icons.menu_book, 'Rules Reference', 'Complete guide to HK Mahjong scoring patterns with examples.'),
          _buildFeatureItem(Icons.group, 'Player Management', 'Save player groups and keep track of total games played.'),
          
          const SizedBox(height: 24),
          const Center(
            child: Text(
              'Swipe to learn the basics ->',
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.green),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
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
            'Types of Mahjong Tiles',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          // Character tiles
          _buildTileSection(
            'Character Tiles',
            'Numbered 1 to 9 in characters',
            ['1m', '2m', '3m', '4m', '5m', '6m', '7m', '8m', '9m'],
          ),
          
          const SizedBox(height: 16),
          
          // Dots tiles
          _buildTileSection(
            'Dots Tiles',
            'Numbered 1 to 9 in dots',
            ['1p', '2p', '3p', '4p', '5p', '6p', '7p', '8p', '9p'],
          ),
          
          const SizedBox(height: 16),
          
          // Bamboo tiles
          _buildTileSection(
            'Bamboo Tiles',
            'Numbered 1 to 9 in bamboo',
            ['1s', '2s', '3s', '4s', '5s', '6s', '7s', '8s', '9s'],
          ),
          
          const SizedBox(height: 16),
          
          // Honor tiles
          _buildTileSection(
            'Honor Tiles',
            'Include Wind tiles (East/South/West/North) and Dragon tiles (Red/Green/White)',
            ['1z', '2z', '3z', '4z', '5z', '6z', '7z'],
          ),
          
          const SizedBox(height: 16),
          

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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Basic Rules',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          const Text(
            '1. Game Objective',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('The goal of mahjong is to form a complete hand, usually consisting of:'),
          const Text('• 4 sets (chow/pong) + 1 pair (eyes)'),
          const Text('• Special hands (e.g., Thirteen Orphans)'),
          
          const SizedBox(height: 16),
          
          const Text(
            '2. Basic Terms',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('• Chow: Three consecutive tiles (e.g., 1m-2m-3m)'),
          const Text('• Pong: Three identical tiles (e.g., 5p-5p-5p)'),
          const Text('• Eyes: A pair of identical tiles'),
          const Text('• Self-Draw: Draw your own winning tile'),
          const Text('• Discard: Discard a tile that lets others win'),
          
          const SizedBox(height: 16),

          const Text(
            '3. Starting the Game',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('The Dealer (East) rolls 2 or 3 dice to determine which wall to break.'),
          const SizedBox(height: 8),
          
          // Dice Table
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Dice Roll & Wall Selection:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _buildDiceRow('5, 9, 13, 17', 'Dealer (East)'),
                _buildDiceRow('6, 10, 14, 18', 'South (Right)'),
                _buildDiceRow('3, 7, 11, 15', 'West (Opposite)'),
                _buildDiceRow('4, 8, 12, 16', 'North (Left)'),
                const SizedBox(height: 8),
                const Text(
                  'Count counter-clockwise starting from Dealer as 1.',
                  style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          const Text('Example: Roll 8 → Count to North (Left). Break North wall.'),
          const Text('From the chosen wall, count stacks clockwise (skipping the rolled number) to start drawing.'),
          
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.amber.withOpacity(0.2),
            child: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.amber),
                SizedBox(width: 8),
                Expanded(child: Text('Remember: Play Counter-Clockwise, Draw Clockwise!')),
              ],
            ),
          ),

          const SizedBox(height: 12),
          const Text('Dealing Procedure:', style: TextStyle(fontWeight: FontWeight.bold)),
          const Text('1. Each player takes 4 tiles (2 stacks) in order.'),
          const Text('2. Repeat until everyone has 12 tiles.'),
          const Text('3. Dealer takes 1st and 3rd tile from end (14 total).'),
          const Text('4. Others take 1 tile (13 total).'),
          const Text('5. Replace Flower tiles from the back of the wall.'),

          const SizedBox(height: 16),
          
          const Text(
            '4. Gameplay Process',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('After dealing and flower replacement, the game proceeds counter-clockwise starting from the Dealer.'),
          
          const SizedBox(height: 12),
          const Text('Standard Turn:', style: TextStyle(fontWeight: FontWeight.bold)),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(children: [Icon(Icons.download), Text('Draw')]),
                Icon(Icons.arrow_forward),
                Column(children: [Icon(Icons.touch_app), Text('Action')]),
                Icon(Icons.arrow_forward),
                Column(children: [Icon(Icons.upload), Text('Discard')]),
              ],
            ),
          ),
          const Text('1. Draw a tile from the wall (Dealer skips this on first turn).'),
          const Text('2. If it\'s a Flower, reveal it and draw a replacement from the back.'),
          const Text('3. Choose to Kong (Concealed/Added) or Win (Self-Draw).'),
          const Text('4. Discard one tile to end your turn.'),

          const SizedBox(height: 16),
          const Text('Interactions (Stealing):', style: TextStyle(fontWeight: FontWeight.bold)),
          const Text('Other players can interrupt the turn by claiming a discard.'),
          
          const SizedBox(height: 8),
          _buildInteractionRow(
            'Chow (Shang)', 
            'Left Player Only', 
            'Form a sequence (e.g., 1-2-3).',
            Colors.blue.shade100,
          ),
          _buildInteractionRow(
            'Pong (Peng)', 
            'Any Player', 
            'Form a triplet (e.g., 3-3-3). Interrupts turn order.',
            Colors.green.shade100,
          ),
          _buildInteractionRow(
            'Kong (Gang)', 
            'Any Player', 
            'Form a quad. Draw replacement. Interrupts turn order.',
            Colors.purple.shade100,
          ),
          _buildInteractionRow(
            'Win (Hu)', 
            'Any Player', 
            'Complete the hand. Ends the game.',
            Colors.red.shade100,
          ),

          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Priority Rule:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                Text('Win > Kong/Pong > Chow'),
                SizedBox(height: 4),
                Text('If one player wants to Chow and another wants to Pong the same tile, Pong wins.'),
              ],
            ),
          ),

          const SizedBox(height: 16),
          const Text('Missed Win Rule (Guo Shui):', style: TextStyle(fontWeight: FontWeight.bold)),
          const Text('If you can win on a discard but choose not to (e.g., to try for a higher score), you cannot win on that same tile from another player until you complete your next turn (draw/action).'),
          const SizedBox(height: 4),
          const Text('Exception: If the new tile gives you a higher Fan count (e.g., completing a specific pattern), you may be allowed to win depending on house rules.'),
        ],
      ),
    );
  }

  Widget _buildInteractionRow(String action, String target, String desc, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.3),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(action, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(target, style: const TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w500)),
                Text(desc, style: const TextStyle(fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiceRow(String numbers, String wall) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(numbers, style: const TextStyle(fontFamily: 'monospace')),
          ),
          const Icon(Icons.arrow_right_alt, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Text(wall, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildScoringPage(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Scoring System',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          const Text(
            'Hong Kong Mahjong Scoring Rules',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Mahjong scoring is determined by fan count. The table below shows the points for each fan count:'),
          const SizedBox(height: 16),
          
          // Scoring Table
          Table(
            border: TableBorder.all(color: Colors.grey.shade400),
            columnWidths: const {
              0: FlexColumnWidth(1.2),
              1: FlexColumnWidth(1),
              2: FlexColumnWidth(1.5),
            },
            children: [
              // Header
              TableRow(
                decoration: BoxDecoration(color: Colors.grey.shade200),
                children: const [
                  Padding(padding: EdgeInsets.all(8.0), child: Text('Fan Points', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black))),
                  Padding(padding: EdgeInsets.all(8.0), child: Text('By Discard', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black))),
                  Padding(padding: EdgeInsets.all(8.0), child: Text('By Self-Draw', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black))),
                ],
              ),
              // Rows
              _buildScoreRow('0 (Chicken)', '1', 'N/A (min 1)'),
              _buildScoreRow('1', '2', '3 (1×3)'),
              _buildScoreRow('2', '4', '6 (2×3)'),
              _buildScoreRow('3', '8', '12 (4×3)'),
              _buildScoreRow('4', '16', '24 (8×3)'),
              _buildScoreRow('5', '24', '36 (12×3)'),
              _buildScoreRow('6', '32', '48 (16×3)'),
              _buildScoreRow('7', '48', '72 (24×3)'),
              _buildScoreRow('8', '64', '96 (32×3)'),
              _buildScoreRow('9', '96', '144 (48×3)'),
              _buildScoreRow('10', '128', '192 (64×3)'),
              _buildScoreRow('11', '192', '288 (96×3)'),
              _buildScoreRow('12', '256', '384 (128×3)'),
              _buildScoreRow('13 (Limit)', '384', '576 (192×3)'),
            ],
          ),
          
          const SizedBox(height: 16),

          const Text(
            'Flower Tiles Scoring',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('• No Flowers: 1 Fan'),
          const Text('• Own Flower: 1 Fan (Flower matches seat wind)'),
          const SizedBox(height: 8),
          const Text('Flower Mapping:'),
          const Text('• Seat 1 (East): Spring, Plum'),
          const Text('• Seat 2 (South): Summer, Orchid'),
          const Text('• Seat 3 (West): Autumn, Chrysanthemum'),
          const Text('• Seat 4 (North): Winter, Bamboo'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? Colors.orange.withOpacity(0.2) : Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: isDark ? Colors.orange.shade800 : Colors.orange.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Important Note:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    color: isDark ? Colors.orange.shade200 : Colors.deepOrange,
                  ),
                ),
                const SizedBox(height: 4),
                const Text('If you have flowers but none match your seat (e.g., East seat holding Summer), you get 0 Fan for flowers and lose the "No Flower" bonus.'),
              ],
            ),
          ),
          
          const SizedBox(height: 16),

          const Text(
            'Honor Tiles Scoring',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('• Dragon Pong/Kong: 1 Fan (Red, Green, or White Dragon)'),
          const Text('• Round Wind Pong/Kong: 1 Fan (Matches the current round wind)'),
          const Text('• Seat Wind Pong/Kong: 1 Fan (Matches your seat wind)'),
          const SizedBox(height: 4),
          const Text(
            'Note: If your seat wind matches the round wind (e.g., East Seat in East Round), a Pong of East Wind gives 2 Fan!',
            style: TextStyle(fontStyle: FontStyle.italic, fontSize: 13),
          ),

          const SizedBox(height: 16),

          const Text(
            'Winning Patterns (Fan List)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Click on a pattern name to see details and examples.'),
          const SizedBox(height: 8),
          
          // 1 Fan
          _buildFanHeader('1 Fan'),
          _buildClickableRuleRow(context, 'Ping Hu (All Chows)', '1 Fan'),
          _buildClickableRuleRow(context, 'No Flowers', '1 Fan'),
          _buildClickableRuleRow(context, 'Own Flower', '1 Fan'),
          _buildClickableRuleRow(context, 'Self-Draw', '1 Fan'),
          _buildClickableRuleRow(context, 'Men Qian Qing', '1 Fan'),
          _buildClickableRuleRow(context, 'Dragon/Wind Pong', '1 Fan'),
          _buildClickableRuleRow(context, 'Robbing the Kong', '1 Fan'),
          _buildClickableRuleRow(context, 'Haidilao', '1 Fan'),
          
          // 2 Fan
          _buildFanHeader('2 Fan'),
          _buildClickableRuleRow(context, 'Kong on Kong/Flower', '2 Fan'),
          _buildClickableRuleRow(context, 'Flower Platform', '2 Fan'),

          // 3 Fan
          _buildFanHeader('3 Fan'),
          _buildClickableRuleRow(context, 'Flower Hand', '3 Fan'),
          _buildClickableRuleRow(context, 'All Pongs (Dui Dui Hu)', '3 Fan'),
          _buildClickableRuleRow(context, 'Mixed One Suit', '3 Fan'),

          // 4 Fan
          _buildFanHeader('4 Fan'),
          _buildClickableRuleRow(context, 'Mixed Terminals', '4 Fan'),

          // 5 Fan
          _buildFanHeader('5 Fan'),
          _buildClickableRuleRow(context, 'Small Three Dragons', '5 Fan'),

          // 6 Fan
          _buildFanHeader('6 Fan'),
          _buildClickableRuleRow(context, 'Small Four Winds', '6 Fan'),

          // 7 Fan
          _buildFanHeader('7 Fan'),
          _buildClickableRuleRow(context, 'Pure One Suit', '7 Fan'),

          // 8 Fan
          _buildFanHeader('8 Fan'),
          _buildClickableRuleRow(context, 'Big Three Dragons', '8 Fan'),
          _buildClickableRuleRow(context, 'Eight Immortals', '8 Fan'),
          _buildClickableRuleRow(context, 'Hidden Treasure', '8 Fan'),

          // 9 Fan
          _buildFanHeader('9 Fan'),
          _buildClickableRuleRow(context, 'Double Kong Replacement', '9 Fan'),

          // 10 Fan
          _buildFanHeader('10 Fan'),
          _buildClickableRuleRow(context, 'All Honors', '10 Fan'),
          _buildClickableRuleRow(context, 'Pure Terminals', '10 Fan'),
          _buildClickableRuleRow(context, 'Nine Gates', '10 Fan'),

          // 13 Fan
          _buildFanHeader('13 Fan'),
          _buildClickableRuleRow(context, 'Thirteen Orphans', '13 Fan'),
          _buildClickableRuleRow(context, 'Blessing of Man', '13 Fan'),
          _buildClickableRuleRow(context, 'Earthly Hand', '13 Fan'),
          _buildClickableRuleRow(context, 'Heavenly Hand', '13 Fan'),
          _buildClickableRuleRow(context, 'Big Four Winds', '13 Fan'),
          _buildClickableRuleRow(context, 'Eighteen Arhats', '13 Fan'),

          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? Colors.green.withOpacity(0.2) : Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: isDark ? Colors.green.shade800 : Colors.green.shade200),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tip:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text('Use this app\'s scoring feature to automatically calculate fan and score!'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  TableRow _buildScoreRow(String fan, String discard, String selfDraw) {
    return TableRow(
      children: [
        Padding(padding: const EdgeInsets.all(8.0), child: Text(fan)),
        Padding(padding: const EdgeInsets.all(8.0), child: Text(discard)),
        Padding(padding: const EdgeInsets.all(8.0), child: Text(selfDraw)),
      ],
    );
  }

  Widget _buildFanHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.green,
        ),
      ),
    );
  }

  Widget _buildClickableRuleRow(BuildContext context, String name, String fan) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (onRuleTap != null) {
              onRuleTap!(name);
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              color: isDark ? Colors.grey.shade800.withOpacity(0.5) : Colors.white,
            ),
            child: Row(
              children: [
                const Icon(Icons.article_outlined, size: 18, color: Colors.green),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    fan,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}