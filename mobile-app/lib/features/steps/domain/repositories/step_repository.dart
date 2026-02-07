abstract class StepRepository {
  /// Returns a stream of the current step count from the device pedometer.
  Stream<int> get stepStream;

  /// Returns a stream of the pedestrian status (walking, stopped, etc.).
  Stream<String> get statusStream;

  /// Initializes the step tracking (requests permissions).
  Future<void> init();
}
