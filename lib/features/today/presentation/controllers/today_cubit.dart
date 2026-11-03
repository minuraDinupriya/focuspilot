import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focuspilot/features/focus/domain/models/focus_mode.dart';
import 'package:focuspilot/features/focus/domain/repositories/focus_session_repository.dart';
import 'package:focuspilot/features/tasks/domain/repositories/task_repository.dart';
import 'package:focuspilot/features/today/presentation/controllers/today_state.dart';

class TodayCubit extends Cubit<TodayState> {
  TodayCubit({
    required FocusSessionRepository sessionRepository,
    required TaskRepository taskRepository,
  }) : this._(
         sessionRepository,
         taskRepository,
       );

  TodayCubit._(
    this._sessionRepository,
    this._taskRepository,
  ) : super(const TodayState()) {
    _initSubscriptions();
  }

  final FocusSessionRepository _sessionRepository;
  final TaskRepository _taskRepository;

  StreamSubscription? _sessionSubscription;
  StreamSubscription? _taskSubscription;

  void _initSubscriptions() {
    emit(state.copyWith(status: TodayStatus.loading));

    // Watch both streams so Today automatically recalculates whenever
    // a Pomodoro completes or a task is created/toggled!
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
      final endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

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

      emit(
        state.copyWith(
          status: TodayStatus.loaded,
          focusMinutesToday: focusMinutes,
          completedSessionsToday: completedWorkSessions.length,
          completedTasksToday: completedTasksCount,
        ),
      );
    } catch (e) {
      if (!isClosed) {
        emit(
          state.copyWith(
            status: TodayStatus.error,
            errorMessage: e.toString(),
          ),
        );
      }
    }
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
