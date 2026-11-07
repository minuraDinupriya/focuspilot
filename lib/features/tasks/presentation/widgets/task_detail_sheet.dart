import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focuspilot/features/tasks/domain/models/task.dart';
import 'package:focuspilot/features/tasks/domain/models/task_details.dart';
import 'package:focuspilot/features/tasks/domain/models/task_priority.dart';
import 'package:focuspilot/features/tasks/presentation/controllers/tasks_cubit.dart';
import 'package:focuspilot/features/tasks/presentation/controllers/tasks_state.dart';

class TaskDetailSheet extends StatefulWidget {
  const TaskDetailSheet({super.key, this.task});

  final Task? task;

  static Future<void> show(BuildContext context, {Task? task}) {
    final cubit = context.read<TasksCubit>();
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: TaskDetailSheet(task: task),
      ),
    );
  }

  @override
  State<TaskDetailSheet> createState() => _TaskDetailSheetState();
}

class _TaskDetailSheetState extends State<TaskDetailSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late final TextEditingController _subtaskController;
  late TaskPriority _priority;
  DateTime? _dueDate;
  String? _category;
  int? _estimatedMinutes;
  String? _recurrenceRule;
  bool _isSaving = false;
  bool _saveFailed = false;

  static const _categories = [
    'Study',
    'Work',
    'Personal',
    'Fitness',
    'Reading',
  ];
  static const _estimatedOptions = [15, 25, 45, 60, 90];
  static const _recurrenceOptions = [
    'none',
    'daily',
    'weekdays',
    'weekly',
    'monthly',
  ];

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    _titleController = TextEditingController(text: t?.title ?? '');
    _descController = TextEditingController(text: t?.description ?? '');
    _subtaskController = TextEditingController();
    _priority = t?.priority ?? TaskPriority.medium;
    _dueDate = t?.dueDate;
    _category = t?.category;
    _estimatedMinutes = t?.estimatedMinutes;
    _recurrenceRule = t?.recurrenceRule;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _subtaskController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSaving || !(_formKey.currentState?.validate() ?? false)) return;

    final cubit = context.read<TasksCubit>();
    final taskId = widget.task?.id;
    final description = _descController.text.trim();
    final details = TaskDetails(
      title: _titleController.text.trim(),
      description: description.isEmpty ? null : description,
      priority: _priority,
      dueDate: _dueDate,
      category: _category,
      estimatedMinutes: _estimatedMinutes,
      recurrenceRule: _recurrenceRule == 'none' ? null : _recurrenceRule,
    );
    FocusScope.of(context).unfocus();
    setState(() {
      _isSaving = true;
      _saveFailed = false;
    });

    final saved = taskId == null
        ? await cubit.addTask(
            title: details.title,
            description: details.description,
            priority: details.priority,
            dueDate: details.dueDate,
            category: details.category,
            estimatedMinutes: details.estimatedMinutes,
            recurrenceRule: details.recurrenceRule,
          )
        : await cubit.updateTaskDetails(taskId, details);

    if (!mounted) return;
    if (saved && ModalRoute.of(context)?.isCurrent == true) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _isSaving = false;
      _saveFailed = !saved;
    });
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 5)),
    );
    if (picked != null && mounted) {
      setState(() => _dueDate = picked);
    }
  }

  void _handleAddSubtask() {
    final text = _subtaskController.text.trim();
    if (text.isEmpty || widget.task == null) return;
    context.read<TasksCubit>().addSubtask(widget.task!.id, text);
    _subtaskController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final openingTask = widget.task;
    final isEditing = openingTask != null;
    final task = openingTask == null
        ? null
        : context.select((TasksCubit cubit) {
            final state = cubit.state;
            final current = state.tasks
                .where((task) => task.id == openingTask.id)
                .firstOrNull;
            return current ??
                (state.status == TasksStatus.loading ? openingTask : null);
          });
    final isUnavailable = isEditing && task == null;

    final form = Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 16,
        left: 20,
        right: 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      isEditing ? 'Edit Task' : 'New Task',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (task != null)
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        color: theme.colorScheme.error,
                      ),
                      tooltip: 'Delete task',
                      onPressed: () {
                        context.read<TasksCubit>().deleteTask(task.id);
                        Navigator.of(context).pop();
                      },
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Title Field
              TextFormField(
                controller: _titleController,
                autofocus: !isEditing,
                decoration: const InputDecoration(
                  labelText: 'Task Title',
                  hintText: 'What needs to be done?',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.check_circle_outline),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Title cannot be empty';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Description Field
              TextFormField(
                controller: _descController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'Add details, links, or notes',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.notes),
                ),
              ),
              const SizedBox(height: 16),

              // Priority Selector
              Text('Priority', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: TaskPriority.values.map((p) {
                  final isSelected = _priority == p;
                  return ChoiceChip(
                    label: Text(p.displayName),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _priority = p),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Category Selector
              Text('Category', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ..._categories.map((c) {
                    final isSelected = _category == c;
                    return ChoiceChip(
                      label: Text(c),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() => _category = selected ? c : null);
                      },
                    );
                  }),
                ],
              ),
              const SizedBox(height: 16),

              // Due Date Selector
              Text('Due Date', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              Row(
                children: [
                  Flexible(
                    child: OutlinedButton.icon(
                      onPressed: _pickDueDate,
                      icon: const Icon(Icons.calendar_today, size: 16),
                      label: Text(
                        _dueDate == null
                            ? 'Set Due Date'
                            : '${_dueDate!.year}-${_dueDate!.month.toString().padLeft(2, '0')}-${_dueDate!.day.toString().padLeft(2, '0')}',
                      ),
                    ),
                  ),
                  if (_dueDate != null) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      tooltip: 'Clear due date',
                      onPressed: () => setState(() => _dueDate = null),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),

              // Focus Time Tracking (Actual vs. Estimated)
              if (task != null &&
                  (task.actualMinutes > 0 ||
                      task.estimatedMinutes != null)) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: task.isOverEstimated
                          ? theme.colorScheme.error.withValues(alpha: 0.5)
                          : theme.colorScheme.outlineVariant,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 12,
                        runSpacing: 6,
                        alignment: WrapAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.timelapse,
                                size: 18,
                                color: task.isOverEstimated
                                    ? theme.colorScheme.error
                                    : theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  'Focus Progress',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            task.estimatedMinutes != null
                                ? '${task.actualMinutes}m / ${task.estimatedMinutes}m'
                                : '${task.actualMinutes}m logged',
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: task.isOverEstimated
                                  ? theme.colorScheme.error
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      if (task.timeProgress != null) ...[
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: task.timeProgress,
                            minHeight: 6,
                            backgroundColor:
                                theme.colorScheme.surfaceContainerHighest,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              task.isOverEstimated
                                  ? theme.colorScheme.error
                                  : theme.colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          task.isOverEstimated
                              ? 'Exceeded estimate by ${task.actualMinutes - task.estimatedMinutes!} min'
                              : '${task.remainingEstimatedMinutes} min remaining of estimate',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: task.isOverEstimated
                                ? theme.colorScheme.error
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Estimated Focus Time
              Text('Estimated Focus Time', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _estimatedOptions.map((m) {
                  final isSelected = _estimatedMinutes == m;
                  return ChoiceChip(
                    label: Text('$m min'),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _estimatedMinutes = selected ? m : null);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Recurrence
              Text('Repeat', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _recurrenceOptions.map((r) {
                  final isSelected = (_recurrenceRule ?? 'none') == r;
                  final label = r[0].toUpperCase() + r.substring(1);
                  return ChoiceChip(
                    label: Text(label),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _recurrenceRule = r),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Subtasks Checklist Section (Available when editing existing task)
              if (task != null) ...[
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        'Subtasks (${task.completedSubtasksCount}/${task.subtasks.length})',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                if (task.subtasks.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: task.subtasksProgress,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
                const SizedBox(height: 8),

                // Subtask list items
                ...task.subtasks.map((s) {
                  return ListTile(
                    key: ValueKey(s.id),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Checkbox(
                      value: s.isCompleted,
                      onChanged: (_) {
                        context.read<TasksCubit>().toggleSubtask(s.id);
                      },
                    ),
                    title: Text(
                      s.title,
                      style: TextStyle(
                        decoration: s.isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        color: s.isCompleted
                            ? theme.colorScheme.outline
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18),
                      tooltip: 'Delete subtask',
                      onPressed: () {
                        context.read<TasksCubit>().deleteSubtask(s.id);
                      },
                    ),
                  );
                }),

                // Add subtask inline input
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _subtaskController,
                        decoration: const InputDecoration(
                          hintText: 'Add a subtask...',
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        onSubmitted: (_) => _handleAddSubtask(),
                      ),
                    ),
                    IconButton.filledTonal(
                      icon: const Icon(Icons.add),
                      tooltip: 'Add subtask',
                      onPressed: _handleAddSubtask,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],

              if (isUnavailable || _saveFailed) ...[
                Semantics(
                  liveRegion: true,
                  child: Text(
                    isUnavailable
                        ? 'This task is no longer available.'
                        : 'Could not save this task. Try again.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],

              // Action Buttons
              Wrap(
                alignment: WrapAlignment.end,
                spacing: 12,
                runSpacing: 8,
                children: [
                  TextButton(
                    onPressed: _isSaving
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: _isSaving || isUnavailable ? null : _submit,
                    child: Text(
                      _isSaving
                          ? 'Saving...'
                          : (isEditing ? 'Save Changes' : 'Create Task'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
    return ExcludeFocus(
      excluding: _isSaving,
      child: AbsorbPointer(absorbing: _isSaving, child: form),
    );
  }
}
