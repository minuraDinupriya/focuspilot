import 'package:flutter/material.dart';
import 'package:focuspilot/features/tasks/domain/models/task.dart';
import 'package:focuspilot/features/tasks/presentation/widgets/task_priority_chip.dart';

class TaskItemTile extends StatelessWidget {
  const TaskItemTile({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
  });

  final Task task;
  final ValueChanged<bool?> onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: theme.colorScheme.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.delete_outline, color: theme.colorScheme.onError),
      ),
      onDismissed: (_) => onDelete(),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        elevation: 0,
        color: task.isCompleted
            ? theme.colorScheme.surfaceContainerLow
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Checkbox(
                value: task.isCompleted,
                onChanged: onToggle,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        color: task.isCompleted
                            ? theme.colorScheme.outline
                            : theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (task.description != null &&
                        task.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        task.description!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              TaskPriorityChip(priority: task.priority),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                color: theme.colorScheme.outline,
                onPressed: onDelete,
                tooltip: 'Delete task',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
