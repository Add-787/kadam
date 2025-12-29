# Environment Configuration Guide

## Overview

Kadam uses **separate entry points** to differentiate between development and production environments. This approach provides clear separation and prevents accidental deployment of dev config to production.

---

## 📁 File Structure

```
lib/
├── main.dart                        # Default entry (uses dev config)
├── main_dev.dart                    # Development entry point
├── main_prod.dart                   # Production entry point
└── config/
    ├── environment.dart             # Environment configuration class
    ├── firebase_options_dev.dart    # Dev Firebase config
    └── firebase_options_prod.dart   # Prod Firebase config
```

---

## 🚀 Running Different Environments

### Development Mode
```bash
# Run on device/emulator
flutter run -t lib/main_dev.dart

# Build APK
flutter build apk -t lib/main_dev.dart

# Build iOS
flutter build ios -t lib/main_dev.dart
```

### Production Mode
```bash
# Run on device/emulator
flutter run -t lib/main_prod.dart --release

# Build APK
flutter build apk -t lib/main_prod.dart --release

# Build iOS
flutter build ios -t lib/main_prod.dart --release

# Build App Bundle (Android)
flutter build appbundle -t lib/main_prod.dart --release
```

### Using VSCode Launch Configurations

Create `.vscode/launch.json`:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Development",
      "request": "launch",
      "type": "dart",
      "program": "lib/main_dev.dart",
      "args": [
        "--flavor",
        "development"
      ]
    },
    {
      "name": "Production",
      "request": "launch",
      "type": "dart",
      "program": "lib/main_prod.dart",
      "args": [
        "--release",
        "--flavor",
        "production"
      ]
    }
  ]
}
```

---

## 🔧 Environment Config Usage

### In Your Code

```dart
import 'package:kadam_mobile/config/environment.dart';

// Check environment
if (EnvironmentConfig.isDevelopment) {
  print('Running in DEV mode');
  // Enable verbose logging
  // Use mock data
}

if (EnvironmentConfig.isProduction) {
  print('Running in PROD mode');
  // Disable debug features
  // Use real APIs
}

// Use environment-specific values
final apiUrl = EnvironmentConfig.apiBaseUrl;
print('API URL: $apiUrl');  // Dev: https://dev-api.kadam.com
                            // Prod: https://api.kadam.com

// Mock health data (dev only)
final healthProvider = getIt<HealthPlatformProvider>();
await healthProvider.initialize(
  useMock: EnvironmentConfig.enableMockHealthData,
);

// Logging
if (EnvironmentConfig.enableDebugLogging) {
  debugPrint('Detailed debug information...');
}

// App name
String appTitle = EnvironmentConfig.appName;
// Dev: "Kadam (Dev)"
// Prod: "Kadam"

// Analytics
if (EnvironmentConfig.enableAnalytics) {
  analytics.logEvent('user_action');
}
```

---

## 🎯 Available Configuration Options

| Property | Development | Production | Usage |
|----------|-------------|------------|-------|
| `environment` | `Environment.development` | `Environment.production` | Check current env |
| `isDevelopment` | `true` | `false` | Quick dev check |
| `isProduction` | `false` | `true` | Quick prod check |
| `apiBaseUrl` | `https://dev-api.kadam.com` | `https://api.kadam.com` | API endpoint |
| `enableDebugLogging` | `true` | `false` | Console logging |
| `enableMockHealthData` | `true` | `false` | Use mock health |
| `appName` | `Kadam (Dev)` | `Kadam` | App title |
| `firebaseTimeout` | `30s` | `10s` | Request timeout |
| `maxRetryAttempts` | `5` | `3` | Retry logic |
| `showPerformanceOverlay` | `true` | `false` | Flutter overlay |
| `enableAnalytics` | `false` | `true` | Track events |
| `verboseErrors` | `true` | `false` | Error details |

---

## 📝 Adding New Config Values

Edit `lib/config/environment.dart`:

```dart
/// Database name
static String get databaseName {
  switch (_environment) {
    case Environment.development:
      return 'kadam_dev.db';
    case Environment.production:
      return 'kadam.db';
  }
}

/// Feature flags
static bool get enableBetaFeatures => isDevelopment;

/// Payment test mode
static bool get useTestPayments => isDevelopment;
```

---

## 🔥 Firebase Configuration

### Generate Production Firebase Config

1. Install FlutterFire CLI:
```bash
dart pub global activate flutterfire_cli
```

