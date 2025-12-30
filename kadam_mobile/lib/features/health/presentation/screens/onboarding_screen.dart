import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/health_platform_provider.dart';
import '../widgets/platform_info_card.dart';
import '../../../../core/platform/models/platform_capability.dart';
import '../../../../core/routes/guards/onboarding_guard.dart';
import '../../../../core/routes/app_routes.dart';

/// Onboarding screen for health platform permissions
///
/// Automatically detects the available platform and requests permissions
/// No manual platform selection - system chooses based on device
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  @override
  void initState() {
    super.initState();

    // Initialize platform detection
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializePlatform();
    });
  }

  Future<void> _initializePlatform() async {
    final provider = context.read<HealthPlatformProvider>();
    await provider.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Setup'),
      ),
      body: Consumer<HealthPlatformProvider>(
        builder: (context, provider, child) {
          // Loading state
          if (provider.isLoading) {
            return _buildLoadingView();
          }

          // Error state
          if (provider.error != null) {
            return _buildErrorView(provider);
          }

          // No platform available
          if (!provider.hasHealthPlatform || !provider.isAvailable) {
            return _buildNoPlatformView(provider);
          }

          // Platform ready - needs permissions
          if (provider.needsPermissions) {
            return _buildPermissionRequestView(provider);
          }

          // All set!
          if (provider.isReady) {
            return _buildSuccessView(provider);
          }

          // Unknown state
          return _buildUnknownStateView(provider);
        },
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 24),
          Text(
            'Detecting health platform...',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(HealthPlatformProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 24),
            Text(
              'Error',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Text(
              provider.error ?? 'Unknown error occurred',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () async {
                provider.clearError();
                await provider.refresh();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoPlatformView(HealthPlatformProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.phonelink_off,
              size: 64,
              color: Colors.orange,
            ),
            const SizedBox(height: 24),
            Text(
              'No Health Platform Available',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              _getNoPlatformMessage(provider.platform),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            if (provider.platform == HealthPlatform.healthConnect) ...[
              ElevatedButton.icon(
                onPressed: () => provider.openSettings(),
                icon: const Icon(Icons.settings),
                label: const Text('Install Health Connect'),
              ),
              const SizedBox(height: 16),
            ],
            OutlinedButton.icon(
              onPressed: () => provider.refresh(),
              icon: const Icon(Icons.refresh),
              label: const Text('Check Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionRequestView(HealthPlatformProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),

          // Platform Info Card
          PlatformInfoCard(
            capability: provider.capability,
            showDebugInfo: false,
          ),
          const SizedBox(height: 24),

          // Intro text
          Text(
            'Kadam needs permission to read your health data',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),

          // Description
          Text(
            _getPermissionDescription(provider.platform),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 32),

          // Data types card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Required Data',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDataTypeItem(Icons.directions_walk, 'Steps'),
                  _buildDataTypeItem(Icons.straighten, 'Distance'),
                  _buildDataTypeItem(Icons.local_fire_department, 'Calories'),
                  _buildDataTypeItem(Icons.favorite, 'Heart Rate'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Request permission button
          ElevatedButton(
            onPressed:
                provider.isLoading ? null : () => _requestPermissions(provider),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: provider.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Grant Permissions',
                    style: TextStyle(fontSize: 16),
                  ),
          ),
          const SizedBox(height: 16),

          // Skip button
          OutlinedButton(
            onPressed: provider.isLoading ? null : () => _skipForNow(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'Skip for Now',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView(HealthPlatformProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              size: 80,
              color: Colors.green.shade600,
            ),
            const SizedBox(height: 24),
            Text(
              'All Set!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Text(
              '${provider.platformName} is connected and ready to use',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => _completeOnboarding(),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 16,
                ),
              ),
              child: const Text(
                'Continue',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnknownStateView(HealthPlatformProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.help_outline,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 24),
            Text(
              'Unknown Status',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Text(
              provider.statusMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => provider.refresh(),
              child: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataTypeItem(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.grey.shade700),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  String _getNoPlatformMessage(HealthPlatform? platform) {
    switch (platform) {
      case HealthPlatform.healthConnect:
        return 'Health Connect is not installed on this device.\n\n'
            'Install Health Connect from the Play Store to sync your health data.';
      case HealthPlatform.appleHealth:
        return 'Apple Health is not available on this device.\n\n'
            'Please ensure you are running iOS 8.0 or later.';
      case HealthPlatform.mock:
        return 'Running in development mode with mock data.';
      default:
        return 'No compatible health platform found on this device.\n\n'
            'Kadam requires Health Connect (Android) or Apple Health (iOS).';
    }
  }

  String _getPermissionDescription(HealthPlatform? platform) {
    switch (platform) {
      case HealthPlatform.healthConnect:
        return 'We\'ll request access to read your health data from Health Connect. '
            'Health Connect aggregates data from all your fitness apps in one place.';
      case HealthPlatform.appleHealth:
        return 'We\'ll request access to read your health data from Apple Health. '
            'Your data stays secure on your device and is never shared without your permission.';
      case HealthPlatform.mock:
        return 'Running in development mode. No real health data will be accessed.';
      default:
        return 'We need permission to read your health data to provide step tracking features.';
    }
  }

  Future<void> _requestPermissions(HealthPlatformProvider provider) async {
    final granted = await provider.requestPermissions();

    if (granted) {
      // Permissions granted - check if ready
      await provider.checkIfReady();
    } else {
      // Show error
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Permissions are required to continue'),
          action: SnackBarAction(
            label: 'Settings',
            onPressed: () => provider.openSettings(),
          ),
        ),
      );
    }
  }

  void _skipForNow() {
    // User chose to skip - go to home with limited functionality
    // Don't mark as complete since permissions weren't granted
    debugPrint('⚠️ [Onboarding] User skipped health permissions');
    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  }

  Future<void> _completeOnboarding() async {
    // All set - mark onboarding as complete and go to home
    debugPrint('✅ [Onboarding] Health permissions granted - marking complete');
    await OnboardingGuard.markAllOnboardingComplete();

    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  }
}
