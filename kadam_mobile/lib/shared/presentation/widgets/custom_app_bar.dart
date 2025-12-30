import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../features/auth/presentation/screens/signout_screen.dart';

/// Custom app bar with no elevation, matching background color
/// Shows "Welcome" title and user profile icon
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return AppBar(
      elevation: 0,
      shadowColor: Colors.transparent,
      scrolledUnderElevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      title: Text(
        'Welcome',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: GestureDetector(
            onTap: () {
              // Navigate to sign out screen
              Navigator.of(context).pushNamed(SignOutScreen.routeName);
            },
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              backgroundImage:
                  user?.photoUrl != null ? NetworkImage(user!.photoUrl!) : null,
              child: user?.photoUrl == null
                  ? Text(
                      _getInitials(user),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  /// Get user initials from display name or email
  String _getInitials(user) {
    if (user == null) return 'U';

    if (user.displayName != null && user.displayName!.isNotEmpty) {
      final parts = user.displayName!.trim().split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return user.displayName!.substring(0, 1).toUpperCase();
    }

    if (user.email.isNotEmpty) {
      return user.email.substring(0, 1).toUpperCase();
    }

    return 'U';
  }
}
