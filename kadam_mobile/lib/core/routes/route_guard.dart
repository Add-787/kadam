import 'package:flutter/material.dart';

/// Base interface for route guards
/// Guards control access to routes by checking conditions before navigation
abstract class RouteGuard {
  /// Check if the user can access the route
  /// Returns true if access is granted, false otherwise
  Future<bool> canActivate(BuildContext context);

  /// The route to redirect to if the guard fails
  String get redirectRoute;

  /// Optional: Custom message to show when guard fails
  String? get failureMessage => null;
}
