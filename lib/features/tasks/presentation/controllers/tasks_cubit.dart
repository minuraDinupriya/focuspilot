import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focuspilot/features/tasks/domain/models/task.dart';
import 'package:focuspilot/features/tasks/domain/models/task_details.dart';
import 'package:focuspilot/features/tasks/domain/models/task_priority.dart';
import 'package:focuspilot/features/tasks/domain/repositories/task_repository.dart';
import 'package:focuspilot/features/tasks/presentation/controllers/tasks_state.dart';

class TasksCubit extends Cubit<TasksState> {
  TasksCubit(this._taskRepository) : super(const TasksState()) {
    loadTasks();
  }

  final TaskRepository _taskRepository;
  StreamSubscription<List<Task>>? _tasksSubscription;

  void loadTasks() {
    emit(state.copyWith(status: TasksStatus.loading));

    _tasksSubscription?.cancel();
    _tasksSubscription = _taskRepository.watchTasks().listen(
      (tasks) {
        emit(
          state.copyWith(
            status: TasksStatus.success,
            tasks: tasks,
            clearErrorMessage: true,
          ),
        );
      },
      onError: (error) {
        emit(
          state.copyWith(
            status: TasksStatus.failure,
            errorMessage: error.toString(),
          ),
        );
      },
    );
  }

  Future<bool> addTask({
    required String title,
    String? description,
    TaskPriority priority = TaskPriority.medium,
    DateTime? dueDate,
    DateTime? scheduledStart,
    String? category,
    List<String> tags = const [],
    int? estimatedMinutes,
    String? recurrenceRule,
  }) async {
    try {
      final task = Task.create(
        title: title,
        description: description,
        priority: priority,
        dueDate: dueDate,
        scheduledStart: scheduledStart,
        category: category,
        tags: tags,
        estimatedMinutes: estimatedMinutes,
        recurrenceRule: recurrenceRule,
      );
      await _taskRepository.saveTask(task);
      return true;
    } catch (e) {
      if (!isClosed) {
        emit(
          state.copyWith(
            status: TasksStatus.failure,
            errorMessage: 'Failed to add task: $e',
          ),
        );
      }
      return false;
    }
  }

  Future<bool> updateTaskDetails(String id, TaskDetails details) async {
    try {
      final saved = await _taskRepository.updateTaskDetails(id, details);
      if (!saved && !isClosed) {
        emit(
          state.copyWith(
            status: TasksStatus.failure,
            errorMessage: 'This task is no longer available.',
          ),
        );
      }
      return saved;
    } catch (e) {
      if (!isClosed) {
        emit(
          state.copyWith(
            status: TasksStatus.failure,
            errorMessage: 'Failed to update task: $e',
          ),
        );
      }
      return false;
    }
  }

  Future<void> addSubtask(String taskId, String title) async {
    try {
      await _taskRepository.addSubtask(taskId, title);
    } catch (e) {
      emit(
        state.copyWith(
          status: TasksStatus.failure,
          errorMessage: 'Failed to add subtask: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> toggleSubtask(String subtaskId) async {
    try {
      await _taskRepository.toggleSubtaskCompletion(subtaskId);
    } catch (e) {
      emit(
        state.copyWith(
          status: TasksStatus.failure,
          errorMessage: 'Failed to toggle subtask: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> deleteSubtask(String subtaskId) async {
    try {
      await _taskRepository.deleteSubtask(subtaskId);
    } catch (e) {
      emit(
        state.copyWith(
          status: TasksStatus.failure,
          errorMessage: 'Failed to delete subtask: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> toggleTask(String id) async {
    try {
      await _taskRepository.toggleTaskCompletion(id);
    } catch (e) {
      emit(
        state.copyWith(
          status: TasksStatus.failure,
          errorMessage: 'Failed to update task: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      await _taskRepository.deleteTask(id);
    } catch (e) {
      emit(
        state.copyWith(
          status: TasksStatus.failure,
          errorMessage: 'Failed to delete task: ${e.toString()}',
        ),
      );
    }
  }

  void setSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query.trim()));
  }

  void setFilter(TasksFilter filter) {
    emit(state.copyWith(filter: filter));
  }

  void setPriorityFilter(TaskPriority? priority) {
    emit(
      state.copyWith(
        priorityFilter: priority,
        clearPriorityFilter: priority == null,
      ),
    );
  }

  void setPrioritySort(bool enabled) {
    emit(state.copyWith(sortByPriority: enabled));
  }

  void setCategoryFilter(String? category) {
    emit(
      state.copyWith(
        categoryFilter: category,
        clearCategoryFilter: category == null,
      ),
    );
  }

  void setDueDateFilter(DueDateFilter filter) {
    emit(state.copyWith(dueDateFilter: filter));
  }

  void resetFilters() {
    emit(
      state.copyWith(
        searchQuery: '',
        filter: TasksFilter.all,
        clearPriorityFilter: true,
        clearCategoryFilter: true,
        dueDateFilter: DueDateFilter.all,
      ),
    );
  }

  @override
  Future<void> close() {
    _tasksSubscription?.cancel();
    return super.close();
  }
}
