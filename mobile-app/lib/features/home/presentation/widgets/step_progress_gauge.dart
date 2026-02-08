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
      height: 280, 
      width: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(280, 280),
            painter: _GaugePainter(
              progress: progress,
              backgroundColor: const Color(0xFF2C2C1E), // Dark muddy yellow for track
              progressColor: AppColors.primary,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 30), // Offset to align with arc center
              Text(
                '$steps',
                style: const TextStyle(
                  fontSize: 56, // Massive font as per design
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -1.0,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'of ${_formatNumber(goal)} steps',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.5),
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
    // Radius adjusted to fit the stroke width
    final radius = min(size.width, size.height) / 2 - 25;

    // Design shows a ~240 degree arc (leaving bottom open)
    // Start from 150 degrees to 390 degrees
    const double startAngle = 150 * (pi / 180);
    const double sweepAngle = 240 * (pi / 180);

    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 45 // Very thick stroke
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
      ..strokeWidth = 45
      ..strokeCap = StrokeCap.round;

    // Draw Progress Arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle * progress,
      false,
      progressPaint,
    );
    
    // Add small dots if needed, but design looks like solid flat arc
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
