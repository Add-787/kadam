# Navigation Architecture

## Overview

The Kadam Mobile app uses a **guard-based navigation system** with a centralized `NavigationHelper` utility class to handle all routing logic. This architecture provides clean separation of concerns, consistent navigation patterns, and testable route protection.

## Core Components

### 1. Route Guards (`lib/core/routes/guards/`)

Guards are reusable classes that check conditions before allowing navigation:

#### `RouteGuard` (Interface)
```dart
abstract class RouteGuard {
  Future<bool> canActivate(BuildContext context);
  String get redirectRoute;
}
```

#### `AuthGuard`
- **Purpose**: Checks if user is authenticated
- **Check**: Uses `AuthProvider.isAuthenticated`
- **Redirect**: `AppRoutes.login`

#### `OnboardingGuard`
- **Purpose**: Checks if user has completed health onboarding
- **Check**: Reads from `SharedPreferences` ('health_onboarding_completed')
- **Redirect**: `AppRoutes.healthOnboarding`
- **Helper Methods**:
  - `markHealthOnboardingComplete()` - Mark onboarding as complete
  - `resetOnboarding()` - Clear completion status (for logout)
  - `isAllOnboardingComplete()` - Check status without context

### 2. NavigationHelper (`lib/core/utils/navigation_helper.dart`)

Centralized utility class that encapsulates all navigation logic using guards.

#### Methods

##### `navigateAfterAuth(BuildContext, {bool isNewUser})`
**Purpose**: Navigate after successful authentication (login or signup)

**Logic**:
- New users → Always route to `healthOnboarding`
- Existing users → Check `OnboardingGuard.canActivate()`
  - Complete → Route to `home`
  - Incomplete → Route to `healthOnboarding`

**Used in**:
- `LoginScreen._navigateAfterLogin()`
- `SignUpScreen._navigateAfterSignup()`

##### `navigateToProtectedRoute(BuildContext, String route)`
**Purpose**: Navigate to a route that requires authentication and onboarding

**Logic**:
1. Check `AuthGuard` → If fails, redirect to login
2. Check `OnboardingGuard` → If fails, redirect to onboarding
3. If both pass, navigate to requested route

**Use case**: For future protected routes like settings, profile, etc.

##### `determineInitialRoute(BuildContext)`
**Purpose**: Determine which route to show when app starts

**Logic**:
1. Check `AuthGuard` → If not authenticated, return `login`
2. Check `OnboardingGuard` → If not complete, return `healthOnboarding`
3. If both pass, return `home`

**Used in**:
- `App._determineInitialRoute()` (app initialization)

##### `handleLogout(BuildContext)`
**Purpose**: Handle user logout

**Logic**:
1. Reset onboarding status using `OnboardingGuard.resetOnboarding()`
2. Navigate to login with `pushNamedAndRemoveUntil`

**Use case**: For future logout functionality

## User Flows

### 1. New User Flow
```
Signup → navigateAfterAuth(isNewUser: true)
       → healthOnboarding
       → markHealthOnboardingComplete()
       → home
```

### 2. Returning User Flow (Complete Onboarding)
```
Login → navigateAfterAuth(isNewUser: false)
      → OnboardingGuard.canActivate() → true
      → home
```

### 3. Returning User Flow (Incomplete Onboarding)
```
Login → navigateAfterAuth(isNewUser: false)
      → OnboardingGuard.canActivate() → false
      → healthOnboarding
      → markHealthOnboardingComplete()
      → home
```

### 4. App Start Flow
```
App Init → determineInitialRoute()
        → Check AuthGuard → If not authenticated → login
        → Check OnboardingGuard → If incomplete → healthOnboarding
        → If both pass → home
```

## Implementation Details

### App Initialization (`lib/app.dart`)

```dart
class _AppState extends State<App> {
  String? _initialRoute;

  @override
  void initState() {
    super.initState();
    _determineInitialRoute();
  }

  Future<void> _determineInitialRoute() async {
    // Use NavigationHelper to determine initial route based on guards
    final route = await NavigationHelper.determineInitialRoute(context);

    if (mounted) {
      setState(() {
        _initialRoute = route;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading while determining initial route
    if (_initialRoute == null) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    // ... rest of build method
  }
}
```

### Login Screen

```dart
Future<void> _navigateAfterLogin() async {
  if (!mounted) return;

  // Use NavigationHelper to determine route based on onboarding status
  await NavigationHelper.navigateAfterAuth(context, isNewUser: false);
}
```

### Signup Screen

```dart
Future<void> _navigateAfterSignup() async {
  if (!mounted) return;

  // Use NavigationHelper for new user navigation
  await NavigationHelper.navigateAfterAuth(context, isNewUser: true);
}
```

### Onboarding Screen

```dart
Future<void> _completeOnboarding() async {
  // Mark onboarding as complete
  await OnboardingGuard.markHealthOnboardingComplete();

  if (mounted) {
    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  }
}
```

