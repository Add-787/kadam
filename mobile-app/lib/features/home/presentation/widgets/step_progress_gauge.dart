import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/presentation/theme/app_colors.dart';

class StepProgressGauge extends StatelessWidget {
  final int steps;
  final int goal;

  const StepProgressGauge({super.key, required this.steps, required this.goal});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      width: 280,
      child: CustomPaint(
        painter: _GaugePainter(
          progress: steps / goal,
          backgroundColor: const Color(0xFF4A4A3A),
          progressColor: AppColors.primary,
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$steps',
                  style: const TextStyle(
                    fontSize: 52,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                    height: 1.0,
                  ),
                ),
                Text(
                  'of ${_formatNumber(goal)} steps',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFFC8A060),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(0)},${(number % 1000).toString().padLeft(3, '0')}';
    }
    return number.toString();
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
    final radius = min(size.width, size.height) / 2 - 15;

    const startAngle = 135 * pi / 180;
    const sweepAngle = 270 * pi / 180;

    // Background arc
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 30
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      backgroundPaint,
    );

    // Progress arc
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 30
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle * progress.clamp(0.0, 1.0),
      false,
      progressPaint,
    );

    // Inner dots
    final dotsPaint = Paint()
      ..color = progressColor.withAlpha(100)
      ..style = PaintingStyle.fill;

    final dotsRadius = radius - 35;
    const totalDots = 12;

    for (int i = 0; i < totalDots; i++) {
      final angle = startAngle + (sweepAngle * (i / (totalDots - 1)));
      final dx = center.dx + dotsRadius * cos(angle);
      final dy = center.dy + dotsRadius * sin(angle);
      canvas.drawCircle(Offset(dx, dy), 2.5, dotsPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
