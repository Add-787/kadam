import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/repositories/history_repository.dart';
import 'history_event.dart';
import 'history_state.dart';

@injectable
class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final HistoryRepository _historyRepository;

  HistoryBloc(this._historyRepository) : super(HistoryState()) {
    on<HistoryFetched>(_onHistoryFetched);
    on<HistoryDateSelected>(_onHistoryDateSelected);
  }

  Future<void> _onHistoryFetched(
    HistoryFetched event,
    Emitter<HistoryState> emit,
  ) async {
    emit(state.copyWith(status: HistoryStatus.loading));
    try {
      final history = await _historyRepository.getHistory();
      final streak = await _historyRepository.getStreak();
      emit(state.copyWith(
        status: HistoryStatus.success,
        history: history,
        streak: streak,
      ));
    } catch (_) {
      emit(state.copyWith(status: HistoryStatus.failure));
    }
  }

  void _onHistoryDateSelected(
    HistoryDateSelected event,
    Emitter<HistoryState> emit,
  ) {
    emit(state.copyWith(selectedDate: event.selectedDate));
  }
}
