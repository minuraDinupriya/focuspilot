import 'package:flutter/material.dart';

class GoalStreaksCard extends StatelessWidget {
  const GoalStreaksCard({
    super.key,
    required this.currentStreakDays,
    required this.bestStreakDays,
    required this.nextMilestoneDays,
    required this.streakBadge,
    required this.focusMinutesToday,
    required this.dailyGoalMinutes,
    required this.dailyGoalProgress,
    required this.isDailyGoalAchieved,
    required this.focusMinutesThisWeek,
    required this.weeklyGoalMinutes,
    required this.weeklyGoalProgress,
    required this.isWeeklyGoalAchieved,
    required this.daysGoalMetThisWeek,
  });

  final int currentStreakDays;
  final int bestStreakDays;
  final int nextMilestoneDays;
  final String streakBadge;
  final int focusMinutesToday;
  final int dailyGoalMinutes;
  final double dailyGoalProgress;
  final bool isDailyGoalAchieved;
  final int focusMinutesThisWeek;
  final int weeklyGoalMinutes;
  final double weeklyGoalProgress;
  final bool isWeeklyGoalAchieved;
  final int daysGoalMetThisWeek;

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
            // Streak Header Banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: currentStreakDays > 0
                          ? Colors.amber.withValues(alpha: 0.2)
                          : colorScheme.surfaceContainerHighest,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        currentStreakDays > 0 ? '🔥' : '🌱',
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              currentStreakDays > 0
                                  ? '$currentStreakDays Day Streak'
                                  : 'No Active Streak',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withValues(
                                  alpha: 0.15,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                streakBadge,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Best: $bestStreakDays d • Next milestone: $nextMilestoneDays d',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Daily Goal Progress
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isDailyGoalAchieved ? Icons.check_circle : Icons.today,
                      size: 16,
                      color: isDailyGoalAchieved
                          ? Colors.green
                          : colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Daily Goal',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${focusMinutesToday}m / ${dailyGoalMinutes}m (${(dailyGoalProgress * 100).toInt()}%)',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDailyGoalAchieved ? Colors.green : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: dailyGoalProgress,
                minHeight: 8,
                backgroundColor: colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isDailyGoalAchieved ? Colors.green : colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isDailyGoalAchieved
                  ? '🎉 Daily goal reached! Excellent work.'
                  : '${(dailyGoalMinutes - focusMinutesToday).clamp(0, dailyGoalMinutes)}m remaining to achieve daily goal',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDailyGoalAchieved
                    ? Colors.green
                    : colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),

            // Weekly Goal Progress
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isWeeklyGoalAchieved
                          ? Icons.military_tech
                          : Icons.date_range,
                      size: 16,
                      color: isWeeklyGoalAchieved
                          ? Colors.amber
                          : colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Weekly Goal',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${focusMinutesThisWeek}m / ${weeklyGoalMinutes}m (${(weeklyGoalProgress * 100).toInt()}%)',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isWeeklyGoalAchieved ? Colors.amber[800] : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: weeklyGoalProgress,
                minHeight: 8,
                backgroundColor: colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isWeeklyGoalAchieved
                      ? Colors.amber[700]!
                      : colorScheme.secondary,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isWeeklyGoalAchieved
                  ? '🏆 Weekly target completed! ($daysGoalMetThisWeek/7 days met daily goal)'
                  : '$daysGoalMetThisWeek/7 days met daily goal • ${(weeklyGoalMinutes - focusMinutesThisWeek).clamp(0, weeklyGoalMinutes)}m remaining this week',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isWeeklyGoalAchieved
                    ? Colors.amber[800]
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
