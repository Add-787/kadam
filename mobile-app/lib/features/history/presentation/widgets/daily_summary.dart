import 'package:flutter/material.dart';
import '../../../../core/presentation/theme/app_colors.dart';

class DailySummary extends StatelessWidget {
  final int steps;
  final double kcal;
  final double km;

  const DailySummary({
    super.key,
    required this.steps,
    required this.kcal,
    required this.km,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatItem('Steps', steps.toString(), 'steps'),
        _buildStatItem('Kcal', kcal.toStringAsFixed(0), 'kcal'),
        _buildStatItem('Km', km.toStringAsFixed(1), 'km'),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, String unit) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.subtext,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
