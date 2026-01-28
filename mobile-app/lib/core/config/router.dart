import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/sign_in_page.dart';
import '../../features/auth/presentation/pages/sign_up_page.dart';
import '../../features/home/presentation/pages/home_page.dart';

final router = GoRouter(
  initialLocation: '/sign-in',
  routes: [
    GoRoute(path: '/sign-in', builder: (context, state) => const SignInPage()),
    GoRoute(path: '/sign-up', builder: (context, state) => const SignUpPage()),
    GoRoute(path: '/home', builder: (context, state) => const HomePage()),
  ],
);
