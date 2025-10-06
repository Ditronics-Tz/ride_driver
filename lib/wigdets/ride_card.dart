import 'package:flutter/material.dart';

class RideCard extends StatelessWidget {
  final String title;
  final String subtitle;

  RideCard({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(title),
            Text(subtitle),
          ],
        ),
      ),
    );
  }
}