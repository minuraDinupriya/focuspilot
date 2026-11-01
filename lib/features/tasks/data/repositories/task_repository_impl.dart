import 'package:drift/drift.dart';
import 'package:focuspilot/features/tasks/data/datasources/database/app_database.dart';
import 'package:focuspilot/features/tasks/domain/models/task.dart';
import 'package:focuspilot/features/tasks/domain/models/task_priority.dart';
import 'package:focuspilot/features/tasks/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  TaskRepositoryImpl(this._database);

  final AppDatabase _database;

  @override
  Stream<List<Task>> watchTasks() {
    final query = _database.select(_database.taskEntries)
      ..orderBy([
        (tbl) => OrderingTerm.asc(tbl.isCompleted),
        (tbl) => OrderingTerm.desc(tbl.createdAt),
      ]);

    return query.watch().map((rows) => rows.map(_toDomain).toList());
  }

  @override
  Future<List<Task>> getTasks() async {
    final query = _database.select(_database.taskEntries)
      ..orderBy([
        (tbl) => OrderingTerm.asc(tbl.isCompleted),
        (tbl) => OrderingTerm.desc(tbl.createdAt),
      ]);

    final rows = await query.get();
    return rows.map(_toDomain).toList();
  }

  @override
  Future<Task?> getTaskById(String id) async {
    final query = _database.select(_database.taskEntries)
      ..where((tbl) => tbl.id.equals(id));
    final row = await query.getSingleOrNull();
    return row != null ? _toDomain(row) : null;
  }

  @override
  Future<void> saveTask(Task task) async {
    await _database
        .into(_database.taskEntries)
        .insertOnConflictUpdate(
          TaskEntriesCompanion.insert(
            id: task.id,
            title: task.title,
            description: Value(task.description),
            isCompleted: Value(task.isCompleted),
            priority: Value(task.priority.name),
            dueDate: Value(task.dueDate),
            createdAt: task.createdAt,
            completedAt: Value(task.completedAt),
          ),
        );
  }

  @override
  Future<void> deleteTask(String id) async {
    final query = _database.delete(_database.taskEntries)
      ..where((tbl) => tbl.id.equals(id));
    await query.go();
  }

  @override
  Future<void> toggleTaskCompletion(String id) async {
    final task = await getTaskById(id);
    if (task == null) return;

    final updatedIsCompleted = !task.isCompleted;
    final updated = task.copyWith(
      isCompleted: updatedIsCompleted,
      completedAt: updatedIsCompleted ? DateTime.now() : null,
      clearCompletedAt: !updatedIsCompleted,
    );
    await saveTask(updated);
  }

  Task _toDomain(TaskEntry entry) {
    return Task(
      id: entry.id,
      title: entry.title,
      description: entry.description,
      isCompleted: entry.isCompleted,
      priority: TaskPriority.fromString(entry.priority),
      dueDate: entry.dueDate,
      createdAt: entry.createdAt,
      completedAt: entry.completedAt,
    );
  }
}
