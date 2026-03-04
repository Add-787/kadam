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

      final String todayString = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final String? lastUpdateDate = prefs.getString('last_step_update_date');
      
      int dailySteps = prefs.getInt('daily_steps_accumulated') ?? 0;

      if (lastUpdateDate != todayString) {
        // Day change detected in background, reset accumulated steps
        dailySteps = 0;
        await prefs.setInt('daily_steps_accumulated', 0);
        await prefs.setString('last_step_update_date', todayString);
        
        // IMPORTANT: We also need to clear last_sensor_steps so that 
        // the next time the app opens, it doesn't calculate a massive delta 
        // from the previous day's sensor reading.
        await prefs.remove('last_sensor_steps');
      }

      print('Background Sync: $dailySteps steps calculated for date: $todayString');

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
