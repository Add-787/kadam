import '../entities/history_entry.dart';

abstract class HistoryRepository {
  Future<List<HistoryEntry>> getHistory();
  Future<int> getStreak();
}
