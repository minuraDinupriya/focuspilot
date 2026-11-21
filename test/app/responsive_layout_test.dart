import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:focuspilot/app/app_shell.dart';
import 'package:focuspilot/app/theme/app_theme.dart';
import 'package:focuspilot/features/focus/domain/models/focus_mode.dart';
import 'package:focuspilot/features/focus/domain/models/focus_session.dart';
import 'package:focuspilot/features/focus/domain/models/ticker.dart';
import 'package:focuspilot/features/focus/presentation/controllers/focus_bloc.dart';
import 'package:focuspilot/features/focus/presentation/controllers/focus_event.dart';
import 'package:focuspilot/features/focus/presentation/controllers/focus_state.dart';
import 'package:focuspilot/features/focus/presentation/focus_screen.dart';
import 'package:focuspilot/features/focus/presentation/widgets/circular_timer_display.dart';
import 'package:focuspilot/features/focus/presentation/widgets/focus_task_selector.dart';
import 'package:focuspilot/features/settings/data/repositories/in_memory_settings_repository.dart';
import 'package:focuspilot/features/settings/presentation/controllers/settings_cubit.dart';
import 'package:focuspilot/features/settings/presentation/widgets/settings_sheet.dart';
import 'package:focuspilot/features/tasks/domain/models/task.dart';
import 'package:focuspilot/features/tasks/domain/models/task_priority.dart';
import 'package:focuspilot/features/tasks/presentation/controllers/tasks_cubit.dart';
import 'package:focuspilot/features/tasks/presentation/controllers/tasks_state.dart';
import 'package:focuspilot/features/tasks/presentation/planner_screen.dart';
import 'package:focuspilot/features/tasks/presentation/tasks_screen.dart';
import 'package:focuspilot/features/tasks/presentation/widgets/task_detail_sheet.dart';
import 'package:focuspilot/features/today/presentation/controllers/today_cubit.dart';
import 'package:focuspilot/features/today/presentation/today_screen.dart';
import 'package:focuspilot/features/today/presentation/widgets/daily_goal_ring.dart';
import 'package:focuspilot/features/today/presentation/widgets/metric_cards_row.dart';
import 'package:focuspilot/features/today/presentation/widgets/productivity_insights_card.dart';
import 'package:focuspilot/features/today/presentation/widgets/weekly_review_sheet.dart';

import '../features/focus/fakes/fake_focus_session_repository.dart';
import '../features/tasks/fakes/fake_task_repository.dart';

class _SilentTicker extends Ticker {
  const _SilentTicker();

  @override
  Stream<int> tick({required int ticks}) => const Stream.empty();

  @override
  Stream<void> pulse() => const Stream.empty();
}

