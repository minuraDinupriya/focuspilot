import 'package:drift/drift.dart';
import 'package:focuspilot/features/focus/domain/models/focus_mode.dart';
import 'package:focuspilot/features/focus/domain/models/focus_session.dart';
import 'package:focuspilot/features/focus/domain/repositories/focus_session_repository.dart';
import 'package:focuspilot/features/tasks/data/datasources/database/app_database.dart';

class FocusSessionRepositoryImpl implements FocusSessionRepository {
  FocusSessionRepositoryImpl(this._database);

  final AppDatabase _database;

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
