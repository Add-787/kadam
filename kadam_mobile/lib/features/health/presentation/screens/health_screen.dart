import 'package:flutter/material.dart';
import '../widgets/daily_step_counter.dart';

/// Health screen - displays step tracking and health metrics
class HealthScreen extends StatelessWidget {
  const HealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).pushNamed('/settings');
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Daily step counter widget
              DailyStepCounter(
                currentSteps:
                    3847, // TODO: Replace with actual data from provider
                targetSteps: 10000,
              ),
              const SizedBox(height: 32),
              // Additional health metrics can be added below
              Text(
                'Track your daily steps and reach your goals!',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
