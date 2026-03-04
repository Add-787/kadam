import 'package:equatable/equatable.dart';

class HistoryEntry extends Equatable {
  final DateTime date;
  final int steps;
  final double calories;
  final double distance;
  final bool isGoalAchieved;

  const HistoryEntry({
    required this.date,
    required this.steps,
    required this.calories,
    required this.distance,
    required this.isGoalAchieved,
  });

  @override
  List<Object?> get props => [date, steps, calories, distance, isGoalAchieved];
}
