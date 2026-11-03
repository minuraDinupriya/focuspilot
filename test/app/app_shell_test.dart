import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:focuspilot/app/app.dart';

import '../features/focus/fakes/fake_focus_session_repository.dart';
import '../features/tasks/presentation/controllers/tasks_cubit_test.dart';

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
      expect(find.byType(NavigationDestination), findsNWidgets(3));
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