void main() {
  late FakeTaskRepository tasks;
  late FakeFocusSessionRepository sessions;
  late TasksCubit tasksCubit;
  late SettingsCubit settingsCubit;
  late TodayCubit todayCubit;
  late FocusBloc focusBloc;
  late Task task;
  late InMemorySettingsRepository settings;

  Future<void> initialize({
    bool withSessions = true,
    int? overtimeSeconds,
    DateTime Function()? now,
  }) async {
    tasks = FakeTaskRepository();
    sessions = FakeFocusSessionRepository();
    task = Task(
      id: 'long-task',
      title: 'Prepare a detailed project proposal and review every milestone',
      category: 'Research and professional development',
      priority: TaskPriority.high,
      createdAt: DateTime.now(),
      dueDate: DateTime.now(),
      estimatedMinutes: 120,
      actualMinutes: 999,
      recurrenceRule: 'weekdays',
    );
    await tasks.saveTask(task);
    if (withSessions) {
      await sessions.saveSession(
        FocusSession(
          id: 'session',
          mode: FocusMode.work,
          durationSeconds: 999 * 60,
          completedAt: DateTime.now(),
          taskId: task.id,
        ),
      );
    }
    settings = InMemorySettingsRepository();
    tasksCubit = TasksCubit(tasks);
    settingsCubit = SettingsCubit(settings);
    todayCubit = TodayCubit(
      sessionRepository: sessions,
      taskRepository: tasks,
      settingsRepository: settings,
    );
    await todayCubit.refresh();
    focusBloc = FocusBloc(
      ticker: const _SilentTicker(),
      sessionRepository: sessions,
      now: now,
      initialState: FocusState(
        status: overtimeSeconds == null
            ? FocusStatus.initial
            : FocusStatus.running,
        linkedTask: task,
        durationSeconds: overtimeSeconds == null ? 1500 : 0,
        totalDurationSeconds: 1500,
        overtimeSeconds: overtimeSeconds,
      ),
    );
  }

  tearDown(() async {
    await focusBloc.close();
    await todayCubit.close();
    await settingsCubit.close();
    await tasksCubit.close();
    tasks.dispose();
    sessions.dispose();
    settings.dispose();
  });

  Future<void> pumpPage(
    WidgetTester tester,
    Widget child, {
    double width = 320,
    double scale = 1,
    bool dark = false,
  }) async {
    tester.view.physicalSize = Size(width, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      BlocProvider.value(
        value: settingsCubit,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: dark ? ThemeMode.dark : ThemeMode.light,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(scale)),
            child: child!,
          ),
          home: MultiBlocProvider(
            providers: [
              BlocProvider.value(value: tasksCubit),
              BlocProvider.value(value: todayCubit),
              BlocProvider.value(value: focusBloc),
            ],
            child: Scaffold(body: child),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final width in [320.0, 390.0, 800.0]) {
    for (final scale in [1.0, 2.0]) {
      final configuration = '${width.toInt()}px at ${scale}x text';
      testWidgets('Today fits $configuration', (tester) async {
        await initialize();
        await pumpPage(tester, const TodayScreen(), width: width, scale: scale);
        expect(tester.takeException(), isNull);
        for (final tab in ['Priority', 'Top Tasks']) {
          await tester.ensureVisible(find.byType(ProductivityInsightsCard));
          await tester.tap(find.text(tab));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }
      });
      testWidgets('Focus fits $configuration', (tester) async {
        await initialize();
        await pumpPage(tester, const FocusScreen(), width: width, scale: scale);
        expect(tester.takeException(), isNull);
        final timerRect = tester.getRect(find.byType(CircularTimerDisplay));
        expect(timerRect.width, closeTo(timerRect.height, 0.01));
        expect(timerRect.left, greaterThanOrEqualTo(20));
        expect(timerRect.right, lessThanOrEqualTo(width - 20));
        final timerText = tester.getRect(find.text('25:00'));
        expect(timerRect.contains(timerText.topLeft), isTrue);
        expect(timerRect.contains(timerText.bottomRight), isTrue);
        expect(tester.widget<Text>(find.text('25:00')).maxLines, 1);
        await tester.ensureVisible(find.text('Start Focus'));
        await tester.tap(find.text('Start Focus'));
        await tester.pumpAndSettle();
        expect(focusBloc.state.status, FocusStatus.running);
        expect(find.text('Pause'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
      testWidgets('Tasks fits $configuration', (tester) async {
        await initialize();
        await pumpPage(tester, const TasksScreen(), width: width, scale: scale);
        expect(tester.takeException(), isNull);
      });
      testWidgets('Task editor fits $configuration with keyboard', (
        tester,
      ) async {
        await initialize();
        tester.view.viewInsets = const FakeViewPadding(bottom: 300);
        addTearDown(tester.view.resetViewInsets);
        await pumpPage(
          tester,
          TaskDetailSheet(task: task),
          width: width,
          scale: scale,
        );
        expect(tester.takeException(), isNull);
        await tester.ensureVisible(find.text('Save Changes'));
        expect(tester.takeException(), isNull);
      });
      testWidgets('Settings fits $configuration', (tester) async {
        await initialize();
        await pumpPage(
          tester,
          const SettingsSheet(),
          width: width,
          scale: scale,
        );
        expect(tester.takeException(), isNull);
      });
      testWidgets('Weekly review fits $configuration', (tester) async {
        await initialize();
        await pumpPage(
          tester,
          WeeklyReviewSheet(data: todayCubit.state.weeklyReview),
          width: width,
          scale: scale,
        );
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('wide Focus choices are compact, centered, and selectable', (
    tester,
  ) async {
    await initialize();
    await pumpPage(tester, const FocusScreen(), width: 1600, dark: true);

    final modeChoices = find.byType(SegmentedButton<FocusMode>);
    final bounds = tester.getRect(modeChoices);
    expect(bounds.width, lessThan(520));
    expect(bounds.center.dx, closeTo(800, 1));
    expect(
      tester.widget<SegmentedButton<FocusMode>>(modeChoices).direction,
      Axis.horizontal,
    );
    await tester.tap(find.text('Short (5m)'));
    await tester.pumpAndSettle();
    expect(focusBloc.state.mode, FocusMode.shortBreak);
    expect(find.text('05:00'), findsOneWidget);
  });

  testWidgets('wide Today groups the summary and keeps insight tabs compact', (
    tester,
  ) async {
    await initialize();
    await pumpPage(tester, const TodayScreen(), width: 1600);

    final goal = tester.getRect(find.byType(DailyGoalRing));
    final metrics = tester.getRect(find.byType(MetricCardsRow));
    expect(goal.right, lessThan(metrics.left));
    expect(goal.center.dy, closeTo(metrics.center.dy, 1));
    final insights = find.byType(ProductivityInsightsCard);
    final panel = tester.getRect(insights);
    expect(panel.width, lessThanOrEqualTo(1040));
    expect(panel.center.dx, closeTo(800, 1));
    final insightChoices = find.byType(SegmentedButton<InsightTab>);
    expect(tester.getSize(insightChoices).width, lessThan(520));
    await tester.ensureVisible(insightChoices);
    await tester.tap(find.text('Top Tasks'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<SegmentedButton<InsightTab>>(insightChoices).selected,
      {InsightTab.topTasks},
    );
  });

  testWidgets('wide Tasks keeps search, filters, and add action together', (
    tester,
  ) async {
    await initialize();
    await pumpPage(tester, const TasksScreen(), width: 1600);

    final search = tester.getRect(find.byType(TextField));
    final filters = find.byType(SegmentedButton<TasksFilter>);
    final filterBounds = tester.getRect(filters);
    final addTask = tester.getRect(find.byType(FloatingActionButton));
    expect(search.center.dx, closeTo(800, 1));
    expect(search.width, lessThanOrEqualTo(840));
    expect(filterBounds.left, closeTo(search.left, 1));
    expect(filterBounds.width, lessThan(520));
    expect(addTask.right, lessThanOrEqualTo(search.right + 1));
    await tester.tap(find.text('Active (1)'));
    await tester.pumpAndSettle();
    expect(tasksCubit.state.filter, TasksFilter.active);
  });

  for (final (width, scale) in [(320.0, 2.0), (1600.0, 1.0)]) {
    testWidgets('Planner date controls fit at ${width.toInt()}px', (
      tester,
    ) async {
      await initialize();
      await pumpPage(tester, const PlannerScreen(), width: width, scale: scale);

      final date = find.ancestor(
        of: find.byIcon(Icons.calendar_month_outlined),
        matching: find.byWidgetPredicate((widget) => widget is OutlinedButton),
      );
      final dateBounds = tester.getRect(date);
      final next = find.byTooltip('Next day');
      final nextBounds = tester.getRect(next);
      expect(dateBounds.width, lessThanOrEqualTo(280));
      expect(nextBounds.left - dateBounds.right, lessThanOrEqualTo(8));
      expect(nextBounds.right, lessThan(width));
      if (width == 1600) {
        expect(nextBounds.right, lessThan(800));
        expect(
          tester.getRect(find.byType(FloatingActionButton)).right,
          lessThanOrEqualTo(1220),
        );
      }
      await tester.tap(next);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('wide navigation and Settings keep choices grouped', (
    tester,
  ) async {
    await initialize();
    await pumpPage(tester, const AppShell(), width: 1600);
    final navigation = tester.getRect(find.byType(NavigationBar));
    expect(navigation.width, lessThanOrEqualTo(640));
    expect(navigation.center.dx, closeTo(800, 1));
    expect(navigation.height, lessThan(100));

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    final sheet = tester.getRect(find.byType(SettingsSheet));
    final themeChoices = find.byKey(const Key('theme_mode_segmented_button'));
    expect(sheet.width, lessThanOrEqualTo(640));
    expect(sheet.center.dx, closeTo(800, 1));
    expect(tester.getSize(themeChoices).width, lessThan(480));
    await tester.ensureVisible(themeChoices);
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    expect(settingsCubit.state.settings.themeMode.name, 'dark');
  });

  for (final page in [const TodayScreen(), const FocusScreen()]) {
    testWidgets('${page.runtimeType} fits narrow dark mode with large text', (
      tester,
    ) async {
      await initialize();
      await pumpPage(tester, page, scale: 2, dark: true);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('flow time and both finish actions fit at large text', (
    tester,
  ) async {
    await initialize(overtimeSeconds: 125 * 60 + 7);
    await pumpPage(tester, const FocusScreen(), scale: 2, dark: true);

    final timer = tester.getRect(find.byType(CircularTimerDisplay));
    final time = tester.getRect(find.text('+125:07'));
    expect(timer.contains(time.topLeft), isTrue);
    expect(timer.contains(time.bottomRight), isTrue);
    for (final label in ['Finish focus', 'Log planned time only']) {
      final action = find.text(label);
      await tester.ensureVisible(action);
      final rect = tester.getRect(action);
      expect(rect.left, greaterThanOrEqualTo(20));
      expect(rect.right, lessThanOrEqualTo(300));
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('foreground catch-up keeps flow time when Today is visible', (
    tester,
  ) async {
    var now = DateTime.now();
    await initialize(withSessions: false, now: () => now);
    await pumpPage(tester, const AppShell(), width: 800);
    expect(find.byType(TodayScreen), findsOneWidget);

    focusBloc.add(const FocusStarted(durationSeconds: 25 * 60));
    await tester.pumpAndSettle();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    now = now.add(const Duration(minutes: 28, seconds: 15));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();

    expect(focusBloc.state.overtimeSeconds, 195);
    expect(focusBloc.state.linkedTask?.id, task.id);
    expect(find.byType(TodayScreen), findsOneWidget);
  });

  testWidgets('custom duration dialog fits large text with keyboard', (
    tester,
  ) async {
    await initialize();
    await pumpPage(tester, const SettingsSheet(), scale: 2);
    final custom = find.text('Custom...').first;
    await tester.ensureVisible(custom);
    await tester.tap(custom);
    await tester.pumpAndSettle();
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Save'), findsOneWidget);
  });

  testWidgets('empty dashboard fits narrow screens with large text', (
    tester,
  ) async {
    await initialize(withSessions: false);
    await pumpPage(tester, const TodayScreen(), scale: 2);
    expect(find.text('No Active Streak'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'task picker preserves route-scoped tasks and supports selection',
    (tester) async {
      await initialize();
      Task? selected;
      await pumpPage(
        tester,
        FocusTaskSelector(
          linkedTask: null,
          onTaskSelected: (value) => selected = value,
        ),
      );
      await tester.tap(find.text('Tag a Task'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.text(task.title));
      await tester.pumpAndSettle();
      expect(selected, task);
      expect(find.text('Select Task to Focus On'), findsNothing);
      await pumpPage(
        tester,
        FocusTaskSelector(
          linkedTask: selected,
          onTaskSelected: (value) => selected = value,
        ),
      );
      await tester.tap(find.byTooltip('Unlink task'));
      await tester.pumpAndSettle();
      expect(selected, isNull);
      expect(tester.takeException(), isNull);
    },
  );
}
