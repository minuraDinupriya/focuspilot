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
  });
}
