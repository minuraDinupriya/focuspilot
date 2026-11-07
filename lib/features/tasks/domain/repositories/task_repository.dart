import 'package:focuspilot/features/tasks/domain/models/task.dart';
import 'package:focuspilot/features/tasks/domain/models/task_details.dart';

abstract class TaskRepository {
  Stream<List<Task>> watchTasks();

  Future<List<Task>> getTasks();

  Future<Task?> getTaskById(String id);

  Future<void> saveTask(Task task);

  /// Saves the editable details of an existing task. Null values clear fields.
  ///
  /// Returns false if the task no longer exists.
  Future<bool> updateTaskDetails(String id, TaskDetails details);

  Future<void> deleteTask(String id);

  Future<void> toggleTaskCompletion(String id);

  Future<void> addActualMinutes(String taskId, int minutes);

  Future<void> addSubtask(String taskId, String title);

  Future<void> toggleSubtaskCompletion(String subtaskId);

  Future<void> deleteSubtask(String subtaskId);
}
