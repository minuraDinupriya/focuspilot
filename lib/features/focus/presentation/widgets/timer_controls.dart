import 'package:flutter/material.dart';
import 'package:focuspilot/features/focus/presentation/controllers/focus_state.dart';

class TimerControls extends StatelessWidget {
  const TimerControls({
    super.key,
    required this.status,
    required this.onStart,
    required this.onPause,
    required this.onResume,
    required this.onReset,
    required this.onSkip,
  });

  final FocusStatus status;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onReset;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Reset button
        IconButton.filledTonal(
          onPressed: status == FocusStatus.initial ? null : onReset,
          icon: const Icon(Icons.refresh),
          tooltip: 'Reset timer',
        ),
        const SizedBox(width: 24),
        // Primary action button
        _buildPrimaryButton(context),
        const SizedBox(width: 24),
        // Skip cycle button
        IconButton.filledTonal(
          onPressed: onSkip,
          icon: const Icon(Icons.skip_next),
          tooltip: 'Skip cycle',
        ),
      ],
    );
  }

  Widget _buildPrimaryButton(BuildContext context) {
    switch (status) {
      case FocusStatus.initial:
        return FilledButton.icon(
          onPressed: onStart,
          icon: const Icon(Icons.play_arrow, size: 28),
          label: const Text('Start Focus', style: TextStyle(fontSize: 16)),
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
    }
  }
}
