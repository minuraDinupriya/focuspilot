import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:focuspilot/features/tasks/data/datasources/database/app_database.dart';
import 'package:focuspilot/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:focuspilot/features/tasks/domain/models/task.dart';
import 'package:focuspilot/features/tasks/domain/models/task_priority.dart';

void main() {
  late AppDatabase database;
  late TaskRepositoryImpl repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = TaskRepositoryImpl(database);
  });

  tearDown(() async {
    await database.close();
  });

  group('TaskRepositoryImpl', () {
    final task1 = Task(
      id: 'task-1',
      title: 'Study Data Structures',
      description: 'Trees and Graphs',
      priority: TaskPriority.high,
      createdAt: DateTime(2026, 11, 1, 9, 0),
    );

    final task2 = Task(
      id: 'task-2',
      title: 'Workout',
      priority: TaskPriority.low,
      createdAt: DateTime(2026, 11, 1, 8, 0),
    );

    test('saveTask and getTasks persists and retrieves tasks', () async {
      await repository.saveTask(task1);
      await repository.saveTask(task2);

      final tasks = await repository.getTasks();

      expect(tasks.length, 2);
      expect(tasks, contains(task1));
      expect(tasks, contains(task2));
    });

    test('getTaskById retrieves single task or null if not found', () async {
      await repository.saveTask(task1);

      final found = await repository.getTaskById('task-1');
      final notFound = await repository.getTaskById('unknown-id');

      expect(found, equals(task1));
      expect(notFound, isNull);
    });

    test('deleteTask removes task from database', () async {
      await repository.saveTask(task1);
      await repository.saveTask(task2);

      await repository.deleteTask('task-1');

      final tasks = await repository.getTasks();
      expect(tasks.length, 1);
      expect(tasks.first.id, 'task-2');
    });

    test(
      'toggleTaskCompletion flips isCompleted and completes timestamp',
      () async {
        await repository.saveTask(task1);

        // Toggle to completed
        await repository.toggleTaskCompletion('task-1');
        var updated = await repository.getTaskById('task-1');

        expect(updated?.isCompleted, isTrue);
        expect(updated?.completedAt, isNotNull);

        // Toggle back to incomplete
        await repository.toggleTaskCompletion('task-1');
        updated = await repository.getTaskById('task-1');

        expect(updated?.isCompleted, isFalse);
        expect(updated?.completedAt, isNull);
      },
    );

    test('watchTasks emits updated list when data changes', () async {
      final stream = repository.watchTasks();

      final expectation = expectLater(
        stream,
        emitsInOrder([
          isEmpty,
          [task1],
          [task1, task2],
        ]),
      );

      // Yield event loop to allow watch() to emit initial empty state
      await pumpEventQueue();

      await repository.saveTask(task1);
      await pumpEventQueue();

      await repository.saveTask(task2);
      await pumpEventQueue();

      await expectation;
    });
  });
}
