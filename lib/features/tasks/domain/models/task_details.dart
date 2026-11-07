import 'package:focuspilot/features/tasks/domain/models/task_priority.dart';

class TaskDetails {
  const TaskDetails({
    required this.title,
    required this.priority,
    this.description,
    this.dueDate,
    this.category,
    this.estimatedMinutes,
    this.recurrenceRule,
  });

  final String title;
  final TaskPriority priority;
  final String? description;
  final DateTime? dueDate;
  final String? category;
  final int? estimatedMinutes;
  final String? recurrenceRule;
}
