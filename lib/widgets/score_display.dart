import 'package:flutter/material.dart';

class ScoreDisplay extends StatelessWidget {
  final int totalScore;
  final int gamesPlayed;

  const ScoreDisplay({
    super.key,
    required this.totalScore,
    required this.gamesPlayed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatColumn('總得分', totalScore.toString()),
        Container(
          height: 40,
          width: 1,
          color: Colors.grey.shade300,
        ),
        _buildStatColumn('總場次', gamesPlayed.toString()),
      ],
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green,
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