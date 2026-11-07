import 'package:flutter/material.dart';
import 'package:focuspilot/app/widgets/adaptive_segmented_button.dart';
import 'package:focuspilot/features/tasks/domain/models/task_priority.dart';
import 'package:focuspilot/features/today/domain/models/productivity_insight.dart';

enum InsightTab { category, priority, topTasks }

class ProductivityInsightsCard extends StatefulWidget {
  const ProductivityInsightsCard({
    super.key,
    required this.categoryInsights,
    required this.priorityInsights,
    required this.topTasksInsights,
  });

  final List<CategoryFocusInsight> categoryInsights;
  final List<PriorityFocusInsight> priorityInsights;
  final List<TopTaskFocusInsight> topTasksInsights;

  @override
  State<ProductivityInsightsCard> createState() =>
      _ProductivityInsightsCardState();
}

class _ProductivityInsightsCardState extends State<ProductivityInsightsCard> {
  InsightTab _selectedTab = InsightTab.category;

  static const _categoryColors = [
    Colors.indigo,
    Colors.teal,
    Colors.deepOrange,
    Colors.purple,
    Colors.blueGrey,
    Colors.amber,
  ];

  Color _colorForCategory(int index) {
    return _categoryColors[index % _categoryColors.length];
  }

  Color _colorForPriority(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.low:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.insights, size: 20, color: colorScheme.primary),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Productivity Insights',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Segmented Button
            AdaptiveSegmentedButton<InsightTab>(
              segments: const [
                ButtonSegment(
                  value: InsightTab.category,
                  label: Text('Category'),
                  icon: Icon(Icons.category_outlined, size: 16),
                ),
                ButtonSegment(
                  value: InsightTab.priority,
                  label: Text('Priority'),
                  icon: Icon(Icons.flag_outlined, size: 16),
                ),
                ButtonSegment(
                  value: InsightTab.topTasks,
                  label: Text('Top Tasks'),
                  icon: Icon(Icons.star_outline, size: 16),
                ),
              ],
              selected: {_selectedTab},
              onSelectionChanged: (selection) {
                setState(() => _selectedTab = selection.first);
              },
            ),
            const SizedBox(height: 16),

            // Content
            _buildTabContent(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(ThemeData theme) {
    switch (_selectedTab) {
      case InsightTab.category:
        return _buildCategoryContent(theme);
      case InsightTab.priority:
        return _buildPriorityContent(theme);
      case InsightTab.topTasks:
        return _buildTopTasksContent(theme);
    }
  }

  Widget _buildCategoryContent(ThemeData theme) {
    if (widget.categoryInsights.isEmpty) {
      return _buildEmptyState(theme, 'No focus time logged by category yet.');
    }

    return Column(
      children: [
        // Stacked Segmented Bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Row(
            children: widget.categoryInsights.asMap().entries.map((e) {
              final idx = e.key;
              final insight = e.value;
              final flex = (insight.percentage * 100).round();
              if (flex <= 0) return const SizedBox.shrink();
              return Expanded(
                flex: flex,
                child: Container(height: 10, color: _colorForCategory(idx)),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),

        // List
        ...widget.categoryInsights.asMap().entries.map((e) {
          final idx = e.key;
          final item = e.value;
          final pct = (item.percentage * 100).toInt();

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: _colorForCategory(idx),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.category,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Flexible(
                  child: Text(
                    '${item.minutes}m ($pct%)',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildPriorityContent(ThemeData theme) {
    final hasData = widget.priorityInsights.any((i) => i.minutes > 0);
    if (!hasData) {
      return _buildEmptyState(theme, 'No focus time logged by priority yet.');
    }

    return Column(
      children: widget.priorityInsights.map((item) {
        final pct = (item.percentage * 100).toInt();
        final color = _colorForPriority(item.priority);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
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
                      Icon(Icons.flag, size: 16, color: color),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          '${item.priority.displayName} Priority',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${item.minutes}m ($pct%)',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: item.percentage,
                  minHeight: 6,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTopTasksContent(ThemeData theme) {
    if (widget.topTasksInsights.isEmpty) {
      return _buildEmptyState(
        theme,
        'No focus time logged on specific tasks yet.',
      );
    }

    return Column(
      children: widget.topTasksInsights.asMap().entries.map((entry) {
        final rank = entry.key + 1;
        final task = entry.value;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: rank == 1
                      ? Colors.amber.withValues(alpha: 0.2)
                      : theme.colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$rank',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: rank == 1 ? Colors.amber[800] : null,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (task.estimatedMinutes != null)
                      Text(
                        'Estimate: ${task.estimatedMinutes}m',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              Text(
                '⏱️ ${task.actualMinutes}m',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState(ThemeData theme, String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Text(
          message,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
