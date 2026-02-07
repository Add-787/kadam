import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../domain/repositories/step_repository.dart';
import 'dart:async';

// Events
abstract class StepsEvent extends Equatable {
  const StepsEvent();

  @override
  List<Object> get props => [];
}

class StepsStarted extends StepsEvent {}

class _StepsUpdated extends StepsEvent {
  final int steps;
  const _StepsUpdated(this.steps);
  @override
  List<Object> get props => [steps];
}

class _StatusUpdated extends StepsEvent {
  final String status;
  const _StatusUpdated(this.status);
  @override
  List<Object> get props => [status];
}

// State
class StepsState extends Equatable {
  final int steps;
  final String status;

  const StepsState({this.steps = 0, this.status = 'unknown'});

  StepsState copyWith({int? steps, String? status}) {
    return StepsState(
      steps: steps ?? this.steps,
      status: status ?? this.status,
    );
  }

  @override
  List<Object> get props => [steps, status];
}

// Bloc
@injectable
class StepsBloc extends Bloc<StepsEvent, StepsState> {
  final StepRepository _stepRepository;
  StreamSubscription? _stepSubscription;
  StreamSubscription? _statusSubscription;

  StepsBloc(this._stepRepository) : super(const StepsState()) {
    on<StepsStarted>(_onStarted);
    on<_StepsUpdated>(_onStepsUpdated);
    on<_StatusUpdated>(_onStatusUpdated);
  }

  Future<void> _onStarted(StepsStarted event, Emitter<StepsState> emit) async {
    await _stepRepository.init();
    
    _stepSubscription?.cancel();
    _stepSubscription = _stepRepository.stepStream.listen((steps) {
      add(_StepsUpdated(steps));
    });

    _statusSubscription?.cancel();
    _statusSubscription = _stepRepository.statusStream.listen((status) {
      add(_StatusUpdated(status));
    });
  }

  void _onStepsUpdated(_StepsUpdated event, Emitter<StepsState> emit) {
    emit(state.copyWith(steps: event.steps));
  }

  void _onStatusUpdated(_StatusUpdated event, Emitter<StepsState> emit) {
    emit(state.copyWith(status: event.status));
  }

  @override
  Future<void> close() {
    _stepSubscription?.cancel();
    _statusSubscription?.cancel();
    return super.close();
  }
}
