import 'package:equatable/equatable.dart';

class DailyFocusMetric extends Equatable {
  const DailyFocusMetric({
    required this.date,
    required this.dayLabel,
    required this.focusMinutes,
    this.isToday = false,
  });

  final DateTime date;
  final String dayLabel; // e.g. "Mon", "Tue"
  final int focusMinutes;
  final bool isToday;

  @override
  List<Object?> get props => [date, dayLabel, focusMinutes, isToday];
}