2. Configure production project:
```bash
flutterfire configure \
  --project=kadam-prod \
  --out=lib/config/firebase_options_prod.dart \
  --platforms=android,ios
```

3. Update `main_prod.dart` if needed (already done)

### Development Firebase Config

Already configured in `lib/config/firebase_options_dev.dart`

---

## 🎨 App Flavor Configuration (Optional Advanced Setup)

For even better separation, you can configure Android/iOS flavors:

### Android (`android/app/build.gradle`)

```gradle
android {
    ...
    flavorDimensions "environment"
    
    productFlavors {
        development {
            dimension "environment"
            applicationIdSuffix ".dev"
            versionNameSuffix "-dev"
            resValue "string", "app_name", "Kadam (Dev)"
        }
        
        production {
            dimension "environment"
            resValue "string", "app_name", "Kadam"
        }
    }
}
```

### iOS (`ios/Runner/Info.plist`)

Create separate schemes in Xcode:
- Kadam-Dev (Development)
- Kadam (Production)

---

## 🧪 Testing

### Unit Tests

```dart
void main() {
  setUp(() {
    // Set environment for testing
    EnvironmentConfig.setEnvironment(Environment.development);
  });

  test('should use mock health data in dev', () {
    expect(EnvironmentConfig.enableMockHealthData, true);
  });

  test('should use real API in prod', () {
    EnvironmentConfig.setEnvironment(Environment.production);
    expect(EnvironmentConfig.apiBaseUrl, 'https://api.kadam.com');
  });
}
```

---

## ✅ Best Practices

1. **Never commit production secrets** - Use environment variables or secure storage
2. **Always test prod build before release** - Run `flutter run -t lib/main_prod.dart --release`
3. **Use different Firebase projects** - One for dev, one for prod
4. **Check environment before sensitive operations**:
   ```dart
   if (EnvironmentConfig.isProduction) {
     // Use real payment gateway
   } else {
     // Use test payment gateway
   }
   ```
5. **Log environment on startup**:
   ```dart
   print('🚀 Starting Kadam in ${EnvironmentConfig.environment.name} mode');
   ```

---

## 🐛 Debugging

### Check Current Environment

Add to your app:

```dart
// In a debug screen or settings
Text('Environment: ${EnvironmentConfig.environment.name}'),
Text('API URL: ${EnvironmentConfig.apiBaseUrl}'),
Text('Mock Health: ${EnvironmentConfig.enableMockHealthData}'),
```

### Common Issues

**Problem**: Production app using dev Firebase

**Solution**: Ensure you ran with `-t lib/main_prod.dart`

**Problem**: Can't differentiate environments

**Solution**: Check that `EnvironmentConfig.setEnvironment()` is called in main

---

## 📦 Build Scripts

Create `scripts/build.sh`:

```bash
#!/bin/bash

# Build development
echo "Building DEVELOPMENT..."
flutter build apk -t lib/main_dev.dart --debug
mv build/app/outputs/flutter-apk/app-debug.apk build/kadam-dev.apk

# Build production
echo "Building PRODUCTION..."
flutter build apk -t lib/main_prod.dart --release
mv build/app/outputs/flutter-apk/app-release.apk build/kadam-prod.apk

echo "✅ Build complete!"
echo "Dev APK: build/kadam-dev.apk"
echo "Prod APK: build/kadam-prod.apk"
```

Make executable:
```bash
chmod +x scripts/build.sh
./scripts/build.sh
```

---

## 🔐 CI/CD Integration

### GitHub Actions Example

```yaml
name: Build & Deploy

on:
  push:
    branches: [main, develop]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        
      - name: Build Development (if develop branch)
        if: github.ref == 'refs/heads/develop'
        run: flutter build apk -t lib/main_dev.dart
        
      - name: Build Production (if main branch)
        if: github.ref == 'refs/heads/main'
        run: flutter build appbundle -t lib/main_prod.dart --release
        
      - name: Upload to Play Store
        if: github.ref == 'refs/heads/main'
        # ... deployment steps
```

---

## 📚 Summary

✅ **Use separate entry points** (`main_dev.dart`, `main_prod.dart`)
✅ **Centralized configuration** (`EnvironmentConfig` class)
✅ **Different Firebase projects** (dev and prod)
✅ **Environment-specific behavior** (mocks, logging, analytics)
✅ **Clear build commands** (`-t lib/main_dev.dart` or `-t lib/main_prod.dart`)
✅ **Safe deployments** (no accidental dev→prod deploys)

Your app now has robust environment management! 🚀
