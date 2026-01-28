import 'package:flutter/material.dart';
import '../../../../core/presentation/theme/app_colors.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/date_selector.dart';
import '../widgets/home_header.dart';
import '../widgets/stat_card.dart';
import '../widgets/step_progress_gauge.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),

                  // Header
                  const HomeHeader(userName: 'User'),
                  const SizedBox(height: 32),

                  // Date Selector
                  const DateSelector(),

                  // View All Button
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'View All',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 12,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Step Progress Gauge
                  const Center(
                    child: StepProgressGauge(steps: 6300, goal: 10000),
                  ),

                  // Change Goal Button
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Change Goal',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 12,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Other Stats Title
                  const Text(
                    'Other Stats',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Stat Cards Row
                  const Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          icon: Icons.directions_walk,
                          value: '2.1 km',
                          label: 'Distance Covered',
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          icon: Icons.water_drop,
                          value: '778 kcal',
                          label: 'Calories burned',
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          icon: Icons.stairs,
                          value: '4',
                          label: 'Stairs Climbed',
                        ),
                      ),
                    ],
                  ),

                  // Bottom padding for nav bar
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),

          // Bottom Navigation Bar
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomBottomNavBar(),
          ),
        ],
      ),
    );
  }
}
