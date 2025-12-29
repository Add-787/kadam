# Health Platform Integration Guide

## Overview

The health platform system uses a factory pattern with automatic platform detection. No manual platform selection is required - the system automatically detects and uses the appropriate platform based on the device OS.

## Architecture

### Components

1. **HealthChannelFactory** (`lib/core/platform/factories/health_channel_factory.dart`)
   - Creates platform-specific health channels
   - Automatic platform detection (iOS → HealthKit, Android → Health Connect)
   - Caching to prevent recreation
   - Mock support for testing

2. **HealthPlatformService** (`lib/core/platform/services/health_platform_service.dart`)
   - Manages the single auto-detected health channel
   - Handles initialization and permission requests
   - Provides platform capabilities and status

3. **HealthPlatformProvider** (`lib/features/health/presentation/providers/health_platform_provider.dart`)
   - State management for UI
   - Exposes loading, error, and platform status
   - Methods for initialization and permissions

4. **HealthOnboardingScreen** (`lib/features/health/presentation/screens/health_onboarding_screen.dart`)
   - User-facing permission request screen
   - Shows detected platform automatically
   - No manual selection UI

## Integration Steps

### 1. Install Dependencies

Add `get_it` to your `pubspec.yaml`:

```yaml
dependencies:
  get_it: ^7.7.0
```

Run:
```bash
flutter pub get
```

### 2. Setup Dependency Injection

The DI setup is already created at `lib/core/di/injection.dart`:

```dart
import 'package:get_it/get_it.dart';
import '../platform/services/health_platform_service.dart';
import '../../features/health/presentation/providers/health_platform_provider.dart';

final getIt = GetIt.instance;

void setupDependencyInjection() {
  // Register HealthPlatformService as singleton
  getIt.registerLazySingleton<HealthPlatformService>(
    () => HealthPlatformService(),
  );
  
  // Register HealthPlatformProvider as factory
  getIt.registerFactory<HealthPlatformProvider>(
    () => HealthPlatformProvider(getIt<HealthPlatformService>()),
  );
}
```

### 3. Update main.dart

Add the health platform provider to your main.dart:

```dart
import 'core/di/injection.dart';
import 'features/health/presentation/providers/health_platform_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Setup dependency injection
  setupDependencyInjection();
  
  // ... existing auth and settings setup ...
  
  // Get health platform provider from DI
  final healthPlatformProvider = getIt<HealthPlatformProvider>();
  
  // Run the app
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: settingsProvider),
        ChangeNotifierProvider.value(value: healthPlatformProvider),
      ],
      child: const App(),
    ),
  );
}
```

### 4. Add Route for Onboarding Screen

In your app's route configuration (e.g., `app.dart`):

```dart
import 'features/health/presentation/screens/health_onboarding_screen.dart';

// In your routes:
routes: {
  '/onboarding': (context) => const HealthOnboardingScreen(),
  '/home': (context) => const HomeScreen(),
  // ... other routes
}
```

### 5. Navigate to Onboarding

When the user needs to setup health tracking (e.g., first launch or from settings):

```dart
Navigator.of(context).pushNamed('/onboarding');
```

## User Flow

1. **App Launch** → User navigates to health onboarding
2. **Auto-Detection** → System detects platform (HealthKit on iOS, Health Connect on Android)
3. **Display Platform** → Shows detected platform name and icon
4. **Request Permissions** → User taps "Grant Permissions"
5. **Platform Dialog** → Native permission dialog appears
6. **Grant Access** → User grants permissions
7. **Ready** → System confirms ready, user continues to app

## Platform-Specific Behavior

### iOS (HealthKit)
- Automatically available on iOS 8.0+
- No installation required
- Permissions managed through iOS Settings
- Data aggregated from Apple Health

### Android (Health Connect)
- Available on Android 9+ (API 28+)
- May require installation from Play Store
- Permissions managed through Health Connect app
- Data aggregated from Samsung Health, Google Fit, Fitbit, etc.

### Debug Mode (Mock)
- Automatically used when no real platform available
- Generates realistic mock data
- Configurable for testing different scenarios

## Usage in Other Screens

Access the platform provider in any screen:

```dart
class HealthDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<HealthPlatformProvider>(
      builder: (context, healthProvider, child) {
        if (!healthProvider.isReady) {
          return Center(
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/onboarding'),
              child: Text('Setup Health Tracking'),
            ),
          );
        }
        
        // Platform is ready - show health data
        return Column(
          children: [
            Text('Connected to: ${healthProvider.platformName}'),
            Text('Status: ${healthProvider.statusMessage}'),
            // ... health data widgets
          ],
        );
      },
    );
  }
}
```

## Checking Platform Status

```dart
final provider = context.read<HealthPlatformProvider>();

// Initialize on app start
await provider.initialize();

// Check status
if (provider.isReady) {
  // Platform ready - can access health data
} else if (provider.needsPermissions) {
  // Need to request permissions
  await provider.requestPermissions();
} else {
  // No platform available or error
  print(provider.error);
}

// Check specific data type support
if (provider.supportsDataType('steps')) {
  // Can read steps data
}
```

## Error Handling

The provider handles errors automatically and exposes them through the `error` property:

```dart
if (provider.error != null) {
  // Show error to user
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(provider.error!)),
  );
}
```

## Testing

For testing, use the mock platform:

```dart
// In test setup
await healthProvider.initialize(useMock: true);

// Mock will generate realistic test data
final steps = await mockChannel.getTodaySteps();
// Returns: 7500 (default mock value)
```

## Next Steps

1. **Implement Apple Health Channel** - Currently has a stub, needs full HealthKit implementation
2. **Add More Data Types** - Extend beyond steps, distance, calories, heart rate
3. **Background Sync** - Setup periodic data sync
4. **Data Caching** - Cache health data locally for offline access
5. **Analytics** - Track platform detection and permission grant rates

## Files Created

- ✅ `lib/core/platform/factories/health_channel_factory.dart`
- ✅ `lib/core/platform/services/health_platform_service.dart`
- ✅ `lib/features/health/presentation/providers/health_platform_provider.dart`
- ✅ `lib/features/health/presentation/screens/health_onboarding_screen.dart`
- ✅ `lib/core/di/injection.dart`
- ✅ `lib/core/platform/models/platform_capability.dart` (updated with icon extension)

## Files Pending

- ⏳ `lib/core/platform/channels/apple_health_channel.dart` (stub exists, needs implementation)
- ⏳ `ios/Runner/HealthKitPlugin.swift` (iOS native code)
- ⏳ Update `main.dart` with provider setup
- ⏳ Add route configuration

## References

- [Health Connect Documentation](https://developer.android.com/health-and-fitness/guides/health-connect)
- [HealthKit Documentation](https://developer.apple.com/documentation/healthkit)
