import 'package:equatable/equatable.dart';
import '../../domain/entities/history_entry.dart';

abstract class HistoryEvent extends Equatable {
  const HistoryEvent();

  @override
  List<Object> get props => [];
}

class HistoryFetched extends HistoryEvent {}

class HistoryDateSelected extends HistoryEvent {
  final DateTime selectedDate;

  const HistoryDateSelected(this.selectedDate);

  @override
  List<Object> get props => [selectedDate];
}
