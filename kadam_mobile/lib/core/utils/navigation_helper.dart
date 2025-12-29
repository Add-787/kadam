import 'package:flutter/material.dart';
import '../routes/app_routes.dart';
import '../routes/guards/auth_guard.dart';
import '../routes/guards/onboarding_guard.dart';

/// Navigation helpers that use guards to determine routing
class NavigationHelper {
  NavigationHelper._();

  /// Navigate after successful authentication (login or signup)
  /// Checks onboarding status and routes accordingly
  static Future<void> navigateAfterAuth(
    BuildContext context, {
    bool isNewUser = false,
  }) async {
    if (!context.mounted) return;

    if (isNewUser) {
      // New users always go to onboarding
      debugPrint('✅ [Navigation] New user - navigating to onboarding');
      Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding);
      return;
    }

    // Existing users - check onboarding status
    final onboardingGuard = OnboardingGuard();
    final hasCompletedOnboarding = await onboardingGuard.canActivate(context);

    if (!context.mounted) return;

    if (hasCompletedOnboarding) {
      debugPrint('✅ [Navigation] Onboarding complete - navigating to home');
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    } else {
      debugPrint(
          '⚠️ [Navigation] Onboarding incomplete - navigating to onboarding');
      Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding);
    }
  }

  /// Navigate to a protected route - checks auth and onboarding guards
  static Future<void> navigateToProtectedRoute(
    BuildContext context,
    String route,
  ) async {
    if (!context.mounted) return;

    // Check auth guard first
    final authGuard = AuthGuard();
    final isAuthenticated = await authGuard.canActivate(context);

    if (!isAuthenticated) {
      debugPrint('🛡️ [Navigation] Not authenticated - redirecting to login');
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed(authGuard.redirectRoute);
      }
      return;
    }

    // Check onboarding guard
    final onboardingGuard = OnboardingGuard();
    final hasCompletedOnboarding = await onboardingGuard.canActivate(context);

    if (!hasCompletedOnboarding) {
      debugPrint(
          '🛡️ [Navigation] Onboarding incomplete - redirecting to onboarding');
      if (context.mounted) {
        Navigator.of(context)
            .pushReplacementNamed(onboardingGuard.redirectRoute);
      }
      return;
    }

    // All guards passed - navigate to route
    if (context.mounted) {
      Navigator.of(context).pushNamed(route);
    }
  }

  /// Determine initial route based on auth and onboarding status
  static Future<String> determineInitialRoute(BuildContext context) async {
    // Check auth guard first
    final authGuard = AuthGuard();
    final isAuthenticated = await authGuard.canActivate(context);

    if (!isAuthenticated) {
      debugPrint('🔍 [Navigation] Initial route: login (not authenticated)');
      return AppRoutes.login;
    }

    // Check onboarding guard
    final onboardingGuard = OnboardingGuard();
    final hasCompletedOnboarding = await onboardingGuard.canActivate(context);

    if (!hasCompletedOnboarding) {
      debugPrint('🔍 [Navigation] Initial route: onboarding (incomplete)');
      return AppRoutes.onboarding;
    }

    debugPrint('🔍 [Navigation] Initial route: home (all checks passed)');
    return AppRoutes.home;
  }

  /// Handle logout - clears onboarding status and navigates to login
  static Future<void> handleLogout(BuildContext context) async {
    // Reset onboarding status on logout
    await OnboardingGuard.resetOnboarding();

    if (context.mounted) {
      debugPrint('👋 [Navigation] Logout - navigating to login');
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.login,
        (route) => false,
      );
    }
  }
}
