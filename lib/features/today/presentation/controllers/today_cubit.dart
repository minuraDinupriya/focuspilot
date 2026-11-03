import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focuspilot/features/focus/domain/models/focus_mode.dart';
import 'package:focuspilot/features/focus/domain/models/focus_session.dart';
import 'package:focuspilot/features/focus/domain/repositories/focus_session_repository.dart';
import 'package:focuspilot/features/tasks/domain/repositories/task_repository.dart';
import 'package:focuspilot/features/today/domain/models/daily_focus_metric.dart';
import 'package:focuspilot/features/today/presentation/controllers/today_state.dart';

class TodayCubit extends Cubit<TodayState> {
  TodayCubit({
    required FocusSessionRepository sessionRepository,
    required TaskRepository taskRepository,
  }) : this._(sessionRepository, taskRepository);

  TodayCubit._(this._sessionRepository, this._taskRepository)
    : super(const TodayState()) {
    _initSubscriptions();
  }

  final FocusSessionRepository _sessionRepository;
  final TaskRepository _taskRepository;

  StreamSubscription? _sessionSubscription;
  StreamSubscription? _taskSubscription;

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

      // Compute last 7 days metrics
      final weeklyMetrics = _calculateWeeklyMetrics(sessions, now);

      // Compute streak
      final streak = _calculateStreak(sessions, now);

      emit(
        state.copyWith(
          status: TodayStatus.loaded,
          focusMinutesToday: focusMinutes,
          completedSessionsToday: completedWorkSessions.length,
          completedTasksToday: completedTasksCount,
          weeklyMetrics: weeklyMetrics,
          currentStreakDays: streak,
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

      // targetDate.weekday: 1 is Mon, 7 is Sun
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

  int _calculateStreak(List<FocusSession> sessions, DateTime now) {
    final workSessions = sessions.where((s) => s.mode == FocusMode.work);
    if (workSessions.isEmpty) return 0;

    // Collect dates that have at least 1 completed work session
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

    // A streak can continue if the user either focused today OR focused yesterday
    DateTime checkDate;
    if (activeDates.contains(today)) {
      checkDate = today;
    } else if (activeDates.contains(yesterday)) {
      checkDate = yesterday;
    } else {
      return 0; // Streak broken
    }

    int streak = 0;
    while (activeDates.contains(checkDate)) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    return streak;
  }

  Future<void> refresh() async {
    await _recalculate();
  }

  @override
  Future<void> close() {
    _sessionSubscription?.cancel();
    _taskSubscription?.cancel();
    return super.close();
  }
}
