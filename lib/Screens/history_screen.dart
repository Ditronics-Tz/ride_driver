import 'package:flutter/material.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ride History'),
        backgroundColor: Colors.blue,
      ),
      body: ListView.builder(
        itemCount: 10, // Replace with actual data count
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.drive_eta),
              ),
              title: Text('Ride #${index + 1}'),
              subtitle: const Text('From: Location A\nTo: Location B'),
              trailing: const Text('\$25.00'),
              onTap: () {
                // Handle tap to view ride details
              },
            ),
          );
        },
      ),
    );
  }
}