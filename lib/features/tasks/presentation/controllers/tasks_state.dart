import 'package:equatable/equatable.dart';
import 'package:focuspilot/features/tasks/domain/models/task.dart';

enum TasksStatus { initial, loading, success, failure }

enum TasksFilter { all, active, completed }

class TasksState extends Equatable {
  const TasksState({
    this.status = TasksStatus.initial,
    this.tasks = const [],
    this.filter = TasksFilter.all,
    this.errorMessage,
  });

  final TasksStatus status;
  final List<Task> tasks;
  final TasksFilter filter;
  final String? errorMessage;

  List<Task> get filteredTasks {
    switch (filter) {
      case TasksFilter.all:
        return tasks;
      case TasksFilter.active:
        return tasks.where((task) => !task.isCompleted).toList();
      case TasksFilter.completed:
        return tasks.where((task) => task.isCompleted).toList();
    }
  }

  int get activeTasksCount => tasks.where((task) => !task.isCompleted).length;

  int get completedTasksCount => tasks.where((task) => task.isCompleted).length;

  TasksState copyWith({
    TasksStatus? status,
    List<Task>? tasks,
    TasksFilter? filter,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return TasksState(
      status: status ?? this.status,
      tasks: tasks ?? this.tasks,
      filter: filter ?? this.filter,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, tasks, filter, errorMessage];
}
