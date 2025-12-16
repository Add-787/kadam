# Environment Configuration

This project supports multiple Firebase environments (dev and prod).

## Files Structure

```
lib/
├── main.dart                      # Default entry point (uses DEV)
├── main_dev.dart                  # Dev environment entry point
├── main_prod.dart                 # Prod environment entry point (TODO: Configure)
├── firebase_options_dev.dart      # Dev Firebase configuration (gitignored)
└── firebase_options_prod.dart     # Prod Firebase configuration (gitignored)
```

## ⚠️ Important: Firebase Configuration Files

**Firebase configuration files are gitignored** to protect API keys and sensitive data.

### First-time Setup

If you've just cloned this repository, you need to generate the Firebase configuration files:

1. **Install FlutterFire CLI:**
   ```bash
   dart pub global activate flutterfire_cli
   ```

2. **Login to Firebase:**
   ```bash
   firebase login
   ```

3. **Generate Dev Configuration:**
   ```bash
   flutterfire configure --project=kadam-dev-5a2a4 --out=lib/firebase_options_dev.dart --platforms=android,ios --android-package-name=com.psyluck.kadam --ios-bundle-id=com.psyluck.kadam
   ```

4. **Generate Prod Configuration (when ready):**
   ```bash
   flutterfire configure --project=<YOUR_PROD_PROJECT_ID> --out=lib/firebase_options_prod.dart --platforms=android,ios --android-package-name=com.psyluck.kadam --ios-bundle-id=com.psyluck.kadam
   ```

## Running the App

### Development Environment (Default)
```bash
flutter run
# OR explicitly:
flutter run -t lib/main_dev.dart
```

### Production Environment
```bash
flutter run -t lib/main_prod.dart
```

## Building the App

### Development Build
```bash
# Android
flutter build apk -t lib/main_dev.dart

# iOS
flutter build ios -t lib/main_dev.dart
```

### Production Build
```bash
# Android
flutter build apk -t lib/main_prod.dart --release

# iOS
flutter build ios -t lib/main_prod.dart --release
```

## Setting Up Production Environment

When you're ready to set up the production Firebase project:

1. **Create or select a production Firebase project** in the [Firebase Console](https://console.firebase.google.com/)

2. **Generate production Firebase configuration:**
   ```bash
   flutterfire configure --project=<YOUR_PROD_PROJECT_ID> --out=lib/firebase_options_prod.dart --platforms=android,ios --android-package-name=com.psyluck.kadam --ios-bundle-id=com.psyluck.kadam
   ```

3. **Update `lib/main_prod.dart`:**
   - Uncomment the Firebase imports
   - Uncomment the Firebase initialization
   - Remove the temporary error screen
   - The file should look like `main_dev.dart` but import `firebase_options_prod.dart`

## Current Configuration

- **Dev Environment**: Connected to `kadam-dev-5a2a4`
- **Prod Environment**: Not configured yet (placeholder)

## Firebase Projects

| Environment | Project ID       | Package Name         |
|-------------|------------------|----------------------|
| Dev         | kadam-dev-5a2a4  | com.psyluck.kadam   |
| Prod        | TBD              | com.psyluck.kadam   |
