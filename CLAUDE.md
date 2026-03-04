# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Kadam is a cross-platform step tracking mobile app built with Flutter/Dart. Users track daily steps, connect with friends, and compete on leaderboards. The Flutter app lives in `mobile-app/` — all Flutter commands must be run from there.

## Commands

All commands run from `mobile-app/`:

```bash
# Dependencies & code generation
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs   # regenerate injection.config.dart
flutter pub run build_runner watch --delete-conflicting-outputs   # watch mode

# Develop & test
flutter run                          # run on connected device/emulator
flutter test                         # run all tests
flutter test test/home_page_test.dart  # run a single test file

# Quality
flutter analyze                      # static analysis (lint)
flutter format lib/                  # format code

# Build
flutter build apk --release          # Android release APK
flutter build ios                    # iOS build
```

## Architecture

### Feature-Based Clean Architecture

Features in `lib/features/` vary in complexity. `auth`, `steps`, and `history` have full clean architecture layers:

```
features/{feature}/
├── data/
│   ├── datasources/    # Firebase / HealthKit / SharedPreferences access
│   └── repositories/   # Repository implementations
├── domain/
│   └── repositories/   # Abstract repository contracts
└── presentation/
    ├── bloc/           # BLoC: events, states, and logic
    └── pages/          # UI widgets and pages
```

`home`, `friends`, `leaderboards`, and `settings` are currently presentation-only (no data/domain layers).

Shared infrastructure lives in `lib/core/`:
- `config/router.dart` — GoRouter setup with auth guard
- `config/injection.dart` + `injection.config.dart` — GetIt/Injectable DI (generated)
- `config/work_manager_config.dart` — background sync task registration
- `services/firestore_service.dart` — low-level Firestore operations
- `models/` — shared data models (`UserModel`, `DailyStepRecord`)
- `presentation/` — shared theme and widgets

### State Management (BLoC)

Strict unidirectional data flow: **View → Event → BLoC → Repository/Service → State → View**.

BLoCs are registered via `@injectable` and injected through GetIt. When adding a new injectable class, re-run `build_runner build` to regenerate `injection.config.dart`.

### Navigation (GoRouter)

Routes are declared in `core/config/router.dart`. Auth state is guarded via `GoRouterRefreshStream` on the Firebase auth stream — unauthenticated users are redirected to `/sign-in`. Bottom nav tabs (`/home`, `/friends`, `/leaderboards`, `/settings`) use `StatefulShellRoute` to preserve tab state.

### Step Tracking Logic

The core innovation is reboot-proof delta accumulation:
1. Each sensor tick calculates a delta from the previous reading and adds it to a SharedPreferences cumulative total.
2. A negative delta (sensor reset after reboot) is treated as the new delta directly.
3. `Workmanager` runs a background task that syncs the local cumulative total to Firestore hourly and resets the counter on day rollover.
4. `StepRepository.getStepsForDate(date)` transparently returns live sensor data for today or Firestore historical data for past dates.

### Firebase / Backend

- **Auth**: Firebase Auth — email/password and Google Sign-In fully implemented; Apple Sign-In is not present.
- **Firestore schema**:
  - `users/{userId}` — profile + `daily_step_goal`
  - `users/{userId}/daily_steps/{yyyy-MM-dd}` — per-day step records (used by `StepRepositoryImpl`)
  - `dailySteps/{id}` — top-level collection used by `FirestoreService` (inconsistency in codebase)
  - `groups/{groupId}` — groups with `members/` and `leaderboards/` subcollections
- **Health data**: `health` package (Health Connect on Android 14+, HealthKit on iOS); `pedometer` as fallback.
- **Local persistence**: SharedPreferences for cumulative step state and daily goal cache.

## CI/CD

Pushing to `dev` (with changes under `mobile-app/`) triggers the GitHub Actions workflow (`.github/workflows/android-dev.yaml`) which builds a release APK and distributes it via Firebase App Distribution to the `developers` and `testers` groups.

Required secrets: `ANDROID_KEYSTORE_BASE64`, `GOOGLE_SERVICES_JSON_BASE64`, `KEY_STORE_PASSWORD`, `KEY_PASSWORD`, `KEY_ALIAS`, `FIREBASE_APP_ID`, `FIREBASE_SERVICE_ACCOUNT_KEY`.

Local development requires `android/app/google-services.json` (not committed; decode from the base64 secret or obtain from Firebase console).
