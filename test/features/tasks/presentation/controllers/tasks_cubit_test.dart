import 'package:flutter_test/flutter_test.dart';
import 'package:focuspilot/features/tasks/domain/models/task.dart';
import 'package:focuspilot/features/tasks/domain/models/task_priority.dart';
import 'package:focuspilot/features/tasks/presentation/controllers/tasks_cubit.dart';
import 'package:focuspilot/features/tasks/presentation/controllers/tasks_state.dart';

import '../../fakes/fake_task_repository.dart';

void main() {
  late FakeTaskRepository repository;
  late TasksCubit cubit;

  setUp(() {
    repository = FakeTaskRepository();
    cubit = TasksCubit(repository);
  });

  tearDown(() async {
    await cubit.close();
    repository.dispose();
  });

  group('TasksCubit', () {
    final testTask = Task(
      id: 'task-1',
      title: 'Study Flutter BLoC',
      priority: TaskPriority.high,
      createdAt: DateTime(2026, 11, 1),
    );

    test('initial state has empty tasks and loading/initial status', () {
      expect(cubit.state.tasks, isEmpty);
      expect(cubit.state.filter, TasksFilter.all);
    });

    test('emits success when repository emits tasks', () async {
      final expectation = expectLater(
        cubit.stream,
        emitsThrough(
          predicate<TasksState>(
            (state) =>
                state.status == TasksStatus.success &&
                state.tasks.contains(testTask),
          ),
        ),
      );

      repository.emitTasks([testTask]);
      await expectation;
    });

    test('addTask calls repository and adds new task', () async {
      await pumpEventQueue();

      await cubit.addTask(
        title: 'New Feature',
        description: 'Implement tests',
        priority: TaskPriority.high,
      );

      expect(repository.tasks.length, 1);
      expect(repository.tasks.first.title, 'New Feature');
      expect(repository.tasks.first.priority, TaskPriority.high);
    });

    test('toggleTask toggles completion', () async {
      repository.emitTasks([testTask]);
      await pumpEventQueue();

      await cubit.toggleTask(testTask.id);
      expect(repository.tasks.first.isCompleted, isTrue);
    });

    test('deleteTask removes task from repository', () async {
      repository.emitTasks([testTask]);
      await pumpEventQueue();

      await cubit.deleteTask(testTask.id);
      expect(repository.tasks, isEmpty);
    });

    test('setFilter updates filter in state', () {
      cubit.setFilter(TasksFilter.active);
      expect(cubit.state.filter, TasksFilter.active);

      cubit.setFilter(TasksFilter.completed);
      expect(cubit.state.filter, TasksFilter.completed);
    });

    test('updateTask updates task in repository', () async {
      repository.emitTasks([testTask]);
      await pumpEventQueue();

      final updated = testTask.copyWith(
        title: 'Updated Title',
        category: 'Study',
        estimatedMinutes: 45,
      );
      await cubit.updateTask(updated);

      expect(repository.tasks.first.title, 'Updated Title');
      expect(repository.tasks.first.category, 'Study');
      expect(repository.tasks.first.estimatedMinutes, 45);
    });

    test(
      'addSubtask, toggleSubtask, and deleteSubtask delegate to repository',
      () async {
        repository.emitTasks([testTask]);
        await pumpEventQueue();

        await cubit.addSubtask(testTask.id, 'Sub 1');
        expect(repository.tasks.first.subtasks.length, 1);
        expect(repository.tasks.first.subtasks.first.title, 'Sub 1');

        final subId = repository.tasks.first.subtasks.first.id;
        await cubit.toggleSubtask(subId);
        expect(repository.tasks.first.subtasks.first.isCompleted, isTrue);

        await cubit.deleteSubtask(subId);
        expect(repository.tasks.first.subtasks, isEmpty);
      },
    );

    test(
      'searchQuery filters tasks by title or category case-insensitively',
      () async {
        final taskA = Task(
          id: '1',
          title: 'Algorithms Midterm',
          category: 'Study',
          createdAt: DateTime(2026, 11, 4),
        );
        final taskB = Task(
          id: '2',
          title: 'Grocery shopping',
          category: 'Personal',
          createdAt: DateTime(2026, 11, 4),
        );

        repository.emitTasks([taskA, taskB]);
        await pumpEventQueue();

        cubit.setSearchQuery('algo');
        expect(cubit.state.filteredTasks.length, 1);
        expect(cubit.state.filteredTasks.first.id, '1');

        cubit.setSearchQuery('personal');
        expect(cubit.state.filteredTasks.length, 1);
        expect(cubit.state.filteredTasks.first.id, '2');

        cubit.setSearchQuery('xyz');
        expect(cubit.state.filteredTasks, isEmpty);
      },
    );

    test(
      'multi-filters combine priority, category and due date correctly',
      () async {
        final now = DateTime.now();
        final overdueDate = now.subtract(const Duration(days: 2));

        final taskHighStudy = Task(
          id: '1',
          title: 'Calculus Final',
          category: 'Study',
          priority: TaskPriority.high,
          dueDate: overdueDate,
          createdAt: now,
        );
        final taskLowStudy = Task(
          id: '2',
          title: 'Read Article',
          category: 'Study',
          priority: TaskPriority.low,
          createdAt: now,
        );
        final taskHighWork = Task(
          id: '3',
          title: 'Submit Report',
          category: 'Work',
          priority: TaskPriority.high,
          createdAt: now,
        );

        repository.emitTasks([taskHighStudy, taskLowStudy, taskHighWork]);
        await pumpEventQueue();

        // Filter by Priority High
        cubit.setPriorityFilter(TaskPriority.high);
        expect(cubit.state.filteredTasks.length, 2);

        // Add Category Study filter
        cubit.setCategoryFilter('Study');
        expect(cubit.state.filteredTasks.length, 1);
        expect(cubit.state.filteredTasks.first.id, '1');

        // Add Overdue DueDate filter
        cubit.setDueDateFilter(DueDateFilter.overdue);
        expect(cubit.state.filteredTasks.length, 1);

        // Reset filters
        cubit.resetFilters();
        expect(cubit.state.filteredTasks.length, 3);
        expect(cubit.state.hasActiveFilters, isFalse);
      },
    );
  });
}