## Data Flow

### Onboarding Status Persistence

```
OnboardingGuard ↔ SharedPreferences
       ↓
Key: 'health_onboarding_completed'
Value: true/false (boolean)
```

**Write Operations**:
- `OnboardingGuard.markHealthOnboardingComplete()` - Set to `true`
- `OnboardingGuard.resetOnboarding()` - Set to `false` (logout)

**Read Operations**:
- `OnboardingGuard.canActivate(context)` - Returns bool
- `OnboardingGuard.isAllOnboardingComplete()` - Returns bool (no context needed)

## Benefits

### 1. **Centralized Logic**
All navigation decisions are in `NavigationHelper`, making the codebase easier to maintain and test.

### 2. **Reusable Guards**
Guards can be used anywhere in the app for consistent route protection.

### 3. **Single Source of Truth**
`SharedPreferences` (via `OnboardingGuard`) is the single source of truth for onboarding status.

### 4. **Testability**
- Guards can be unit tested independently
- `NavigationHelper` methods can be tested with mock guards
- No tight coupling to UI components

### 5. **Consistency**
All navigation uses the same patterns - no direct provider checks, no mixed approaches.

### 6. **Extensibility**
Easy to add new guards (e.g., `SubscriptionGuard`, `HealthPermissionGuard`) without changing existing code.

## Future Enhancements

### 1. Route Middleware
Add automatic guard checking to `AppRoutes.onGenerateRoute()`:

```dart
Route? onGenerateRoute(RouteSettings settings) {
  // Check guards for protected routes
  if (protectedRoutes.contains(settings.name)) {
    // Run guards automatically
  }
  // ... route generation logic
}
```

### 2. Additional Guards

- **`SubscriptionGuard`**: Check premium subscription status
- **`HealthPermissionGuard`**: Verify health platform is connected and authorized
- **`ProfileCompleteGuard`**: Ensure user profile is complete
- **`FirstTimeGuard`**: Show welcome screens for first-time users

### 3. Guard Composition

Allow multiple guards per route:

```dart
@RouteConfig(
  path: '/health-details',
  guards: [AuthGuard(), OnboardingGuard(), HealthPermissionGuard()],
)
```

### 4. Navigation Analytics

Add tracking to `NavigationHelper` methods:

```dart
static Future<void> navigateAfterAuth(...) async {
  analytics.logEvent('navigation', {
    'source': 'auth',
    'destination': route,
    'isNewUser': isNewUser,
  });
  // ... navigation logic
}
```

## Testing Strategy

### Unit Tests

```dart
// Test guards
test('AuthGuard returns false when not authenticated', () async {
  final guard = AuthGuard();
  final result = await guard.canActivate(mockContext);
  expect(result, false);
});

// Test NavigationHelper
test('determineInitialRoute returns login for unauthenticated user', () async {
  final route = await NavigationHelper.determineInitialRoute(mockContext);
  expect(route, AppRoutes.login);
});

// Test SharedPreferences persistence
test('markHealthOnboardingComplete sets flag in SharedPreferences', () async {
  await OnboardingGuard.markHealthOnboardingComplete();
  final prefs = await SharedPreferences.getInstance();
  expect(prefs.getBool('health_onboarding_completed'), true);
});
```

### Integration Tests

```dart
testWidgets('New user signup flow navigates to onboarding', (tester) async {
  // 1. Navigate to signup
  // 2. Complete signup form
  // 3. Verify navigation to healthOnboarding
  // 4. Complete onboarding
  // 5. Verify navigation to home
});
```

## Troubleshooting

### Issue: Initial route not determined correctly

**Check**:
1. `SharedPreferences` is initialized before checking guards
2. `AuthProvider` is available in the widget tree
3. `initState` calls `_determineInitialRoute()`

### Issue: User stuck in onboarding loop

**Check**:
1. `OnboardingGuard.markHealthOnboardingComplete()` is called
2. `SharedPreferences` write operation succeeds
3. No exceptions during guard checks

**Debug**:
```dart
// Add debug logs
debugPrint('🔍 [OnboardingGuard] Status: ${await prefs.getBool("health_onboarding_completed")}');
```

### Issue: Navigation not working after logout

**Check**:
1. `OnboardingGuard.resetOnboarding()` is called during logout
2. Auth state is properly cleared
3. App reinitializes with fresh state

## Summary

The guard-based navigation architecture provides:
- ✅ **Clean separation of concerns** - Navigation logic separated from UI
- ✅ **Consistent patterns** - All routes use the same guard system
- ✅ **Single source of truth** - SharedPreferences for onboarding status
- ✅ **Testability** - Guards and helpers are independently testable
- ✅ **Extensibility** - Easy to add new guards and navigation patterns
- ✅ **Maintainability** - Centralized logic in `NavigationHelper`

This architecture scales well as the app grows and provides a solid foundation for complex navigation requirements.
