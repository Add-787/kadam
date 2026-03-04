import 'package:health/health.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:injectable/injectable.dart';
import 'dart:async';

abstract class StepLocalDataSource {
  Stream<StepCount> get stepCountStream;
  Stream<PedestrianStatus> get pedestrianStatusStream;
  Future<bool> requestPermission();
  Future<int?> getStepsForInterval(DateTime start, DateTime end);
}

@LazySingleton(as: StepLocalDataSource)
class StepLocalDataSourceImpl implements StepLocalDataSource {
  final Health _health = Health();

  @override
  Stream<StepCount> get stepCountStream => Pedometer.stepCountStream;

  @override
  Stream<PedestrianStatus> get pedestrianStatusStream =>
      Pedometer.pedestrianStatusStream;

  @override
  Future<bool> requestPermission() async {
    final status = await Permission.activityRecognition.request();
    return status.isGranted;
  }

  @override
  Future<int?> getStepsForInterval(DateTime start, DateTime end) async {
    try {
      final requested = await _health.requestAuthorization(
        [HealthDataType.STEPS],
        permissions: [HealthDataAccess.READ],
      );

      print('[Health] requestAuthorization result: $requested');
      if (!requested) return null;

      final steps = await _health.getTotalStepsInInterval(start, end);
      print('[Health] getStepsForInterval($start - $end) result: $steps');
      return steps;
    } catch (e) {
      print('[Health] Error: $e');
      return null;
    }
  }
}
