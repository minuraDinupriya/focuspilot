import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:focuspilot/features/focus/domain/models/focus_mode.dart';
import 'package:focuspilot/features/focus/domain/models/focus_session.dart';
import 'package:focuspilot/features/tasks/domain/models/task.dart';
import 'package:focuspilot/features/today/presentation/controllers/today_cubit.dart';
import 'package:focuspilot/features/today/presentation/today_screen.dart';
import 'package:focuspilot/features/today/presentation/widgets/daily_goal_ring.dart';
import 'package:focuspilot/features/today/presentation/widgets/metric_cards_row.dart';
import 'package:focuspilot/features/today/presentation/widgets/quick_start_focus_card.dart';

import '../../tasks/fakes/fake_task_repository.dart';
import '../fakes/fake_focus_session_repository.dart';

void main() {
  group('TodayScreen Widget Tests', () {
    late FakeFocusSessionRepository fakeSessionRepository;
    late FakeTaskRepository fakeTaskRepository;

    setUp(() {
      fakeSessionRepository = FakeFocusSessionRepository();
      fakeTaskRepository = FakeTaskRepository();
    });

    tearDown(() {
      fakeSessionRepository.dispose();
      fakeTaskRepository.dispose();
    });

    Widget createSubject({
      required TodayCubit cubit,
      VoidCallback? onNavigateToFocus,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: BlocProvider<TodayCubit>.value(
            value: cubit,
            child: TodayScreen(onNavigateToFocus: onNavigateToFocus),
          ),
        ),
      );
    }

    testWidgets('renders daily goal ring, metric cards, and quick start card', (
      tester,
    ) async {
      final cubit = TodayCubit(
        sessionRepository: fakeSessionRepository,
        taskRepository: fakeTaskRepository,
      );

      await tester.pumpWidget(createSubject(cubit: cubit));
      await tester.pump();

      expect(find.byType(DailyGoalRing), findsOneWidget);
      expect(find.byType(MetricCardsRow), findsOneWidget);
      expect(find.byType(QuickStartFocusCard), findsOneWidget);
      expect(find.text('Good day!'), findsOneWidget);

      cubit.close();
    });

    testWidgets('displays updated metrics when repository emits data', (
      tester,
    ) async {
      final now = DateTime.now();
      await fakeSessionRepository.saveSession(
        FocusSession(
          id: '1',
          mode: FocusMode.work,
          completedAt: now.subtract(const Duration(minutes: 30)),
          durationSeconds: 1500, // 25 mins
        ),
      );
      await fakeTaskRepository.saveTask(
        Task(id: 't1', title: 'Task 1', isCompleted: true, createdAt: now),
      );

      final cubit = TodayCubit(
        sessionRepository: fakeSessionRepository,
        taskRepository: fakeTaskRepository,
      );

      // Trigger recalculate and build
      await cubit.refresh();

      await tester.pumpWidget(createSubject(cubit: cubit));
      await tester.pump();

      expect(find.text('25 / 120'), findsOneWidget);
      expect(find.text('25m'), findsOneWidget);
      expect(find.text('1'), findsNWidgets(2)); // 1 session, 1 task

      cubit.close();
    });

    testWidgets('invokes onNavigateToFocus callback when quick start tapped', (
      tester,
    ) async {
      final cubit = TodayCubit(
        sessionRepository: fakeSessionRepository,
        taskRepository: fakeTaskRepository,
      );

      var navigated = false;
      await tester.pumpWidget(
        createSubject(cubit: cubit, onNavigateToFocus: () => navigated = true),
      );
      await tester.pump();

      await tester.tap(find.text('Start'));
      await tester.pump();

      expect(navigated, isTrue);

      cubit.close();
    });
  });
}
