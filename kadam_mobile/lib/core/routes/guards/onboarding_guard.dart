import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../route_guard.dart';
import '../app_routes.dart';

/// Guard that checks if the user has completed onboarding
/// Redirects to health onboarding if not completed
class OnboardingGuard implements RouteGuard {
  // Key used to store onboarding completion status
  static const String _onboardingKey = 'onboarding_completed';

  @override
  Future<bool> canActivate(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    // Check if general onboarding is completed
    final hasCompletedOnboarding = prefs.getBool(_onboardingKey) ?? false;

    final isComplete = hasCompletedOnboarding;

    if (!isComplete) {
      debugPrint(
          '🛡️ [OnboardingGuard] Access denied - Onboarding not completed');
      debugPrint('   General onboarding: $hasCompletedOnboarding');
    } else {
      debugPrint('🛡️ [OnboardingGuard] Access granted - Onboarding completed');
    }

    return isComplete;
  }

  @override
  String get redirectRoute => AppRoutes.onboarding;

  @override
  String get failureMessage => 'Please complete onboarding to continue';

  /// Mark general onboarding as completed
  static Future<void> markOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
    debugPrint('✅ [OnboardingGuard] General onboarding marked as complete');
  }


  /// Mark both onboarding steps as completed
  static Future<void> markAllOnboardingComplete() async {
    await markOnboardingComplete();
  }

  /// Reset onboarding status (useful for testing or logout)
  static Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_onboardingKey);
    debugPrint('🔄 [OnboardingGuard] Onboarding status reset');
  }

  /// Check if general onboarding is completed (without guard)
  static Future<bool> isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingKey) ?? false;
  }


  /// Check if all onboarding is completed (without guard)
  static Future<bool> isAllOnboardingComplete() async {
    final general = await isOnboardingComplete();
    return general;
  }
}
