import 'dart:async';

import 'package:focuspilot/features/tasks/domain/models/subtask.dart';
import 'package:focuspilot/features/tasks/domain/models/task.dart';
import 'package:focuspilot/features/tasks/domain/repositories/task_repository.dart';

class FakeTaskRepository implements TaskRepository {
  final _controller = StreamController<List<Task>>.broadcast();
  final List<Task> _tasks = [];

  List<Task> get tasks => List.unmodifiable(_tasks);

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
      final updatedIsCompleted = !task.isCompleted;
      final updated = task.copyWith(
        isCompleted: updatedIsCompleted,
        completedAt: updatedIsCompleted ? DateTime.now() : null,
        clearCompletedAt: !updatedIsCompleted,
      );
      await saveTask(updated);

      if (updatedIsCompleted && task.isRecurring) {
        final nextInstance = task.createNextRecurringInstance();
        if (nextInstance != null) {
          await saveTask(nextInstance);
        }
      }
    }
  }

  @override
  Future<void> addSubtask(String taskId, String title) async {
    final task = await getTaskById(taskId);
    if (task == null) return;

    final newSubtask = Subtask.create(
      taskId: taskId,
      title: title,
      orderIndex: task.subtasks.length,
    );
    final updated = task.copyWith(subtasks: [...task.subtasks, newSubtask]);
    await saveTask(updated);
  }

  @override
  Future<void> toggleSubtaskCompletion(String subtaskId) async {
    for (var i = 0; i < _tasks.length; i++) {
      final task = _tasks[i];
      final subtaskIndex = task.subtasks.indexWhere((s) => s.id == subtaskId);
      if (subtaskIndex >= 0) {
        final currentSubtask = task.subtasks[subtaskIndex];
        final updatedSubtasks = List<Subtask>.from(task.subtasks);
        updatedSubtasks[subtaskIndex] = currentSubtask.copyWith(
          isCompleted: !currentSubtask.isCompleted,
        );
        await saveTask(task.copyWith(subtasks: updatedSubtasks));
        return;
      }
    }
  }

  @override
  Future<void> deleteSubtask(String subtaskId) async {
    for (var i = 0; i < _tasks.length; i++) {
      final task = _tasks[i];
      if (task.subtasks.any((s) => s.id == subtaskId)) {
        final updatedSubtasks = task.subtasks
            .where((s) => s.id != subtaskId)
            .toList();
        await saveTask(task.copyWith(subtasks: updatedSubtasks));
        return;
      }
    }
  }

  void dispose() {
    _controller.close();
  }
}
