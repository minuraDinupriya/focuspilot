import 'package:equatable/equatable.dart';
import 'package:focuspilot/features/today/domain/models/daily_focus_metric.dart';

enum TodayStatus { initial, loading, loaded, error }

class TodayState extends Equatable {
  const TodayState({
    this.status = TodayStatus.initial,
    this.focusMinutesToday = 0,
    this.dailyGoalMinutes = 120,
    this.completedSessionsToday = 0,
    this.completedTasksToday = 0,
    this.weeklyMetrics = const [],
    this.currentStreakDays = 0,
    this.errorMessage,
  });

  final TodayStatus status;
  final int focusMinutesToday;
  final int dailyGoalMinutes;
  final int completedSessionsToday;
  final int completedTasksToday;
  final List<DailyFocusMetric> weeklyMetrics;
  final int currentStreakDays;
  final String? errorMessage;

  double get goalProgress {
    if (dailyGoalMinutes <= 0) return 0.0;
    final progress = focusMinutesToday / dailyGoalMinutes;
    return progress.clamp(0.0, 1.0);
  }

  int get maxWeeklyMinutes {
    if (weeklyMetrics.isEmpty) return 60;
    final highest = weeklyMetrics
        .map((m) => m.focusMinutes)
        .fold<int>(0, (max, val) => val > max ? val : max);
    return highest > 60 ? highest : 60;
  }

  TodayState copyWith({
    TodayStatus? status,
    int? focusMinutesToday,
    int? dailyGoalMinutes,
    int? completedSessionsToday,
    int? completedTasksToday,
    List<DailyFocusMetric>? weeklyMetrics,
    int? currentStreakDays,
    String? errorMessage,
  }) {
    return TodayState(
      status: status ?? this.status,
      focusMinutesToday: focusMinutesToday ?? this.focusMinutesToday,
      dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
      completedSessionsToday:
          completedSessionsToday ?? this.completedSessionsToday,
      completedTasksToday: completedTasksToday ?? this.completedTasksToday,
      weeklyMetrics: weeklyMetrics ?? this.weeklyMetrics,
      currentStreakDays: currentStreakDays ?? this.currentStreakDays,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    focusMinutesToday,
    dailyGoalMinutes,
    completedSessionsToday,
    completedTasksToday,
    weeklyMetrics,
    currentStreakDays,
    errorMessage,
  ];
}
