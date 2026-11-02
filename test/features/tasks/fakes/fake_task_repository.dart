import 'dart:async';

import 'package:focuspilot/features/tasks/domain/models/task.dart';
import 'package:focuspilot/features/tasks/domain/repositories/task_repository.dart';

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
