import 'package:focuspilot/features/focus/domain/models/focus_session.dart';

abstract class FocusSessionRepository {
  Future<void> saveSession(FocusSession session);

  Stream<List<FocusSession>> watchSessions();

  Future<List<FocusSession>> getSessions();

  Future<int> getCompletedSessionsCountToday();

  Future<int> getTodayFocusMinutes();

  Future<int> getTaskFocusMinutes(String taskId);
}
