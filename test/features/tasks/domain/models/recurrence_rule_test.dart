import 'package:flutter_test/flutter_test.dart';
import 'package:focuspilot/features/tasks/domain/models/recurrence_rule.dart';
import 'package:focuspilot/features/tasks/domain/models/subtask.dart';
import 'package:focuspilot/features/tasks/domain/models/task.dart';

void main() {
  group('RecurrenceType', () {
    test('calculateNextDueDate correctly calculates daily recurrence', () {
      final base = DateTime(2026, 11, 4, 10, 0);
      final next = RecurrenceType.daily.calculateNextDueDate(base);

      expect(next, DateTime(2026, 11, 5, 10, 0));
    });

    test('calculateNextDueDate correctly calculates weekdays recurrence', () {
      // Thursday -> Friday
      final thursday = DateTime(2026, 11, 5, 9, 0); // Nov 5, 2026 is Thursday
      expect(
        RecurrenceType.weekdays.calculateNextDueDate(thursday),
        DateTime(2026, 11, 6, 9, 0),
      );

      // Friday -> Monday (skips weekend)
      final friday = DateTime(2026, 11, 6, 9, 0); // Nov 6, 2026 is Friday
      expect(
        RecurrenceType.weekdays.calculateNextDueDate(friday),
        DateTime(2026, 11, 9, 9, 0),
      );
    });

    test('calculateNextDueDate correctly calculates weekly recurrence', () {
      final base = DateTime(2026, 11, 4, 10, 0);
      final next = RecurrenceType.weekly.calculateNextDueDate(base);

      expect(next, DateTime(2026, 11, 11, 10, 0));
    });

    test('calculateNextDueDate correctly calculates monthly recurrence', () {
      final base = DateTime(2026, 11, 4, 10, 0);
      final next = RecurrenceType.monthly.calculateNextDueDate(base);

      expect(next, DateTime(2026, 12, 4, 10, 0));
    });

    test(
      'Task createNextRecurringInstance resets subtasks and advances due date',
      () {
        final subtask1 = Subtask(
          id: 's1',
          taskId: 'parent-1',
          title: 'Step 1',
          isCompleted: true,
        );
        final subtask2 = Subtask(
          id: 's2',
          taskId: 'parent-1',
          title: 'Step 2',
          isCompleted: false,
        );

        final task = Task(
          id: 'parent-1',
          title: 'Weekly Standup Notes',
          recurrenceRule: 'weekly',
          dueDate: DateTime(2026, 11, 4, 9, 0),
          createdAt: DateTime(2026, 11, 1),
          subtasks: [subtask1, subtask2],
        );

        final nextTask = task.createNextRecurringInstance();

        expect(nextTask, isNotNull);
        expect(nextTask!.title, 'Weekly Standup Notes');
        expect(nextTask.isCompleted, isFalse);
        expect(nextTask.dueDate, DateTime(2026, 11, 11, 9, 0));
        expect(nextTask.subtasks.length, 2);
        expect(nextTask.subtasks.every((s) => !s.isCompleted), isTrue);
        expect(nextTask.subtasks.first.taskId, nextTask.id);
      },
    );
  });
}
