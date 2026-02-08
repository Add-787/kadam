import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/injection.dart';
import '../../../../core/presentation/theme/app_colors.dart';
import '../../../../core/presentation/widgets/kadam_button.dart';
import '../../../../core/presentation/widgets/kadam_text_field.dart';
import '../../../../core/presentation/widgets/social_login_button.dart';
import '../bloc/sign_up_bloc.dart';
import '../bloc/sign_up_event.dart';
import '../bloc/sign_up_state.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<SignUpBloc>(),
      child: const SignUpView(),
    );
  }
}

class SignUpView extends StatelessWidget {
  const SignUpView({super.key});

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
        child: BlocListener<SignUpBloc, SignUpState>(
          listener: (context, state) {
            if (state.status == SignUpStatus.failure) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(
                      state.errorMessage ?? 'Sign Up Failed',
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.red.shade900,
                  ),
                );
            }
            if (state.status == SignUpStatus.success) {
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
                    'Sign up to your account',
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
                    'Join our journey! Select method to sign up',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: AppColors.subtext),
                  ),
                  const SizedBox(height: 48),

                  KadamTextField(
                    hint: 'Enter a username',
                    icon: Icons.person_outline_rounded,
                    onChanged: (value) => context.read<SignUpBloc>().add(
                      SignUpUsernameChanged(value),
                    ),
                  ),
                  const SizedBox(height: 16),

                  KadamTextField(
                    hint: 'Enter your mail',
                    icon: Icons.mail_outline_rounded,
                    onChanged: (value) =>
                        context.read<SignUpBloc>().add(SignUpEmailChanged(value)),
                  ),
                  const SizedBox(height: 16),

                  KadamTextField(
                    hint: 'Enter your password',
                    icon: Icons.lock_outline_rounded,
                    obscureText: true,
                    onChanged: (value) => context.read<SignUpBloc>().add(
                      SignUpPasswordChanged(value),
                    ),
                  ),
                  const SizedBox(height: 16),

                  KadamTextField(
                    hint: 'Confirm password',
                    icon: Icons.lock_outline_rounded,
                    obscureText: true,
                    onChanged: (value) => context.read<SignUpBloc>().add(
                      SignUpConfirmPasswordChanged(value),
                    ),
                  ),
                  const SizedBox(height: 32),

                  BlocBuilder<SignUpBloc, SignUpState>(
                    builder: (context, state) {
                      return KadamButton(
                        label: 'Sign up',
                        isLoading: state.status == SignUpStatus.loading,
                        onPressed: () => context.read<SignUpBloc>().add(
                          const SignUpSubmitted(),
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
                          onPressed: () => context.read<SignUpBloc>().add(
                            const SignUpGooglePressed(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SocialLoginButton(
                          icon: Icons.apple,
                          label: 'Apple',
                          onPressed: () => context.read<SignUpBloc>().add(
                            const SignUpApplePressed(),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 48),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Have an account? ",
                        style: TextStyle(color: AppColors.subtext),
                      ),
                      GestureDetector(
                        onTap: () => context.go('/sign-in'),
                        child: const Text(
                          'Sign in',
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
