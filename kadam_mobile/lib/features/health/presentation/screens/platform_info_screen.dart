import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/health_platform_provider.dart';
import '../widgets/platform_info_card.dart';

/// Screen that displays comprehensive health platform information
/// Useful for debugging and understanding the current platform status
class PlatformInfoScreen extends StatelessWidget {
  const PlatformInfoScreen({super.key});

  static const routeName = '/platform-info';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Platform Information'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshPlatform(context),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Consumer<HealthPlatformProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading platform information...'),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // Main platform info card
                PlatformInfoCard(
                  capability: provider.capability,
                  showDebugInfo: true,
                ),

                // Additional actions
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Request permissions button
                      if (provider.isAvailable && !provider.isAuthorized)
                        ElevatedButton.icon(
                          onPressed: () =>
                              _requestPermissions(context, provider),
                          icon: const Icon(Icons.lock_open),
                          label: const Text('Request Permissions'),
                        ),

                      const SizedBox(height: 12),

                      // Open platform settings
                      if (provider.isAvailable)
                        OutlinedButton.icon(
                          onPressed: () => _openPlatformSettings(provider),
                          icon: const Icon(Icons.settings),
                          label: Text('Open ${provider.platformName} Settings'),
                        ),

                      const SizedBox(height: 12),

                      // Refresh button
                      OutlinedButton.icon(
                        onPressed: () => _refreshPlatform(context),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh Information'),
                      ),

                      // Error display
                      if (provider.error != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline, color: Colors.red[700]),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Error',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red[700],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      provider.error!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.red[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Platform recommendations
                _buildRecommendations(context, provider),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecommendations(
    BuildContext context,
    HealthPlatformProvider provider,
  ) {
    if (!provider.isAvailable) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          color: Colors.blue[50],
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700]),
                    const SizedBox(width: 8),
                    Text(
                      'Recommendations',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '• Install Health Connect from Google Play Store\n'
                  '• Ensure your device runs Android 8.0 or higher\n'
                  '• Check that Health Connect is enabled in system settings',
                  style: TextStyle(color: Colors.blue[900]),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (provider.isAvailable && !provider.isAuthorized) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          color: Colors.orange[50],
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lock_outline, color: Colors.orange[700]),
                    const SizedBox(width: 8),
                    Text(
                      'Authorization Needed',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Tap "Request Permissions" above to grant access to your health data. '
                  'This allows Kadam to read your steps and activity information.',
                  style: TextStyle(color: Colors.orange[900]),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (provider.isReady) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          color: Colors.green[50],
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green[700]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'All set! Your health platform is ready to use.',
                    style: TextStyle(
                      color: Colors.green[900],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Future<void> _refreshPlatform(BuildContext context) async {
    final provider = context.read<HealthPlatformProvider>();
    await provider.refresh();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Platform information refreshed'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _requestPermissions(
    BuildContext context,
    HealthPlatformProvider provider,
  ) async {
    final granted = await provider.requestPermissions();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            granted
                ? 'Permissions granted successfully!'
                : 'Permissions denied. Some features may not work.',
          ),
          backgroundColor: granted ? Colors.green : Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _openPlatformSettings(HealthPlatformProvider provider) async {
    await provider.openSettings();
  }
}
