import 'package:flutter/material.dart';
import 'package:focuspilot/features/tasks/presentation/controllers/tasks_state.dart';

class TaskFilterBar extends StatelessWidget {
  const TaskFilterBar({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
    required this.allCount,
    required this.activeCount,
    required this.completedCount,
  });

  final TasksFilter selectedFilter;
  final ValueChanged<TasksFilter> onFilterSelected;
  final int allCount;
  final int activeCount;
  final int completedCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SegmentedButton<TasksFilter>(
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
    );
  }
}
