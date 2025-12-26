import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kadam_mobile/features/health/presentation/screens/health_screen.dart';
import 'package:kadam_mobile/features/leaderboard/presentation/leaderboard_screen.dart';
import '../auth/presentation/providers/auth_provider.dart';
import '../../shared/widgets/floating_bottom_bar.dart';

/// Main scaffold with bottom navigation for the app
///
/// Manages navigation between main app sections:
/// - Home (step tracking)
/// - Friends
/// - Leaderboard
class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  // Screens for each tab
  final List<Widget> _screens = [
    const HealthScreen(), // Home - Step tracking
    const _FriendsScreen(), // Friends placeholder
    const LeaderboardScreen(), // Leaderboard placeholder
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Check authentication status
    final authProvider = context.watch<AuthProvider>();

    // If not authenticated, redirect to login
    if (!authProvider.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/login');
      });

      // Show loading while redirecting
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // Display the current screen
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          // Floating bottom bar positioned at the bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: FloatingBottomBar(
              currentIndex: _currentIndex,
              onTap: _onTabTapped,
            ),
          ),
        ],
      ),
    );
  }
}

/// Placeholder screen for Friends tab
class _FriendsScreen extends StatelessWidget {
  const _FriendsScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_rounded, size: 64),
            SizedBox(height: 16),
            Text(
              'Friends Screen',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Coming soon...'),
          ],
        ),
      ),
    );
  }
}
