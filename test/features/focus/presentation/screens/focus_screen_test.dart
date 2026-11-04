import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:focuspilot/features/focus/domain/models/focus_mode.dart';
import 'package:focuspilot/features/focus/domain/models/ticker.dart';
import 'package:focuspilot/features/focus/presentation/controllers/focus_bloc.dart';
import 'package:focuspilot/features/focus/presentation/controllers/focus_state.dart';
import 'package:focuspilot/features/focus/presentation/focus_screen.dart';
import 'package:focuspilot/features/focus/presentation/widgets/circular_timer_display.dart';
import 'package:focuspilot/features/focus/presentation/widgets/focus_mode_selector.dart';
import 'package:focuspilot/features/focus/presentation/widgets/timer_controls.dart';
import 'package:focuspilot/features/tasks/presentation/controllers/tasks_cubit.dart';

import '../../../tasks/fakes/fake_task_repository.dart';
import '../../fakes/fake_focus_session_repository.dart';

class TestTicker extends Ticker {
  const TestTicker();

  @override
  Stream<int> tick({required int ticks}) => const Stream.empty();
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

  group('FocusScreen', () {
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
  });
}
