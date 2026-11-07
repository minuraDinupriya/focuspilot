import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:focuspilot/features/focus/domain/models/focus_mode.dart';
import 'package:focuspilot/features/focus/domain/models/focus_session.dart';
import 'package:focuspilot/features/focus/domain/models/ticker.dart';
import 'package:focuspilot/features/focus/presentation/controllers/focus_bloc.dart';
import 'package:focuspilot/features/focus/presentation/controllers/focus_event.dart';
import 'package:focuspilot/features/focus/presentation/controllers/focus_state.dart';
import 'package:focuspilot/features/focus/presentation/focus_screen.dart';
import 'package:focuspilot/features/focus/presentation/widgets/circular_timer_display.dart';
import 'package:focuspilot/features/focus/presentation/widgets/focus_mode_selector.dart';
import 'package:focuspilot/features/focus/presentation/widgets/timer_controls.dart';
import 'package:focuspilot/features/tasks/domain/models/task.dart';
import 'package:focuspilot/features/tasks/presentation/controllers/tasks_cubit.dart';

import '../../../tasks/fakes/fake_task_repository.dart';
import '../../fakes/fake_focus_session_repository.dart';

class TestTicker extends Ticker {
  const TestTicker();

  @override
  Stream<int> tick({required int ticks}) => const Stream.empty();

  @override
  Stream<void> pulse() => const Stream.empty();
}

class _RetryFocusRepository extends FakeFocusSessionRepository {
  final firstFinish = Completer<void>();

  @override
  Future<void> recordWorkSession(FocusSession session) {
    if (session.durationSeconds > 1500 && !firstFinish.isCompleted) {
      return firstFinish.future;
    }
    return super.recordWorkSession(session);
  }
}

