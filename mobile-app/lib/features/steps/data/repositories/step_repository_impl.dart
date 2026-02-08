import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:pedometer/pedometer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/repositories/step_repository.dart';
import '../datasources/step_local_data_source.dart';

@LazySingleton(as: StepRepository)
class StepRepositoryImpl implements StepRepository {
  final StepLocalDataSource _localDataSource;
  final AuthRepository _authRepository;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StreamController<int> _stepController = StreamController.broadcast();
  
  StreamSubscription<StepCount>? _stepSubscription;

  static const String _keyStartOfDaySteps = 'sensor_value_at_start_of_day';
  static const String _keyLastKnownDate = 'last_known_date';
  static const String _keyDailyStepGoal = 'daily_step_goal';

  int _startOfDaySteps = 0;
  String? _lastKnownDate;
  late SharedPreferences _prefs;

  StepRepositoryImpl(this._localDataSource, this._authRepository);

  @override
  Stream<int> get stepStream => _stepController.stream;

  @override
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _startOfDaySteps = _prefs.getInt(_keyStartOfDaySteps) ?? -1;
    _lastKnownDate = _prefs.getString(_keyLastKnownDate);

    final granted = await _localDataSource.requestPermission();
    if (granted) {
      _startListening();
    } else {
      _stepController.addError('Permission Denied');
    }
  }

  @override
  Future<int> getDailyGoal() async {
    _prefs = await SharedPreferences.getInstance();
    return _prefs.getInt(_keyDailyStepGoal) ?? 10000;
  }

  @override
  Future<void> setDailyGoal(int goal) async {
    _prefs = await SharedPreferences.getInstance();
    await _prefs.setInt(_keyDailyStepGoal, goal);

    final user = _authRepository.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set({
        'daily_step_goal': goal,
      }, SetOptions(merge: true));
    }
  }

  void _startListening() {
    _stepSubscription = _localDataSource.stepCountStream.listen(
      (stepCount) {
        _handleStepUpdate(stepCount.steps);
      },
      onError: (error) {
        _stepController.addError(error);
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
    _stepController.close();
  }
}
