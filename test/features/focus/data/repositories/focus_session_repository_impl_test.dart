import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:focuspilot/features/focus/data/repositories/focus_session_repository_impl.dart';
import 'package:focuspilot/features/focus/domain/models/focus_mode.dart';
import 'package:focuspilot/features/focus/domain/models/focus_session.dart';
import 'package:focuspilot/features/tasks/data/datasources/database/app_database.dart';

void main() {
  late AppDatabase database;
  late FocusSessionRepositoryImpl repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = FocusSessionRepositoryImpl(database);
  });

  tearDown(() async {
    await database.close();
  });

  group('FocusSessionRepositoryImpl', () {
    final now = DateTime.now();

    final session1 = FocusSession(
      id: 'session-1',
      mode: FocusMode.work,
      durationSeconds: 1500,
      completedAt: now,
      taskId: 'task-1',
    );

    final session2 = FocusSession(
      id: 'session-2',
      mode: FocusMode.shortBreak,
      durationSeconds: 300,
      completedAt: now,
    );

    test(
      'saveSession and getSessions persists and retrieves sessions',
      () async {
        await repository.saveSession(session1);
        await repository.saveSession(session2);

        final sessions = await repository.getSessions();

        expect(sessions.length, 2);
        expect(sessions.any((s) => s.id == 'session-1'), isTrue);
        expect(sessions.any((s) => s.id == 'session-2'), isTrue);
      },
    );

    test(
      'getCompletedSessionsCountToday counts only today work sessions',
      () async {
        await repository.saveSession(session1);
        await repository.saveSession(
          session2,
        ); // break, not counted as focus session

        final count = await repository.getCompletedSessionsCountToday();
        expect(count, 1);
      },
    );

    test('getTodayFocusMinutes calculates minutes accurately', () async {
      await repository.saveSession(session1); // 1500 sec = 25 min

      final minutes = await repository.getTodayFocusMinutes();
      expect(minutes, 25);
    });
  });
}
