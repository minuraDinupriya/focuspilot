import 'package:flutter/material.dart';
import 'package:focuspilot/features/focus/presentation/controllers/focus_state.dart';

class KeepOnTopButton extends StatelessWidget {
  const KeepOnTopButton({super.key, required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.push_pin_outlined),
      label: const Text('Keep on top'),
    );
  }
}

class MiniTimerView extends StatelessWidget {
  const MiniTimerView({
    super.key,
    required this.state,
    required this.controls,
    required this.onRestore,
  });

  final FocusState state;
  final Widget controls;
  final VoidCallback? onRestore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final task = state.linkedTask;
    final mode = state.isOvertime ? 'Flow Time' : state.mode.displayName;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        state.isPaused ? '$mode · Paused' : mode,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: onRestore,
                      icon: const Icon(Icons.open_in_full),
                      tooltip: 'Restore main window',
                    ),
                  ],
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Semantics(
                    label: state.isOvertime
                        ? 'Elapsed flow time'
                        : 'Time remaining',
                    child: Text(
                      state.timerString,
                      maxLines: 1,
                      style: theme.textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: state.progress,
                  semanticsLabel: 'Session progress',
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                ),
                if (task != null) ...[
                  const SizedBox(height: 12),
                  Tooltip(
                    message: task.title,
                    excludeFromSemantics: true,
                    child: Text(
                      task.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
                if (state.hasSaveError) ...[
                  const SizedBox(height: 12),
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      'Couldn’t save your focus time. Try saving again.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colors.error),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                controls,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
