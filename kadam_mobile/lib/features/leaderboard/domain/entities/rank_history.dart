import 'package:equatable/equatable.dart';

/// Rank history entry for tracking user's rank over time
class RankHistory extends Equatable {
  /// Date of this rank entry (YYYY-MM-DD)
  final String date;

  /// User's rank on this date
  final int rank;

  /// Steps on this date
  final int steps;

  const RankHistory({
    required this.date,
    required this.rank,
    required this.steps,
  });

  @override
  List<Object?> get props => [date, rank, steps];

  @override
  String toString() {
    return 'RankHistory(date: $date, rank: $rank, steps: $steps)';
  }
}
