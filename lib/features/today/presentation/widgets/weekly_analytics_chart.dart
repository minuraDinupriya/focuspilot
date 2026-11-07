import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:focuspilot/features/today/domain/models/daily_focus_metric.dart';

class WeeklyAnalyticsChart extends StatelessWidget {
  const WeeklyAnalyticsChart({
    super.key,
    required this.metrics,
    required this.maxMinutes,
    required this.streakDays,
    this.onViewReview,
  });

  final List<DailyFocusMetric> metrics;
  final int maxMinutes;
  final int streakDays;
  final VoidCallback? onViewReview;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textScale = MediaQuery.textScalerOf(context).scale(12) / 12;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
          // Header: Title and Streak Badge
          Wrap(
            spacing: 12,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Focus Activity',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Last 7 days',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              // Streak Pill
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.local_fire_department_rounded,
                      color: Colors.deepOrange,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        '$streakDays Day Streak',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 7-Day Bar Chart
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: math.max(
                    constraints.maxWidth,
                    metrics.length * 48 * textScale,
                  ),
                  height: 120 * textScale,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: metrics.map((metric) {
                      final ratio = maxMinutes > 0
                          ? (metric.focusMinutes / maxMinutes).clamp(0.05, 1.0)
                          : 0.05;

                      final isToday = metric.isToday;
                      final barColor = isToday
                          ? theme.colorScheme.primary
                          : (metric.focusMinutes > 0
                                ? theme.colorScheme.primary.withValues(
                                    alpha: 0.45,
                                  )
                                : theme.colorScheme.surfaceContainerHighest);

                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // Minutes text on top of bar
                              if (metric.focusMinutes > 0)
                                Text(
                                  '${metric.focusMinutes}m',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontSize: 10,
                                    fontWeight: isToday
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isToday
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.onSurfaceVariant,
                                  ),
                                )
                              else
                                const SizedBox(height: 14),
                              const SizedBox(height: 4),

                              // The Bar
                              Expanded(
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: FractionallySizedBox(
                                    heightFactor: ratio,
                                    child: Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: barColor,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Day label below bar
                              Text(
                                metric.dayLabel,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: isToday
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isToday
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          ),
          if (onViewReview != null) ...[
            const SizedBox(height: 14),
            Divider(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 6),
            InkWell(
              key: const Key('weekly_analytics_view_review_button'),
              onTap: onViewReview,
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.insights_rounded,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'View Weekly Review Summary',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
