import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focuspilot/features/focus/domain/models/focus_mode.dart';
import 'package:focuspilot/features/focus/presentation/controllers/focus_bloc.dart';
import 'package:focuspilot/features/focus/presentation/controllers/focus_event.dart';
import 'package:focuspilot/features/focus/presentation/controllers/focus_state.dart';
import 'package:focuspilot/features/focus/presentation/widgets/circular_timer_display.dart';
import 'package:focuspilot/features/focus/presentation/widgets/focus_mode_selector.dart';
import 'package:focuspilot/features/focus/presentation/widgets/focus_task_selector.dart';
import 'package:focuspilot/features/focus/presentation/widgets/timer_controls.dart';

class FocusScreen extends StatelessWidget {
  const FocusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: BlocConsumer<FocusBloc, FocusState>(
        listenWhen: (previous, current) =>
            (!previous.isCompleted && current.isCompleted) ||
            (previous.isOvertime &&
                !current.isOvertime &&
                current.mode == FocusMode.shortBreak),
        listener: (context, state) {
          final message = state.isCompleted
              ? state.mode == FocusMode.work
                    ? '🎉 Focus session completed! Great work!'
                    : '☕ Break completed! Ready to focus?'
              : 'Focus time saved.';

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );
        },
        builder: (context, state) {
          final bloc = context.read<FocusBloc>();
          final sessionActive = state.isSessionActive;
          final content = Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (!sessionActive) ...[
                // Today's completed sessions pill
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.local_fire_department,
                        size: 18,
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          '${state.sessionsCompletedToday} sessions completed today',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSecondaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Mode Selector
                FocusModeSelector(
                  selectedMode: state.mode,
                  onModeSelected: (mode) {
                    bloc.add(FocusModeChanged(mode: mode));
                  },
                ),
                const SizedBox(height: 36),
              ],

              // Circular Timer Display
              CircularTimerDisplay(
                timerString: state.timerString,
                progress: state.progress,
                mode: state.mode,
                linkedTask: sessionActive ? null : state.linkedTask,
                isOvertime: state.isOvertime,
                diameter: sessionActive ? 320 : 260,
              ),
              if (sessionActive && state.linkedTask != null) ...[
                const SizedBox(height: 20),
                Text(
                  state.linkedTask!.title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium,
                ),
              ],
              if (state.isOvertime && !state.isSaving) ...[
                const SizedBox(height: 16),
                _FlowTimeMessage(state: state),
              ],
              const SizedBox(height: 24),

              if (!sessionActive) ...[
                FocusTaskSelector(
                  linkedTask: state.linkedTask,
                  onTaskSelected: (task) {
                    bloc.add(FocusTaskLinked(task: task));
                  },
                ),
                const SizedBox(height: 36),
              ],

              // Controls
              TimerControls(
                state: state,
                onStart: () {
                  bloc.add(
                    FocusStarted(durationSeconds: state.totalDurationSeconds),
                  );
                },
                onPause: () {
                  bloc.add(const FocusPaused());
                },
                onResume: () {
                  bloc.add(const FocusResumed());
                },
                onReset: () {
                  bloc.add(const FocusReset());
                },
                onSkip: () {
                  bloc.add(const FocusSkipped());
                },
                onFinishOvertime: (includeOvertime) {
                  bloc.add(
                    FocusOvertimeFinished(includeOvertime: includeOvertime),
                  );
                },
              ),
              if (state.isRunning || state.isPaused) ...[
                const SizedBox(height: 20),
                ActionChip(
                  avatar: Icon(
                    Icons.bolt,
                    size: 18,
                    color: state.distractionCount > 0
                        ? theme.colorScheme.error
                        : theme.colorScheme.primary,
                  ),
                  label: Text(
                    'Distractions: ${state.distractionCount} (+1)',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  tooltip: 'Tap to log an interruption during this session',
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    bloc.add(const FocusDistractionRecorded());
                  },
                ),
              ],
            ],
          );
          if (!sessionActive) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: SizedBox(width: double.infinity, child: content),
            );
          }

          final colors = theme.colorScheme;
          return DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                radius: 0.85,
                colors: [
                  Color.alphaBlend(
                    colors.primary.withValues(alpha: 0.08),
                    colors.surface,
                  ),
                  colors.surface,
                ],
              ),
            ),
            child: SafeArea(
              minimum: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 480),
                        child: content,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FlowTimeMessage extends StatelessWidget {
  const _FlowTimeMessage({required this.state});

  final FocusState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String message;
    if (state.hasSaveError) {
      message = 'Couldn’t save your focus time. Try saving again.';
    } else if (state.isPaused) {
      message = 'Flow time is paused. Resume when you’re ready.';
    } else {
      message = 'Target reached. Extra time counts toward your focus when you finish.';
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Semantics(
        liveRegion: true,
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: state.hasSaveError
                ? theme.colorScheme.error
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
