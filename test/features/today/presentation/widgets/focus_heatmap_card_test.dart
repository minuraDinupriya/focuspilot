import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:focuspilot/features/today/domain/models/heatmap_day.dart';
import 'package:focuspilot/features/today/presentation/widgets/focus_heatmap_card.dart';

void main() {
  group('FocusHeatmapCard Widget Tests', () {
    testWidgets('renders title, hours badge, legend, and cells', (
      tester,
    ) async {
      final now = DateTime(2026, 11, 5);
      final days = List.generate(91, (i) {
        return HeatmapDay(
          date: now.subtract(Duration(days: 90 - i)),
          focusMinutes: i == 90 ? 75 : 0,
          level: i == 90 ? 3 : 0,
        );
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FocusHeatmapCard(heatmapDays: days, totalMinutes: 75),
          ),
        ),
      );

      expect(find.text('Focus Activity (90 Days)'), findsOneWidget);
      expect(find.text('1.3h logged'), findsOneWidget);
      expect(find.text('Less'), findsOneWidget);
      expect(find.text('More'), findsOneWidget);
    });

    testWidgets('tapping a cell displays selected day callout', (tester) async {
      final now = DateTime(2026, 11, 5);
      final days = List.generate(91, (i) {
        return HeatmapDay(
          date: now.subtract(Duration(days: 90 - i)),
          focusMinutes: i == 90 ? 90 : 0,
          level: i == 90 ? 3 : 0,
        );
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FocusHeatmapCard(heatmapDays: days, totalMinutes: 90),
          ),
        ),
      );

      // Initially no callout is visible
      expect(find.byIcon(Icons.event_note), findsNothing);

      // Tap on one of the cells
      final cellFinders = find.byType(GestureDetector);
      expect(cellFinders, findsWidgets);
      await tester.tap(cellFinders.last);
      await tester.pumpAndSettle();

      // Selected callout is now displayed
      expect(find.byIcon(Icons.event_note), findsOneWidget);
      expect(find.textContaining('90m focused'), findsOneWidget);
    });
  });
}
