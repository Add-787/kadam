import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/theme/app_colors.dart';
import '../../../../core/presentation/widgets/kadam_button.dart';
import '../../../../core/presentation/widgets/kadam_text_field.dart';
import '../../../../core/presentation/widgets/social_login_button.dart';
import '../bloc/sign_up_bloc.dart';
import '../bloc/sign_up_event.dart';
import '../bloc/sign_up_state.dart';

final getIt = GetIt.instance;

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
      body: BlocListener<SignUpBloc, SignUpState>(
        listener: (context, state) {
          if (state.status == SignUpStatus.failure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text(state.errorMessage ?? 'Sign Up Failed')),
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
                const SizedBox(height: 40),
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
                const SizedBox(height: 20),

                const Text(
                  'Sign up to your account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Join our journey! Select method to sign up',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: AppColors.hint),
                ),
                const SizedBox(height: 30),

                KadamTextField(
                  hint: 'Enter a username',
                  icon: Icons.person_outline,
                  onChanged: (value) => context.read<SignUpBloc>().add(
                    SignUpUsernameChanged(value),
                  ),
                ),
                const SizedBox(height: 16),

                KadamTextField(
                  hint: 'Enter your mail',
                  icon: Icons.email_outlined,
                  onChanged: (value) =>
                      context.read<SignUpBloc>().add(SignUpEmailChanged(value)),
                ),
                const SizedBox(height: 16),

                KadamTextField(
                  hint: 'Enter your password',
                  icon: Icons.lock_outline,
                  obscureText: true,
                  onChanged: (value) => context.read<SignUpBloc>().add(
                    SignUpPasswordChanged(value),
                  ),
                ),
                const SizedBox(height: 16),

                KadamTextField(
                  hint: 'Confirm password',
                  icon: Icons.lock_outline,
                  obscureText: true,
                  onChanged: (value) => context.read<SignUpBloc>().add(
                    SignUpConfirmPasswordChanged(value),
                  ),
                ),
                const SizedBox(height: 24),

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

                const SizedBox(height: 24),

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
                const SizedBox(height: 24),

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

                const SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Have an account? ",
                      style: TextStyle(color: AppColors.text),
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
    );
  }
}
