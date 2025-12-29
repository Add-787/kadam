// TODO: Generate this file by running:
// flutterfire configure --project=<YOUR_PROD_PROJECT_ID> --out=lib/config/firebase_options_prod.dart
//
// For now, this is a placeholder. Replace with actual production Firebase config.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps (PRODUCTION).
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // TODO: Replace with your production Firebase config
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_PROD_WEB_API_KEY',
    appId: 'YOUR_PROD_WEB_APP_ID',
    messagingSenderId: 'YOUR_PROD_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROD_PROJECT_ID',
    authDomain: 'YOUR_PROD_PROJECT_ID.firebaseapp.com',
    storageBucket: 'YOUR_PROD_PROJECT_ID.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_PROD_ANDROID_API_KEY',
    appId: 'YOUR_PROD_ANDROID_APP_ID',
    messagingSenderId: 'YOUR_PROD_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROD_PROJECT_ID',
    storageBucket: 'YOUR_PROD_PROJECT_ID.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_PROD_IOS_API_KEY',
    appId: 'YOUR_PROD_IOS_APP_ID',
    messagingSenderId: 'YOUR_PROD_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROD_PROJECT_ID',
    storageBucket: 'YOUR_PROD_PROJECT_ID.appspot.com',
    iosBundleId: 'com.psyluck.kadam',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'YOUR_PROD_MACOS_API_KEY',
    appId: 'YOUR_PROD_MACOS_APP_ID',
    messagingSenderId: 'YOUR_PROD_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROD_PROJECT_ID',
    storageBucket: 'YOUR_PROD_PROJECT_ID.appspot.com',
    iosBundleId: 'com.psyluck.kadam',
  );
}
