import 'package:drift/drift.dart';
import 'package:focuspilot/features/tasks/data/datasources/database/app_database.dart';
import 'package:focuspilot/features/tasks/domain/models/subtask.dart';
import 'package:focuspilot/features/tasks/domain/models/task.dart';
import 'package:focuspilot/features/tasks/domain/models/task_priority.dart';
import 'package:focuspilot/features/tasks/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  TaskRepositoryImpl(this._database);

  final AppDatabase _database;

  @override
  Stream<List<Task>> watchTasks() {
    final query =
        _database.select(_database.taskEntries).join([
          leftOuterJoin(
            _database.subtaskEntries,
            _database.subtaskEntries.taskId.equalsExp(_database.taskEntries.id),
          ),
        ])..orderBy([
          OrderingTerm.asc(_database.taskEntries.isCompleted),
          OrderingTerm.desc(_database.taskEntries.createdAt),
          OrderingTerm.asc(_database.subtaskEntries.orderIndex),
        ]);

    return query.watch().map((rows) {
      final tasksMap = <String, Task>{};
      final subtasksMap = <String, List<Subtask>>{};

      for (final row in rows) {
        final taskEntry = row.readTable(_database.taskEntries);
        final subtaskEntry = row.readTableOrNull(_database.subtaskEntries);

        if (!tasksMap.containsKey(taskEntry.id)) {
          tasksMap[taskEntry.id] = _toDomain(taskEntry, const []);
        }

        if (subtaskEntry != null) {
          subtasksMap
              .putIfAbsent(taskEntry.id, () => [])
              .add(_subtaskToDomain(subtaskEntry));
        }
      }

      return tasksMap.values.map((task) {
        return task.copyWith(subtasks: subtasksMap[task.id] ?? const []);
      }).toList();
    });
  }

  @override
  Future<List<Task>> getTasks() async {
    final query =
        _database.select(_database.taskEntries).join([
          leftOuterJoin(
            _database.subtaskEntries,
            _database.subtaskEntries.taskId.equalsExp(_database.taskEntries.id),
          ),
        ])..orderBy([
          OrderingTerm.asc(_database.taskEntries.isCompleted),
          OrderingTerm.desc(_database.taskEntries.createdAt),
          OrderingTerm.asc(_database.subtaskEntries.orderIndex),
        ]);

    final rows = await query.get();
    final tasksMap = <String, Task>{};
    final subtasksMap = <String, List<Subtask>>{};

    for (final row in rows) {
      final taskEntry = row.readTable(_database.taskEntries);
      final subtaskEntry = row.readTableOrNull(_database.subtaskEntries);

      if (!tasksMap.containsKey(taskEntry.id)) {
        tasksMap[taskEntry.id] = _toDomain(taskEntry, const []);
      }

      if (subtaskEntry != null) {
        subtasksMap
            .putIfAbsent(taskEntry.id, () => [])
            .add(_subtaskToDomain(subtaskEntry));
      }
    }

    return tasksMap.values.map((task) {
      return task.copyWith(subtasks: subtasksMap[task.id] ?? const []);
    }).toList();
  }

  @override
  Future<Task?> getTaskById(String id) async {
    final taskQuery = _database.select(_database.taskEntries)
      ..where((tbl) => tbl.id.equals(id));
    final taskEntry = await taskQuery.getSingleOrNull();
    if (taskEntry == null) return null;

    final subtasksQuery = _database.select(_database.subtaskEntries)
      ..where((tbl) => tbl.taskId.equals(id))
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.orderIndex)]);
    final subtaskRows = await subtasksQuery.get();

    return _toDomain(taskEntry, subtaskRows.map(_subtaskToDomain).toList());
  }

  @override
  Future<void> saveTask(Task task) async {
    final tagsString = task.tags.join(',');
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
            category: Value(task.category),
            tags: Value(tagsString),
            estimatedMinutes: Value(task.estimatedMinutes),
            recurrenceRule: Value(task.recurrenceRule),
          ),
        );

    for (var i = 0; i < task.subtasks.length; i++) {
      final s = task.subtasks[i];
      await _database
          .into(_database.subtaskEntries)
          .insertOnConflictUpdate(
            SubtaskEntriesCompanion.insert(
              id: s.id,
              taskId: task.id,
              title: s.title,
              isCompleted: Value(s.isCompleted),
              orderIndex: Value(i),
            ),
          );
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    final subtasksQuery = _database.delete(_database.subtaskEntries)
      ..where((tbl) => tbl.taskId.equals(id));
    await subtasksQuery.go();

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

    if (updatedIsCompleted && task.isRecurring) {
      final nextInstance = task.createNextRecurringInstance();
      if (nextInstance != null) {
        await saveTask(nextInstance);
      }
    }
  }

  @override
  Future<void> addSubtask(String taskId, String title) async {
    final countQuery = _database.select(_database.subtaskEntries)
      ..where((tbl) => tbl.taskId.equals(taskId));
    final existing = await countQuery.get();
    final newSubtask = Subtask.create(
      taskId: taskId,
      title: title,
      orderIndex: existing.length,
    );
    await _database
        .into(_database.subtaskEntries)
        .insert(
          SubtaskEntriesCompanion.insert(
            id: newSubtask.id,
            taskId: taskId,
            title: newSubtask.title,
            isCompleted: const Value(false),
            orderIndex: Value(newSubtask.orderIndex),
          ),
        );
  }

  @override
  Future<void> toggleSubtaskCompletion(String subtaskId) async {
    final query = _database.select(_database.subtaskEntries)
      ..where((tbl) => tbl.id.equals(subtaskId));
    final entry = await query.getSingleOrNull();
    if (entry == null) return;

    final updated = entry.copyWith(isCompleted: !entry.isCompleted);
    await _database.update(_database.subtaskEntries).replace(updated);
  }

  @override
  Future<void> deleteSubtask(String subtaskId) async {
    final query = _database.delete(_database.subtaskEntries)
      ..where((tbl) => tbl.id.equals(subtaskId));
    await query.go();
  }

  Task _toDomain(TaskEntry entry, List<Subtask> subtasks) {
    final tagsList = entry.tags.isEmpty
        ? const <String>[]
        : entry.tags
              .split(',')
              .map((t) => t.trim())
              .where((t) => t.isNotEmpty)
              .toList();

    return Task(
      id: entry.id,
      title: entry.title,
      description: entry.description,
      isCompleted: entry.isCompleted,
      priority: TaskPriority.fromString(entry.priority),
      dueDate: entry.dueDate,
      createdAt: entry.createdAt,
      completedAt: entry.completedAt,
      category: entry.category,
      tags: tagsList,
      estimatedMinutes: entry.estimatedMinutes,
      recurrenceRule: entry.recurrenceRule,
      subtasks: subtasks,
    );
  }

  Subtask _subtaskToDomain(SubtaskEntry entry) {
    return Subtask(
      id: entry.id,
      taskId: entry.taskId,
      title: entry.title,
      isCompleted: entry.isCompleted,
      orderIndex: entry.orderIndex,
    );
  }
}
