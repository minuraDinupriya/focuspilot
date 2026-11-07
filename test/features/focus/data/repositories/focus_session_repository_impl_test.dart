import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:focuspilot/features/focus/data/repositories/focus_session_repository_impl.dart';
import 'package:focuspilot/features/focus/domain/models/focus_mode.dart';
import 'package:focuspilot/features/focus/domain/models/focus_session.dart';
import 'package:focuspilot/features/tasks/data/datasources/database/app_database.dart';
import 'package:focuspilot/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:focuspilot/features/tasks/domain/models/task.dart';

class _FailingTaskRepository extends TaskRepositoryImpl {
  _FailingTaskRepository(super.database);

  @override
  Future<void> addActualMinutes(String taskId, int minutes) async {
    await super.addActualMinutes(taskId, minutes);
    throw StateError('Task credit failed');
  }
}

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

    test(
      'extends one work session and credits only additional minutes',
      () async {
        final tasks = TaskRepositoryImpl(database);
        final task = Task.create(title: 'Draft the report', actualMinutes: 7);
        await tasks.saveTask(task);
        final completedAt = DateTime(now.year, now.month, now.day, 12);
        final checkpoint = FocusSession(
          id: 'extended-work',
          mode: FocusMode.work,
          durationSeconds: 1500,
          completedAt: completedAt,
          taskId: task.id,
        );
        final extended = FocusSession(
          id: checkpoint.id,
          mode: checkpoint.mode,
          durationSeconds: 1530,
          completedAt: completedAt.add(const Duration(seconds: 30)),
          taskId: task.id,
          distractionCount: 2,
        );

        await repository.recordWorkSession(checkpoint);
        expect((await tasks.getTaskById(task.id))?.actualMinutes, 32);
        expect(await repository.getCompletedSessionsCountToday(), 1);

        await Future.wait([
          repository.recordWorkSession(extended),
          repository.recordWorkSession(extended),
        ]);
        await repository.recordWorkSession(checkpoint);

        expect(await repository.getSessions(), [extended]);
        expect(await repository.getCompletedSessionsCountToday(), 1);
        expect(await repository.getTodayFocusMinutes(), 26);
        expect(await repository.getTaskFocusMinutes(task.id), 26);
        expect((await tasks.getTaskById(task.id))?.actualMinutes, 33);
      },
    );

    test(
      'failed task credit rolls back the work session and can be retried',
      () async {
        final tasks = TaskRepositoryImpl(database);
        final task = Task.create(title: 'Review the report', actualMinutes: 7);
        await tasks.saveTask(task);
        final session = FocusSession.create(
          mode: FocusMode.work,
          durationSeconds: 1500,
          taskId: task.id,
        );
        final failingRepository = FocusSessionRepositoryImpl(
          database,
          taskRepository: _FailingTaskRepository(database),
        );

        await expectLater(
          failingRepository.recordWorkSession(session),
          throwsStateError,
        );
        expect(await repository.getSessions(), isEmpty);
        expect((await tasks.getTaskById(task.id))?.actualMinutes, 7);

        await repository.recordWorkSession(session);
        expect(await repository.getSessions(), hasLength(1));
        expect((await tasks.getTaskById(task.id))?.actualMinutes, 32);
      },
    );

    test('persists distraction count and session status correctly', () async {
      final sessionWithDistractions = FocusSession(
        id: 'session-distractions',
        mode: FocusMode.work,
        durationSeconds: 1200,
        completedAt: now,
        distractionCount: 4,
        status: SessionStatus.skipped,
      );

      await repository.saveSession(sessionWithDistractions);
      final retrieved = await repository.getSessions();
      final target = retrieved.firstWhere(
        (s) => s.id == 'session-distractions',
      );

      expect(target.distractionCount, 4);
      expect(target.status, SessionStatus.skipped);
    });

    test('getTaskFocusMinutes aggregates focus time linked to task', () async {
      final sessionTask1 = FocusSession(
        id: 's-task-1',
        mode: FocusMode.work,
        durationSeconds: 1500, // 25 mins
        completedAt: DateTime.now(),
        taskId: 'target-task',
      );
      final sessionTask2 = FocusSession(
        id: 's-task-2',
        mode: FocusMode.work,
        durationSeconds: 1200, // 20 mins
        completedAt: DateTime.now(),
        taskId: 'target-task',
      );
      final sessionBreak = FocusSession(
        id: 's-break',
        mode: FocusMode.shortBreak,
        durationSeconds: 300,
        completedAt: DateTime.now(),
        taskId: 'target-task',
      );

      await repository.saveSession(sessionTask1);
      await repository.saveSession(sessionTask2);
      await repository.saveSession(sessionBreak);

      final totalMinutes = await repository.getTaskFocusMinutes('target-task');
      expect(totalMinutes, 45); // 25 + 20 (break excluded)

      final nonExistent = await repository.getTaskFocusMinutes('other-task');
      expect(nonExistent, 0);
    });
  });
}
