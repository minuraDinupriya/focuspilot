import 'package:equatable/equatable.dart';

class HeatmapDay extends Equatable {
  const HeatmapDay({
    required this.date,
    required this.focusMinutes,
    required this.level,
  });

  final DateTime date;
  final int focusMinutes;
  final int level; // 0 (none), 1 (light), 2 (medium), 3 (high), 4 (very high)

  static int calculateLevel(int minutes) {
    if (minutes <= 0) return 0;
    if (minutes < 25) return 1;
    if (minutes < 60) return 2;
    if (minutes < 120) return 3;
    return 4;
  }

  factory HeatmapDay.fromMinutes({
    required DateTime date,
    required int focusMinutes,
  }) {
    return HeatmapDay(
      date: date,
      focusMinutes: focusMinutes,
      level: calculateLevel(focusMinutes),
    );
  }

  @override
  List<Object?> get props => [date, focusMinutes, level];
}
