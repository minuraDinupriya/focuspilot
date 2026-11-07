import 'package:flutter/material.dart';

/// Stacks segments when their labels need more room, including at large text sizes.
class AdaptiveSegmentedButton<T> extends StatelessWidget {
  const AdaptiveSegmentedButton({
    super.key,
    required this.segments,
    required this.selected,
    required this.onSelectionChanged,
    this.horizontalMinWidth = 400,
    this.buttonKey,
  });

  final List<ButtonSegment<T>> segments;
  final Set<T> selected;
  final ValueChanged<Set<T>>? onSelectionChanged;
  final double horizontalMinWidth;
  final Key? buttonKey;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textScale = MediaQuery.textScalerOf(context).scale(14) / 14;
        final isVertical =
            constraints.maxWidth < horizontalMinWidth * textScale;
        return SizedBox(
          width: constraints.hasBoundedWidth ? constraints.maxWidth : null,
          child: SegmentedButton<T>(
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
          ),
        );
      },
    );
  }
}
