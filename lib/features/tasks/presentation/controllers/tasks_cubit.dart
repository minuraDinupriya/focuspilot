import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focuspilot/features/tasks/domain/models/task.dart';
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

  Future<void> addTask({
    required String title,
    String? description,
    TaskPriority priority = TaskPriority.medium,
    DateTime? dueDate,
  }) async {
    try {
      final task = Task.create(
        title: title,
        description: description,
        priority: priority,
        dueDate: dueDate,
      );
      await _taskRepository.saveTask(task);
    } catch (e) {
      emit(
        state.copyWith(
          status: TasksStatus.failure,
          errorMessage: 'Failed to add task: ${e.toString()}',
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

  void setFilter(TasksFilter filter) {
    emit(state.copyWith(filter: filter));
  }

  @override
  Future<void> close() {
    _tasksSubscription?.cancel();
    return super.close();
  }
}
