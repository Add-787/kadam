import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../../../core/utils/navigation_helper.dart';

/// Sign out confirmation screen
class SignOutScreen extends StatefulWidget {
  const SignOutScreen({super.key});

  static const routeName = '/signout';

  @override
  State<SignOutScreen> createState() => _SignOutScreenState();
}

class _SignOutScreenState extends State<SignOutScreen> {
  bool _isSigningOut = false;

  Future<void> _handleSignOut() async {
    setState(() {
      _isSigningOut = true;
    });

    try {
      // Sign out from Firebase
      final authProvider = context.read<AuthProvider>();
      await authProvider.signOut();

      if (mounted) {
        // Use NavigationHelper to handle logout
        // This will:
        // 1. Reset onboarding status
        // 2. Clear navigation stack
        // 3. Navigate to login screen
        await NavigationHelper.handleLogout(context);
      }
    } catch (e) {
      setState(() {
        _isSigningOut = false;
      });

      if (mounted) {
        final authProvider = context.read<AuthProvider>();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Failed to sign out'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleCancel() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Out'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _isSigningOut ? null : _handleCancel,
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Sign out icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.logout,
                  size: 50,
                  color: Colors.red.shade400,
                ),
              ),
              const SizedBox(height: 32),

              // Title
              Text(
                'Sign Out?',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // User info
              if (user != null) ...[
                Text(
                  user.displayName ?? user.email,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey.shade700,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  user.email,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade500,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
              ],

              // Description
              Text(
                'Are you sure you want to sign out of your account?',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'You\'ll need to sign in again to access your health data.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade500,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Sign out button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSigningOut ? null : _handleSignOut,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSigningOut
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Sign Out',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // Cancel button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _isSigningOut ? null : _handleCancel,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
