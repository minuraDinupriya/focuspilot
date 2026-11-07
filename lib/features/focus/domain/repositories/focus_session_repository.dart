import 'package:focuspilot/features/focus/domain/models/focus_session.dart';

abstract class FocusSessionRepository {
  Future<void> saveSession(FocusSession session);

  /// Records or extends a work session and credits its linked task atomically.
  ///
  /// Reuse the same session ID and task ID when extending or retrying. Task
  /// credit changes only by the difference in rounded minutes, and an older
  /// shorter record cannot undo an extension. Use this method for each write
  /// to that session ID.
  Future<void> recordWorkSession(FocusSession session);

  Stream<List<FocusSession>> watchSessions();

  Future<List<FocusSession>> getSessions();

  Future<int> getCompletedSessionsCountToday();

  Future<int> getTodayFocusMinutes();

  Future<int> getTaskFocusMinutes(String taskId);
}
