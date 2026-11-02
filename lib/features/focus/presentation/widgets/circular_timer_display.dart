import 'package:flutter/material.dart';
import 'package:focuspilot/features/focus/domain/models/focus_mode.dart';
import 'package:focuspilot/features/tasks/domain/models/task.dart';

class CircularTimerDisplay extends StatelessWidget {
  const CircularTimerDisplay({
    super.key,
    required this.timerString,
    required this.progress,
    required this.mode,
    this.linkedTask,
  });

  final String timerString;
  final double progress;
  final FocusMode mode;
  final Task? linkedTask;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const size = 260.0;

    Color progressColor;
    switch (mode) {
      case FocusMode.work:
        progressColor = theme.colorScheme.primary;
        break;
      case FocusMode.shortBreak:
        progressColor = theme.colorScheme.tertiary;
        break;
      case FocusMode.longBreak:
        progressColor = theme.colorScheme.secondary;
        break;
    }

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background track
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: 12,
              strokeCap: StrokeCap.round,
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.5,
                ),
              ),
            ),
          ),
          // Active progress indicator
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 12,
              strokeCap: StrokeCap.round,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
          // Center content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                mode.displayName.toUpperCase(),
                style: theme.textTheme.labelMedium?.copyWith(
                  letterSpacing: 2.0,
                  color: progressColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                timerString,
                style: theme.textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: -1,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              if (linkedTask != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.task_alt,
                        size: 14,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          linkedTask!.title,
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
