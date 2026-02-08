import 'package:flutter/material.dart';
import '../../../../core/presentation/theme/app_colors.dart';

class DateSelector extends StatefulWidget {
  const DateSelector({super.key});

  @override
  State<DateSelector> createState() => _DateSelectorState();
}

class _DateSelectorState extends State<DateSelector> {
  int _selectedIndex = 2; // Default to '07 Mon'

  // Mock data for UI - In real app, this would be dynamic
  final List<Map<String, String>> _dates = [
    {'day': '05', 'weekday': 'Sat'},
    {'day': '06', 'weekday': 'Sun'},
    {'day': '07', 'weekday': 'Mon'},
    {'day': '08', 'weekday': 'Tue'},
    {'day': '09', 'weekday': 'Wed'},
    {'day': '10', 'weekday': 'Thu'},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90, // Taller capsule
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _dates.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final isSelected = index == _selectedIndex;
          final date = _dates[index];
          
          return GestureDetector(
            onTap: () => setState(() => _selectedIndex = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 64,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(32), // Full capsule
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.surface,
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    date['day']!,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.black : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date['weekday']!,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.black.withOpacity(0.7) : AppColors.subtext,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
