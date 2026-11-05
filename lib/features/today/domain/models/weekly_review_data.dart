import 'package:equatable/equatable.dart';
import 'package:focuspilot/features/tasks/domain/models/task.dart';

/// Immutable domain model capturing a user's productivity and focus summary
/// over the current 7-day period compared to the preceding 7 days.
class WeeklyReviewData extends Equatable {
  const WeeklyReviewData({
    required this.startDate,
    required this.endDate,
    required this.focusMinutesThisWeek,
    required this.focusMinutesPreviousWeek,
    required this.completedSessionsCount,
    required this.completedTasksCount,
    required this.daysGoalMetCount,
    required this.dailyGoalMinutes,
    this.bestDayLabel,
    this.bestDayMinutes = 0,
    this.topCategory,
    this.topCategoryMinutes = 0,
    this.topTasks = const [],
  });

  final DateTime startDate;
  final DateTime endDate;
  final int focusMinutesThisWeek;
  final int focusMinutesPreviousWeek;
  final int completedSessionsCount;
  final int completedTasksCount;
  final int daysGoalMetCount;
  final int dailyGoalMinutes;
  final String? bestDayLabel;
  final int bestDayMinutes;
  final String? topCategory;
  final int topCategoryMinutes;
  final List<Task> topTasks;

  /// Goal achievement rate across the 7-day review period (0.0 to 1.0).
  double get goalAchievementRate => (daysGoalMetCount / 7.0).clamp(0.0, 1.0);

  /// Percentage difference in focus minutes compared to previous week.
  /// Returns null if previous week had 0 minutes and this week also has 0 minutes.
  double? get changePercentage {
    if (focusMinutesPreviousWeek == 0) {
      return focusMinutesThisWeek > 0 ? 100.0 : null;
    }
    return ((focusMinutesThisWeek - focusMinutesPreviousWeek) /
            focusMinutesPreviousWeek) *
        100.0;
  }

  bool get isPositiveTrend => (changePercentage ?? 0.0) >= 0;

  String get trendText {
    final change = changePercentage;
    if (change == null) {
      return 'No prior activity';
    }
    if (change == 0) {
      return 'Equal to last week';
    }
    final prefix = change > 0 ? '+' : '';
    return '$prefix${change.toStringAsFixed(0)}% vs last week';
  }

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  String get dateRangeText {
    final startMonth = _months[startDate.month - 1];
    final endMonth = _months[endDate.month - 1];
    if (startMonth == endMonth) {
      return '$startMonth ${startDate.day} – ${endDate.day}';
    }
    return '$startMonth ${startDate.day} – $endMonth ${endDate.day}';
  }

  static String formatMinutes(int minutes) {
    if (minutes <= 0) return '0m';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  String get focusTimeFormatted => formatMinutes(focusMinutesThisWeek);
  String get previousFocusTimeFormatted =>
      formatMinutes(focusMinutesPreviousWeek);
  String get bestDayTimeFormatted => formatMinutes(bestDayMinutes);

  String get motivationalMessage {
    if (focusMinutesThisWeek == 0) {
      return 'Every productive journey begins with a single step. Start your first focus session today!';
    }
    if (daysGoalMetCount >= 5) {
      return 'Outstanding consistency! You are building an unbeatable focus habit.';
    }
    if (daysGoalMetCount >= 3) {
      return 'Solid progress this week! Keep pushing your momentum into next week.';
    }
    if (focusMinutesThisWeek >= focusMinutesPreviousWeek &&
        focusMinutesPreviousWeek > 0) {
      return 'You improved upon last week’s focus time. Great dedication!';
    }
    return 'Every session counts. Reflect on your wins and set your sights on a focused week ahead.';
  }

  @override
  List<Object?> get props => [
    startDate,
    endDate,
    focusMinutesThisWeek,
    focusMinutesPreviousWeek,
    completedSessionsCount,
    completedTasksCount,
    daysGoalMetCount,
    dailyGoalMinutes,
    bestDayLabel,
    bestDayMinutes,
    topCategory,
    topCategoryMinutes,
    topTasks,
  ];
}
