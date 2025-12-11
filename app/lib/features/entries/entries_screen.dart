// TogetherLog - Entries Screen
// Displays entries for a specific log - to be implemented in MILESTONE 10

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Entries list screen - placeholder for MILESTONE 10
class EntriesScreen extends StatelessWidget {
  const EntriesScreen({
    required this.logId,
    super.key,
  });

  final String logId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Entries'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/logs'),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.photo_library_outlined,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'Entries Screen',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Log ID: $logId',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'To be implemented in MILESTONE 10',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
