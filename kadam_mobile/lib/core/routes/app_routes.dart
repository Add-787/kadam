import 'package:flutter/material.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/auth/presentation/screens/signout_screen.dart';
import '../../features/home/main_scaffold.dart';
import '../../features/health/presentation/screens/onboarding_screen.dart';

/// Application routes configuration
class AppRoutes {
  // Private constructor to prevent instantiation
  AppRoutes._();

  // Route names
  static const String home = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String signout = '/signout';
  static const String onboarding = '/onboarding';

  // Route generator
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const MainScaffold(),
        );

      case login:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const LoginScreen(),
        );

      case signup:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const SignUpScreen(),
        );

      case signout:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const SignOutScreen(),
        );

      case onboarding:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const OnboardingScreen(),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Route not found: ${settings.name}'),
            ),
          ),
        );
    }
  }
}
