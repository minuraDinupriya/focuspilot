import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:focuspilot/features/tasks/domain/models/task.dart';
import 'package:focuspilot/features/tasks/presentation/widgets/task_item_tile.dart';

void main() {
  group('TaskItemTile Widget Tests', () {
    testWidgets('renders estimated time when only estimatedMinutes is set', (
      tester,
    ) async {
      final task = Task.create(title: 'Estimate Only', estimatedMinutes: 45);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskItemTile(task: task, onToggle: (_) {}, onDelete: () {}),
          ),
        ),
      );

      expect(find.text('⏱️ 45m'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets(
      'renders actual vs estimated time and progress bar when both present',
      (tester) async {
        final task = Task(
          id: 't-prog',
          title: 'Study Physics',
          createdAt: DateTime.now(),
          estimatedMinutes: 60,
          actualMinutes: 30,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TaskItemTile(task: task, onToggle: (_) {}, onDelete: () {}),
            ),
          ),
        );

        expect(find.text('⏱️ 30m / 60m'), findsOneWidget);
        final indicator = tester.widget<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator),
        );
        expect(indicator.value, 0.5);
      },
    );

    testWidgets(
      'renders warning indicator when actual minutes exceed estimate',
      (tester) async {
        final task = Task(
          id: 't-over',
          title: 'Debugging',
          createdAt: DateTime.now(),
          estimatedMinutes: 60,
          actualMinutes: 80,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TaskItemTile(task: task, onToggle: (_) {}, onDelete: () {}),
            ),
          ),
        );

        expect(find.text('⏱️ 80m / 60m'), findsOneWidget);
        final indicator = tester.widget<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator),
        );
        expect(indicator.value, 1.0); // clamped to 1.0
      },
    );

    testWidgets('renders logged time when only actualMinutes is set', (
      tester,
    ) async {
      final task = Task(
        id: 't-logged',
        title: 'Ad-hoc Reading',
        createdAt: DateTime.now(),
        actualMinutes: 25,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskItemTile(task: task, onToggle: (_) {}, onDelete: () {}),
          ),
        ),
      );

      expect(find.text('⏱️ 25m logged'), findsOneWidget);
      // No estimated minutes means no progress bar
      expect(find.byType(LinearProgressIndicator), findsNothing);
    });

    testWidgets('triggers onToggle and onDelete callbacks', (tester) async {
      var toggled = false;
      var deleted = false;
      final task = Task.create(title: 'Interactive Task');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskItemTile(
              task: task,
              onToggle: (_) => toggled = true,
              onDelete: () => deleted = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(Checkbox));
      expect(toggled, isTrue);

      await tester.tap(find.byIcon(Icons.delete_outline));
      expect(deleted, isTrue);
    });
  });
}
