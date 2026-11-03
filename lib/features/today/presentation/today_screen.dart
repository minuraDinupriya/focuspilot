import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focuspilot/features/today/presentation/controllers/today_cubit.dart';
import 'package:focuspilot/features/today/presentation/controllers/today_state.dart';
import 'package:focuspilot/features/today/presentation/widgets/daily_goal_ring.dart';
import 'package:focuspilot/features/today/presentation/widgets/metric_cards_row.dart';
import 'package:focuspilot/features/today/presentation/widgets/quick_start_focus_card.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key, this.onNavigateToFocus});

  final VoidCallback? onNavigateToFocus;

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
                // Header Greeting
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

                // Quick Start Focus CTA Card
                QuickStartFocusCard(
                  onStartPressed: () {
                    if (onNavigateToFocus != null) {
                      onNavigateToFocus!();
                    } else {
                      // Feedback snackbar when pressed directly
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
