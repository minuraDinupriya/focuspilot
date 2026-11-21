import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:focuspilot/features/focus/presentation/controllers/focus_state.dart';
import 'package:focuspilot/features/focus/presentation/widgets/mini_timer_view.dart';
import 'package:focuspilot/features/focus/presentation/widgets/timer_controls.dart';
import 'package:focuspilot/features/tasks/domain/models/task.dart';

void main() {
  testWidgets('mini timer keeps flow time controls reachable at large text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(250, 220);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    final task = Task.create(
      title: 'Read the database transaction notes and finish the exercises',
    );
    final state = FocusState(
      status: FocusStatus.running,
      linkedTask: task,
      overtimeSeconds: 83,
    );
    bool? includeOvertime;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MiniTimerView(
            state: state,
            onRestore: () {},
            controls: TimerControls(
              state: state,
              onStart: () {},
              onPause: () {},
              onResume: () {},
              onReset: () {},
              onSkip: () {},
              onFinishOvertime: (include) => includeOvertime = include,
            ),
          ),
        ),
      ),
    );

    expect(find.byTooltip('Restore main window').hitTestable(), findsOneWidget);
    expect(find.text('+01:23'), findsOneWidget);
    expect(find.byTooltip(task.title), findsOneWidget);
    final finish = find.text('Finish focus');
    await tester.ensureVisible(finish);
    await tester.tap(finish);
    expect(includeOvertime, isTrue);
    expect(tester.takeException(), isNull);
  });
}
