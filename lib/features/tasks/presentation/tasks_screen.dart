import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focuspilot/features/tasks/domain/models/task_priority.dart';
import 'package:focuspilot/features/tasks/presentation/controllers/tasks_cubit.dart';
import 'package:focuspilot/features/tasks/presentation/controllers/tasks_state.dart';
import 'package:focuspilot/features/tasks/presentation/widgets/add_task_bottom_sheet.dart';
import 'package:focuspilot/features/tasks/presentation/widgets/task_filter_bar.dart';
import 'package:focuspilot/features/tasks/presentation/widgets/task_item_tile.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: BlocConsumer<TasksCubit, TasksState>(
        listener: (context, state) {
          if (state.status == TasksStatus.failure &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == TasksStatus.loading && state.tasks.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == TasksStatus.failure && state.tasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 56,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load tasks',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  FilledButton.tonal(
                    onPressed: () => context.read<TasksCubit>().loadTasks(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              TaskFilterBar(
                selectedFilter: state.filter,
                onFilterSelected: (filter) {
                  context.read<TasksCubit>().setFilter(filter);
                },
                allCount: state.tasks.length,
                activeCount: state.activeTasksCount,
                completedCount: state.completedTasksCount,
              ),
              Expanded(
                child: state.filteredTasks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.checklist_rtl_outlined,
                              size: 64,
                              color: theme.colorScheme.outlineVariant,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              state.filter == TasksFilter.all
                                  ? 'No tasks yet'
                                  : state.filter == TasksFilter.active
                                  ? 'No active tasks'
                                  : 'No completed tasks',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              state.filter == TasksFilter.all
                                  ? 'Tap + below to create your first task'
                                  : 'Tasks will appear here when filtered',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80, top: 4),
                        itemCount: state.filteredTasks.length,
                        itemBuilder: (context, index) {
                          final task = state.filteredTasks[index];
                          return TaskItemTile(
                            task: task,
                            onToggle: (_) {
                              context.read<TasksCubit>().toggleTask(task.id);
                            },
                            onDelete: () {
                              context.read<TasksCubit>().deleteTask(task.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Deleted "${task.title}"'),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          AddTaskBottomSheet.show(
            context,
            onSubmit:
                ({
                  required String title,
                  String? description,
                  required TaskPriority priority,
                }) {
                  context.read<TasksCubit>().addTask(
                    title: title,
                    description: description,
                    priority: priority,
                  );
                },
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
    );
  }
}
