import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:focuspilot/features/tasks/data/datasources/database/app_database.dart';
import 'package:focuspilot/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:focuspilot/features/tasks/domain/models/subtask.dart';
import 'package:focuspilot/features/tasks/domain/models/task.dart';
import 'package:focuspilot/features/tasks/domain/models/task_details.dart';
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

  test('v9 task rows survive migration with no planned start', () async {
    final upgraded = AppDatabase(
      NativeDatabase.memory(
        setup: (db) {
          db.execute('''
            CREATE TABLE task_entries (
              id TEXT NOT NULL PRIMARY KEY,
              title TEXT NOT NULL,
              description TEXT,
              is_completed INTEGER NOT NULL DEFAULT 0,
              priority TEXT NOT NULL DEFAULT 'medium',
              due_date INTEGER,
              created_at INTEGER NOT NULL,
              completed_at INTEGER,
              category TEXT,
              tags TEXT NOT NULL DEFAULT '',
              estimated_minutes INTEGER,
              actual_minutes INTEGER NOT NULL DEFAULT 0,
              recurrence_rule TEXT
            );
            INSERT INTO task_entries (id, title, created_at, actual_minutes)
            VALUES ('existing', 'Saved task', 1794500000, 25);
            PRAGMA user_version = 9;
          ''');
        },
      ),
    );
    addTearDown(upgraded.close);

    final task = await upgraded.select(upgraded.taskEntries).getSingle();
    expect(task.title, 'Saved task');
    expect(task.actualMinutes, 25);
    expect(task.scheduledStart, isNull);
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

    test('persists a planned start independently of the due date', () async {
      final start = DateTime(2026, 11, 19, 9, 30);
      final due = DateTime(2026, 11, 20);
      final task = task1.copyWith(scheduledStart: start, dueDate: due);
      await repository.saveTask(task);
      expect(
        (await repository.watchTasks().first).single.scheduledStart,
        start,
      );

      await repository.updateTaskDetails(
        task.id,
        TaskDetails(title: task.title, priority: task.priority, dueDate: due),
      );
      final updated = await repository.getTaskById(task.id);
      expect(updated?.scheduledStart, isNull);
      expect(updated?.dueDate, due);
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
      'restores the deleted task snapshot, including its checklist',
      () async {
        final task = task1.copyWith(
          scheduledStart: DateTime(2026, 11, 15, 9),
          estimatedMinutes: 75,
          actualMinutes: 42,
          isCompleted: true,
          completedAt: DateTime(2026, 11, 15, 10),
          subtasks: [
            Subtask(
              id: 'completed',
              taskId: task1.id,
              title: 'First step',
              isCompleted: true,
            ),
          ],
        );
        await repository.saveTask(task);
        final deleted = await repository.deleteTask(task.id);
        expect(deleted, task);
        expect(await repository.getTaskById(task.id), isNull);
        await repository.restoreTask(deleted!);
        expect(await repository.getTaskById(task.id), task);
        await repository.addActualMinutes(task.id, 5);
        await repository.restoreTask(deleted);
        expect((await repository.getTaskById(task.id))?.actualMinutes, 47);
      },
    );

    test(
      'undoing a subtask restores its state ahead of a new subtask',
      () async {
        await repository.saveTask(task1);
        await repository.addSubtask(task1.id, 'First step');
        final original = (await repository.getTaskById(task1.id))!
            .subtasks
            .single;
        await repository.toggleSubtaskCompletion(original.id);
        final deleted = await repository.deleteSubtask(original.id);
        await repository.addSubtask(task1.id, 'New step');
        await repository.restoreSubtask(deleted!);

        final subtasks = (await repository.getTaskById(task1.id))!.subtasks;
        expect(subtasks.first, original.copyWith(isCompleted: true));
        expect(subtasks.last.title, 'New step');
      },
    );

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
          actualMinutes: 45,
          recurrenceRule: 'weekly',
          createdAt: DateTime(2026, 11, 4, 10, 0),
        );

        await repository.saveTask(advancedTask);
        final retrieved = await repository.getTaskById('task-adv');

        expect(retrieved, isNotNull);
        expect(retrieved!.category, 'Study');
        expect(retrieved.tags, ['cs101', 'midterm']);
        expect(retrieved.estimatedMinutes, 90);
        expect(retrieved.actualMinutes, 45);
        expect(retrieved.recurrenceRule, 'weekly');
      },
    );

    test('updateTaskDetails changes only editable fields', () async {
      await repository.saveTask(
        task1.copyWith(
          dueDate: DateTime(2026, 11, 2),
          category: 'School',
          estimatedMinutes: 45,
          actualMinutes: 15,
          recurrenceRule: 'weekly',
          tags: const ['cs101'],
          isCompleted: true,
          completedAt: DateTime(2026, 11, 1, 9, 30),
        ),
      );
      await repository.addSubtask(task1.id, 'Read notes');
      await repository.addSubtask(task1.id, 'Old exercise');
      final beforeEditing = (await repository.getTaskById(task1.id))!;

      await repository.toggleSubtaskCompletion(beforeEditing.subtasks[0].id);
      await repository.deleteSubtask(beforeEditing.subtasks[1].id);
      await repository.addSubtask(task1.id, 'New exercise');
      await repository.addActualMinutes(task1.id, 25);
      final current = (await repository.getTaskById(task1.id))!;

      expect(
        await repository.updateTaskDetails(
          task1.id,
          const TaskDetails(title: 'Review graphs', priority: TaskPriority.low),
        ),
        isTrue,
      );
      expect(
        await repository.getTaskById(task1.id),
        current.copyWith(
          title: 'Review graphs',
          priority: TaskPriority.low,
          clearDescription: true,
          clearDueDate: true,
          clearCategory: true,
          clearEstimatedMinutes: true,
          clearRecurrenceRule: true,
        ),
      );
    });

    test('updateTaskDetails does not recreate a deleted task', () async {
      await repository.saveTask(task1);
      await repository.deleteTask(task1.id);

      expect(
        await repository.updateTaskDetails(
          task1.id,
          const TaskDetails(title: 'Review graphs', priority: TaskPriority.low),
        ),
        isFalse,
      );
      expect(await repository.getTaskById(task1.id), isNull);
    });

    test('addActualMinutes increments actualMinutes on task', () async {
      await repository.saveTask(task1);
      expect((await repository.getTaskById('task-1'))!.actualMinutes, 0);

      await repository.addActualMinutes('task-1', 25);
      expect((await repository.getTaskById('task-1'))!.actualMinutes, 25);

      await repository.addActualMinutes('task-1', 25);
      expect((await repository.getTaskById('task-1'))!.actualMinutes, 50);
    });

    test('concurrent focus time and task edits both persist', () async {
      await repository.saveTask(task1);
      final dueDate = DateTime(2026, 11, 2);

      await Future.wait([
        repository.addActualMinutes(task1.id, 25),
        repository.updateTaskDetails(
          task1.id,
          TaskDetails(
            title: 'Review graphs',
            priority: TaskPriority.low,
            description: 'Practice topological sorting',
            dueDate: dueDate,
            category: 'School',
            estimatedMinutes: 45,
            recurrenceRule: 'weekly',
          ),
        ),
        repository.addActualMinutes(task1.id, 10),
      ]);

      expect(
        await repository.getTaskById(task1.id),
        task1.copyWith(
          title: 'Review graphs',
          priority: TaskPriority.low,
          description: 'Practice topological sorting',
          dueDate: dueDate,
          category: 'School',
          estimatedMinutes: 45,
          actualMinutes: 35,
          recurrenceRule: 'weekly',
        ),
      );
    });

    test('completing a task preserves concurrent edits and progress', () async {
      await repository.saveTask(task1);
      await repository.addSubtask(task1.id, 'Read notes');
      final original = (await repository.getTaskById(task1.id))!;
      final subtaskId = original.subtasks.single.id;

      await Future.wait([
        repository.toggleTaskCompletion(task1.id),
        repository.updateTaskDetails(
          task1.id,
          const TaskDetails(title: 'Review graphs', priority: TaskPriority.low),
        ),
        repository.addActualMinutes(task1.id, 25),
        repository.toggleSubtaskCompletion(subtaskId),
      ]);

      final updated = (await repository.getTaskById(task1.id))!;
      expect(updated.isCompleted, isTrue);
      expect(updated.completedAt, isNotNull);
      expect(updated.title, 'Review graphs');
      expect(updated.priority, TaskPriority.low);
      expect(updated.description, isNull);
      expect(updated.actualMinutes, 25);
      expect(updated.subtasks.single.isCompleted, isTrue);
    });

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
