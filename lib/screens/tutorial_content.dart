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
            'Welcome to Mahjong Score Calculator',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Text(
            'This app will help you:',
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(height: 8),
          Text('• Learn basic mahjong rules'),
          Text('• Calculate mahjong scores'),
          Text('• Record game results'),
          Text('• Manage player groups'),
          SizedBox(height: 16),
          Text(
            'Let\'s start learning mahjong!',
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
            'Types of Mahjong Tiles',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          // Character tiles
          _buildTileSection(
            'Character Tiles (1m-9m)',
            'Numbered 1 to 9 in characters',
            ['1m', '2m', '3m', '4m', '5m', '6m', '7m', '8m', '9m'],
          ),
          
          const SizedBox(height: 16),
          
          // Circle tiles
          _buildTileSection(
            'Circle Tiles (1p-9p)',
            'Numbered 1 to 9 in circles',
            ['1p', '2p', '3p', '4p', '5p', '6p', '7p', '8p', '9p'],
          ),
          
          const SizedBox(height: 16),
          
          // Bamboo tiles
          _buildTileSection(
            'Bamboo Tiles (1s-9s)',
            'Numbered 1 to 9 in bamboo',
            ['1s', '2s', '3s', '4s', '5s', '6s', '7s', '8s', '9s'],
          ),
          
          const SizedBox(height: 16),
          
          // Honor tiles
          _buildTileSection(
            'Honor Tiles (1z-7z)',
            'Include wind tiles (E/S/W/N) and dragon tiles (White/Green/Red)',
            ['1z', '2z', '3z', '4z', '5z', '6z', '7z'],
          ),
          
          const SizedBox(height: 16),
          
          // Honor tiles explanation
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
                  'Honor Tiles:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text('1z = East　2z = South　3z = West　4z = North'),
                Text('5z = White　6z = Green　7z = Red'),
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
            'Basic Rules',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          
          Text(
            '1. Game Objective',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('The goal of mahjong is to form a complete hand, usually consisting of:'),
          Text('• 4 sets (chow/pong) + 1 pair (eyes)'),
          Text('• 7 pairs (Seven Pairs hand)'),
          Text('• Special hands (e.g., Thirteen Orphans)'),
          
          SizedBox(height: 16),
          
          Text(
            '2. Basic Terms',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('• Chow: Three consecutive tiles (e.g., 1m-2m-3m)'),
          Text('• Pong: Three identical tiles (e.g., 5p-5p-5p)'),
          Text('• Eyes: A pair of identical tiles'),
          Text('• Self-Draw: Draw your own winning tile'),
          Text('• Discard: Discard a tile that lets others win'),
          
          SizedBox(height: 16),
          
          Text(
            '3. Game Flow',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('• Each player starts with 13 tiles'),
          Text('• Take turns drawing and discarding tiles'),
          Text('• Can chow, pong, or kong others\' tiles'),
          Text('• Form a complete hand to win'),
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
            'Scoring System',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          const Text(
            'Hong Kong Mahjong Scoring Rules',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Mahjong scoring is determined by fan count:'),
          const Text('• 1 fan = 1 point'),
          const Text('• 2 fan = 2 points'),
          const Text('• 3 fan = 4 points'),
          const Text('• 4 fan = 8 points'),
          const Text('• 5 fan = 16 points'),
          const Text('• And so on...'),
          
          const SizedBox(height: 16),
          
          const Text(
            'Common Fan Counts',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          
          _buildScoringExample('All Chows', '1 fan', 'Four chows plus a pair', ['1m', '2m', '3m']),
          _buildScoringExample('All Pongs', '4 fan', 'Four pongs plus a pair', ['5p', '5p', '5p']),
          _buildScoringExample('Pure Hand', '7 fan', 'All same suit', ['1s', '2s', '3s']),
          _buildScoringExample('Big Three Dragons', '8 fan', 'Three dragon pongs (White/Green/Red)', ['7z', '7z', '7z']),
          
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