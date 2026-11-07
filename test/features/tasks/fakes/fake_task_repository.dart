import 'dart:async';

import 'package:focuspilot/features/tasks/domain/models/subtask.dart';
import 'package:focuspilot/features/tasks/domain/models/task.dart';
import 'package:focuspilot/features/tasks/domain/models/task_details.dart';
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
  Future<bool> updateTaskDetails(String id, TaskDetails details) async {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index < 0) return false;

    _tasks[index] = _tasks[index].copyWith(
      title: details.title,
      priority: details.priority,
      description: details.description,
      clearDescription: details.description == null,
      dueDate: details.dueDate,
      clearDueDate: details.dueDate == null,
      category: details.category,
      clearCategory: details.category == null,
      estimatedMinutes: details.estimatedMinutes,
      clearEstimatedMinutes: details.estimatedMinutes == null,
      recurrenceRule: details.recurrenceRule,
      clearRecurrenceRule: details.recurrenceRule == null,
    );
    _controller.add(List.unmodifiable(_tasks));
    return true;
  }

  @override
  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((t) => t.id == id);
    _controller.add(List.unmodifiable(_tasks));
  }

  @override
  Future<void> toggleTaskCompletion(String id) async {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index < 0) return;

    final task = _tasks[index];
    final isCompleted = !task.isCompleted;
    _tasks[index] = task.copyWith(
      isCompleted: isCompleted,
      completedAt: isCompleted ? DateTime.now() : null,
      clearCompletedAt: !isCompleted,
    );

    if (isCompleted) {
      final nextInstance = task.createNextRecurringInstance();
      if (nextInstance != null) {
        _tasks.add(nextInstance);
      }
    }
    _controller.add(List.unmodifiable(_tasks));
  }

  @override
  Future<void> addActualMinutes(String taskId, int minutes) async {
    final index = _tasks.indexWhere((task) => task.id == taskId);
    if (index < 0) return;

    final task = _tasks[index];
    _tasks[index] = task.copyWith(actualMinutes: task.actualMinutes + minutes);
    _controller.add(List.unmodifiable(_tasks));
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
