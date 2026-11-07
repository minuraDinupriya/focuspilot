import 'package:flutter/material.dart';
import 'package:focuspilot/features/focus/domain/models/focus_mode.dart';
import 'package:focuspilot/features/focus/presentation/controllers/focus_state.dart';

class TimerControls extends StatelessWidget {
  const TimerControls({
    super.key,
    required this.state,
    required this.onStart,
    required this.onPause,
    required this.onResume,
    required this.onReset,
    required this.onSkip,
    required this.onFinishOvertime,
  });

  final FocusState state;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onReset;
  final VoidCallback onSkip;
  final ValueChanged<bool> onFinishOvertime;

  @override
  Widget build(BuildContext context) {
    if (state.isSaving) {
      return _buildPrimaryButton();
    }

    if (state.isOvertime) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: () => onFinishOvertime(true),
                icon: const Icon(Icons.check),
                label: const Text('Finish focus'),
              ),
              OutlinedButton.icon(
                onPressed: state.isPaused ? onResume : onPause,
                icon: Icon(state.isPaused ? Icons.play_arrow : Icons.pause),
                label: Text(state.isPaused ? 'Resume' : 'Pause'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          TextButton(
            onPressed: () => onFinishOvertime(false),
            child: const Text('Log planned time only'),
          ),
        ],
      );
    }

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 16,
      runSpacing: 12,
      children: [
        // Reset button
        IconButton.filledTonal(
          onPressed: state.isInitial ? null : onReset,
          icon: const Icon(Icons.refresh),
          tooltip: 'Reset timer',
        ),
        // Primary action button
        _buildPrimaryButton(),
        // Skip cycle button
        IconButton.filledTonal(
          onPressed: onSkip,
          icon: const Icon(Icons.skip_next),
          tooltip: 'Skip cycle',
        ),
      ],
    );
  }

  Widget _buildPrimaryButton() {
    switch (state.status) {
      case FocusStatus.initial:
        return FilledButton.icon(
          onPressed: onStart,
          icon: const Icon(Icons.play_arrow, size: 28),
          label: Text(
            state.mode == FocusMode.work ? 'Start Focus' : 'Start Break',
            style: const TextStyle(fontSize: 16),
          ),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          ),
        );
      case FocusStatus.running:
        return FilledButton.icon(
          onPressed: onPause,
          icon: const Icon(Icons.pause, size: 28),
          label: const Text('Pause', style: TextStyle(fontSize: 16)),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          ),
        );
      case FocusStatus.paused:
        return FilledButton.icon(
          onPressed: onResume,
          icon: const Icon(Icons.play_arrow, size: 28),
          label: const Text('Resume', style: TextStyle(fontSize: 16)),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          ),
        );
      case FocusStatus.completed:
        return FilledButton.icon(
          onPressed: onStart,
          icon: const Icon(Icons.replay, size: 28),
          label: const Text('Start New', style: TextStyle(fontSize: 16)),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          ),
        );
      case FocusStatus.saving:
        return Semantics(
          liveRegion: true,
          child: FilledButton.icon(
            onPressed: null,
            icon: const Icon(Icons.hourglass_top),
            label: const Text('Saving focus…'),
          ),
        );
    }
  }
}