void main() {
  late FakeFocusSessionRepository focusRepository;
  late FakeTaskRepository taskRepository;
  late TasksCubit tasksCubit;

  setUp(() {
    focusRepository = FakeFocusSessionRepository();
    taskRepository = FakeTaskRepository();
    tasksCubit = TasksCubit(taskRepository);
  });

  tearDown(() async {
    await tasksCubit.close();
    focusRepository.dispose();
    taskRepository.dispose();
  });

  Widget createWidgetUnderTest(FocusBloc bloc) {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<FocusBloc>.value(value: bloc),
          BlocProvider<TasksCubit>.value(value: tasksCubit),
        ],
        child: const FocusScreen(),
      ),
    );
  }

  Future<FocusBloc> enterFlowTime(
    WidgetTester tester,
    FakeFocusSessionRepository repository,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    var now = DateTime.now();
    final bloc = FocusBloc(
      ticker: const TestTicker(),
      sessionRepository: repository,
      now: () => now,
    );
    addTearDown(bloc.close);

    await tester.pumpWidget(createWidgetUnderTest(bloc));
    await tester.tap(find.text('Start Focus'));
    await tester.pumpAndSettle();
    now = now.add(const Duration(minutes: 26, seconds: 23));
    bloc.add(const FocusAppForegrounded());
    await tester.pumpAndSettle();
    return bloc;
  }

  group('FocusScreen', () {
    for (final (label, savedSeconds) in [
      ('Finish focus', 1583),
      ('Log planned time only', 1500),
    ]) {
      testWidgets('$label saves the selected focus time and prepares a break', (
        tester,
      ) async {
        final repository = FakeFocusSessionRepository();
        addTearDown(repository.dispose);
        final bloc = await enterFlowTime(tester, repository);

        expect(find.text('FLOW TIME'), findsOneWidget);
        expect(find.text('+01:23'), findsOneWidget);
        expect(find.text('Pause'), findsOneWidget);
        expect(find.byTooltip('Reset timer'), findsNothing);
        expect(find.byTooltip('Skip cycle'), findsNothing);
        expect(
          tester
              .widget<FocusModeSelector>(find.byType(FocusModeSelector))
              .enabled,
          isFalse,
        );
        expect(
          tester
              .widget<ActionChip>(find.widgetWithText(ActionChip, 'Tag a Task'))
              .onPressed,
          isNull,
        );

        final finish = find.text(label);
        await tester.ensureVisible(finish);
        await tester.tap(finish);
        await tester.pumpAndSettle();

        final sessions = await repository.getSessions();
        expect(sessions, hasLength(1));
        expect(sessions.single.durationSeconds, savedSeconds);
        expect(bloc.state.mode, FocusMode.shortBreak);
        expect(find.text('Start Break'), findsOneWidget);
        expect(find.text('Focus time saved.'), findsOneWidget);
      });
    }

    testWidgets(
      'a failed finish keeps flow time visible and available to retry',
      (tester) async {
        final repository = _RetryFocusRepository();
        addTearDown(repository.dispose);
        await enterFlowTime(tester, repository);
        final finish = find.text('Finish focus');

        await tester.ensureVisible(finish);
        await tester.tap(finish);
        await tester.pumpAndSettle();
        expect(find.text('Saving focus…'), findsOneWidget);
        expect(find.text('Log planned time only'), findsNothing);

        repository.firstFinish.completeError(StateError('Save failed'));
        await tester.pumpAndSettle();
        expect(find.text('+01:23'), findsOneWidget);
        expect(
          find.textContaining('Couldn’t save your focus time.'),
          findsOneWidget,
        );
        expect(find.text('Resume'), findsOneWidget);

        await tester.ensureVisible(finish);
        await tester.tap(finish);
        await tester.pumpAndSettle();
        expect((await repository.getSessions()).single.durationSeconds, 1583);
        expect(find.text('Start Break'), findsOneWidget);
      },
    );

    testWidgets('renders timer display, mode selector, and controls', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final bloc = FocusBloc(
        ticker: const TestTicker(),
        sessionRepository: focusRepository,
      );
      addTearDown(bloc.close);

      await tester.pumpWidget(createWidgetUnderTest(bloc));
      await tester.pumpAndSettle();

      expect(find.byType(CircularTimerDisplay), findsOneWidget);
      expect(find.byType(FocusModeSelector), findsOneWidget);
      expect(find.byType(TimerControls), findsOneWidget);
      expect(find.text('25:00'), findsOneWidget);
      expect(find.text('Start Focus'), findsOneWidget);
    });

    testWidgets('switching mode updates timer display', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final bloc = FocusBloc(
        ticker: const TestTicker(),
        sessionRepository: focusRepository,
        initialState: const FocusState(
          mode: FocusMode.shortBreak,
          durationSeconds: 5 * 60,
          totalDurationSeconds: 5 * 60,
        ),
      );
      addTearDown(bloc.close);

      await tester.pumpWidget(createWidgetUnderTest(bloc));
      await tester.pumpAndSettle();

      expect(find.text('05:00'), findsOneWidget);
    });

    testWidgets('tapping Start Focus begins timer and displays Pause', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final bloc = FocusBloc(
        ticker: const TestTicker(),
        sessionRepository: focusRepository,
        initialState: const FocusState(
          status: FocusStatus.running,
          durationSeconds: 25 * 60,
          totalDurationSeconds: 25 * 60,
        ),
      );
      addTearDown(bloc.close);

      await tester.pumpWidget(createWidgetUnderTest(bloc));
      await tester.pumpAndSettle();

      expect(find.text('Pause'), findsOneWidget);
    });

    testWidgets('displays distraction counter button during running session', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final bloc = FocusBloc(
        ticker: const TestTicker(),
        sessionRepository: focusRepository,
        initialState: const FocusState(
          status: FocusStatus.running,
          durationSeconds: 25 * 60,
          totalDurationSeconds: 25 * 60,
          distractionCount: 3,
        ),
      );
      addTearDown(bloc.close);

      await tester.pumpWidget(createWidgetUnderTest(bloc));
      await tester.pumpAndSettle();

      expect(find.text('Distractions: 3 (+1)'), findsOneWidget);
    });

    testWidgets('displays linked task with actual and estimated minutes', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final task = Task(
        id: 't-focus',
        title: 'Study Data Structures',
        createdAt: DateTime.now(),
        estimatedMinutes: 50,
        actualMinutes: 25,
      );

      final bloc = FocusBloc(
        ticker: const TestTicker(),
        sessionRepository: focusRepository,
        initialState: FocusState(linkedTask: task),
      );
      addTearDown(bloc.close);

      await tester.pumpWidget(createWidgetUnderTest(bloc));
      await tester.pumpAndSettle();

      expect(
        find.text('Focusing: Study Data Structures (25m/50m)'),
        findsOneWidget,
      );
    });
  });
}
