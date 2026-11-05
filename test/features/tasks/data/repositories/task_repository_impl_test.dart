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

    test(
      'persists category, tags, estimatedMinutes and recurrenceRule',
      () async {
        final advancedTask = Task(
          id: 'task-adv',
          title: 'Algorithms Homework',
          category: 'Study',
          tags: const ['cs101', 'midterm'],
          estimatedMinutes: 90,
          recurrenceRule: 'weekly',
          createdAt: DateTime(2026, 11, 4, 10, 0),
        );

        await repository.saveTask(advancedTask);
        final retrieved = await repository.getTaskById('task-adv');

        expect(retrieved, isNotNull);
        expect(retrieved!.category, 'Study');
        expect(retrieved.tags, ['cs101', 'midterm']);
        expect(retrieved.estimatedMinutes, 90);
        expect(retrieved.recurrenceRule, 'weekly');
      },
    );

    test(
      'addSubtask, toggleSubtaskCompletion, and deleteSubtask operations',
      () async {
        await repository.saveTask(task1);

        await repository.addSubtask('task-1', 'Read Chapter 4');
        await repository.addSubtask('task-1', 'Do Exercises 1-5');

        var taskWithSubs = await repository.getTaskById('task-1');
        expect(taskWithSubs!.subtasks.length, 2);
        expect(taskWithSubs.subtasks[0].title, 'Read Chapter 4');
        expect(taskWithSubs.subtasks[0].isCompleted, isFalse);

        final firstSubtaskId = taskWithSubs.subtasks[0].id;
        await repository.toggleSubtaskCompletion(firstSubtaskId);

        taskWithSubs = await repository.getTaskById('task-1');
        expect(taskWithSubs!.subtasks[0].isCompleted, isTrue);
        expect(taskWithSubs.completedSubtasksCount, 1);
        expect(taskWithSubs.subtasksProgress, 0.5);

        await repository.deleteSubtask(firstSubtaskId);
        taskWithSubs = await repository.getTaskById('task-1');
        expect(taskWithSubs!.subtasks.length, 1);
        expect(taskWithSubs.subtasks[0].title, 'Do Exercises 1-5');
      },
    );

    test('deleting a task cascades and removes all of its subtasks', () async {
      await repository.saveTask(task1);
      await repository.addSubtask('task-1', 'Subtask A');
      await repository.addSubtask('task-1', 'Subtask B');

      await repository.deleteTask('task-1');
      final tasks = await repository.getTasks();
      expect(tasks, isEmpty);

      final subtaskRows = await database.select(database.subtaskEntries).get();
      expect(subtaskRows, isEmpty);
    });

    test(
      'completing a recurring task automatically schedules the next instance',
      () async {
        final recurringTask = Task(
          id: 'rec-1',
          title: 'Daily Review',
          recurrenceRule: 'daily',
          dueDate: DateTime(2026, 11, 4, 18, 0),
          createdAt: DateTime(2026, 11, 4),
        );

        await repository.saveTask(recurringTask);

        // Complete the task
        await repository.toggleTaskCompletion('rec-1');

        final tasks = await repository.getTasks();
        // Expect 2 tasks: the completed original + the new active instance
        expect(tasks.length, 2);

        final completedOriginal = tasks.firstWhere((t) => t.id == 'rec-1');
        expect(completedOriginal.isCompleted, isTrue);

        final nextInstance = tasks.firstWhere((t) => t.id != 'rec-1');
        expect(nextInstance.title, 'Daily Review');
        expect(nextInstance.isCompleted, isFalse);
        expect(nextInstance.dueDate, DateTime(2026, 11, 5, 18, 0));
      },
    );
  });
}
