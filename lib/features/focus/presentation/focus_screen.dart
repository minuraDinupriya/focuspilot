import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focuspilot/features/focus/domain/models/focus_mode.dart';
import 'package:focuspilot/features/focus/presentation/controllers/focus_bloc.dart';
import 'package:focuspilot/features/focus/presentation/controllers/focus_event.dart';
import 'package:focuspilot/features/focus/presentation/controllers/focus_state.dart';
import 'package:focuspilot/features/focus/presentation/widgets/circular_timer_display.dart';
import 'package:focuspilot/features/focus/presentation/widgets/focus_mode_selector.dart';
import 'package:focuspilot/features/focus/presentation/widgets/focus_task_selector.dart';
import 'package:focuspilot/features/focus/presentation/widgets/timer_controls.dart';

class FocusScreen extends StatefulWidget {
  const FocusScreen({super.key});

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<FocusBloc>().add(const FocusAppForegrounded());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: BlocConsumer<FocusBloc, FocusState>(
        listener: (context, state) {
          if (state.status == FocusStatus.completed) {
            final message = state.mode == FocusMode.work
                ? '🎉 Focus session completed! Great work!'
                : '☕ Break completed! Ready to focus?';

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
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
                      Text(
                        '${state.sessionsCompletedToday} sessions completed today',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSecondaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Mode Selector
                FocusModeSelector(
                  selectedMode: state.mode,
                  enabled: !state.isRunning,
                  onModeSelected: (mode) {
                    context.read<FocusBloc>().add(FocusModeChanged(mode: mode));
                  },
                ),
                const SizedBox(height: 36),

                // Circular Timer Display
                CircularTimerDisplay(
                  timerString: state.timerString,
                  progress: state.progress,
                  mode: state.mode,
                  linkedTask: state.linkedTask,
                ),
                const SizedBox(height: 24),

                // Link task chip
                FocusTaskSelector(
                  linkedTask: state.linkedTask,
                  onTaskSelected: (task) {
                    context.read<FocusBloc>().add(FocusTaskLinked(task: task));
                  },
                ),
                const SizedBox(height: 36),

                // Controls
                TimerControls(
                  status: state.status,
                  onStart: () {
                    context.read<FocusBloc>().add(
                      FocusStarted(durationSeconds: state.durationSeconds),
                    );
                  },
                  onPause: () {
                    context.read<FocusBloc>().add(const FocusPaused());
                  },
                  onResume: () {
                    context.read<FocusBloc>().add(const FocusResumed());
                  },
                  onReset: () {
                    context.read<FocusBloc>().add(const FocusReset());
                  },
                  onSkip: () {
                    final nextMode = state.mode == FocusMode.work
                        ? FocusMode.shortBreak
                        : FocusMode.work;
                    context.read<FocusBloc>().add(
                      FocusModeChanged(mode: nextMode),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
