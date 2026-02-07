import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/presentation/theme/app_colors.dart';
import '../../../steps/presentation/bloc/steps_bloc.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/date_selector.dart';
import '../widgets/home_header.dart';
import '../widgets/stat_card.dart';
import '../widgets/step_progress_gauge.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetIt.I<StepsBloc>()..add(StepsStarted()),
      child: Scaffold(
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

                    // Step Progress Gauge (Connected to BLoC)
                    Center(
                      child: BlocBuilder<StepsBloc, StepsState>(
                        builder: (context, state) {
                          // Display status for debugging (optional, can remove later)
                          if (state.status == 'Permission Denied') {
                            return const Text(
                              'Please enable activity permissions',
                              style: TextStyle(color: Colors.red),
                            );
                          }

                          return StepProgressGauge(
                            steps: state.steps,
                            goal: 10000,
                          );
                        },
                      ),
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
      ),
    );
  }
}
