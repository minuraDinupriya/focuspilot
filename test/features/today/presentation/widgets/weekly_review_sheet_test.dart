import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:focuspilot/features/tasks/domain/models/task.dart';
import 'package:focuspilot/features/tasks/domain/models/task_priority.dart';
import 'package:focuspilot/features/today/domain/models/weekly_review_data.dart';
import 'package:focuspilot/features/today/presentation/widgets/weekly_review_sheet.dart';

void main() {
  group('WeeklyReviewSheet Widget Tests', () {
    final testData = WeeklyReviewData(
      startDate: DateTime(2026, 10, 26),
      endDate: DateTime(2026, 11, 1),
      focusMinutesThisWeek: 330, // 5h 30m
      focusMinutesPreviousWeek: 210, // 3h 30m
      completedSessionsCount: 7,
      completedTasksCount: 5,
      daysGoalMetCount: 5,
      dailyGoalMinutes: 60,
      bestDayLabel: 'Wednesday',
      bestDayMinutes: 90,
      topCategory: 'Engineering',
      topCategoryMinutes: 180,
      topTasks: [
        Task(
          id: 't1',
          title: 'Implement Weekly Review Modal',
          category: 'Engineering',
          priority: TaskPriority.high,
          actualMinutes: 90,
          createdAt: DateTime(2026, 10, 26),
        ),
      ],
    );

    testWidgets('renders all review sections when data is provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return Center(
                  child: ElevatedButton(
                    onPressed: () => WeeklyReviewSheet.show(context, testData),
                    child: const Text('Open Sheet'),
                  ),
                );
              },
            ),
          ),
        ),
      );

      // Open bottom sheet
      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      // Header verification
      expect(find.text('Weekly Review'), findsOneWidget);
      expect(find.text('Oct 26 – Nov 1'), findsOneWidget);

      // Focus Time comparison card
      expect(find.text('5h 30m'), findsOneWidget);
      expect(find.text('3h 30m'), findsOneWidget);
      expect(find.text('+57% vs last week'), findsOneWidget);

      // Stats grid
      expect(find.text('Daily Goals Met'), findsOneWidget);
      expect(find.text('5 / 7 days'), findsOneWidget);
      expect(find.text('Completed Tasks'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('Best Day'), findsOneWidget);
      expect(find.text('Wednesday'), findsOneWidget);
      expect(find.text('Top Category'), findsOneWidget);
      expect(find.text('Engineering'), findsWidgets);

      // Top tasks section
      await tester.scrollUntilVisible(
        find.text('Implement Weekly Review Modal'),
        100,
      );
      expect(find.text('Top Focused Tasks'), findsOneWidget);
      expect(find.text('Implement Weekly Review Modal'), findsOneWidget);

      // Takeaway and close button
      expect(
        find.byKey(const Key('weekly_review_close_button')),
        findsOneWidget,
      );

      // Dismiss sheet via close button
      await tester.tap(find.byKey(const Key('weekly_review_close_button')));
      await tester.pumpAndSettle();

      expect(find.text('Weekly Review'), findsNothing);
    });

    testWidgets('renders fallback message when data is null', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return Center(
                  child: ElevatedButton(
                    onPressed: () => WeeklyReviewSheet.show(context, null),
                    child: const Text('Open Empty Sheet'),
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Empty Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('No weekly activity recorded yet.'), findsOneWidget);
    });
  });
}
