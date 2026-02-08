import 'package:equatable/equatable.dart';
import '../../domain/entities/history_entry.dart';

enum HistoryStatus { initial, loading, success, failure }

class HistoryState extends Equatable {
  final HistoryStatus status;
  final List<HistoryEntry> history;
  final int streak;
  final DateTime selectedDate;

  HistoryState({
    this.status = HistoryStatus.initial,
    this.history = const [],
    this.streak = 0,
    DateTime? selectedDate,
  }) : selectedDate = selectedDate ?? DateTime.now();

  HistoryEntry? get selectedEntry {
    try {
      return history.firstWhere(
        (e) => e.date.year == selectedDate.year &&
               e.date.month == selectedDate.month &&
               e.date.day == selectedDate.day,
      );
    } catch (_) {
      return null;
    }
  }

  HistoryState copyWith({
    HistoryStatus? status,
    List<HistoryEntry>? history,
    int? streak,
    DateTime? selectedDate,
  }) {
    return HistoryState(
      status: status ?? this.status,
      history: history ?? this.history,
      streak: streak ?? this.streak,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }

  @override
  List<Object?> get props => [status, history, streak, selectedDate];
}
