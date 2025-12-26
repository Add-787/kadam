import 'package:flutter/material.dart';

/// A stateless widget that displays daily step progress
/// 
/// Shows current steps, target steps, and progress percentage
/// with a circular progress indicator and motivational messages
class DailyStepCounter extends StatelessWidget {
  /// Current number of steps taken today
  final int currentSteps;

  /// Target number of steps for the day
  final int targetSteps;

  const DailyStepCounter({
    super.key,
    required this.currentSteps,
    required this.targetSteps,
  });

  /// Calculate progress percentage (0.0 to 1.0)
  double get _progressPercentage {
    if (targetSteps == 0) return 0.0;
    return (currentSteps / targetSteps).clamp(0.0, 1.0);
  }

  /// Get percentage as integer (0 to 100)
  int get _percentageInt => (_progressPercentage * 100).round();

  /// Get remaining steps to reach goal
  int get _stepsRemaining {
    final remaining = targetSteps - currentSteps;
    return remaining > 0 ? remaining : 0;
  }

  /// Get motivational message based on progress
  String get _motivationalMessage {
    final progress = _percentageInt;
    if (progress >= 100) {
      return '🎉 Goal achieved! Keep it up!';
    } else if (progress >= 75) {
      return '💪 Almost there! Just $_stepsRemaining more!';
    } else if (progress >= 50) {
      return '👍 Halfway there! You\'re doing great!';
    } else if (progress >= 25) {
      return '🚶 Good start! Keep moving!';
    } else {
      return '🌟 Let\'s get moving today!';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Circular progress indicator with step count
            SizedBox(
              width: 200,
              height: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background circle
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: CircularProgressIndicator(
                      value: 1.0,
                      strokeWidth: 12,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        colorScheme.surfaceContainerHighest,
                      ),
                    ),
                  ),
                  // Progress circle
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: CircularProgressIndicator(
                      value: _progressPercentage,
                      strokeWidth: 12,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _progressPercentage >= 1.0
                            ? colorScheme.tertiary
                            : colorScheme.primary,
                      ),
                    ),
                  ),
                  // Center content
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Current steps
                      Text(
                        currentSteps.toString(),
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Target steps
                      Text(
                        'of $targetSteps steps',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Percentage badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _progressPercentage >= 1.0
                              ? colorScheme.tertiaryContainer
                              : colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$_percentageInt%',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: _progressPercentage >= 1.0
                                ? colorScheme.onTertiaryContainer
                                : colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Motivational message
            Text(
              _motivationalMessage,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            // Steps remaining (only show if not goal reached)
            if (_stepsRemaining > 0) ...[
              const SizedBox(height: 8),
              Text(
                '$_stepsRemaining steps to go',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}