import 'package:equatable/equatable.dart';
import 'package:focuspilot/features/tasks/domain/models/task.dart';
import 'package:focuspilot/features/tasks/domain/models/task_priority.dart';

enum TasksStatus { initial, loading, success, failure }

enum TasksFilter { all, active, completed }

enum DueDateFilter {
  all,
  today,
  thisWeek,
  overdue;

  String get displayName {
    switch (this) {
      case DueDateFilter.all:
        return 'All Dates';
      case DueDateFilter.today:
        return 'Today';
      case DueDateFilter.thisWeek:
        return 'This Week';
      case DueDateFilter.overdue:
        return 'Overdue';
    }
  }
}

class TasksState extends Equatable {
  const TasksState({
    this.status = TasksStatus.initial,
    this.tasks = const [],
    this.filter = TasksFilter.all,
    this.searchQuery = '',
    this.priorityFilter,
    this.categoryFilter,
    this.dueDateFilter = DueDateFilter.all,
    this.errorMessage,
  });

  final TasksStatus status;
  final List<Task> tasks;
  final TasksFilter filter;
  final String searchQuery;
  final TaskPriority? priorityFilter;
  final String? categoryFilter;
  final DueDateFilter dueDateFilter;
  final String? errorMessage;

  bool get hasActiveFilters =>
      searchQuery.isNotEmpty ||
      filter != TasksFilter.all ||
      priorityFilter != null ||
      categoryFilter != null ||
      dueDateFilter != DueDateFilter.all;

  List<String> get availableCategories =>
      tasks.map((t) => t.category).whereType<String>().toSet().toList();

  List<Task> get filteredTasks {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final weekEnd = todayStart.add(const Duration(days: 7));

    return tasks.where((task) {
      // 1. Search Query
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        final titleMatch = task.title.toLowerCase().contains(query);
        final descMatch =
            task.description?.toLowerCase().contains(query) ?? false;
        final catMatch = task.category?.toLowerCase().contains(query) ?? false;
        final tagMatch = task.tags.any((t) => t.toLowerCase().contains(query));
        if (!titleMatch && !descMatch && !catMatch && !tagMatch) {
          return false;
        }
      }

      // 2. Status Filter
      switch (filter) {
        case TasksFilter.all:
          break;
        case TasksFilter.active:
          if (task.isCompleted) return false;
          break;
        case TasksFilter.completed:
          if (!task.isCompleted) return false;
          break;
      }

      // 3. Priority Filter
      if (priorityFilter != null && task.priority != priorityFilter) {
        return false;
      }

      // 4. Category Filter
      if (categoryFilter != null && task.category != categoryFilter) {
        return false;
      }

      // 5. Due Date Filter
      switch (dueDateFilter) {
        case DueDateFilter.all:
          break;
        case DueDateFilter.today:
          if (task.dueDate == null) return false;
          if (task.dueDate!.isBefore(todayStart) ||
              task.dueDate!.isAfter(todayEnd)) {
            return false;
          }
          break;
        case DueDateFilter.thisWeek:
          if (task.dueDate == null) return false;
          if (task.dueDate!.isBefore(todayStart) ||
              task.dueDate!.isAfter(weekEnd)) {
            return false;
          }
          break;
        case DueDateFilter.overdue:
          if (!task.isOverdue) return false;
          break;
      }

      return true;
    }).toList();
  }

  int get activeTasksCount => tasks.where((task) => !task.isCompleted).length;

  int get completedTasksCount => tasks.where((task) => task.isCompleted).length;

  TasksState copyWith({
    TasksStatus? status,
    List<Task>? tasks,
    TasksFilter? filter,
    String? searchQuery,
    TaskPriority? priorityFilter,
    bool clearPriorityFilter = false,
    String? categoryFilter,
    bool clearCategoryFilter = false,
    DueDateFilter? dueDateFilter,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return TasksState(
      status: status ?? this.status,
      tasks: tasks ?? this.tasks,
      filter: filter ?? this.filter,
      searchQuery: searchQuery ?? this.searchQuery,
      priorityFilter: clearPriorityFilter
          ? null
          : (priorityFilter ?? this.priorityFilter),
      categoryFilter: clearCategoryFilter
          ? null
          : (categoryFilter ?? this.categoryFilter),
      dueDateFilter: dueDateFilter ?? this.dueDateFilter,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    status,
    tasks,
    filter,
    searchQuery,
    priorityFilter,
    categoryFilter,
    dueDateFilter,
    errorMessage,
  ];
}
