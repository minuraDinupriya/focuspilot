import 'package:flutter/material.dart';
import 'package:focuspilot/app/widgets/adaptive_segmented_button.dart';
import 'package:focuspilot/features/tasks/domain/models/task_priority.dart';
import 'package:focuspilot/features/tasks/presentation/controllers/tasks_state.dart';

class TaskFilterBar extends StatelessWidget {
  const TaskFilterBar({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
    required this.allCount,
    required this.activeCount,
    required this.completedCount,
    this.selectedPriority,
    this.onPrioritySelected,
    this.selectedCategory,
    this.categories = const [],
    this.onCategorySelected,
    this.selectedDueDate = DueDateFilter.all,
    this.onDueDateSelected,
    this.hasActiveFilters = false,
    this.onResetFilters,
  });

  final TasksFilter selectedFilter;
  final ValueChanged<TasksFilter> onFilterSelected;
  final int allCount;
  final int activeCount;
  final int completedCount;
  final TaskPriority? selectedPriority;
  final ValueChanged<TaskPriority?>? onPrioritySelected;
  final String? selectedCategory;
  final List<String> categories;
  final ValueChanged<String?>? onCategorySelected;
  final DueDateFilter selectedDueDate;
  final ValueChanged<DueDateFilter>? onDueDateSelected;
  final bool hasActiveFilters;
  final VoidCallback? onResetFilters;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Primary Status SegmentedButton
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: AdaptiveSegmentedButton<TasksFilter>(
            segments: [
              ButtonSegment<TasksFilter>(
                value: TasksFilter.all,
                label: Text('All ($allCount)'),
              ),
              ButtonSegment<TasksFilter>(
                value: TasksFilter.active,
                label: Text('Active ($activeCount)'),
              ),
              ButtonSegment<TasksFilter>(
                value: TasksFilter.completed,
                label: Text('Done ($completedCount)'),
              ),
            ],
            selected: {selectedFilter},
            onSelectionChanged: (Set<TasksFilter> newSelection) {
              onFilterSelected(newSelection.first);
            },
          ),
        ),

        // Secondary Multi-Filter Chips Row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              // Priority Popup/Filter Chip
              PopupMenuButton<TaskPriority?>(
                initialValue: selectedPriority,
                onSelected: onPrioritySelected,
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: null,
                    child: Text('All Priorities'),
                  ),
                  ...TaskPriority.values.map(
                    (p) => PopupMenuItem(value: p, child: Text(p.displayName)),
                  ),
                ],
                child: FilterChip(
                  label: Text(
                    selectedPriority == null
                        ? 'Priority'
                        : selectedPriority!.displayName,
                  ),
                  selected: selectedPriority != null,
                  onSelected: (_) {},
                ),
              ),
              const SizedBox(width: 8),

              // Due Date Popup/Filter Chip
              PopupMenuButton<DueDateFilter>(
                initialValue: selectedDueDate,
                onSelected: onDueDateSelected,
                itemBuilder: (context) => DueDateFilter.values
                    .map(
                      (d) =>
                          PopupMenuItem(value: d, child: Text(d.displayName)),
                    )
                    .toList(),
                child: FilterChip(
                  label: Text(
                    selectedDueDate == DueDateFilter.all
                        ? 'Due Date'
                        : selectedDueDate.displayName,
                  ),
                  selected: selectedDueDate != DueDateFilter.all,
                  onSelected: (_) {},
                ),
              ),
              const SizedBox(width: 8),

              // Category Filter Chip (if categories exist)
              if (categories.isNotEmpty) ...[
                PopupMenuButton<String?>(
                  initialValue: selectedCategory,
                  onSelected: onCategorySelected,
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: null,
                      child: Text('All Categories'),
                    ),
                    ...categories.map(
                      (c) => PopupMenuItem(value: c, child: Text(c)),
                    ),
                  ],
                  child: FilterChip(
                    label: Text(selectedCategory ?? 'Category'),
                    selected: selectedCategory != null,
                    onSelected: (_) {},
                  ),
                ),
                const SizedBox(width: 8),
              ],

              // Clear Filters Chip
              if (hasActiveFilters)
                ActionChip(
                  avatar: const Icon(Icons.close, size: 16),
                  label: const Text('Reset'),
                  backgroundColor: theme.colorScheme.errorContainer.withValues(
                    alpha: 0.6,
                  ),
                  onPressed: onResetFilters,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
