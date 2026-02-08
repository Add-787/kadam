import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'package:injectable/injectable.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/pages/sign_in_page.dart';
import '../../features/auth/presentation/pages/sign_up_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/history/presentation/pages/history_page.dart';
import '../../features/friends/presentation/pages/friends_page.dart';
import '../../features/leaderboards/presentation/pages/leaderboards_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../presentation/pages/main_layout.dart';
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
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          MainLayout(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomePage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/friends',
              builder: (context, state) => const FriendsPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/leaderboards',
              builder: (context, state) => const LeaderboardsPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsPage(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/history',
      builder: (context, state) => const HistoryPage(),
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
