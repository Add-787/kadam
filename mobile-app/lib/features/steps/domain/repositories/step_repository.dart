abstract class StepRepository {
  /// Returns a stream of the current step count from the device pedometer.
  Stream<int> get stepStream;

  /// Returns the current accumulated steps synchronously.
  int get currentSteps;

  /// Initializes the step tracking (requests permissions).
  Future<void> init();

  /// Gets the daily step goal from local storage or remote.
  Future<int> getDailyGoal();

  /// Sets the daily step goal and persists it.
  Future<void> setDailyGoal(int goal);

  /// Gets the step count for a specific date.
  Future<int> getStepsForDate(DateTime date);

  /// Returns a set of date strings (yyyy-MM-dd) that have step data within the given range.
  Future<Set<String>> getDatesWithData(DateTime start, DateTime end);
}
