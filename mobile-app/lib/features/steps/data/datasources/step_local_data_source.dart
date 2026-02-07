import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:injectable/injectable.dart';
import 'dart:async';

abstract class StepLocalDataSource {
  Stream<StepCount> get stepCountStream;
  Stream<PedestrianStatus> get pedestrianStatusStream;
  Future<bool> requestPermission();
}

@LazySingleton(as: StepLocalDataSource)
class StepLocalDataSourceImpl implements StepLocalDataSource {
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
}
