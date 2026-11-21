import 'package:flutter/material.dart';

/// Keeps horizontal choices compact and stacks them when space is limited.
class AdaptiveSegmentedButton<T> extends StatelessWidget {
  const AdaptiveSegmentedButton({
    super.key,
    required this.segments,
    required this.selected,
    required this.onSelectionChanged,
    this.horizontalMinWidth = 400,
    this.alignment = AlignmentDirectional.centerStart,
    this.buttonKey,
  });

  final List<ButtonSegment<T>> segments;
  final Set<T> selected;
  final ValueChanged<Set<T>>? onSelectionChanged;
  final double horizontalMinWidth;
  final AlignmentGeometry alignment;
  final Key? buttonKey;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textScale = MediaQuery.textScalerOf(context).scale(14) / 14;
        final isVertical =
            constraints.maxWidth < horizontalMinWidth * textScale;
        final button = SegmentedButton<T>(
          key: buttonKey,
          direction: isVertical ? Axis.vertical : Axis.horizontal,
          style: isVertical
              ? SegmentedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                )
              : null,
          segments: segments,
          selected: selected,
          onSelectionChanged: onSelectionChanged,
        );
        return Align(
          alignment: alignment,
          heightFactor: 1,
          child: isVertical
              ? SizedBox(width: constraints.maxWidth, child: button)
              : ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 480 * textScale),
                  child: button,
                ),
        );
      },
    );
  }
}
