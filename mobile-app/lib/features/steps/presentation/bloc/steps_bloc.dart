import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/repositories/step_repository.dart';
import 'dart:async';

// Events
abstract class StepsEvent extends Equatable {
  const StepsEvent();

  @override
  List<Object> get props => [];
}

class StepsStarted extends StepsEvent {}

class GoalChanged extends StepsEvent {
  final int dailyGoal;
  const GoalChanged(this.dailyGoal);
  @override
  List<Object> get props => [dailyGoal];
}

class DateSelected extends StepsEvent {
  final DateTime date;
  const DateSelected(this.date);
  @override
  List<Object> get props => [date];
}

class _StepsUpdated extends StepsEvent {
  final int steps;
  const _StepsUpdated(this.steps);
  @override
  List<Object> get props => [steps];
}

// State
class StepsState extends Equatable {
  final int steps;
  final int dailyGoal;
  final DateTime selectedDate;
  final DateTime? joinedDate;

  const StepsState({
    this.steps = 0,
    this.dailyGoal = 10000,
    required this.selectedDate,
    this.joinedDate,
  });

  StepsState copyWith({
    int? steps,
    int? dailyGoal,
    DateTime? selectedDate,
    DateTime? joinedDate,
  }) {
    return StepsState(
      steps: steps ?? this.steps,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      selectedDate: selectedDate ?? this.selectedDate,
      joinedDate: joinedDate ?? this.joinedDate,
    );
  }

  @override
  List<Object?> get props => [steps, dailyGoal, selectedDate, joinedDate];
}

// Bloc
@injectable
class StepsBloc extends Bloc<StepsEvent, StepsState> {
  final StepRepository _stepRepository;
  final AuthRepository _authRepository;
  StreamSubscription? _stepSubscription;

  StepsBloc(this._stepRepository, this._authRepository)
    : super(StepsState(selectedDate: DateTime.now())) {
    on<StepsStarted>(_onStarted);
    on<GoalChanged>(_onGoalChanged);
    on<DateSelected>(_onDateSelected);
    on<_StepsUpdated>(_onStepsUpdated);
  }

  Future<void> _onStarted(StepsStarted event, Emitter<StepsState> emit) async {
    final joinedDate = await _authRepository.getJoinedDate();
    final dailyGoal = await _stepRepository.getDailyGoal();
    
    // Immediate UI update from cache
    final currentSteps = _stepRepository.currentSteps;
    emit(state.copyWith(
      joinedDate: joinedDate, 
      dailyGoal: dailyGoal,
      steps: currentSteps,
    ));

    // Subscribe before init to avoid missing broadcast events
    _stepSubscription?.cancel();
    _stepSubscription = _stepRepository.stepStream.listen((steps) {
      add(_StepsUpdated(steps));
    });

    await _stepRepository.init();
  }

  Future<void> _onGoalChanged(GoalChanged event, Emitter<StepsState> emit) async {
    emit(state.copyWith(dailyGoal: event.dailyGoal));
    await _stepRepository.setDailyGoal(event.dailyGoal);
  }

  Future<void> _onDateSelected(DateSelected event, Emitter<StepsState> emit) async {
    final steps = await _stepRepository.getStepsForDate(event.date);
    emit(state.copyWith(selectedDate: event.date, steps: steps));
  }

  void _onStepsUpdated(_StepsUpdated event, Emitter<StepsState> emit) {
    final now = DateTime.now();
    final isTodaySelected = state.selectedDate.year == now.year &&
        state.selectedDate.month == now.month &&
        state.selectedDate.day == now.day;

    if (isTodaySelected) {
      emit(state.copyWith(steps: event.steps));
    }
  }

  @override
  Future<void> close() {
    _stepSubscription?.cancel();
    return super.close();
  }
}
