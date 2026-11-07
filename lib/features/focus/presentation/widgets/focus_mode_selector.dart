import 'package:flutter/material.dart';
import 'package:focuspilot/app/widgets/adaptive_segmented_button.dart';
import 'package:focuspilot/features/focus/domain/models/focus_mode.dart';

class FocusModeSelector extends StatelessWidget {
  const FocusModeSelector({
    super.key,
    required this.selectedMode,
    required this.onModeSelected,
    this.enabled = true,
  });

  final FocusMode selectedMode;
  final ValueChanged<FocusMode> onModeSelected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return AdaptiveSegmentedButton<FocusMode>(
      segments: const [
        ButtonSegment<FocusMode>(
          value: FocusMode.work,
          label: Text('Focus (25m)'),
          icon: Icon(Icons.timer_outlined),
        ),
        ButtonSegment<FocusMode>(
          value: FocusMode.shortBreak,
          label: Text('Short (5m)'),
          icon: Icon(Icons.coffee_outlined),
        ),
        ButtonSegment<FocusMode>(
          value: FocusMode.longBreak,
          label: Text('Long (15m)'),
          icon: Icon(Icons.weekend_outlined),
        ),
      ],
      selected: {selectedMode},
      onSelectionChanged: enabled
          ? (selection) => onModeSelected(selection.first)
          : null,
    );
  }
}
