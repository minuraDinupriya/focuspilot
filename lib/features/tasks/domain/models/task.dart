import 'package:equatable/equatable.dart';
import 'package:focuspilot/features/tasks/domain/models/recurrence_rule.dart';
import 'package:focuspilot/features/tasks/domain/models/subtask.dart';
import 'package:focuspilot/features/tasks/domain/models/task_priority.dart';
import 'package:uuid/uuid.dart';

class Task extends Equatable {
  const Task({
    required this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
    this.priority = TaskPriority.medium,
    this.dueDate,
    this.scheduledStart,
    required this.createdAt,
    this.completedAt,
    this.category,
    this.tags = const [],
    this.estimatedMinutes,
    this.actualMinutes = 0,
    this.recurrenceRule,
    this.subtasks = const [],
  });

  final String id;
  final String title;
  final String? description;
  final bool isCompleted;
  final TaskPriority priority;
  final DateTime? dueDate;
  final DateTime? scheduledStart;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? category;
  final List<String> tags;
  final int? estimatedMinutes;
  final int actualMinutes;
  final String? recurrenceRule;
  final List<Subtask> subtasks;

  int get completedSubtasksCount => subtasks.where((s) => s.isCompleted).length;

  double get subtasksProgress {
    if (subtasks.isEmpty) return isCompleted ? 1.0 : 0.0;
    return (completedSubtasksCount / subtasks.length).clamp(0.0, 1.0);
  }

  bool get isOverdue {
    if (isCompleted || dueDate == null) return false;
    return dueDate!.isBefore(DateTime.now());
  }

  double? get timeProgress {
    if (estimatedMinutes == null || estimatedMinutes! <= 0) return null;
    return (actualMinutes / estimatedMinutes!).clamp(0.0, 1.0);
  }

  bool get isOverEstimated {
    if (estimatedMinutes == null || estimatedMinutes! <= 0) return false;
    return actualMinutes > estimatedMinutes!;
  }

  int get remainingEstimatedMinutes {
    if (estimatedMinutes == null) return 0;
    final diff = estimatedMinutes! - actualMinutes;
    return diff > 0 ? diff : 0;
  }

  bool get isRecurring => recurrenceRule != null && recurrenceRule != 'none';

  RecurrenceType get recurrenceType =>
      RecurrenceType.fromString(recurrenceRule);

  Task? createNextRecurringInstance() {
    if (!isRecurring) return null;
    final baseDate = dueDate ?? DateTime.now();
    final nextDueDate = recurrenceType.calculateNextDueDate(baseDate);

    final nextTaskId = const Uuid().v4();
    final nextSubtasks = subtasks.map((s) {
      return Subtask.create(
        taskId: nextTaskId,
        title: s.title,
        orderIndex: s.orderIndex,
      );
    }).toList();

    return Task(
      id: nextTaskId,
      title: title,
      description: description,
      isCompleted: false,
      priority: priority,
      dueDate: nextDueDate,
      createdAt: DateTime.now(),
      category: category,
      tags: tags,
      estimatedMinutes: estimatedMinutes,
      actualMinutes: 0,
      recurrenceRule: recurrenceRule,
      subtasks: nextSubtasks,
    );
  }

  factory Task.create({
    required String title,
    String? description,
    TaskPriority priority = TaskPriority.medium,
    DateTime? dueDate,
    DateTime? scheduledStart,
    String? category,
    List<String> tags = const [],
    int? estimatedMinutes,
    int actualMinutes = 0,
    String? recurrenceRule,
    List<Subtask> subtasks = const [],
  }) {
    return Task(
      id: const Uuid().v4(),
      title: title.trim(),
      description: description?.trim().isEmpty ?? true
          ? null
          : description?.trim(),
      isCompleted: false,
      priority: priority,
      dueDate: dueDate,
      scheduledStart: scheduledStart,
      createdAt: DateTime.now(),
      completedAt: null,
      category: category?.trim().isEmpty ?? true ? null : category?.trim(),
      tags: tags,
      estimatedMinutes: estimatedMinutes,
      actualMinutes: actualMinutes,
      recurrenceRule: recurrenceRule?.trim().isEmpty ?? true
          ? null
          : recurrenceRule?.trim(),
      subtasks: subtasks,
    );
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    TaskPriority? priority,
    DateTime? dueDate,
    DateTime? scheduledStart,
    DateTime? createdAt,
    DateTime? completedAt,
    String? category,
    List<String>? tags,
    int? estimatedMinutes,
    int? actualMinutes,
    String? recurrenceRule,
    List<Subtask>? subtasks,
    bool clearDescription = false,
    bool clearDueDate = false,
    bool clearScheduledStart = false,
    bool clearCompletedAt = false,
    bool clearCategory = false,
    bool clearEstimatedMinutes = false,
    bool clearRecurrenceRule = false,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: clearDescription ? null : (description ?? this.description),
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      scheduledStart: clearScheduledStart
          ? null
          : scheduledStart ?? this.scheduledStart,
      createdAt: createdAt ?? this.createdAt,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
      category: clearCategory ? null : (category ?? this.category),
      tags: tags ?? this.tags,
      estimatedMinutes: clearEstimatedMinutes
          ? null
          : (estimatedMinutes ?? this.estimatedMinutes),
      actualMinutes: actualMinutes ?? this.actualMinutes,
      recurrenceRule: clearRecurrenceRule
          ? null
          : (recurrenceRule ?? this.recurrenceRule),
      subtasks: subtasks ?? this.subtasks,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    isCompleted,
    priority,
    dueDate,
    scheduledStart,
    createdAt,
    completedAt,
    category,
    tags,
    estimatedMinutes,
    actualMinutes,
    recurrenceRule,
    subtasks,
  ];
}
