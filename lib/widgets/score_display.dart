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
        _buildStatColumn('Saved Groups', gamesPlayed.toString()),
      ],
    );
  }

  Widget _buildStatColumn(String label, String value) {
    final isScore = label == 'Total Score';
    
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
            fontSize: 13,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }
}