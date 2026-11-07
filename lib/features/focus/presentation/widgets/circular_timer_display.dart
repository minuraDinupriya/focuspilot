import 'dart:math' as math;

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
    this.isOvertime = false,
  });

  final String timerString;
  final double progress;
  final FocusMode mode;
  final Task? linkedTask;
  final bool isOvertime;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textScale = MediaQuery.textScalerOf(context).scale(14) / 14;

    Color progressColor;
    switch (mode) {
      case FocusMode.work:
        progressColor = isOvertime
            ? theme.colorScheme.secondary
            : theme.colorScheme.primary;
        break;
      case FocusMode.shortBreak:
        progressColor = theme.colorScheme.tertiary;
        break;
      case FocusMode.longBreak:
        progressColor = theme.colorScheme.secondary;
        break;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.min(260 * textScale, constraints.maxWidth);
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
              Padding(
                padding: const EdgeInsets.all(28),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: SizedBox(
                    width: size - 56,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isOvertime
                              ? 'FLOW TIME'
                              : mode.displayName.toUpperCase(),
                          style: theme.textTheme.labelMedium?.copyWith(
                            letterSpacing: 2.0,
                            color: progressColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            timerString,
                            maxLines: 1,
                            style: theme.textTheme.displayLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              letterSpacing: -1,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
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
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
