import 'dart:async';

import 'package:focuspilot/features/focus/domain/models/focus_mode.dart';
import 'package:focuspilot/features/focus/domain/models/focus_session.dart';
import 'package:focuspilot/features/focus/domain/repositories/focus_session_repository.dart';

class FakeFocusSessionRepository implements FocusSessionRepository {
  final _controller = StreamController<List<FocusSession>>.broadcast();
  final List<FocusSession> _sessions = [];

  @override
  Future<void> saveSession(FocusSession session) async {
    _sessions.add(session);
    _controller.add(List.unmodifiable(_sessions));
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
          s.mode == FocusMode.work;
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

  void dispose() {
    _controller.close();
  }
}
