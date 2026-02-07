import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'package:injectable/injectable.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/pages/sign_in_page.dart';
import '../../features/auth/presentation/pages/sign_up_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import 'injection.dart';

final router = GoRouter(
  initialLocation: '/sign-in',
  refreshListenable: GoRouterRefreshStream(getIt<AuthRepository>().userStream),
  redirect: (context, state) {
    final isLoggedIn = getIt<AuthRepository>().currentUser != null;
    final isLoggingIn =
        state.uri.toString() == '/sign-in' || state.uri.toString() == '/sign-up';

    // If NOT logged in, and trying to go somewhere else -> force login
    if (!isLoggedIn && !isLoggingIn) return '/sign-in';

    // If ALREADY logged in, and trying to go to login/signup -> force home
    if (isLoggedIn && isLoggingIn) return '/home';

    return null; // No redirect needed
  },
  routes: [
    GoRoute(
      path: '/sign-in',
      builder: (context, state) => const SignInPage(),
    ),
    GoRoute(
      path: '/sign-up',
      builder: (context, state) => const SignUpPage(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomePage(),
    ),
  ],
);

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  late final StreamSubscription _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
