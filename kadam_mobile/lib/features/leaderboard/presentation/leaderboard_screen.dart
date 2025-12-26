import 'package:flutter/material.dart';

/// Placeholder screen for Leaderboard tab
class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emoji_events_rounded, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Leaderboard Screen',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Coming soon...'),
          ],
        ),
      ),
    );
  }
}
