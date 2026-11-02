import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focuspilot/features/tasks/domain/models/task.dart';
import 'package:focuspilot/features/tasks/presentation/controllers/tasks_cubit.dart';
import 'package:focuspilot/features/tasks/presentation/controllers/tasks_state.dart';

class FocusTaskSelector extends StatelessWidget {
  const FocusTaskSelector({
    super.key,
    required this.linkedTask,
    required this.onTaskSelected,
  });

  final Task? linkedTask;
  final ValueChanged<Task?> onTaskSelected;

  void _showTaskPicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return BlocBuilder<TasksCubit, TasksState>(
          builder: (context, state) {
            final activeTasks = state.tasks
                .where((t) => !t.isCompleted)
                .toList();

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Select Task to Focus On',
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (activeTasks.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          'No active tasks found.\nAdd tasks in the Tasks tab to link them.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: activeTasks.length,
                        itemBuilder: (context, index) {
                          final task = activeTasks[index];
                          final isSelected = linkedTask?.id == task.id;

                          return ListTile(
                            leading: Icon(
                              isSelected
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_unchecked,
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : null,
                            ),
                            title: Text(task.title),
                            subtitle: task.description != null
                                ? Text(
                                    task.description!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  )
                                : null,
                            onTap: () {
                              onTaskSelected(isSelected ? null : task);
                              Navigator.of(sheetContext).pop();
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (linkedTask != null) {
      return InputChip(
        avatar: const Icon(Icons.task_alt, size: 18),
        label: Text('Focusing: ${linkedTask!.title}'),
        onDeleted: () => onTaskSelected(null),
      );
    }

    return ActionChip(
      avatar: const Icon(Icons.add, size: 18),
      label: const Text('Tag a Task'),
      onPressed: () => _showTaskPicker(context),
    );
  }
}
