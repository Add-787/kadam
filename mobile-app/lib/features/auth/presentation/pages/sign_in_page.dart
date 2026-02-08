import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/injection.dart';
import '../bloc/sign_in_bloc.dart';
import '../bloc/sign_in_event.dart';
import '../bloc/sign_in_state.dart';
import '../../../../core/presentation/theme/app_colors.dart';
import '../../../../core/presentation/widgets/kadam_button.dart';
import '../../../../core/presentation/widgets/kadam_text_field.dart';
import '../../../../core/presentation/widgets/social_login_button.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Provide the BLoC to the subtree
    return BlocProvider(
      create: (context) => getIt<SignInBloc>(),
      child: const SignInView(),
    );
  }
}

class SignInView extends StatelessWidget {
  const SignInView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.6), // Light burst from top center
            radius: 1.2,
            colors: [
              Color(0xFF2C2C20), // Subtle yellow tint at top
              AppColors.background,
            ],
          ),
        ),
        child: BlocListener<SignInBloc, SignInState>(
          listener: (context, state) {
            if (state.status == SignInStatus.failure) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(
                      state.errorMessage ?? 'Authentication Failure',
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.red.shade900,
                  ),
                );
            }
            if (state.status == SignInStatus.success) {
              // Save userId to SharedPreferences for background tasks
              final userId = getIt<FirebaseAuth>().currentUser?.uid;
              if (userId != null) {
                SharedPreferences.getInstance().then((prefs) {
                  prefs.setString('user_id', userId);
                });
              }
              // Navigate to Home
              context.go('/home');
            }
          },
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 60),
                  // Logo Area
                  const Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.bolt,
                          color: AppColors.primary,
                          size: 64, // Larger icon
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Kadam',
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: -1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Title
                  const Text(
                    'Sign in to your account',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Welcome back! Select method to log in',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: AppColors.subtext),
                  ),
                  const SizedBox(height: 48),

                  // Email Field
                  KadamTextField(
                    hint: 'Enter your mail',
                    icon: Icons.mail_outline_rounded,
                    onChanged: (value) =>
                        context.read<SignInBloc>().add(SignInEmailChanged(value)),
                  ),
                  const SizedBox(height: 16),

                  // Password Field
                  KadamTextField(
                    hint: 'Enter your password',
                    icon: Icons.lock_outline_rounded,
                    obscureText: true,
                    onChanged: (value) => context.read<SignInBloc>().add(
                      SignInPasswordChanged(value),
                    ),
                  ),

                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.subtext,
                      ),
                      child: const Text(
                        'Forgot password?',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Log In Button
                  BlocBuilder<SignInBloc, SignInState>(
                    builder: (context, state) {
                      return KadamButton(
                        label: 'Log In',
                        isLoading: state.status == SignInStatus.loading,
                        onPressed: () => context.read<SignInBloc>().add(
                          const SignInSubmitted(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 40),

                  // Divider
                  const Row(
                    children: [
                      Expanded(
                          child: Divider(
                              color: AppColors.accent, thickness: 1)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Or continue with',
                          style: TextStyle(color: AppColors.subtext, fontSize: 12),
                        ),
                      ),
                      Expanded(
                          child: Divider(
                              color: AppColors.accent, thickness: 1)),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Social Buttons
                  Row(
                    children: [
                      Expanded(
                        child: SocialLoginButton(
                          icon: Icons.g_mobiledata,
                          label: 'Google',
                          onPressed: () {
                            context.read<SignInBloc>().add(
                              const SignInGooglePressed(),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SocialLoginButton(
                          icon: Icons.apple,
                          label: 'Apple',
                          onPressed: () {
                            context.read<SignInBloc>().add(
                              const SignInApplePressed(),
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 48),

                  // Footer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(color: AppColors.subtext),
                      ),
                      GestureDetector(
                        onTap: () => context.go('/sign-up'),
                        child: const Text(
                          'Sign up',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
