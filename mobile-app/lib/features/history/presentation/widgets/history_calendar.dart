import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/presentation/theme/app_colors.dart';
import '../../domain/entities/history_entry.dart';

class HistoryCalendar extends StatelessWidget {
  final List<HistoryEntry> history;
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const HistoryCalendar({
    super.key,
    required this.history,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Basic calendar logic for the current month
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
    final lastDayOfMonth = DateTime(selectedDate.year, selectedDate.month + 1, 0);
    
    final daysInMonth = lastDayOfMonth.day;
    final firstWeekday = firstDayOfMonth.weekday; // 1 = Mon, 7 = Sun

    // Adjust firstWeekday to match Sun-Sat grid (0 = Sun)
    final startOffset = firstWeekday % 7;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
             Text(
              DateFormat('MMMM yyyy').format(selectedDate),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: Colors.white),
                  onPressed: () => onDateSelected(DateTime(selectedDate.year, selectedDate.month - 1)),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: Colors.white),
                  onPressed: () => onDateSelected(DateTime(selectedDate.year, selectedDate.month + 1)),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
              .map((day) => Text(
                    day,
                    style: const TextStyle(color: AppColors.subtext, fontSize: 12),
                  ))
              .toList(),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: daysInMonth + startOffset,
          itemBuilder: (context, index) {
            if (index < startOffset) {
              return const SizedBox.shrink();
            }

            final day = index - startOffset + 1;
            final date = DateTime(selectedDate.year, selectedDate.month, day);
            final isSelected = date.day == selectedDate.day &&
                date.month == selectedDate.month &&
                date.year == selectedDate.year;
            
            final entry = history.firstWhere(
              (e) => e.date.year == date.year && e.date.month == date.month && e.date.day == date.day,
              orElse: () => HistoryEntry(date: date, steps: 0, calories: 0, distance: 0, isGoalAchieved: false),
            );

            final hasData = entry.steps > 0;
            final isAchieved = entry.isGoalAchieved;

            return GestureDetector(
              onTap: () => onDateSelected(date),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected 
                      ? AppColors.primary 
                      : (isAchieved ? AppColors.primary.withOpacity(0.2) : Colors.transparent),
                  border: isAchieved && !isSelected
                      ? Border.all(color: AppColors.primary, width: 1)
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  day.toString(),
                  style: TextStyle(
                    color: isSelected ? Colors.black : (hasData ? Colors.white : AppColors.hint),
                    fontWeight: isSelected || hasData ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
