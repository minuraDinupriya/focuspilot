import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focuspilot/features/focus/domain/models/focus_mode.dart';
import 'package:focuspilot/features/focus/domain/models/focus_session.dart';
import 'package:focuspilot/features/focus/domain/repositories/focus_session_repository.dart';
import 'package:focuspilot/features/settings/domain/repositories/settings_repository.dart';
import 'package:focuspilot/features/tasks/domain/models/task.dart';
import 'package:focuspilot/features/tasks/domain/models/task_priority.dart';
import 'package:focuspilot/features/tasks/domain/repositories/task_repository.dart';
import 'package:focuspilot/features/today/domain/models/daily_focus_metric.dart';
import 'package:focuspilot/features/today/domain/models/heatmap_day.dart';
import 'package:focuspilot/features/today/domain/models/productivity_insight.dart';
import 'package:focuspilot/features/today/presentation/controllers/today_state.dart';

class TodayCubit extends Cubit<TodayState> {
  TodayCubit({
    required FocusSessionRepository sessionRepository,
    required TaskRepository taskRepository,
    SettingsRepository? settingsRepository,
  }) : this._(sessionRepository, taskRepository, settingsRepository);

  TodayCubit._(
    this._sessionRepository,
    this._taskRepository,
    this._settingsRepository,
  ) : super(const TodayState()) {
    _initSubscriptions();
  }

  final FocusSessionRepository _sessionRepository;
  final TaskRepository _taskRepository;
  final SettingsRepository? _settingsRepository;

  StreamSubscription? _sessionSubscription;
  StreamSubscription? _taskSubscription;
  StreamSubscription? _settingsSubscription;

  void _initSubscriptions() {
    emit(state.copyWith(status: TodayStatus.loading));

    _sessionSubscription = _sessionRepository.watchSessions().listen(
      (sessions) {
        if (!isClosed) _recalculate();
      },
      onError: (e) {
        if (!isClosed) {
          emit(
            state.copyWith(
              status: TodayStatus.error,
              errorMessage: e.toString(),
            ),
          );
        }
      },
    );

    _taskSubscription = _taskRepository.watchTasks().listen(
      (tasks) {
        if (!isClosed) _recalculate();
      },
      onError: (e) {
        if (!isClosed) {
          emit(
            state.copyWith(
              status: TodayStatus.error,
              errorMessage: e.toString(),
            ),
          );
        }
      },
    );

    if (_settingsRepository != null) {
      _settingsSubscription = _settingsRepository.watchSettings().listen((
        settings,
      ) {
        if (!isClosed) {
          emit(
            state.copyWith(
              dailyGoalMinutes: settings.dailyGoalMinutes,
              weeklyGoalMinutes: settings.weeklyGoalMinutes,
            ),
          );
        }
      });
    }

    _recalculate();
  }

