import 'package:focuspilot/features/tasks/domain/models/task.dart';

abstract class TaskRepository {
  Stream<List<Task>> watchTasks();

  Future<List<Task>> getTasks();

  Future<Task?> getTaskById(String id);

  Future<void> saveTask(Task task);

  Future<void> deleteTask(String id);

  Future<void> toggleTaskCompletion(String id);
}
