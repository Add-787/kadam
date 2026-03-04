import 'package:injectable/injectable.dart';
import '../../domain/entities/history_entry.dart';
import '../../domain/repositories/history_repository.dart';

@LazySingleton(as: HistoryRepository)
class HistoryRepositoryImpl implements HistoryRepository {
  @override
  Future<List<HistoryEntry>> getHistory() async {
    // Mock data for the last 30 days
    final now = DateTime.now();
    return List.generate(30, (index) {
      final date = now.subtract(Duration(days: index));
      return HistoryEntry(
        date: date,
        steps: 4000 + (index * 100) % 6000,
        calories: 200 + (index * 10) % 500,
        distance: 2.0 + (index * 0.1) % 5.0,
        isGoalAchieved: index % 3 != 0,
      );
    });
  }

  @override
  Future<int> getStreak() async {
    return 3; // Mock streak
  }
}