  Future<void> _recalculate() async {
    try {
      final now = DateTime.now();
      final startOfToday = DateTime(now.year, now.month, now.day);
      final endOfToday = DateTime(
        now.year,
        now.month,
        now.day,
        23,
        59,
        59,
        999,
      );

      final sessions = await _sessionRepository.getSessions();
      if (isClosed) return;

      final todaySessions = sessions.where((s) {
        return s.completedAt.isAfter(startOfToday) &&
            s.completedAt.isBefore(endOfToday);
      }).toList();

      final completedWorkSessions = todaySessions.where(
        (s) => s.mode == FocusMode.work,
      );

      final totalSeconds = completedWorkSessions.fold<int>(
        0,
        (sum, s) => sum + s.durationSeconds,
      );
      final focusMinutes = (totalSeconds / 60).round();

      final tasks = await _taskRepository.getTasks();
      if (isClosed) return;

      final completedTasksCount = tasks.where((t) => t.isCompleted).length;

      // Extract pending priority tasks (High priority first, max 3)
      final pendingTasks = tasks.where((t) => !t.isCompleted).toList();
      pendingTasks.sort((a, b) {
        final aWeight = _priorityWeight(a.priority);
        final bWeight = _priorityWeight(b.priority);
        return bWeight.compareTo(aWeight); // highest weight first
      });
      final priorityTasks = pendingTasks.take(3).toList();

      // Compute last 7 days metrics
      final weeklyMetrics = _calculateWeeklyMetrics(sessions, now);

      // Compute last 91 days (13 weeks) heatmap days
      final heatmapDays = _calculateHeatmapDays(sessions, now);

      // Compute streak and best historical streak
      final streak = _calculateStreak(sessions, now);
      final bestStreak = _calculateBestStreak(sessions);

      int goalMinutes = state.dailyGoalMinutes;
      int weeklyGoalMinutes = state.weeklyGoalMinutes;
      if (_settingsRepository != null) {
        final s = await _settingsRepository.getSettings();
        goalMinutes = s.dailyGoalMinutes;
        weeklyGoalMinutes = s.weeklyGoalMinutes;
      }

      // Compute weekly focus minutes and days goal met
      final focusMinutesThisWeek = weeklyMetrics.fold<int>(
        0,
        (sum, m) => sum + m.focusMinutes,
      );
      final daysGoalMetThisWeek = weeklyMetrics
          .where((m) => m.focusMinutes >= goalMinutes)
          .length;

      // Compute task productivity insights (FOC-33)
      final categoryInsights = _calculateCategoryInsights(tasks);
      final priorityInsights = _calculatePriorityInsights(tasks);
      final topTasksInsights = _calculateTopTasksInsights(tasks);

      emit(
        state.copyWith(
          status: TodayStatus.loaded,
          focusMinutesToday: focusMinutes,
          dailyGoalMinutes: goalMinutes,
          focusMinutesThisWeek: focusMinutesThisWeek,
          weeklyGoalMinutes: weeklyGoalMinutes,
          completedSessionsToday: completedWorkSessions.length,
          completedTasksToday: completedTasksCount,
          weeklyMetrics: weeklyMetrics,
          heatmapDays: heatmapDays,
          currentStreakDays: streak,
          bestStreakDays: bestStreak,
          daysGoalMetThisWeek: daysGoalMetThisWeek,
          priorityTasks: priorityTasks,
          categoryInsights: categoryInsights,
          priorityInsights: priorityInsights,
          topTasksInsights: topTasksInsights,
        ),
      );
    } catch (e) {
      if (!isClosed) {
        emit(
          state.copyWith(status: TodayStatus.error, errorMessage: e.toString()),
        );
      }
    }
  }

