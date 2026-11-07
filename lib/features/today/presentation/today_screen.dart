import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focuspilot/features/tasks/domain/models/task.dart';
import 'package:focuspilot/features/today/presentation/controllers/today_cubit.dart';
import 'package:focuspilot/features/today/presentation/controllers/today_state.dart';
import 'package:focuspilot/features/today/presentation/widgets/daily_goal_ring.dart';
import 'package:focuspilot/features/today/presentation/widgets/focus_heatmap_card.dart';
import 'package:focuspilot/features/today/presentation/widgets/goal_streaks_card.dart';
import 'package:focuspilot/features/today/presentation/widgets/metric_cards_row.dart';
import 'package:focuspilot/features/today/presentation/widgets/priority_tasks_preview.dart';
import 'package:focuspilot/features/today/presentation/widgets/productivity_insights_card.dart';
import 'package:focuspilot/features/today/presentation/widgets/quick_start_focus_card.dart';
import 'package:focuspilot/features/today/presentation/widgets/weekly_analytics_chart.dart';
import 'package:focuspilot/features/today/presentation/widgets/weekly_review_sheet.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key, this.onNavigateToFocus, this.onFocusTask});

  final VoidCallback? onNavigateToFocus;
  final ValueChanged<Task>? onFocusTask;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<TodayCubit, TodayState>(
      builder: (context, state) {
        if (state.status == TodayStatus.loading &&
            state.focusMinutesToday == 0 &&
            state.completedSessionsToday == 0) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.status == TodayStatus.error &&
            state.errorMessage != null &&
            state.focusMinutesToday == 0) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: 12),
                Text(
                  'Could not load dashboard',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                FilledButton.tonal(
                  onPressed: () => context.read<TodayCubit>().refresh(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => context.read<TodayCubit>().refresh(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Greeting & Weekly Review Action
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Good day!',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Stay focused and crush your goals.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    FilledButton.tonalIcon(
                      key: const Key('weekly_review_button'),
                      onPressed: () =>
                          WeeklyReviewSheet.show(context, state.weeklyReview),
                      icon: const Icon(Icons.insights_rounded, size: 18),
                      label: const Text('Review'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Circular Goal Ring
                DailyGoalRing(
                  progress: state.goalProgress,
                  currentMinutes: state.focusMinutesToday,
                  goalMinutes: state.dailyGoalMinutes,
                ),
                const SizedBox(height: 28),

                // Metrics Row (Focus Minutes, Sessions, Tasks)
                MetricCardsRow(
                  focusMinutes: state.focusMinutesToday,
                  completedSessions: state.completedSessionsToday,
                  completedTasks: state.completedTasksToday,
                ),
                const SizedBox(height: 24),

                // Goals & Streaks Tracker (FOC-32)
                GoalStreaksCard(
                  currentStreakDays: state.currentStreakDays,
                  bestStreakDays: state.bestStreakDays,
                  nextMilestoneDays: state.nextStreakMilestone,
                  streakBadge: state.streakMilestoneBadge,
                  focusMinutesToday: state.focusMinutesToday,
                  dailyGoalMinutes: state.dailyGoalMinutes,
                  dailyGoalProgress: state.goalProgress,
                  isDailyGoalAchieved: state.isDailyGoalAchieved,
                  focusMinutesThisWeek: state.focusMinutesThisWeek,
                  weeklyGoalMinutes: state.weeklyGoalMinutes,
                  weeklyGoalProgress: state.weeklyGoalProgress,
                  isWeeklyGoalAchieved: state.isWeeklyGoalAchieved,
                  daysGoalMetThisWeek: state.daysGoalMetThisWeek,
                ),
                const SizedBox(height: 24),

                // Priority Focus Tasks (FOC-14)
                if (state.priorityTasks.isNotEmpty) ...[
                  PriorityTasksPreview(
                    tasks: state.priorityTasks,
                    onToggleTask: (id) =>
                        context.read<TodayCubit>().toggleTask(id),
                    onFocusTask: (task) {
                      if (onFocusTask != null) {
                        onFocusTask!(task);
                      } else if (onNavigateToFocus != null) {
                        onNavigateToFocus!();
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                ],

                // Task Productivity Insights (FOC-33)
                ProductivityInsightsCard(
                  categoryInsights: state.categoryInsights,
                  priorityInsights: state.priorityInsights,
                  topTasksInsights: state.topTasksInsights,
                ),
                const SizedBox(height: 24),

                // 7-Day Weekly Analytics Chart (FOC-13 & FOC-34)
                if (state.weeklyMetrics.isNotEmpty) ...[
                  WeeklyAnalyticsChart(
                    metrics: state.weeklyMetrics,
                    maxMinutes: state.maxWeeklyMinutes,
                    streakDays: state.currentStreakDays,
                    onViewReview: () =>
                        WeeklyReviewSheet.show(context, state.weeklyReview),
                  ),
                  const SizedBox(height: 24),
                ],

                // 90-Day Focus Activity Heatmap (FOC-31)
                if (state.heatmapDays.isNotEmpty) ...[
                  FocusHeatmapCard(
                    heatmapDays: state.heatmapDays,
                    totalMinutes: state.totalHeatmapMinutes,
                  ),
                  const SizedBox(height: 24),
                ],

                // Quick Start Focus CTA Card
                QuickStartFocusCard(
                  onStartPressed: () {
                    if (onNavigateToFocus != null) {
                      onNavigateToFocus!();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Switch to Focus tab to start!'),
                          duration: Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
