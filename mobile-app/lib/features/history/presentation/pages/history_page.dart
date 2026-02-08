import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/theme/app_colors.dart';
import '../bloc/history_bloc.dart';
import '../bloc/history_event.dart';
import '../bloc/history_state.dart';
import '../widgets/daily_summary.dart';
import '../widgets/history_calendar.dart';
import '../widgets/streak_card.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetIt.I<HistoryBloc>()..add(HistoryFetched()),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          title: const Text(
            'History',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<HistoryBloc, HistoryState>(
          builder: (context, state) {
            if (state.status == HistoryStatus.loading) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }

            if (state.status == HistoryStatus.failure) {
              return const Center(child: Text('Failed to load history', style: TextStyle(color: Colors.white)));
            }

            final selectedEntry = state.selectedEntry;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  StreakCard(streak: state.streak),
                  const SizedBox(height: 32),
                  
                  if (selectedEntry != null) ...[
                    DailySummary(
                      steps: selectedEntry.steps,
                      kcal: selectedEntry.calories,
                      km: selectedEntry.distance,
                    ),
                    const SizedBox(height: 32),
                  ],

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: HistoryCalendar(
                      history: state.history,
                      selectedDate: state.selectedDate,
                      onDateSelected: (date) {
                        context.read<HistoryBloc>().add(HistoryDateSelected(date));
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
