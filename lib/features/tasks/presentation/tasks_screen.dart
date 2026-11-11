import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focuspilot/features/tasks/presentation/controllers/tasks_cubit.dart';
import 'package:focuspilot/features/tasks/presentation/controllers/tasks_state.dart';
import 'package:focuspilot/features/tasks/presentation/widgets/task_delete_undo.dart';
import 'package:focuspilot/features/tasks/presentation/widgets/task_detail_sheet.dart';
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

          final visibleTasks = state.filteredTasks;
          return Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search tasks by title, category, or tags...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: state.searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              context.read<TasksCubit>().setSearchQuery('');
                            },
                          )
                        : null,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (val) {
                    context.read<TasksCubit>().setSearchQuery(val);
                  },
                ),
              ),

              // Filter Bar
              TaskFilterBar(
                selectedFilter: state.filter,
                onFilterSelected: (filter) {
                  context.read<TasksCubit>().setFilter(filter);
                },
                allCount: state.tasks.length,
                activeCount: state.activeTasksCount,
                completedCount: state.completedTasksCount,
                sortByPriority: state.sortByPriority,
                onPrioritySortChanged: context
                    .read<TasksCubit>()
                    .setPrioritySort,
                selectedPriority: state.priorityFilter,
                onPrioritySelected: (priority) {
                  context.read<TasksCubit>().setPriorityFilter(priority);
                },
                selectedCategory: state.categoryFilter,
                categories: state.availableCategories,
                onCategorySelected: (cat) {
                  context.read<TasksCubit>().setCategoryFilter(cat);
                },
                selectedDueDate: state.dueDateFilter,
                onDueDateSelected: (due) {
                  context.read<TasksCubit>().setDueDateFilter(due);
                },
                hasActiveFilters: state.hasActiveFilters,
                onResetFilters: () {
                  context.read<TasksCubit>().resetFilters();
                },
              ),
              Expanded(
                child: visibleTasks.isEmpty
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
                        itemCount: visibleTasks.length,
                        itemBuilder: (context, index) {
                          final task = visibleTasks[index];
                          return TaskItemTile(
                            task: task,
                            onTap: () =>
                                TaskDetailSheet.show(context, task: task),
                            onToggle: (_) {
                              context.read<TasksCubit>().toggleTask(task.id);
                            },
                            onDelete: () =>
                                deleteTaskWithUndo(context, task.id),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => TaskDetailSheet.show(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
    );
  }
}
