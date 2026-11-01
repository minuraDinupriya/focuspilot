import 'package:flutter_test/flutter_test.dart';
import 'package:focuspilot/features/tasks/domain/models/task.dart';
import 'package:focuspilot/features/tasks/domain/models/task_priority.dart';

void main() {
  group('Task model', () {
    final fixedDate = DateTime(2026, 11, 1, 10, 0);

    test('supports value equality', () {
      final taskA = Task(
        id: 'task-1',
        title: 'Complete assignment',
        createdAt: fixedDate,
      );

      final taskB = Task(
        id: 'task-1',
        title: 'Complete assignment',
        createdAt: fixedDate,
      );

      expect(taskA, equals(taskB));
    });

    test('Task.create populates unique id, createdAt and default values', () {
      final task = Task.create(title: 'Review PR');

      expect(task.id, isNotEmpty);
      expect(task.title, 'Review PR');
      expect(task.description, isNull);
      expect(task.isCompleted, isFalse);
      expect(task.priority, TaskPriority.medium);
      expect(task.createdAt, isNotNull);
      expect(task.completedAt, isNull);
    });

    test('copyWith updates specified fields and preserves others', () {
      final original = Task(
        id: 'task-1',
        title: 'Original Title',
        description: 'Original Description',
        priority: TaskPriority.low,
        createdAt: fixedDate,
      );

      final updated = original.copyWith(
        title: 'Updated Title',
        priority: TaskPriority.high,
        isCompleted: true,
      );

      expect(updated.id, 'task-1');
      expect(updated.title, 'Updated Title');
      expect(updated.description, 'Original Description');
      expect(updated.priority, TaskPriority.high);
      expect(updated.isCompleted, isTrue);
      expect(updated.createdAt, fixedDate);
    });

    test('copyWith clears nullable fields when explicit flags are set', () {
      final original = Task(
        id: 'task-1',
        title: 'Clean room',
        description: 'Sweep and dust',
        dueDate: fixedDate,
        createdAt: fixedDate,
      );

      final updated = original.copyWith(
        clearDescription: true,
        clearDueDate: true,
      );

      expect(updated.description, isNull);
      expect(updated.dueDate, isNull);
    });
  });

  group('TaskPriority enum', () {
    test('displayName returns expected strings', () {
      expect(TaskPriority.low.displayName, 'Low');
      expect(TaskPriority.medium.displayName, 'Medium');
      expect(TaskPriority.high.displayName, 'High');
    });

    test('fromString parses correctly and defaults to medium', () {
      expect(TaskPriority.fromString('low'), TaskPriority.low);
      expect(TaskPriority.fromString('HIGH'), TaskPriority.high);
      expect(TaskPriority.fromString('invalid_string'), TaskPriority.medium);
    });
  });
}
