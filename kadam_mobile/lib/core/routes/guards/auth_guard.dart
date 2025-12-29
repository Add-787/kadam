import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../route_guard.dart';
import '../app_routes.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';

/// Guard that checks if the user is authenticated
/// Redirects to login screen if not authenticated
class AuthGuard implements RouteGuard {
  @override
  Future<bool> canActivate(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Check if user is authenticated
    final isAuthenticated = authProvider.isAuthenticated;

    if (!isAuthenticated) {
      debugPrint('🛡️ [AuthGuard] Access denied - User not authenticated');
    } else {
      debugPrint('🛡️ [AuthGuard] Access granted - User authenticated');
    }

    return isAuthenticated;
  }

  @override
  String get redirectRoute => AppRoutes.login;

  @override
  String get failureMessage => 'Please login to continue';
}
