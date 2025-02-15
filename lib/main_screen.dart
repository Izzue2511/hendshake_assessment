import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'history_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  List<Map<String, String>> history = [];
  String activity = '';
  String price = '';
  String? preferredType;
  final List<String> activityTypes = [
    'recreational',
    'education',
    'social',
    'diy',
    'charity',
    'cooking',
    'relaxation',
    'music',
    'busywork'
  ];

  @override
  void initState() {
    super.initState();
    loadPreferences();
  }

  // Load preferences from SharedPreferences
  void loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      final savedType = prefs.getString('preferredType');
      preferredType = activityTypes.contains(savedType) ? savedType : null;
      final historyData = prefs.getStringList('history') ?? [];
      history = historyData.map((entry) {
        final parts = entry.split('|');
        return {'activity': parts[0], 'price': parts[1], 'type': parts[2]};
      }).toList();
    });
  }

  // Save preferences to SharedPreferences
  void savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('preferredType', preferredType ?? '');
    final historyData =
        history.map((entry) => '${entry['activity']}|${entry['price']}|${entry['type']}').toList();
    prefs.setStringList('history', historyData);
  }

  // Fetch a random activity from the API
  void fetchActivity() async {
    final response = await http.get(Uri.parse(
        'https://bored.api.lewagon.com/api/activity${preferredType != null ? '?type=$preferredType' : ''}'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        final newActivity = {
          'activity': data['activity'].toString(),
          'price': data['price'].toString(),
          'type': data['type'].toString()
        };
        history.add(newActivity);
        if (history.length > 50) {
          history.removeAt(0);
        }
        activity = data['activity'].toString();
        price = data['price'].toString();
        savePreferences();
      });
    } else {
      throw Exception('Failed to load activity');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity App'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
                  ),
                  hint: const Text('Select Activity Type'),
                  value: preferredType,
                  onChanged: (newValue) {
                    setState(() {
                      preferredType = newValue;
                    });
                    savePreferences();
                  },
                  items: activityTypes.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Center(child: Text(value)),
                    );
                  }).toList(),
                  isExpanded: true,
                  dropdownColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Activity: $activity',
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Price: $price',
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: fetchActivity,
                child: const Text('Next'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            HistoryScreen(history: history, preferredType: preferredType)),
                  );
                },
                child: const Text('History'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
