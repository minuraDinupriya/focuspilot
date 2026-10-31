import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:focuspilot/app/app_shell.dart';

void main() {
  group('AppShell navigation', () {
    Future<void> pumpAppShell(WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: AppShell()));
    }

    testWidgets('displays Today screen initially', (tester) async {
      await pumpAppShell(tester);

      expect(find.text('Welcome to your Today screen'), findsOneWidget);

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationDestination), findsNWidgets(3));
    });

    testWidgets('navigates to Tasks screen', (tester) async {
      await pumpAppShell(tester);

      await tester.tap(find.text('Tasks'));
      await tester.pumpAndSettle();

      expect(find.text('Manage your tasks here'), findsOneWidget);
      expect(find.text('Welcome to your Today screen'), findsNothing);
    });

    testWidgets('navigates to Focus screen', (tester) async {
      await pumpAppShell(tester);

      await tester.tap(find.text('Focus'));
      await tester.pumpAndSettle();

      expect(find.text('Start your focus session'), findsOneWidget);
      expect(find.text('Welcome to your Today screen'), findsNothing);
    });

    testWidgets('can return to Today screen', (tester) async {
      await pumpAppShell(tester);

      await tester.tap(find.text('Tasks'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Today'));
      await tester.pumpAndSettle();

      expect(find.text('Welcome to your Today screen'), findsOneWidget);
    });

    testWidgets('updates the selected navigation destination', (tester) async {
      await pumpAppShell(tester);

      NavigationBar navigationBar = tester.widget<NavigationBar>(
        find.byType(NavigationBar),
      );

      expect(navigationBar.selectedIndex, 0);

      await tester.tap(find.text('Focus'));
      await tester.pumpAndSettle();

      navigationBar = tester.widget<NavigationBar>(find.byType(NavigationBar));

      expect(navigationBar.selectedIndex, 2);
    });
  });
}
