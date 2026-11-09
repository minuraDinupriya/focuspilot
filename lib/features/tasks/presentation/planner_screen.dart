import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focuspilot/features/tasks/domain/models/task.dart';
import 'package:focuspilot/features/tasks/presentation/controllers/tasks_cubit.dart';
import 'package:focuspilot/features/tasks/presentation/controllers/tasks_state.dart';
import 'package:focuspilot/features/tasks/presentation/widgets/task_detail_sheet.dart';
import 'package:focuspilot/features/tasks/presentation/widgets/task_priority_chip.dart';

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  DateTime _day = DateUtils.dateOnly(DateTime.now());

  void _moveDay(int offset) {
    setState(() => _day = DateTime(_day.year, _day.month, _day.day + offset));
  }

  Future<void> _chooseDay() async {
    final day = await showDatePicker(
      context: context,
      initialDate: _day,
      firstDate: DateTime(_day.year - 10),
      lastDate: DateTime(_day.year + 10, 12, 31),
    );
    if (day != null && mounted) setState(() => _day = day);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateLabel = MaterialLocalizations.of(context).formatMediumDate(_day);
    return Scaffold(
      body: BlocBuilder<TasksCubit, TasksState>(
        builder: (context, state) {
          final scheduled =
              state.tasks.where((task) {
                return DateUtils.isSameDay(
                  task.scheduledStart?.toLocal(),
                  _day,
                );
              }).toList()..sort((a, b) {
                final order = a.scheduledStart!.compareTo(b.scheduledStart!);
                return order != 0 ? order : a.id.compareTo(b.id);
              });

          return ListView(
            key: ValueKey(_day),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
            children: [
              Text('Day Planner', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    tooltip: 'Previous day',
                    onPressed: () => _moveDay(-1),
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _chooseDay,
                      icon: const Icon(Icons.calendar_month_outlined),
                      label: Text(dateLabel, textAlign: TextAlign.center),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Next day',
                    onPressed: () => _moveDay(1),
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton(
                  onPressed: DateUtils.isSameDay(_day, DateTime.now())
                      ? null
                      : () => setState(
                          () => _day = DateUtils.dateOnly(DateTime.now()),
                        ),
                  child: const Text('Back to today'),
                ),
              ),
              if (state.status == TasksStatus.loading && state.tasks.isEmpty)
                const Center(child: CircularProgressIndicator())
              else if (state.status == TasksStatus.failure &&
                  state.tasks.isEmpty)
                Column(
                  children: [
                    const Text('Could not load planned tasks.'),
                    TextButton(
                      onPressed: context.read<TasksCubit>().loadTasks,
                      child: const Text('Retry'),
                    ),
                  ],
                )
              else if (scheduled.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    'Nothing planned for this day. Plan a task to give it a start time.',
                    textAlign: TextAlign.center,
                  ),
                )
              else
                for (final task in scheduled) _TimelineEntry(task: task),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => TaskDetailSheet.show(
          context,
          initialScheduledStart: DateTime(_day.year, _day.month, _day.day, 9),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Plan task'),
      ),
    );
  }
}

class _TimelineEntry extends StatelessWidget {
  const _TimelineEntry({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final start = task.scheduledStart!.toLocal();
    final time = TimeOfDay.fromDateTime(start).format(context);
    return Container(
      decoration: BoxDecoration(
        border: BorderDirectional(
          start: BorderSide(color: theme.colorScheme.outlineVariant, width: 2),
        ),
      ),
      padding: const EdgeInsetsDirectional.only(start: 12, bottom: 8),
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => TaskDetailSheet.show(context, task: task),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  time,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text(task.title, style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    TaskPriorityChip(priority: task.priority),
                    if (task.estimatedMinutes case final minutes?)
                      Text('$minutes min'),
                    if (task.isCompleted) const Text('Completed'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
