import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:pedometer/pedometer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../domain/repositories/step_repository.dart';
import '../datasources/step_local_data_source.dart';

@LazySingleton(as: StepRepository)
class StepRepositoryImpl implements StepRepository {
  final StepLocalDataSource _localDataSource;
  final StreamController<int> _stepController = StreamController.broadcast();
  final StreamController<String> _statusController = StreamController.broadcast();
  
  StreamSubscription<StepCount>? _stepSubscription;
  StreamSubscription<PedestrianStatus>? _statusSubscription;

  static const String _keyStartOfDaySteps = 'sensor_value_at_start_of_day';
  static const String _keyLastKnownDate = 'last_known_date';

  int _startOfDaySteps = 0;
  String? _lastKnownDate;
  late SharedPreferences _prefs;

  StepRepositoryImpl(this._localDataSource);

  @override
  Stream<int> get stepStream => _stepController.stream;

  @override
  Stream<String> get statusStream => _statusController.stream;

  @override
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _startOfDaySteps = _prefs.getInt(_keyStartOfDaySteps) ?? -1;
    _lastKnownDate = _prefs.getString(_keyLastKnownDate);

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
        _handleStepUpdate(stepCount.steps);
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

  void _handleStepUpdate(int currentSensorSteps) async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    if (_lastKnownDate != today) {
      // It's a new day or first time initialization
      _startOfDaySteps = currentSensorSteps;
      _lastKnownDate = today;
      
      await _prefs.setInt(_keyStartOfDaySteps, _startOfDaySteps);
      await _prefs.setString(_keyLastKnownDate, _lastKnownDate!);
    }

    // If the sensor value is less than _startOfDaySteps (e.g. phone rebooted on Android),
    // we should reset _startOfDaySteps to avoid negative steps.
    if (currentSensorSteps < _startOfDaySteps) {
      _startOfDaySteps = currentSensorSteps;
      await _prefs.setInt(_keyStartOfDaySteps, _startOfDaySteps);
    }

    final dailySteps = currentSensorSteps - _startOfDaySteps;
    _stepController.add(dailySteps);
  }
  
  void dispose() {
    _stepSubscription?.cancel();
    _statusSubscription?.cancel();
    _stepController.close();
    _statusController.close();
  }
}
