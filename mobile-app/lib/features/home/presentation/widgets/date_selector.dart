import 'package:flutter/material.dart';
import '../../../../core/presentation/theme/app_colors.dart';

class DateSelector extends StatefulWidget {
  const DateSelector({super.key});

  @override
  State<DateSelector> createState() => _DateSelectorState();
}

class _DateSelectorState extends State<DateSelector> {
  int _selectedIndex = 2; // Default to '07 Mon' as per screenshot

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
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _dates.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final isSelected = index == _selectedIndex;
          final date = _dates[index];
          return GestureDetector(
            onTap: () => setState(() => _selectedIndex = index),
            child: Container(
              width: 56,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.surface,
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    date['day']!,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.black : AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    date['weekday']!,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.black : AppColors.hint,
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
