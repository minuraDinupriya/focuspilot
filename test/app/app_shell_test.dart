import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:focuspilot/app/app.dart';
import 'package:focuspilot/features/tasks/domain/models/task.dart';

import '../features/focus/fakes/fake_focus_session_repository.dart';
import '../features/tasks/fakes/fake_task_repository.dart';

void main() {
  group('AppShell navigation', () {
    late FakeTaskRepository taskRepository;
    late FakeFocusSessionRepository focusRepository;

    setUp(() {
      taskRepository = FakeTaskRepository();
      focusRepository = FakeFocusSessionRepository();
    });

    tearDown(() {
      taskRepository.dispose();
      focusRepository.dispose();
    });

    Future<void> pumpAppShell(WidgetTester tester) async {
      await tester.pumpWidget(
        FocusPilotApp(
          taskRepository: taskRepository,
          focusSessionRepository: focusRepository,
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('displays Today screen initially', (tester) async {
      await pumpAppShell(tester);

      expect(find.text('Good day!'), findsOneWidget);

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationDestination), findsNWidgets(4));
    });

    testWidgets('Planner shows the selected day in start-time order', (
      tester,
    ) async {
      final today = DateTime.now();
      DateTime start(int hour, {int dayOffset = 0}) =>
          DateTime(today.year, today.month, today.day + dayOffset, hour);
      taskRepository.emitTasks([
        Task.create(title: 'Afternoon reading', scheduledStart: start(15)),
        Task.create(title: 'Morning review', scheduledStart: start(9)),
        Task.create(
          title: 'Tomorrow’s work',
          scheduledStart: start(10, dayOffset: 1),
        ),
        Task.create(title: 'Unscheduled task'),
      ]);
      await pumpAppShell(tester);
      await tester.tap(find.text('Planner'));
      await tester.pumpAndSettle();

      expect(find.text('Day Planner'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Morning review')).dy,
        lessThan(tester.getTopLeft(find.text('Afternoon reading')).dy),
      );
      expect(find.text('Unscheduled task'), findsNothing);
      await tester.tap(find.byTooltip('Next day'));
      await tester.pumpAndSettle();
      expect(find.text('Tomorrow’s work'), findsOneWidget);
      expect(find.text('Morning review'), findsNothing);

      await tester.tap(find.text('Plan task'));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Clear planned start'), findsOneWidget);
    });

    testWidgets('navigates to Tasks screen', (tester) async {
      await pumpAppShell(tester);

      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.byIcon(Icons.task_alt_outlined),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No tasks yet'), findsOneWidget);
      expect(find.text('Good day!'), findsNothing);
    });

    testWidgets('navigates to Focus screen', (tester) async {
      await pumpAppShell(tester);

      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.byIcon(Icons.timer_outlined),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Start Focus'), findsOneWidget);
      expect(find.text('25:00'), findsOneWidget);
      expect(find.text('Good day!'), findsNothing);
    });

    testWidgets('can return to Today screen', (tester) async {
      await pumpAppShell(tester);

      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.byIcon(Icons.task_alt_outlined),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.byIcon(Icons.today_outlined),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Good day!'), findsOneWidget);
    });

    testWidgets('updates the selected navigation destination', (tester) async {
      await pumpAppShell(tester);

      NavigationBar navigationBar = tester.widget<NavigationBar>(
        find.byType(NavigationBar),
      );

      expect(navigationBar.selectedIndex, 0);

      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.byIcon(Icons.timer_outlined),
        ),
      );
      await tester.pumpAndSettle();

      navigationBar = tester.widget<NavigationBar>(find.byType(NavigationBar));

      expect(navigationBar.selectedIndex, 2);
    });
  });
}
