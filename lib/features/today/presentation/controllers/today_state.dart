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
    this.focusMinutesThisWeek = 0,
    this.weeklyGoalMinutes = 600,
    this.completedSessionsToday = 0,
    this.completedTasksToday = 0,
    this.weeklyMetrics = const [],
    this.heatmapDays = const [],
    this.currentStreakDays = 0,
    this.bestStreakDays = 0,
    this.daysGoalMetThisWeek = 0,
    this.priorityTasks = const [],
    this.errorMessage,
  });

  final TodayStatus status;
  final int focusMinutesToday;
  final int dailyGoalMinutes;
  final int focusMinutesThisWeek;
  final int weeklyGoalMinutes;
  final int completedSessionsToday;
  final int completedTasksToday;
  final List<DailyFocusMetric> weeklyMetrics;
  final List<HeatmapDay> heatmapDays;
  final int currentStreakDays;
  final int bestStreakDays;
  final int daysGoalMetThisWeek;
  final List<Task> priorityTasks;
  final String? errorMessage;

  double get goalProgress {
    if (dailyGoalMinutes <= 0) return 0.0;
    final progress = focusMinutesToday / dailyGoalMinutes;
    return progress.clamp(0.0, 1.0);
  }

  double get weeklyGoalProgress {
    if (weeklyGoalMinutes <= 0) return 0.0;
    final progress = focusMinutesThisWeek / weeklyGoalMinutes;
    return progress.clamp(0.0, 1.0);
  }

  bool get isDailyGoalAchieved =>
      dailyGoalMinutes > 0 && focusMinutesToday >= dailyGoalMinutes;

  bool get isWeeklyGoalAchieved =>
      weeklyGoalMinutes > 0 && focusMinutesThisWeek >= weeklyGoalMinutes;

  int get nextStreakMilestone {
    const milestones = [3, 7, 14, 21, 30, 60, 100, 365];
    for (final m in milestones) {
      if (currentStreakDays < m) return m;
    }
    return currentStreakDays + 10;
  }

  String get streakMilestoneBadge {
    if (currentStreakDays >= 30) return '🔥 Master Streak';
    if (currentStreakDays >= 14) return '⚡ Champion Streak';
    if (currentStreakDays >= 7) return '🌟 Weekly Pro';
    if (currentStreakDays >= 3) return '🚀 Momentum';
    return '🌱 Building Habit';
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
    int? focusMinutesThisWeek,
    int? weeklyGoalMinutes,
    int? completedSessionsToday,
    int? completedTasksToday,
    List<DailyFocusMetric>? weeklyMetrics,
    List<HeatmapDay>? heatmapDays,
    int? currentStreakDays,
    int? bestStreakDays,
    int? daysGoalMetThisWeek,
    List<Task>? priorityTasks,
    String? errorMessage,
  }) {
    return TodayState(
      status: status ?? this.status,
      focusMinutesToday: focusMinutesToday ?? this.focusMinutesToday,
      dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
      focusMinutesThisWeek: focusMinutesThisWeek ?? this.focusMinutesThisWeek,
      weeklyGoalMinutes: weeklyGoalMinutes ?? this.weeklyGoalMinutes,
      completedSessionsToday:
          completedSessionsToday ?? this.completedSessionsToday,
      completedTasksToday: completedTasksToday ?? this.completedTasksToday,
      weeklyMetrics: weeklyMetrics ?? this.weeklyMetrics,
      heatmapDays: heatmapDays ?? this.heatmapDays,
      currentStreakDays: currentStreakDays ?? this.currentStreakDays,
      bestStreakDays: bestStreakDays ?? this.bestStreakDays,
      daysGoalMetThisWeek: daysGoalMetThisWeek ?? this.daysGoalMetThisWeek,
      priorityTasks: priorityTasks ?? this.priorityTasks,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    focusMinutesToday,
    dailyGoalMinutes,
    focusMinutesThisWeek,
    weeklyGoalMinutes,
    completedSessionsToday,
    completedTasksToday,
    weeklyMetrics,
    heatmapDays,
    currentStreakDays,
    bestStreakDays,
    daysGoalMetThisWeek,
    priorityTasks,
    errorMessage,
  ];
}
