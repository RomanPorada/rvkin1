import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formatter = DateFormat('yyyy-MM-dd');

  // By default today is selected
  DateTime _selectedDate = DateTime.now();

  // Existing code...

  @override
  Widget build(BuildContext context) {
    final date = _formatter.format(_selectedDate);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                "Виберіть дату:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2022, 2, 24),
                      lastDate: DateTime.now(),
                    );

                    if (date == null) {
                      return;
                    }

                    setState(() => _selectedDate = date);
                  },
                  child: Text(date),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Updated display of war stats
            FutureBuilder(
              future: getStats(date),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final data = snapshot.data!;

                return Center(
                  child: Column(
                    children: [
                      _buildStatBox("Здохло: ${data[0]} орків", Colors.red),
                      _buildStatBox("Згоріло: ${data[1]} танків", Colors.red),
                      _buildStatBox("Згоріло: ${data[2]} літаків", Colors.red),
                      _buildStatBox("Згоріло: ${data[3]} гелікоптерів", Colors.red,),
                      _buildStatBox("Знищено: ${data[4]} млрс", Colors.red,),
                      _buildStatBox("Потоплено: ${data[5]} катерів", Colors.red,)
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox(String text, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
            fontSize: 24, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  Future<List<int>> getStats(String date) async {
    const url = "https://russianwarship.rip/api/v2";
    final date = _formatter.format(_selectedDate);
    final uri = Uri.parse("$url/statistics/$date");
    final response = await get(uri);
    final json = jsonDecode(response.body);
    print(json);
    final personnel = json['data']['stats']['personnel_units'] as int;
    final tanks = json['data']['stats']['tanks'] as int;
    final planes = json['data']['stats']['planes'] as int;
    final helicopters = json['data']['stats']['helicopters'] as int;
    final mlrs = json['data']['stats']['mlrs'] as int;
    final warships_cutters = json['data']['stats']['warships_cutters'] as int;
    return [personnel, tanks, planes, helicopters, mlrs, warships_cutters];
  }
}