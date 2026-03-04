import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/presentation/theme/app_colors.dart';
import '../../../steps/presentation/bloc/steps_bloc.dart';

class DateSelector extends StatefulWidget {
  final DateTime? joinedDate;
  const DateSelector({super.key, this.joinedDate});

  @override
  State<DateSelector> createState() => _DateSelectorState();
}

class _DateSelectorState extends State<DateSelector> {
  late final ScrollController _scrollController;
  late final List<DateTime> _dates;
  final int _daysAround = 14;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _dates = _generateDates();
    
    // Scroll to today after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToToday();
    });
  }

  List<DateTime> _generateDates() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return List.generate(
      (_daysAround * 2) + 1,
      (index) => today.add(Duration(days: index - _daysAround)),
    );
  }

  void _scrollToToday() {
    if (_scrollController.hasClients) {
      // Each item is 64 width + 16 separator = 80 total
      const itemWidth = 80.0;
      final screenWidth = MediaQuery.of(context).size.width;
      // DateSelector is inside a Column with 24 horizontal padding on both sides
      final viewportWidth = screenWidth - 48;
      
      final itemCenter = (_daysAround * itemWidth) + 32; // 32 is half of 64
      final offset = itemCenter - (viewportWidth / 2);
      
      _scrollController.animateTo(
        offset.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // If joinedDate is null, we assume today (or allow all for now)
    final joinedDate = widget.joinedDate != null 
        ? DateTime(widget.joinedDate!.year, widget.joinedDate!.month, widget.joinedDate!.day)
        : today;

    return BlocBuilder<StepsBloc, StepsState>(
      builder: (context, state) {
        return SizedBox(
          height: 90,
          child: ListView.separated(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            itemCount: _dates.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final date = _dates[index];
              final isSelected = _isSameDay(date, state.selectedDate);
              final dateStr = DateFormat('yyyy-MM-dd').format(date);
              final isToday = _isSameDay(date, today);

              // Date is in valid range (after joined, not in future)
              final isInRange = (date.isAfter(joinedDate) || _isSameDay(date, joinedDate)) &&
                                (date.isBefore(today) || isToday);

              // Has step data (today always counts, past dates need Firestore data)
              final hasData = isToday || state.datesWithData.contains(dateStr);

              final isEnabled = isInRange && hasData;
              final isDisabled = isInRange && !hasData; // valid range but no data

              double opacity;
              if (!isInRange) {
                opacity = 0.25; // future or pre-join dates
              } else if (isDisabled) {
                opacity = 0.4; // in range but no step data
              } else {
                opacity = 1.0;
              }

              return GestureDetector(
                onTap: isEnabled ? () {
                  context.read<StepsBloc>().add(DateSelected(date));
                } : null,
                child: Opacity(
                  opacity: opacity,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 64,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : isDisabled
                                ? AppColors.surface.withOpacity(0.5)
                                : AppColors.surface,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('dd').format(date),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? Colors.black : Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('E').format(date),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isSelected ? Colors.black.withOpacity(0.7) : AppColors.subtext,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }
}
