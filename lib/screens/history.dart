import 'package:flutter/material.dart';
import '../models/game_record.dart';
import '../utils/date_formatter.dart';
import '../widgets/base_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample data - would be fetched from database or storage
    final List<GameRecord> records = [
      GameRecord(
        id: '1',
        date: DateTime.now().subtract(const Duration(days: 1)),
        players: [],
        rounds: 10,
      ),
      GameRecord(
        id: '2',
        date: DateTime.now().subtract(const Duration(days: 3)),
        players: [],
        rounds: 8,
      ),
      GameRecord(
        id: '3',
        date: DateTime.now().subtract(const Duration(days: 7)),
        players: [],
        rounds: 12,
      ),
    ];

    return BaseScreen(
      title: 'Game History',
      currentIndex: 1,
      body: records.isEmpty
          ? const Center(
              child: Text(
                'No history records',
                style: TextStyle(fontSize: 17, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: records.length,
              itemBuilder: (context, index) {
                final record = records[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.history),
                    ),
                    title: Text('Game #${index + 1}'),
                    subtitle: Text(
                      'Date: ${formatDate(record.date)}\n'
                      'Rounds: ${record.rounds}',
                    ),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: const Icon(Icons.arrow_forward_ios),
                      onPressed: () {
                        // View detailed history record
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}