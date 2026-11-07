import 'package:drift/drift.dart';
import 'package:focuspilot/features/focus/domain/models/focus_mode.dart';
import 'package:focuspilot/features/focus/domain/models/focus_session.dart';
import 'package:focuspilot/features/focus/domain/repositories/focus_session_repository.dart';
import 'package:focuspilot/features/tasks/data/datasources/database/app_database.dart';
import 'package:focuspilot/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:focuspilot/features/tasks/domain/repositories/task_repository.dart';

class FocusSessionRepositoryImpl implements FocusSessionRepository {
  /// [taskRepository] must use the same database to share write transactions.
  FocusSessionRepositoryImpl(this._database, {TaskRepository? taskRepository})
    : _taskRepository = taskRepository ?? TaskRepositoryImpl(_database);

  final AppDatabase _database;
  final TaskRepository _taskRepository;

  @override
  Future<void> saveSession(FocusSession session) async {
    await _database
        .into(_database.focusSessionEntries)
        .insertOnConflictUpdate(
          FocusSessionEntriesCompanion.insert(
            id: session.id,
            mode: session.mode.name,
            durationSeconds: session.durationSeconds,
            completedAt: session.completedAt,
            taskId: Value(session.taskId),
            distractionCount: Value(session.distractionCount),
            status: Value(session.status.name),
          ),
        );
  }

  @override
  Future<void> recordWorkSession(FocusSession session) async {
    if (session.mode != FocusMode.work) {
      throw ArgumentError.value(session.mode, 'session.mode', 'must be work');
    }

    await _database.transaction(() async {
      final query = _database.select(_database.focusSessionEntries)
        ..where((table) => table.id.equals(session.id));
      final previous = await query.getSingleOrNull();
      if (previous != null) {
        if (previous.mode != FocusMode.work.name ||
            previous.taskId != session.taskId) {
          throw StateError(
            'The recorded work session has a different mode or task.',
          );
        }
        if (previous.durationSeconds > session.durationSeconds) return;
      }

      await saveSession(session);
      final taskId = session.taskId;
      final previousMinutes = ((previous?.durationSeconds ?? 0) / 60).round();
      final addedMinutes =
          (session.durationSeconds / 60).round() - previousMinutes;
      if (taskId != null && addedMinutes > 0) {
        await _taskRepository.addActualMinutes(taskId, addedMinutes);
      }
    });
  }

  @override
  Stream<List<FocusSession>> watchSessions() {
    final query = _database.select(_database.focusSessionEntries)
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.completedAt)]);

    return query.watch().map((rows) => rows.map(_toDomain).toList());
  }

  @override
  Future<List<FocusSession>> getSessions() async {
    final query = _database.select(_database.focusSessionEntries)
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.completedAt)]);

    final rows = await query.get();
    return rows.map(_toDomain).toList();
  }

  @override
  Future<int> getCompletedSessionsCountToday() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    final query = _database.select(_database.focusSessionEntries)
      ..where(
        (tbl) =>
            tbl.completedAt.isBiggerOrEqualValue(startOfDay) &
            tbl.completedAt.isSmallerOrEqualValue(endOfDay) &
            tbl.mode.equals(FocusMode.work.name) &
            tbl.status.equals(SessionStatus.completed.name),
      );

    final rows = await query.get();
    return rows.length;
  }

  @override
  Future<int> getTodayFocusMinutes() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    final query = _database.select(_database.focusSessionEntries)
      ..where(
        (tbl) =>
            tbl.completedAt.isBiggerOrEqualValue(startOfDay) &
            tbl.completedAt.isSmallerOrEqualValue(endOfDay) &
            tbl.mode.equals(FocusMode.work.name),
      );

    final rows = await query.get();
    final totalSeconds = rows.fold<int>(0, (sum, s) => sum + s.durationSeconds);
    return (totalSeconds / 60).round();
  }

  @override
  Future<int> getTaskFocusMinutes(String taskId) async {
    final query = _database.select(_database.focusSessionEntries)
      ..where(
        (tbl) =>
            tbl.taskId.equals(taskId) & tbl.mode.equals(FocusMode.work.name),
      );

    final rows = await query.get();
    final totalSeconds = rows.fold<int>(0, (sum, s) => sum + s.durationSeconds);
    return (totalSeconds / 60).round();
  }

  FocusSession _toDomain(FocusSessionEntry entry) {
    return FocusSession(
      id: entry.id,
      mode: FocusMode.fromString(entry.mode),
      durationSeconds: entry.durationSeconds,
      completedAt: entry.completedAt,
      taskId: entry.taskId,
      distractionCount: entry.distractionCount,
      status: SessionStatus.fromString(entry.status),
    );
  }
}
