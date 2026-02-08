import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';
import 'package:kadam/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

const String syncTaskName = "com.kadam.stepSyncTask";

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      final prefs = await SharedPreferences.getInstance();

      final String? userId = prefs.getString('user_id');
      if (userId == null) {
        print('Background Sync Aborted: User not logged in');
        return Future.value(true);
      }

      // Get the last known total steps (saved when the app was in foreground)
      // or try to get current total steps if possible.
      // Since background sensor access is tricky, we rely on the last stored total.
      final int currentTotalSteps = prefs.getInt('total_steps') ?? 0;
      final int startOfDaySteps = prefs.getInt('steps_at_start_of_day') ?? 0;

      final int dailySteps = currentTotalSteps - startOfDaySteps;

      print(
        'Background Sync: $dailySteps steps calculated from total: $currentTotalSteps and start: $startOfDaySteps',
      );

      final String todayString = DateFormat(
        'yyyy-MM-dd',
      ).format(DateTime.now());

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('daily_steps')
          .doc(todayString)
          .set({
            'steps': dailySteps,
            'last_updated': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      print('Background Sync: Successfully uploaded steps to Firestore');

      return Future.value(true);
    } catch (e) {
      print('Background Sync Error: $e');
      return Future.value(false);
    }
  });
}

class WorkManagerConfig {
  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: true, // Set to false in production
    );
  }

  static Future<void> registerPeriodicTask() async {
    await Workmanager().registerPeriodicTask(
      "1",
      syncTaskName,
      frequency: const Duration(hours: 1),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }
}
