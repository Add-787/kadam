import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/theme/app_colors.dart';
import '../../../steps/presentation/bloc/steps_bloc.dart';
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
        body: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.8), // Light burst from very top
              radius: 1.5,
              colors: [
                Color(0xFF2C2C20), // Subtle yellow tint
                AppColors.background,
              ],
            ),
          ),
          child: Stack(
            children: [
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 16),

                      // Header
                      const HomeHeader(userName: 'User'),
                      const SizedBox(height: 32),

                      // Date Selector
                      BlocBuilder<StepsBloc, StepsState>(
                        builder: (context, state) {
                          return DateSelector(joinedDate: state.joinedDate);
                        },
                      ),
                      const SizedBox(height: 24),

                      // View All Button
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => context.push('/history'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            padding: EdgeInsets.zero,
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'View All',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 12,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Step Progress Gauge (Connected to BLoC)
                      Center(
                        child: BlocBuilder<StepsBloc, StepsState>(
                          builder: (context, state) {
                            if (state.status == 'Permission Denied') {
                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.red.withOpacity(0.5)),
                                ),
                                child: const Text(
                                  'Please enable activity permissions to track steps',
                                  style: TextStyle(color: Colors.redAccent),
                                  textAlign: TextAlign.center,
                                ),
                              );
                            }

                            return StepProgressGauge(
                              steps: state.steps,
                              goal: 10000,
                            );
                          },
                        ),
                      ),
                      
                      const SizedBox(height: 16),

                      // Change Goal Button
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                           style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            padding: EdgeInsets.zero,
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Change Goal',
                                style: TextStyle(
                                  fontSize: 14,
                                   fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 12,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Other Stats Title
                      const Text(
                        'Other Stats',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Stat Cards Row
                      const Row(
                        children: [
                          Expanded(
                            child: StatCard(
                              icon: Icons.directions_walk_rounded,
                              value: '2.1 km',
                              label: 'Distance Covered',
                              color: Color(0xFFE6A23C), // Orange-ish
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: StatCard(
                              icon: Icons.local_fire_department_rounded,
                              value: '778 kcal',
                              label: 'Calories burned',
                              color: Color(0xFFFFCC00), // Yellow
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: StatCard(
                              icon: Icons.stairs_rounded,
                              value: '4',
                              label: 'Stairs Climbed',
                              color: Color(0xFFA6A65E), // Olive
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
            ],
          ),
        ),
      ),
    );
  }
}
