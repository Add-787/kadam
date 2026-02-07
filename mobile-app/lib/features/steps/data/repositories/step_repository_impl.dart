import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:pedometer/pedometer.dart';
import '../../domain/repositories/step_repository.dart';
import '../datasources/step_local_data_source.dart';

@LazySingleton(as: StepRepository)
class StepRepositoryImpl implements StepRepository {
  final StepLocalDataSource _localDataSource;
  final StreamController<int> _stepController = StreamController.broadcast();
  final StreamController<String> _statusController = StreamController.broadcast();
  
  StreamSubscription<StepCount>? _stepSubscription;
  StreamSubscription<PedestrianStatus>? _statusSubscription;

  StepRepositoryImpl(this._localDataSource);

  @override
  Stream<int> get stepStream => _stepController.stream;

  @override
  Stream<String> get statusStream => _statusController.stream;

  @override
  Future<void> init() async {
    final granted = await _localDataSource.requestPermission();
    if (granted) {
      _startListening();
    } else {
      _statusController.add('Permission Denied');
    }
  }

  void _startListening() {
    _stepSubscription = _localDataSource.stepCountStream.listen(
      (stepCount) {
        _stepController.add(stepCount.steps);
      },
      onError: (error) {
        _statusController.add('Error: $error');
      },
    );

    _statusSubscription = _localDataSource.pedestrianStatusStream.listen(
      (status) {
        _statusController.add(status.status);
      },
      onError: (error) {
        _statusController.add('Status Error: $error');
      },
    );
  }
  
  void dispose() {
    _stepSubscription?.cancel();
    _statusSubscription?.cancel();
    _stepController.close();
    _statusController.close();
  }
}
