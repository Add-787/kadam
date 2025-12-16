import 'package:flutter/material.dart';
// TODO: Uncomment the following lines after generating firebase_options_prod.dart
// Run: flutterfire configure --project=<YOUR_PROD_PROJECT_ID> --out=lib/firebase_options_prod.dart
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options_prod.dart';
// import 'src/app.dart';
// import 'src/settings/settings_controller.dart';
// import 'src/settings/settings_service.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with PROD configuration
  // TODO: Uncomment after setting up production Firebase project
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  // TEMPORARY: Show error until prod is configured
  runApp(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Production Firebase is not configured yet.\n\n'
              'Please run:\n'
              'flutterfire configure --project=<YOUR_PROD_PROJECT_ID> --out=lib/firebase_options_prod.dart\n\n'
              'Then update lib/main_prod.dart',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ),
    ),
  );
}
