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

  static const String _keyLastSensorSteps = 'last_sensor_steps';
  static const String _keyDailyStepsAccumulated = 'daily_steps_accumulated';
  static const String _keyLastStepUpdateDate = 'last_step_update_date';
  static const String _keyDailyStepGoal = 'daily_step_goal';

  int _dailyStepsAccumulated = 0;
  String? _lastStepUpdateDate;
  late SharedPreferences _prefs;

  StepRepositoryImpl(this._localDataSource, this._authRepository);

  @override
  Stream<int> get stepStream => _stepController.stream;

  @override
  int get currentSteps => _dailyStepsAccumulated;

  @override
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    
    // Refresh daily steps from prefs in case they were updated elsewhere
    _dailyStepsAccumulated = _prefs.getInt(_keyDailyStepsAccumulated) ?? 0;
    _lastStepUpdateDate = _prefs.getString(_keyLastStepUpdateDate);

    // If it's a new day, reset
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    if (_lastStepUpdateDate != today) {
      _dailyStepsAccumulated = 0;
      _lastStepUpdateDate = today; // Update local variable too
      await _prefs.setInt(_keyDailyStepsAccumulated, 0);
      await _prefs.setString(_keyLastStepUpdateDate, today);
      await _prefs.remove(_keyLastSensorSteps);
    }
    
    // Fetch today's total from the health store to catch up on missed steps
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);
    final healthTotal = await _localDataSource.getStepsForInterval(midnight, now);
    if (healthTotal != null && healthTotal > _dailyStepsAccumulated) {
      _dailyStepsAccumulated = healthTotal;
      await _prefs.setInt(_keyDailyStepsAccumulated, _dailyStepsAccumulated);
      await _prefs.remove(_keyLastSensorSteps);
    }

    _stepController.add(_dailyStepsAccumulated);

    // Sync to Firestore on init so today's data is always up to date
    _syncToFirestore(today, _dailyStepsAccumulated);

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

  @override
  Future<int> getStepsForDate(DateTime date) async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final requestedDate = DateFormat('yyyy-MM-dd').format(date);

    if (requestedDate == today) {
      return _dailyStepsAccumulated;
    }

    // Primary: Health Connect
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    final healthSteps = await _localDataSource.getStepsForInterval(startOfDay, endOfDay);
    if (healthSteps != null && healthSteps > 0) {
      return healthSteps;
    }

    // Backup: Firestore
    final user = _authRepository.currentUser;
    if (user == null) return 0;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('daily_steps')
          .doc(requestedDate)
          .get();

      if (doc.exists) {
        return doc.data()?['steps'] as int? ?? 0;
      }
    } catch (e) {
      print('Error fetching steps for $requestedDate: $e');
    }
    return 0;
  }

  void _syncToFirestore(String dateStr, int steps) {
    final user = _authRepository.currentUser;
    if (user == null) return;

    _firestore
        .collection('users')
        .doc(user.uid)
        .collection('daily_steps')
        .doc(dateStr)
        .set({
          'steps': steps,
          'last_updated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true))
        .catchError((e) => print('Firestore sync error: $e'));
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
    
    // Check for day change
    if (_lastStepUpdateDate != today) {
      _dailyStepsAccumulated = 0;
      _lastStepUpdateDate = today;
      await _prefs.setString(_keyLastStepUpdateDate, today);
      await _prefs.setInt(_keyDailyStepsAccumulated, 0);
      
      // Reset last sensor steps to current to start fresh for the new day
      await _prefs.setInt(_keyLastSensorSteps, currentSensorSteps);
    }

    int? lastSensorStepsStored = _prefs.getInt(_keyLastSensorSteps);
    
    // If we have no record of last sensor steps, store the current one
    // but don't reset _dailyStepsAccumulated if it already has value (e.g. from app restart)
    if (lastSensorStepsStored == null) {
      await _prefs.setInt(_keyLastSensorSteps, currentSensorSteps);
      _stepController.add(_dailyStepsAccumulated);
      return;
    }

    int lastSensorSteps = lastSensorStepsStored;
    int delta = currentSensorSteps - lastSensorSteps;

    if (delta < 0) {
      // Reboot occurred, sensor reset
      delta = currentSensorSteps;
    }

    _dailyStepsAccumulated += delta;
    
    await _prefs.setInt(_keyDailyStepsAccumulated, _dailyStepsAccumulated);
    await _prefs.setInt(_keyLastSensorSteps, currentSensorSteps);
    
    _stepController.add(_dailyStepsAccumulated);
  }
  
  @override
  Future<Set<String>> getDatesWithData(DateTime start, DateTime end) async {
    final dates = <String>{};
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Today always has data if we have accumulated steps
    if (_dailyStepsAccumulated > 0) {
      dates.add(today);
    }

    final user = _authRepository.currentUser;
    if (user == null) return dates;

    try {
      final startStr = DateFormat('yyyy-MM-dd').format(start);
      final endStr = DateFormat('yyyy-MM-dd').format(end);

      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('daily_steps')
          .where(FieldPath.documentId, isGreaterThanOrEqualTo: startStr)
          .where(FieldPath.documentId, isLessThanOrEqualTo: endStr)
          .where('steps', isGreaterThan: 0)
          .get();

      for (final doc in snapshot.docs) {
        dates.add(doc.id);
      }
    } catch (e) {
      print('Error fetching dates with data: $e');
    }

    return dates;
  }

  void dispose() {
    _stepSubscription?.cancel();
    _stepController.close();
  }
}
