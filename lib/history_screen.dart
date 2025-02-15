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
      body: ListView.builder(
        itemCount: history.length,
        itemBuilder: (context, index) {
          final item = history[index];
          return ListTile(
            title: Text(
              item['activity']!,
              style: TextStyle(
                color: item['type'] == preferredType ? Colors.blue : Colors.black,
              ),
            ),
            subtitle: Text('Price: ${item['price']}'),
          );
        },
      ),
    );
  }
}
