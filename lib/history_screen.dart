import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  final List<Map<String, String>> history;
  final String? preferredType;

  const HistoryScreen({super.key, required this.history, this.preferredType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: history.length,
          itemBuilder: (context, index) {
            final item = history[index];
            return Card(
              child: ListTile(
                title: Text(
                  item['activity']!,
                  style: TextStyle(
                    color: item['type'] == preferredType ? Colors.blue : Colors.black,
                    fontWeight: item['type'] == preferredType ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                subtitle: Text('Price: ${item['price']}'),
              ),
            );
          },
        ),
      ),
    );
  }
}
