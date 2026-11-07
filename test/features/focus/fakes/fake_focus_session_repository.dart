import 'dart:async';

import 'package:focuspilot/features/focus/domain/models/focus_mode.dart';
import 'package:focuspilot/features/focus/domain/models/focus_session.dart';
import 'package:focuspilot/features/focus/domain/repositories/focus_session_repository.dart';
import 'package:focuspilot/features/tasks/domain/repositories/task_repository.dart';

class FakeFocusSessionRepository implements FocusSessionRepository {
  FakeFocusSessionRepository({this.taskRepository});

  final TaskRepository? taskRepository;
  final _controller = StreamController<List<FocusSession>>.broadcast();
  final List<FocusSession> _sessions = [];
  Future<void> _pendingRecord = Future<void>.value();

  @override
  Future<void> saveSession(FocusSession session) async {
    final index = _sessions.indexWhere((entry) => entry.id == session.id);
    if (index < 0) {
      _sessions.add(session);
    } else {
      _sessions[index] = session;
    }
    _controller.add(List.unmodifiable(_sessions));
  }

  @override
  Future<void> recordWorkSession(FocusSession session) {
    final record = _pendingRecord.then((_) async {
      if (session.mode != FocusMode.work) {
        throw ArgumentError.value(session.mode, 'session.mode', 'must be work');
      }

      final index = _sessions.indexWhere((entry) => entry.id == session.id);
      final previous = index < 0 ? null : _sessions[index];
      if (previous != null) {
        if (previous.mode != FocusMode.work ||
            previous.taskId != session.taskId) {
          throw StateError(
            'The recorded work session has a different mode or task.',
          );
        }
        if (previous.durationSeconds > session.durationSeconds) return;
      }

      final taskId = session.taskId;
      final previousMinutes = ((previous?.durationSeconds ?? 0) / 60).round();
      final addedMinutes =
          (session.durationSeconds / 60).round() - previousMinutes;
      if (taskId != null && addedMinutes > 0) {
        await taskRepository?.addActualMinutes(taskId, addedMinutes);
      }
      await saveSession(session);
    });
    _pendingRecord = record.then<void>((_) {}, onError: (Object _) {});
    return record;
  }

  @override
  Stream<List<FocusSession>> watchSessions() {
    scheduleMicrotask(() => _controller.add(List.unmodifiable(_sessions)));
    return _controller.stream;
  }

  @override
  Future<List<FocusSession>> getSessions() async =>
      List.unmodifiable(_sessions);

  @override
  Future<int> getCompletedSessionsCountToday() async {
    final now = DateTime.now();
    return _sessions.where((s) {
      return s.completedAt.year == now.year &&
          s.completedAt.month == now.month &&
          s.completedAt.day == now.day &&
          s.mode == FocusMode.work &&
          s.status == SessionStatus.completed;
    }).length;
  }

  @override
  Future<int> getTodayFocusMinutes() async {
    final now = DateTime.now();
    final todayWorkSessions = _sessions.where((s) {
      return s.completedAt.year == now.year &&
          s.completedAt.month == now.month &&
          s.completedAt.day == now.day &&
          s.mode == FocusMode.work;
    });
    final totalSeconds = todayWorkSessions.fold<int>(
      0,
      (sum, s) => sum + s.durationSeconds,
    );
    return (totalSeconds / 60).round();
  }

  @override
  Future<int> getTaskFocusMinutes(String taskId) async {
    final taskSessions = _sessions.where((s) {
      return s.taskId == taskId && s.mode == FocusMode.work;
    });
    final totalSeconds = taskSessions.fold<int>(
      0,
      (sum, s) => sum + s.durationSeconds,
    );
    return (totalSeconds / 60).round();
  }

  void dispose() {
    _controller.close();
  }
}
