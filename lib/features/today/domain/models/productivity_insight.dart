import 'package:equatable/equatable.dart';
import 'package:focuspilot/features/tasks/domain/models/task_priority.dart';

class CategoryFocusInsight extends Equatable {
  const CategoryFocusInsight({
    required this.category,
    required this.minutes,
    required this.percentage,
  });

  final String category;
  final int minutes;
  final double percentage; // 0.0 to 1.0

  @override
  List<Object?> get props => [category, minutes, percentage];
}

class PriorityFocusInsight extends Equatable {
  const PriorityFocusInsight({
    required this.priority,
    required this.minutes,
    required this.percentage,
  });

  final TaskPriority priority;
  final int minutes;
  final double percentage; // 0.0 to 1.0

  @override
  List<Object?> get props => [priority, minutes, percentage];
}

class TopTaskFocusInsight extends Equatable {
  const TopTaskFocusInsight({
    required this.taskId,
    required this.title,
    required this.actualMinutes,
    this.estimatedMinutes,
  });

  final String taskId;
  final String title;
  final int actualMinutes;
  final int? estimatedMinutes;

  @override
  List<Object?> get props => [taskId, title, actualMinutes, estimatedMinutes];
}
