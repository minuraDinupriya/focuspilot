import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:focuspilot/features/tasks/domain/models/task_priority.dart';
import 'package:focuspilot/features/today/domain/models/productivity_insight.dart';
import 'package:focuspilot/features/today/presentation/widgets/productivity_insights_card.dart';

void main() {
  group('ProductivityInsightsCard Widget Tests', () {
    final categories = [
      const CategoryFocusInsight(
        category: 'Study',
        minutes: 90,
        percentage: 0.6,
      ),
      const CategoryFocusInsight(
        category: 'Work',
        minutes: 60,
        percentage: 0.4,
      ),
    ];

    final priorities = [
      const PriorityFocusInsight(
        priority: TaskPriority.high,
        minutes: 90,
        percentage: 0.6,
      ),
      const PriorityFocusInsight(
        priority: TaskPriority.medium,
        minutes: 60,
        percentage: 0.4,
      ),
      const PriorityFocusInsight(
        priority: TaskPriority.low,
        minutes: 0,
        percentage: 0.0,
      ),
    ];

    final topTasks = [
      const TopTaskFocusInsight(
        taskId: 't1',
        title: 'Complete Thesis Chapter',
        actualMinutes: 90,
        estimatedMinutes: 120,
      ),
      const TopTaskFocusInsight(
        taskId: 't2',
        title: 'Team Sync & Notes',
        actualMinutes: 60,
      ),
    ];

    testWidgets(
      'renders category insights initially and switches between tabs',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: ProductivityInsightsCard(
                  categoryInsights: categories,
                  priorityInsights: priorities,
                  topTasksInsights: topTasks,
                ),
              ),
            ),
          ),
        );

        expect(find.text('Productivity Insights'), findsOneWidget);
        expect(find.text('Category'), findsOneWidget);
        expect(find.text('Priority'), findsOneWidget);
        expect(find.text('Top Tasks'), findsOneWidget);

        // Category tab content
        expect(find.text('Study'), findsOneWidget);
        expect(find.text('90m (60%)'), findsOneWidget);
        expect(find.text('Work'), findsOneWidget);
        expect(find.text('60m (40%)'), findsOneWidget);

        // Switch to Priority tab
        await tester.tap(find.text('Priority'));
        await tester.pumpAndSettle();

        expect(find.text('High Priority'), findsOneWidget);
        expect(find.text('Medium Priority'), findsOneWidget);

        // Switch to Top Tasks tab
        await tester.tap(find.text('Top Tasks'));
        await tester.pumpAndSettle();

        expect(find.text('Complete Thesis Chapter'), findsOneWidget);
        expect(find.text('⏱️ 90m'), findsOneWidget);
        expect(find.text('Team Sync & Notes'), findsOneWidget);
        expect(find.text('⏱️ 60m'), findsOneWidget);
      },
    );

    testWidgets('renders empty state messages when no data exists', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProductivityInsightsCard(
              categoryInsights: [],
              priorityInsights: [],
              topTasksInsights: [],
            ),
          ),
        ),
      );

      expect(
        find.text('No focus time logged by category yet.'),
        findsOneWidget,
      );

      // Switch to Priority
      await tester.tap(find.text('Priority'));
      await tester.pumpAndSettle();
      expect(
        find.text('No focus time logged by priority yet.'),
        findsOneWidget,
      );

      // Switch to Top Tasks
      await tester.tap(find.text('Top Tasks'));
      await tester.pumpAndSettle();
      expect(
        find.text('No focus time logged on specific tasks yet.'),
        findsOneWidget,
      );
    });
  });
}
