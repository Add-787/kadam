import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/presentation/theme/app_colors.dart';

class StepProgressGauge extends StatelessWidget {
  final int steps;
  final int goal;

  const StepProgressGauge({
    super.key,
    required this.steps,
    required this.goal,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate progress (0.0 to 1.0)
    final double progress = (steps / goal).clamp(0.0, 1.0);

    return SizedBox(
      height: 250, // Slightly increased height for better centering
      width: 250,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(250, 250),
            painter: _GaugePainter(
              progress: progress,
              backgroundColor: const Color(0xFF2C2C1E), // Darker background track
              progressColor: AppColors.primary,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20), // Offset to align with arc center
              Icon(
                Icons.directions_walk,
                color: AppColors.primary.withOpacity(0.8),
                size: 28,
              ),
              const SizedBox(height: 4),
              Text(
                '$steps',
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Explicit white for visibility
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'of ${_formatNumber(goal)} steps',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    final str = number.toString();
    // Simple thousands separator
    if (str.length > 3) {
      return '${str.substring(0, str.length - 3)},${str.substring(str.length - 3)}';
    }
    return str;
  }
}

class _GaugePainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;

  _GaugePainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 20;

    // Start from bottom-left (135 degrees) to bottom-right (405 degrees)
    // This creates a 270-degree arc (open at bottom)
    const double startAngle = 135 * (pi / 180);
    const double sweepAngle = 270 * (pi / 180);

    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    // Draw Background Arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      backgroundPaint,
    );

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    // Draw Progress Arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
