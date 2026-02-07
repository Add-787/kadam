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
      body: BlocListener<SignInBloc, SignInState>(
        listener: (context, state) {
          if (state.status == SignInStatus.failure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? 'Authentication Failure'),
                ),
              );
          }
          if (state.status == SignInStatus.success) {
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
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bolt, color: AppColors.primary, size: 40),
                      SizedBox(width: 8),
                      Text(
                        'Kadam',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
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
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Welcome back! Select method to log in',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: AppColors.hint),
                ),
                const SizedBox(height: 40),

                // Email Field
                KadamTextField(
                  hint: 'Enter your mail',
                  icon: Icons.email_outlined,
                  onChanged: (value) =>
                      context.read<SignInBloc>().add(SignInEmailChanged(value)),
                ),
                const SizedBox(height: 16),

                // Password Field
                KadamTextField(
                  hint: 'Enter your password',
                  icon: Icons.lock_outline,
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
                    child: const Text(
                      'Forgot password?',
                      style: TextStyle(color: AppColors.primary),
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

                const SizedBox(height: 32),

                // Divider
                const Row(
                  children: [
                    Expanded(child: Divider(color: AppColors.hint)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Or continue with',
                        style: TextStyle(color: AppColors.hint),
                      ),
                    ),
                    Expanded(child: Divider(color: AppColors.hint)),
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

                const SizedBox(height: 40),

                // Footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(color: AppColors.text),
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
    );
  }
}