  int _priorityWeight(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return 3;
      case TaskPriority.medium:
        return 2;
      case TaskPriority.low:
        return 1;
    }
  }

  Future<void> toggleTask(String id) async {
    try {
      await _taskRepository.toggleTaskCompletion(id);
    } catch (e) {
      if (!isClosed) {
        emit(
          state.copyWith(status: TodayStatus.error, errorMessage: e.toString()),
        );
      }
    }
  }

  static const _dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  List<DailyFocusMetric> _calculateWeeklyMetrics(
    List<FocusSession> sessions,
    DateTime now,
  ) {
    final metrics = <DailyFocusMetric>[];
    final workSessions = sessions.where((s) => s.mode == FocusMode.work);

    for (int i = 6; i >= 0; i--) {
      final targetDate = now.subtract(Duration(days: i));
      final dayStart = DateTime(
        targetDate.year,
        targetDate.month,
        targetDate.day,
      );
      final dayEnd = DateTime(
        targetDate.year,
        targetDate.month,
        targetDate.day,
        23,
        59,
        59,
        999,
      );

      final daySessions = workSessions.where((s) {
        return s.completedAt.isAfter(dayStart) &&
            s.completedAt.isBefore(dayEnd);
      });

      final totalSecs = daySessions.fold<int>(
        0,
        (sum, s) => sum + s.durationSeconds,
      );
      final minutes = (totalSecs / 60).round();

      final label = _dayLabels[targetDate.weekday - 1];

      metrics.add(
        DailyFocusMetric(
          date: dayStart,
          dayLabel: label,
          focusMinutes: minutes,
          isToday: i == 0,
        ),
      );
    }

    return metrics;
  }

  List<HeatmapDay> _calculateHeatmapDays(
    List<FocusSession> sessions,
    DateTime now,
  ) {
    final workSessions = sessions.where((s) => s.mode == FocusMode.work);
    final minutesByDate = <DateTime, int>{};

    for (final s in workSessions) {
      final d = DateTime(
        s.completedAt.year,
        s.completedAt.month,
        s.completedAt.day,
      );
      minutesByDate[d] =
          (minutesByDate[d] ?? 0) + (s.durationSeconds / 60).round();
    }

    final today = DateTime(now.year, now.month, now.day);
    // Align to Monday of 12 weeks ago (total 13 weeks = 91 days)
    final daysSinceMonday = today.weekday - 1;
    final currentWeekMonday = today.subtract(Duration(days: daysSinceMonday));
    final startDate = currentWeekMonday.subtract(const Duration(days: 12 * 7));

    final heatmap = <HeatmapDay>[];
    for (int i = 0; i < 91; i++) {
      final date = startDate.add(Duration(days: i));
      final minutes = minutesByDate[date] ?? 0;
      heatmap.add(HeatmapDay.fromMinutes(date: date, focusMinutes: minutes));
    }

    return heatmap;
  }

  int _calculateStreak(List<FocusSession> sessions, DateTime now) {
    final workSessions = sessions.where((s) => s.mode == FocusMode.work);
    if (workSessions.isEmpty) return 0;

    final activeDates = <DateTime>{};
    for (final session in workSessions) {
      final date = DateTime(
        session.completedAt.year,
        session.completedAt.month,
        session.completedAt.day,
      );
      activeDates.add(date);
    }

    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    DateTime checkDate;
    if (activeDates.contains(today)) {
      checkDate = today;
    } else if (activeDates.contains(yesterday)) {
      checkDate = yesterday;
    } else {
      return 0;
    }

    int streak = 0;
    while (activeDates.contains(checkDate)) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    return streak;
  }

  int _calculateBestStreak(List<FocusSession> sessions) {
    final workSessions = sessions.where((s) => s.mode == FocusMode.work);
    if (workSessions.isEmpty) return 0;

    final dates =
        workSessions
            .map((s) {
              return DateTime(
                s.completedAt.year,
                s.completedAt.month,
                s.completedAt.day,
              );
            })
            .toSet()
            .toList()
          ..sort();

    int maxStreak = 1;
    int current = 1;
    for (int i = 1; i < dates.length; i++) {
      if (dates[i].difference(dates[i - 1]).inDays == 1) {
        current++;
        if (current > maxStreak) maxStreak = current;
      } else {
        current = 1;
      }
    }
    return maxStreak;
  }

  List<CategoryFocusInsight> _calculateCategoryInsights(List<Task> tasks) {
    final map = <String, int>{};
    for (final task in tasks) {
      if (task.actualMinutes > 0) {
        final cat = task.category?.trim().isNotEmpty ?? false
            ? task.category!.trim()
            : 'General';
        map[cat] = (map[cat] ?? 0) + task.actualMinutes;
      }
    }
    final total = map.values.fold<int>(0, (sum, m) => sum + m);
    final insights = map.entries.map((entry) {
      final percentage = total > 0 ? (entry.value / total) : 0.0;
      return CategoryFocusInsight(
        category: entry.key,
        minutes: entry.value,
        percentage: percentage,
      );
    }).toList();
    insights.sort((a, b) => b.minutes.compareTo(a.minutes));
    return insights;
  }

  List<PriorityFocusInsight> _calculatePriorityInsights(List<Task> tasks) {
    final map = <TaskPriority, int>{
      TaskPriority.high: 0,
      TaskPriority.medium: 0,
      TaskPriority.low: 0,
    };
    for (final task in tasks) {
      if (task.actualMinutes > 0) {
        map[task.priority] = (map[task.priority] ?? 0) + task.actualMinutes;
      }
    }
    final total = map.values.fold<int>(0, (sum, m) => sum + m);
    return TaskPriority.values.map((priority) {
      final mins = map[priority] ?? 0;
      final percentage = total > 0 ? (mins / total) : 0.0;
      return PriorityFocusInsight(
        priority: priority,
        minutes: mins,
        percentage: percentage,
      );
    }).toList();
  }

  List<TopTaskFocusInsight> _calculateTopTasksInsights(List<Task> tasks) {
    final focusedTasks = tasks.where((t) => t.actualMinutes > 0).toList();
    focusedTasks.sort((a, b) => b.actualMinutes.compareTo(a.actualMinutes));
    return focusedTasks.take(5).map((t) {
      return TopTaskFocusInsight(
        taskId: t.id,
        title: t.title,
        actualMinutes: t.actualMinutes,
        estimatedMinutes: t.estimatedMinutes,
      );
    }).toList();
  }

  Future<void> refresh() async {
    await _recalculate();
  }

  @override
  Future<void> close() {
    _sessionSubscription?.cancel();
    _taskSubscription?.cancel();
    _settingsSubscription?.cancel();
    return super.close();
  }
}
