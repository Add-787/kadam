abstract class StepRepository {
  /// Returns a stream of the current step count from the device pedometer.
  Stream<int> get stepStream;

  /// Initializes the step tracking (requests permissions).
  Future<void> init();

  /// Gets the daily step goal from local storage or remote.
  Future<int> getDailyGoal();

  /// Sets the daily step goal and persists it.
  Future<void> setDailyGoal(int goal);
}
