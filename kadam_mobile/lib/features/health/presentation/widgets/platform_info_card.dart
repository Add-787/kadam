import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/platform/models/platform_capability.dart';

/// Widget that displays detailed information about the health platform
class PlatformInfoCard extends StatelessWidget {
  final PlatformCapability? capability;
  final bool showDebugInfo;

  const PlatformInfoCard({
    super.key,
    this.capability,
    this.showDebugInfo = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  _getPlatformIcon(),
                  size: 32,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Health Platform Info',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getDeviceInfo(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // Platform Details
            if (capability != null) ...[
              _buildInfoRow(
                context,
                'Platform',
                capability!.platformName,
                Icons.health_and_safety,
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                context,
                'Status',
                _getStatusText(),
                Icons.info_outline,
                statusColor: _getStatusColor(context),
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                context,
                'Available',
                capability!.isAvailable ? 'Yes' : 'No',
                Icons.check_circle_outline,
                statusColor:
                    capability!.isAvailable ? Colors.green : Colors.red,
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                context,
                'Authorized',
                capability!.isAuthorized ? 'Yes' : 'No',
                Icons.lock_outline,
                statusColor:
                    capability!.isAuthorized ? Colors.green : Colors.orange,
              ),
              if (capability!.version.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildInfoRow(
                  context,
                  'Version',
                  capability!.version,
                  Icons.code,
                ),
              ],
              const SizedBox(height: 16),

              // Supported Data Types
              Text(
                'Supported Data Types',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              if (capability!.supportedDataTypes.isEmpty)
                Text(
                  'No data types available',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: capability!.supportedDataTypes
                      .map((type) => Chip(
                            label: Text(
                              _formatDataType(type),
                              style: const TextStyle(fontSize: 12),
                            ),
                            backgroundColor: Colors.blue[50],
                            side: BorderSide(color: Colors.blue[200]!),
                          ))
                      .toList(),
                ),

              // Debug Info
              if (showDebugInfo) ...[
                const Divider(height: 24),
                Text(
                  'Debug Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Raw Platform: ${capability!.platform.name}',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Is Ready: ${capability!.isReady}',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Data Type Count: ${capability!.supportedDataTypes.length}',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ] else ...[
              // No capability information
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 48,
                        color: Colors.orange[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Platform information not available',
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Initialize the health platform to see details',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    Color? statusColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[700],
                ),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
        ),
      ],
    );
  }

  IconData _getPlatformIcon() {
    if (capability == null) return Icons.help_outline;

    switch (capability!.platform) {
      case HealthPlatform.appleHealth:
        return Icons.favorite;
      case HealthPlatform.healthConnect:
      case HealthPlatform.googleFit:
        return Icons.health_and_safety;
      case HealthPlatform.samsungHealth:
        return Icons.monitor_heart;
      case HealthPlatform.mock:
        return Icons.science;
      default:
        return Icons.help_outline;
    }
  }

  String _getDeviceInfo() {
    if (Platform.isAndroid) {
      return 'Android Device';
    } else if (Platform.isIOS) {
      return 'iOS Device';
    } else if (Platform.isMacOS) {
      return 'macOS Device';
    } else {
      return 'Unknown Device';
    }
  }

  String _getStatusText() {
    if (capability == null) return 'Unknown';

    if (capability!.isReady) {
      return 'Ready';
    } else if (capability!.isAvailable && !capability!.isAuthorized) {
      return 'Needs Authorization';
    } else if (!capability!.isAvailable) {
      return 'Not Available';
    } else {
      return 'Unknown';
    }
  }

  Color _getStatusColor(BuildContext context) {
    if (capability == null) return Colors.grey;

    if (capability!.isReady) {
      return Colors.green;
    } else if (capability!.isAvailable && !capability!.isAuthorized) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  String _formatDataType(String type) {
    // Convert snake_case or camelCase to Title Case
    return type
        .replaceAll('_', ' ')
        .replaceAllMapped(
          RegExp(r'([A-Z])'),
          (match) => ' ${match.group(1)}',
        )
        .trim()
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }
}
