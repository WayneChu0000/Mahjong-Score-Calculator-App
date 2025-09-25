import 'package:flutter/material.dart';

class ScoreDisplay extends StatelessWidget {
  final int gamesPlayed;

  const ScoreDisplay({
    super.key,
    required this.gamesPlayed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatColumn('總場次', gamesPlayed.toString()),
      ],
    );
  }

  Widget _buildStatColumn(String label, String value) {
    final isScore = label == '總得分';
    
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isScore 
                ? (value.startsWith('-') ? Colors.red : Colors.green)
                : Colors.green,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }
}