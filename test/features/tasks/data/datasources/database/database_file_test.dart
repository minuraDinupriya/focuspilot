import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:focuspilot/features/focus/data/repositories/focus_session_repository_impl.dart';
import 'package:focuspilot/features/focus/domain/models/focus_mode.dart';
import 'package:focuspilot/features/focus/domain/models/focus_session.dart';
import 'package:focuspilot/features/settings/data/repositories/sqlite_settings_repository.dart';
import 'package:focuspilot/features/settings/domain/models/app_theme_mode.dart';
import 'package:focuspilot/features/settings/domain/models/user_settings.dart';
import 'package:focuspilot/features/tasks/data/datasources/database/app_database.dart';
import 'package:focuspilot/features/tasks/data/datasources/database/database_file.dart';
import 'package:focuspilot/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:focuspilot/features/tasks/domain/models/task.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory temporaryDirectory;
  late Directory documents;
  late Directory support;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'focuspilot-db-',
    );
    documents = await Directory(p.join(temporaryDirectory.path, 'Documents'))
        .create();
    support = Directory(p.join(temporaryDirectory.path, 'Application Support'));
  });

  tearDown(() async {
    await temporaryDirectory.delete(recursive: true);
  });

  Future<File> resolve({bool isWindows = true}) => resolveDatabaseFile(
    isWindows: isWindows,
    documentsDirectory: () async => documents,
    supportDirectory: () async => support,
  );

  test('non-Windows installations retain the Documents path', () async {
    final file = await resolveDatabaseFile(
      isWindows: false,
      documentsDirectory: () async => documents,
      supportDirectory: () => throw StateError('Must not request support'),
    );

    expect(file.path, p.join(documents.path, 'focuspilot.sqlite'));
    expect(await support.exists(), isFalse);
  });

  test(
    'new Windows installations create the application support directory',
    () async {
      final file = await resolve();

      expect(file.path, p.join(support.path, 'focuspilot.sqlite'));
      expect(await support.exists(), isTrue);
      expect(
        await File(p.join(documents.path, 'focuspilot.sqlite')).exists(),
        isFalse,
      );
    },
  );

  test('legacy Windows data and SQLite sidecars remain in place', () async {
    final legacy = await File(p.join(documents.path, 'focuspilot.sqlite'))
        .writeAsString('legacy database');
    final wal = await File('${legacy.path}-wal')
        .writeAsString('pending writes');
    final shm = await File('${legacy.path}-shm').writeAsString('shared memory');

    expect((await resolve()).path, legacy.path);
    expect(await legacy.readAsString(), 'legacy database');
    expect(await wal.readAsString(), 'pending writes');
    expect(await shm.readAsString(), 'shared memory');
    expect(await support.exists(), isFalse);
  });

  test(
    'legacy data takes precedence when both database locations exist',
    () async {
      final legacy = await File(p.join(documents.path, 'focuspilot.sqlite'))
          .writeAsString('legacy data');
      await support.create(recursive: true);
      final other = await File(p.join(support.path, 'focuspilot.sqlite'))
          .writeAsString('support data');

      expect((await resolve()).path, legacy.path);
      expect(await legacy.readAsString(), 'legacy data');
      expect(await other.readAsString(), 'support data');
    },
  );

  for (final legacy in [false, true]) {
    test(
      'tasks, settings, and session credits survive reopening ${legacy ? 'legacy' : 'new'} Windows data',
      () async {
        final file = legacy
            ? File(p.join(documents.path, 'focuspilot.sqlite'))
            : await resolve();
        var database = AppDatabase(NativeDatabase.createInBackground(file));
        try {
          final tasks = TaskRepositoryImpl(database);
          final task = Task.create(
            title: 'Review transactions',
            scheduledStart: DateTime(2026, 11, 21, 9),
            estimatedMinutes: 45,
          );
          await tasks.saveTask(task);
          await tasks.addSubtask(task.id, 'Practice isolation levels');
          final subtask = (await tasks.getTaskById(task.id))!.subtasks.single;
          await tasks.toggleSubtaskCompletion(subtask.id);
          const settings = UserSettings(
            workDurationMinutes: 45,
            themeMode: AppThemeMode.dark,
          );
          await SqliteSettingsRepository(database).saveSettings(settings);
          final session = FocusSession(
            id: 'work-session',
            mode: FocusMode.work,
            durationSeconds: 1500,
            completedAt: DateTime(2026, 11, 21, 10),
            taskId: task.id,
          );
          await FocusSessionRepositoryImpl(database).recordWorkSession(session);
          await database.close();

          final reopenedFile = await resolve();
          expect(reopenedFile.path, file.path);
          database = AppDatabase(
            NativeDatabase.createInBackground(reopenedFile),
          );
          final restored = await TaskRepositoryImpl(database)
              .getTaskById(task.id);
          expect(restored?.title, task.title);
          expect(restored?.scheduledStart, task.scheduledStart);
          expect(restored?.estimatedMinutes, 45);
          expect(restored?.actualMinutes, 25);
          expect(restored?.subtasks.single.id, subtask.id);
          expect(restored?.subtasks.single.isCompleted, isTrue);
          expect(
            await SqliteSettingsRepository(database).getSettings(),
            settings,
          );
          final sessions = FocusSessionRepositoryImpl(database);
          expect(await sessions.getSessions(), [session]);

          // Retrying the same completed session must not credit its task twice.
          await sessions.recordWorkSession(session);
          expect(
            (await TaskRepositoryImpl(database).getTaskById(task.id))
                ?.actualMinutes,
            25,
          );
          expect(database.schemaVersion, 11);
        } finally {
          await database.close();
        }
      },
    );
  }
}
