import 'dart:async';

import 'package:focuspilot/features/focus/domain/models/focus_mode.dart';
import 'package:focuspilot/features/focus/domain/models/focus_session.dart';
import 'package:focuspilot/features/focus/domain/repositories/focus_session_repository.dart';

class FakeFocusSessionRepository implements FocusSessionRepository {
  final _controller = StreamController<List<FocusSession>>.broadcast();
  final List<FocusSession> _sessions = [];

  void emitSessions(List<FocusSession> sessions) {
    _sessions.clear();
    _sessions.addAll(sessions);
    _controller.add(List.unmodifiable(_sessions));
  }

  void emitError(Object error) {
    _controller.addError(error);
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
  Future<void> saveSession(FocusSession session) async {
    _sessions.add(session);
    _controller.add(List.unmodifiable(_sessions));
  }

  @override
  Future<int> getCompletedSessionsCountToday() async {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    return _sessions.where((s) => s.completedAt.isAfter(startOfToday)).length;
  }

  @override
  Future<int> getTodayFocusMinutes() async {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final totalSeconds = _sessions
        .where(
          (s) =>
              s.completedAt.isAfter(startOfToday) && s.mode == FocusMode.work,
        )
        .fold<int>(0, (sum, s) => sum + s.durationSeconds);
    return (totalSeconds / 60).round();
  }

  void dispose() {
    _controller.close();
  }
}
