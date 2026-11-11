import 'package:drift/drift.dart';
import 'package:focuspilot/features/tasks/data/datasources/database/app_database.dart';
import 'package:focuspilot/features/tasks/domain/models/subtask.dart';
import 'package:focuspilot/features/tasks/domain/models/task.dart';
import 'package:focuspilot/features/tasks/domain/models/task_details.dart';
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
            scheduledStart: Value(task.scheduledStart),
            createdAt: task.createdAt,
            completedAt: Value(task.completedAt),
            category: Value(task.category),
            tags: Value(tagsString),
            estimatedMinutes: Value(task.estimatedMinutes),
            actualMinutes: Value(task.actualMinutes),
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
  Future<bool> updateTaskDetails(String id, TaskDetails details) async {
    final query = _database.update(_database.taskEntries)
      ..where((table) => table.id.equals(id));
    final updatedRows = await query.write(
      TaskEntriesCompanion(
        title: Value(details.title),
        priority: Value(details.priority.name),
        description: Value(details.description),
        dueDate: Value(details.dueDate),
        scheduledStart: Value(details.scheduledStart),
        category: Value(details.category),
        estimatedMinutes: Value(details.estimatedMinutes),
        recurrenceRule: Value(details.recurrenceRule),
      ),
    );
    return updatedRows > 0;
  }

  @override
  Future<Task?> deleteTask(String id) {
    return _database.transaction(() async {
      final task = await getTaskById(id);
      if (task == null) return null;

      final query = _database.delete(_database.taskEntries)
        ..where((tbl) => tbl.id.equals(id));
      await query.go();
      return task;
    });
  }

  @override
  Future<void> restoreTask(Task task) {
    return _database.transaction(() async {
      if (await getTaskById(task.id) == null) {
        await saveTask(task.copyWith(subtasks: const []));
        for (final subtask in task.subtasks) {
          await _insertSubtask(subtask);
        }
      }
    });
  }

  @override
  Future<void> toggleTaskCompletion(String id) {
    return _database.transaction(() async {
      final task = await getTaskById(id);
      if (task == null) return;

      final isCompleted = !task.isCompleted;
      final query = _database.update(_database.taskEntries)
        ..where((table) => table.id.equals(id));
      await query.write(
        TaskEntriesCompanion(
          isCompleted: Value(isCompleted),
          completedAt: Value(isCompleted ? DateTime.now() : null),
        ),
      );

      if (isCompleted) {
        final nextInstance = task.createNextRecurringInstance();
        if (nextInstance != null) {
          await saveTask(nextInstance);
        }
      }
    });
  }

  @override
  Future<void> addActualMinutes(String taskId, int minutes) async {
    final tasks = _database.taskEntries;
    final query = _database.update(tasks)
      ..where((table) => table.id.equals(taskId));
    await query.write(
      TaskEntriesCompanion.custom(
        actualMinutes: tasks.actualMinutes + Variable<int>(minutes),
      ),
    );
  }

  @override
  Future<void> addSubtask(String taskId, String title) {
    return _database.transaction(() async {
      final entries = _database.subtaskEntries;
      final query = _database.select(entries)
        ..where((table) => table.taskId.equals(taskId))
        ..orderBy([(table) => OrderingTerm.desc(table.orderIndex)])
        ..limit(1);
      final last = await query.getSingleOrNull();
      final subtask = Subtask.create(
        taskId: taskId,
        title: title,
        orderIndex: (last?.orderIndex ?? -1) + 1,
      );
      await _insertSubtask(subtask);
    });
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
  Future<Subtask?> deleteSubtask(String subtaskId) async {
    final query = _database.delete(_database.subtaskEntries)
      ..where((tbl) => tbl.id.equals(subtaskId));
    final deleted = (await query.goAndReturn()).singleOrNull;
    return deleted == null ? null : _subtaskToDomain(deleted);
  }

  @override
  Future<void> restoreSubtask(Subtask subtask) {
    return _database.transaction(() async {
      final entries = _database.subtaskEntries;
      final existing = _database.select(entries)
        ..where((table) => table.id.equals(subtask.id));
      if (await existing.getSingleOrNull() != null) return;

      final occupied = _database.select(entries)
        ..where(
          (table) =>
              table.taskId.equals(subtask.taskId) &
              table.orderIndex.equals(subtask.orderIndex),
        )
        ..limit(1);
      if (await occupied.getSingleOrNull() != null) {
        final later = _database.update(entries)
          ..where(
            (table) =>
                table.taskId.equals(subtask.taskId) &
                table.orderIndex.isBiggerOrEqualValue(subtask.orderIndex),
          );
        await later.write(
          SubtaskEntriesCompanion.custom(
            orderIndex: entries.orderIndex + const Variable<int>(1),
          ),
        );
      }
      await _insertSubtask(subtask);
    });
  }

  Future<void> _insertSubtask(Subtask subtask) async {
    await _database
        .into(_database.subtaskEntries)
        .insert(
          SubtaskEntriesCompanion.insert(
            id: subtask.id,
            taskId: subtask.taskId,
            title: subtask.title,
            isCompleted: Value(subtask.isCompleted),
            orderIndex: Value(subtask.orderIndex),
          ),
        );
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
      scheduledStart: entry.scheduledStart,
      createdAt: entry.createdAt,
      completedAt: entry.completedAt,
      category: entry.category,
      tags: tagsList,
      estimatedMinutes: entry.estimatedMinutes,
      actualMinutes: entry.actualMinutes,
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
