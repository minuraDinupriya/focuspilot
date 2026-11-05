import 'package:equatable/equatable.dart';
import 'package:focuspilot/features/tasks/domain/models/task.dart';
import 'package:focuspilot/features/today/domain/models/daily_focus_metric.dart';
import 'package:focuspilot/features/today/domain/models/heatmap_day.dart';

enum TodayStatus { initial, loading, loaded, error }

class TodayState extends Equatable {
  const TodayState({
    this.status = TodayStatus.initial,
    this.focusMinutesToday = 0,
    this.dailyGoalMinutes = 120,
    this.completedSessionsToday = 0,
    this.completedTasksToday = 0,
    this.weeklyMetrics = const [],
    this.heatmapDays = const [],
    this.currentStreakDays = 0,
    this.priorityTasks = const [],
    this.errorMessage,
  });

  final TodayStatus status;
  final int focusMinutesToday;
  final int dailyGoalMinutes;
  final int completedSessionsToday;
  final int completedTasksToday;
  final List<DailyFocusMetric> weeklyMetrics;
  final List<HeatmapDay> heatmapDays;
  final int currentStreakDays;
  final List<Task> priorityTasks;
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

  int get totalHeatmapMinutes =>
      heatmapDays.fold<int>(0, (sum, d) => sum + d.focusMinutes);

  double get totalHeatmapHours => totalHeatmapMinutes / 60.0;

  TodayState copyWith({
    TodayStatus? status,
    int? focusMinutesToday,
    int? dailyGoalMinutes,
    int? completedSessionsToday,
    int? completedTasksToday,
    List<DailyFocusMetric>? weeklyMetrics,
    List<HeatmapDay>? heatmapDays,
    int? currentStreakDays,
    List<Task>? priorityTasks,
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
      heatmapDays: heatmapDays ?? this.heatmapDays,
      currentStreakDays: currentStreakDays ?? this.currentStreakDays,
      priorityTasks: priorityTasks ?? this.priorityTasks,
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
    heatmapDays,
    currentStreakDays,
    priorityTasks,
    errorMessage,
  ];
}
