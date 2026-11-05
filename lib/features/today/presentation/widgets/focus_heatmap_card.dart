import 'package:flutter/material.dart';
import 'package:focuspilot/features/today/domain/models/heatmap_day.dart';

class FocusHeatmapCard extends StatefulWidget {
  const FocusHeatmapCard({
    super.key,
    required this.heatmapDays,
    required this.totalMinutes,
  });

  final List<HeatmapDay> heatmapDays;
  final int totalMinutes;

  @override
  State<FocusHeatmapCard> createState() => _FocusHeatmapCardState();
}

class _FocusHeatmapCardState extends State<FocusHeatmapCard> {
  HeatmapDay? _selectedDay;

  static const _monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static const _weekdayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  Color _colorForLevel(int level, ColorScheme colorScheme) {
    switch (level) {
      case 1:
        return colorScheme.primary.withValues(alpha: 0.35);
      case 2:
        return colorScheme.primary.withValues(alpha: 0.6);
      case 3:
        return colorScheme.primary.withValues(alpha: 0.82);
      case 4:
        return colorScheme.primary;
      case 0:
      default:
        return colorScheme.surfaceContainerHighest.withValues(alpha: 0.5);
    }
  }

  String _formatDate(DateTime d) {
    return '${_monthNames[d.month - 1]} ${d.day}, ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final totalHours = (widget.totalMinutes / 60.0).toStringAsFixed(1);

    // Group 91 days into 13 columns of 7 days
    final columns = <List<HeatmapDay>>[];
    for (int c = 0; c < 13; c++) {
      final startIndex = c * 7;
      if (startIndex + 7 <= widget.heatmapDays.length) {
        columns.add(widget.heatmapDays.sublist(startIndex, startIndex + 7));
      }
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.grid_view_rounded,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Focus Activity (90 Days)',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${totalHours}h logged',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Heatmap Grid
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row Labels (M, W, F)
                  Padding(
                    padding: const EdgeInsets.only(right: 6, top: 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(7, (rowIndex) {
                        final showLabel =
                            rowIndex == 0 || rowIndex == 2 || rowIndex == 4;
                        return Container(
                          height: 14,
                          margin: const EdgeInsets.symmetric(vertical: 2),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            showLabel ? _weekdayLabels[rowIndex] : '',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontSize: 10,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  // 13 Week Columns
                  Row(
                    children: columns.map((week) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Column(
                          children: week.map((day) {
                            final isSelected = _selectedDay?.date == day.date;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedDay = isSelected ? null : day;
                                });
                              },
                              child: Container(
                                width: 14,
                                height: 14,
                                margin: const EdgeInsets.symmetric(vertical: 2),
                                decoration: BoxDecoration(
                                  color: _colorForLevel(day.level, colorScheme),
                                  borderRadius: BorderRadius.circular(3),
                                  border: isSelected
                                      ? Border.all(
                                          color: colorScheme.onSurface,
                                          width: 1.5,
                                        )
                                      : null,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Selected Day Callout
            if (_selectedDay != null)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.event_note,
                      size: 14,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${_formatDate(_selectedDay!.date)}: ${_selectedDay!.focusMinutes}m focused',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Less',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 10,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 4),
                ...List.generate(5, (level) {
                  return Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.symmetric(horizontal: 1.5),
                    decoration: BoxDecoration(
                      color: _colorForLevel(level, colorScheme),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                }),
                const SizedBox(width: 4),
                Text(
                  'More',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 10,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
