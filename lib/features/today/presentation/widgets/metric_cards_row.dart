import 'package:flutter/material.dart';

class MetricCardsRow extends StatelessWidget {
  const MetricCardsRow({
    super.key,
    required this.focusMinutes,
    required this.completedSessions,
    required this.completedTasks,
  });

  final int focusMinutes;
  final int completedSessions;
  final int completedTasks;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            icon: Icons.timer_outlined,
            title: 'Focus',
            value: '${focusMinutes}m',
            color: Colors.indigo,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MetricCard(
            icon: Icons.check_circle_outline_rounded,
            title: 'Sessions',
            value: '$completedSessions',
            color: Colors.teal,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MetricCard(
            icon: Icons.task_alt_rounded,
            title: 'Tasks',
            value: '$completedTasks',
            color: Colors.deepOrange,
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

