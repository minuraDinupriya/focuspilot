import 'package:flutter/material.dart';
import 'package:focuspilot/features/tasks/domain/models/task_priority.dart';
import 'package:focuspilot/features/today/domain/models/weekly_review_data.dart';

/// Modal bottom sheet displaying a comprehensive summary of the user's
/// weekly focus performance, goal achievements, top tasks, and momentum.
class WeeklyReviewSheet extends StatelessWidget {
  const WeeklyReviewSheet({super.key, this.data});

  final WeeklyReviewData? data;

  static Future<void> show(BuildContext context, WeeklyReviewData? data) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => WeeklyReviewSheet(data: data),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final review = data;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Column(
                children: [
                  const SizedBox(height: 12),
                  // Drag Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Scrollable Content
                  Expanded(
                    child: review == null
                        ? const Center(
                            child: Text('No weekly activity recorded yet.'),
                          )
                        : ListView(
                            controller: scrollController,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            children: [
                              // Header Section
                              Center(
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: theme
                                            .colorScheme
                                            .primaryContainer
                                            .withValues(alpha: 0.6),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.insights_rounded,
                                        size: 32,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Weekly Review',
                                      style: theme.textTheme.headlineSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      review.dateRangeText,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: theme
                                                .colorScheme
                                                .onSurfaceVariant,
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Focus Time Comparison Card
                              _buildComparisonCard(context, review),
                              const SizedBox(height: 16),

                              // 2x2 Key Stats Grid
                              _buildStatsGrid(context, review),
                              const SizedBox(height: 20),

                              // Top Tasks Highlight
                              if (review.topTasks.isNotEmpty) ...[
                                Text(
                                  'Top Focused Tasks',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                ...review.topTasks.map(
                                  (task) => _buildTopTaskTile(context, task),
                                ),
                                const SizedBox(height: 20),
                              ],

                              // Motivational Message
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.tertiaryContainer
                                      .withValues(alpha: 0.35),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: theme.colorScheme.tertiary
                                        .withValues(alpha: 0.25),
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.lightbulb_rounded,
                                      size: 24,
                                      color: theme.colorScheme.tertiary,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Weekly Takeaway',
                                            style: theme.textTheme.labelLarge
                                                ?.copyWith(
                                                  color: theme
                                                      .colorScheme
                                                      .onTertiaryContainer,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            review.motivationalMessage,
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                                  color: theme
                                                      .colorScheme
                                                      .onTertiaryContainer,
                                                  height: 1.35,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 28),

                              // Close / Done Button
                              FilledButton(
                                key: const Key('weekly_review_done_button'),
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Done'),
                              ),
                              const SizedBox(height: 32),
                            ],
                          ),
                  ),
                ],
              ),
              Positioned(
                top: 8,
                right: 12,
                child: IconButton(
                  key: const Key('weekly_review_close_button'),
                  icon: const Icon(Icons.close_rounded),
                  tooltip: 'Close',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildComparisonCard(BuildContext context, WeeklyReviewData review) {
    final theme = Theme.of(context);
    final trendColor = review.isPositiveTrend ? Colors.green : Colors.orange;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            children: [
              Text(
                'Focus Time',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              // Trend Pill
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: trendColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: trendColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      review.isPositiveTrend
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                      size: 16,
                      color: trendColor,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        review.trendText,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: trendColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'This Week',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      review.focusTimeFormatted,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Previous Week',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      review.previousFocusTimeFormatted,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, WeeklyReviewData review) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final textScale = MediaQuery.textScalerOf(context).scale(14) / 14;
        final cardWidth = constraints.maxWidth < 360 * textScale
            ? constraints.maxWidth
            : (constraints.maxWidth - 12) / 2;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            // 1. Daily Goals Met
            _buildStatCard(
              context: context,
              width: cardWidth,
              icon: Icons.check_circle_rounded,
              iconColor: Colors.teal,
              label: 'Daily Goals Met',
              value: '${review.daysGoalMetCount} / 7 days',
              subtext:
                  '${(review.goalAchievementRate * 100).toStringAsFixed(0)}% achievement',
            ),

            // 2. Completed Tasks
            _buildStatCard(
              context: context,
              width: cardWidth,
              icon: Icons.task_alt_rounded,
              iconColor: theme.colorScheme.primary,
              label: 'Completed Tasks',
              value: '${review.completedTasksCount}',
              subtext: '${review.completedSessionsCount} focus sessions',
            ),

            // 3. Best Day
            _buildStatCard(
              context: context,
              width: cardWidth,
              icon: Icons.local_fire_department_rounded,
              iconColor: Colors.deepOrange,
              label: 'Best Day',
              value: review.bestDayLabel ?? 'N/A',
              subtext: review.bestDayMinutes > 0
                  ? '${review.bestDayTimeFormatted} focused'
                  : 'No sessions',
            ),

            // 4. Top Category
            _buildStatCard(
              context: context,
              width: cardWidth,
              icon: Icons.pie_chart_rounded,
              iconColor: Colors.purple,
              label: 'Top Category',
              value: review.topCategory ?? 'General',
              subtext: review.topCategoryMinutes > 0
                  ? '${WeeklyReviewData.formatMinutes(review.topCategoryMinutes)} focus'
                  : 'All categories',
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required double width,
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required String subtext,
  }) {
    final theme = Theme.of(context);

    return Container(
      width: width,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: iconColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtext,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopTaskTile(BuildContext context, dynamic task) {
    final theme = Theme.of(context);
    final priorityColor = _priorityColor(task.priority, theme);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: priorityColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (task.category != null &&
                    task.category!.trim().isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    task.category!.trim(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              WeeklyReviewData.formatMinutes(task.actualMinutes),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _priorityColor(TaskPriority priority, ThemeData theme) {
    switch (priority) {
      case TaskPriority.high:
        return Colors.redAccent;
      case TaskPriority.medium:
        return Colors.orangeAccent;
      case TaskPriority.low:
        return Colors.blueAccent;
    }
  }
}
