import 'package:flutter/material.dart';
import '../models/player.dart';

class PlayerCard extends StatelessWidget {
  final Player player;
  final Function(int) onScoreChanged;

  const PlayerCard({
    super.key,
    required this.player,
    required this.onScoreChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.primaries[player.id % Colors.primaries.length],
                  child: Text('${player.id + 1}'),
                ),
                const SizedBox(width: 16),
                Text(
                  player.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${player.score}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: player.score >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildScoreButton(
                  icon: Icons.remove,
                  color: Colors.red.shade200,
                  value: -100,
                ),
                _buildScoreButton(
                  icon: Icons.remove,
                  color: Colors.red.shade300,
                  value: -500,
                ),
                _buildScoreButton(
                  icon: Icons.add,
                  color: Colors.green.shade300,
                  value: 500,
                ),
                _buildScoreButton(
                  icon: Icons.add,
                  color: Colors.green.shade200,
                  value: 100,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreButton({
    required IconData icon,
    required Color color,
    required int value,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(12),
      ),
      onPressed: () {
        onScoreChanged(player.score + value);
      },
      child: Icon(icon, color: Colors.white),
    );
  }
}