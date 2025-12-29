# Navigation Quick Reference

Quick reference for common navigation patterns in Kadam Mobile.

## 🚀 Common Tasks

### After Login
```dart
await NavigationHelper.navigateAfterAuth(context, isNewUser: false);
```

### After Signup
```dart
await NavigationHelper.navigateAfterAuth(context, isNewUser: true);
```

### Logout
```dart
// 1. Sign out from Firebase
await context.read<AuthProvider>().signOut();

// 2. Clear onboarding & navigate to login
if (mounted) {
  await NavigationHelper.handleLogout(context);
}
```

### Determine Initial Route (App Start)
```dart
final route = await NavigationHelper.determineInitialRoute(context);
setState(() => _initialRoute = route);
```

### Navigate to Protected Route
```dart
await NavigationHelper.navigateToProtectedRoute(context, AppRoutes.settings);
```

## 🛡️ Guard Usage

### Check if User is Authenticated
```dart
final authGuard = AuthGuard();
final isAuthenticated = await authGuard.canActivate(context);
```

### Check if Onboarding is Complete
```dart
final onboardingGuard = OnboardingGuard();
final isComplete = await onboardingGuard.canActivate(context);
```

### Mark Onboarding Complete
```dart
await OnboardingGuard.markHealthOnboardingComplete();
```

### Reset Onboarding (for Logout)
```dart
await OnboardingGuard.resetOnboarding();
```

### Check Onboarding Status (No Context)
```dart
final isComplete = await OnboardingGuard.isAllOnboardingComplete();
```

## 📋 Flow Patterns

### New User Flow
```
Signup → navigateAfterAuth(isNewUser: true) 
       → Onboarding 
       → markComplete() 
       → Home
```

### Existing User (Complete)
```
Login → navigateAfterAuth(isNewUser: false) 
      → canActivate() == true 
      → Home
```

### Existing User (Incomplete)
```
Login → navigateAfterAuth(isNewUser: false) 
      → canActivate() == false 
      → Onboarding
```

### App Restart
```
App Start → determineInitialRoute()
          ├─ Not auth → Login
          ├─ Auth, no onboarding → Onboarding
          └─ Auth, with onboarding → Home
```

## 🔑 Key Files

| File | Purpose |
|------|---------|
| `lib/core/utils/navigation_helper.dart` | All navigation logic |
| `lib/core/routes/guards/auth_guard.dart` | Auth checking |
| `lib/core/routes/guards/onboarding_guard.dart` | Onboarding status |
| `lib/core/routes/route_guard.dart` | Guard interface |
| `docs/navigation_architecture.md` | Full documentation |
| `docs/navigation_implementation_summary.md` | Implementation details |

## ⚠️ Important Notes

1. **Always check `mounted`** before navigating:
   ```dart
   if (!mounted) return;
   await NavigationHelper.navigateAfterAuth(context);
   ```

2. **Onboarding status** is stored in `SharedPreferences` with key:
   - `'health_onboarding_completed'` - boolean

3. **On logout**, always reset onboarding:
   ```dart
   await OnboardingGuard.resetOnboarding();
   ```

4. **Guards return bool**:
   - `true` = Can navigate
   - `false` = Should redirect to `guard.redirectRoute`

5. **NavigationHelper handles context checks** internally, but still good practice to check `mounted` before calling.

## 🧪 Testing Checklist

- [ ] New user signup → onboarding → home
- [ ] Login with incomplete onboarding → onboarding → home
- [ ] Login with complete onboarding → home
- [ ] App restart not authenticated → login
- [ ] App restart authenticated, incomplete → onboarding
- [ ] App restart authenticated, complete → home
- [ ] Logout → reset onboarding → login
- [ ] Logout → login → should see onboarding again

## 🐛 Troubleshooting

### User stuck in onboarding loop
**Check**: Is `markHealthOnboardingComplete()` being called?
```dart
// Add debug logging
debugPrint('📍 [Onboarding] Marking complete...');
await OnboardingGuard.markHealthOnboardingComplete();
final prefs = await SharedPreferences.getInstance();
debugPrint('📍 [Onboarding] Status: ${prefs.getBool("health_onboarding_completed")}');
```

### Wrong initial route on app start
**Check**: Is `determineInitialRoute()` being awaited?
```dart
// Make sure setState is inside the async callback
Future<void> _determineInitialRoute() async {
  final route = await NavigationHelper.determineInitialRoute(context);
  if (mounted) {  // ⚠️ Important!
    setState(() => _initialRoute = route);
  }
}
```

### Onboarding not reset on logout
**Check**: Is `handleLogout()` being called?
```dart
await context.read<AuthProvider>().signOut();
if (mounted) {
  await NavigationHelper.handleLogout(context);  // ⚠️ This resets onboarding
}
```

## 💡 Pro Tips

1. Use `NavigationHelper` methods instead of direct navigation
2. Don't check providers directly for navigation decisions
3. Always use guards for route protection
4. Centralize navigation logic - don't duplicate
5. Add debug logs when debugging navigation issues
6. Test all flows after making navigation changes

## 📚 More Information

- Full architecture guide: `docs/navigation_architecture.md`
- Implementation summary: `docs/navigation_implementation_summary.md`
- Logout examples: `lib/core/routes/guards/logout_examples.dart`
- Guard examples: `lib/core/routes/guards/guard_usage_examples.dart`
