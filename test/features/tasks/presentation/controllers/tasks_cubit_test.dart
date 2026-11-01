import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:focuspilot/features/tasks/domain/models/task.dart';
import 'package:focuspilot/features/tasks/domain/models/task_priority.dart';
import 'package:focuspilot/features/tasks/domain/repositories/task_repository.dart';
import 'package:focuspilot/features/tasks/presentation/controllers/tasks_cubit.dart';
import 'package:focuspilot/features/tasks/presentation/controllers/tasks_state.dart';

class FakeTaskRepository implements TaskRepository {
  final _controller = StreamController<List<Task>>.broadcast();
  final List<Task> _tasks = [];

  void emitTasks(List<Task> tasks) {
    _tasks.clear();
    _tasks.addAll(tasks);
    _controller.add(List.unmodifiable(_tasks));
  }

  void emitError(Object error) {
    _controller.addError(error);
  }

  @override
  Stream<List<Task>> watchTasks() {
    scheduleMicrotask(() => _controller.add(List.unmodifiable(_tasks)));
    return _controller.stream;
  }

  @override
  Future<List<Task>> getTasks() async => List.unmodifiable(_tasks);

  @override
  Future<Task?> getTaskById(String id) async {
    try {
      return _tasks.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveTask(Task task) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index >= 0) {
      _tasks[index] = task;
    } else {
      _tasks.add(task);
    }
    _controller.add(List.unmodifiable(_tasks));
  }

  @override
  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((t) => t.id == id);
    _controller.add(List.unmodifiable(_tasks));
  }

  @override
  Future<void> toggleTaskCompletion(String id) async {
    final task = await getTaskById(id);
    if (task != null) {
      final updated = task.copyWith(
        isCompleted: !task.isCompleted,
        completedAt: !task.isCompleted ? DateTime.now() : null,
        clearCompletedAt: task.isCompleted,
      );
      await saveTask(updated);
    }
  }

  void dispose() {
    _controller.close();
  }
}

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

      expect(repository._tasks.length, 1);
      expect(repository._tasks.first.title, 'New Feature');
      expect(repository._tasks.first.priority, TaskPriority.high);
    });

    test('toggleTask toggles completion', () async {
      repository.emitTasks([testTask]);
      await pumpEventQueue();

      await cubit.toggleTask(testTask.id);
      expect(repository._tasks.first.isCompleted, isTrue);
    });

    test('deleteTask removes task from repository', () async {
      repository.emitTasks([testTask]);
      await pumpEventQueue();

      await cubit.deleteTask(testTask.id);
      expect(repository._tasks, isEmpty);
    });

    test('setFilter updates filter in state', () {
      cubit.setFilter(TasksFilter.active);
      expect(cubit.state.filter, TasksFilter.active);

      cubit.setFilter(TasksFilter.completed);
      expect(cubit.state.filter, TasksFilter.completed);
    });
  });
}
