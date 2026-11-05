import 'package:flutter_test/flutter_test.dart';
import 'package:focuspilot/features/focus/domain/models/focus_mode.dart';
import 'package:focuspilot/features/focus/domain/models/focus_session.dart';
import 'package:focuspilot/features/tasks/domain/models/task.dart';
import 'package:focuspilot/features/tasks/domain/models/task_priority.dart';
import 'package:focuspilot/features/today/presentation/controllers/today_cubit.dart';
import 'package:focuspilot/features/today/presentation/controllers/today_state.dart';

import '../../tasks/fakes/fake_task_repository.dart';
import '../fakes/fake_focus_session_repository.dart';

void main() {
  group('TodayCubit', () {
    late FakeFocusSessionRepository fakeSessionRepository;
    late FakeTaskRepository fakeTaskRepository;
    late TodayCubit cubit;

    setUp(() {
      fakeSessionRepository = FakeFocusSessionRepository();
      fakeTaskRepository = FakeTaskRepository();
      cubit = TodayCubit(
        sessionRepository: fakeSessionRepository,
        taskRepository: fakeTaskRepository,
      );
    });

    tearDown(() {
      cubit.close();
      fakeSessionRepository.dispose();
      fakeTaskRepository.dispose();
    });

    test('initial state has default values and progress 0.0', () {
      expect(cubit.state.status, TodayStatus.loading);
      expect(cubit.state.dailyGoalMinutes, 120);
      expect(cubit.state.goalProgress, 0.0);
    });

    test('calculates today focus minutes and sessions correctly', () async {
      final now = DateTime.now();

      final session1 = FocusSession(
        id: '1',
        mode: FocusMode.work,
        completedAt: now.subtract(const Duration(hours: 1)),
        durationSeconds: 1500, // 25 mins
      );

      final session2 = FocusSession(
        id: '2',
        mode: FocusMode.work,
        completedAt: now.subtract(const Duration(minutes: 30)),
        durationSeconds: 1500, // 25 mins
      );

      // Short break session (should not count towards work focus minutes)
      final session3 = FocusSession(
        id: '3',
        mode: FocusMode.shortBreak,
        completedAt: now.subtract(const Duration(minutes: 10)),
        durationSeconds: 300,
      );

      fakeSessionRepository.emitSessions([session1, session2, session3]);
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.status, TodayStatus.loaded);
      expect(cubit.state.focusMinutesToday, 50); // 25 + 25
      expect(cubit.state.completedSessionsToday, 2);
      expect(cubit.state.goalProgress, closeTo(50 / 120, 0.001));
    });

    test('updates completed tasks count and sorts priority tasks', () async {
      final now = DateTime.now();
      final taskLow = Task(
        id: 't_low',
        title: 'Low task',
        priority: TaskPriority.low,
        isCompleted: false,
        createdAt: now,
      );
      final taskHigh = Task(
        id: 't_high',
        title: 'High task',
        priority: TaskPriority.high,
        isCompleted: false,
        createdAt: now,
      );
      final taskDone = Task(
        id: 't_done',
        title: 'Done task',
        priority: TaskPriority.high,
        isCompleted: true,
        createdAt: now,
      );

      fakeTaskRepository.emitTasks([taskLow, taskHigh, taskDone]);
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.status, TodayStatus.loaded);
      expect(cubit.state.completedTasksToday, 1);
      // High priority task should be first in priorityTasks
      expect(cubit.state.priorityTasks.length, 2);
      expect(cubit.state.priorityTasks.first.title, 'High task');
    });

    test('calculates 7-day weekly metrics and streak correctly', () async {
      final now = DateTime.now();

      final sessionToday = FocusSession(
        id: 's_today',
        mode: FocusMode.work,
        completedAt: now,
        durationSeconds: 1500, // 25m
      );

      final sessionYesterday = FocusSession(
        id: 's_yest',
        mode: FocusMode.work,
        completedAt: now.subtract(const Duration(days: 1)),
        durationSeconds: 3000, // 50m
      );

      fakeSessionRepository.emitSessions([sessionToday, sessionYesterday]);
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.weeklyMetrics.length, 7);
      expect(cubit.state.currentStreakDays, 2);
      expect(cubit.state.weeklyMetrics.last.focusMinutes, 25);
      expect(cubit.state.weeklyMetrics.last.isToday, isTrue);
    });

    test('calculates 7-day weekly metrics and streak correctly', () async {
      final now = DateTime.now();

      // Today session
      final sessionToday = FocusSession(
        id: 's_today',
        mode: FocusMode.work,
        completedAt: now,
        durationSeconds: 1500, // 25m
      );

      // Yesterday session
      final sessionYesterday = FocusSession(
        id: 's_yest',
        mode: FocusMode.work,
        completedAt: now.subtract(const Duration(days: 1)),
        durationSeconds: 3000, // 50m
      );

      // 2 days ago session
      final session2DaysAgo = FocusSession(
        id: 's_2days',
        mode: FocusMode.work,
        completedAt: now.subtract(const Duration(days: 2)),
        durationSeconds: 1500, // 25m
      );

      fakeSessionRepository.emitSessions([
        sessionToday,
        sessionYesterday,
        session2DaysAgo,
      ]);
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.weeklyMetrics.length, 7);
      expect(cubit.state.currentStreakDays, 3);
      expect(cubit.state.weeklyMetrics.last.focusMinutes, 25); // today is last
      expect(cubit.state.weeklyMetrics.last.isToday, isTrue);
    });

    test('calculates 91 heatmapDays across 13 full weeks', () async {
      final now = DateTime.now();
      final sessionToday = FocusSession(
        id: 'h_today',
        mode: FocusMode.work,
        completedAt: now,
        durationSeconds: 3600, // 60 mins -> level 3
      );
      final session30DaysAgo = FocusSession(
        id: 'h_30',
        mode: FocusMode.work,
        completedAt: now.subtract(const Duration(days: 30)),
        durationSeconds: 1500, // 25 mins -> level 2
      );

      fakeSessionRepository.emitSessions([sessionToday, session30DaysAgo]);
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.heatmapDays.length, 91);
      expect(cubit.state.totalHeatmapMinutes, 85);
      expect(cubit.state.totalHeatmapHours, closeTo(85 / 60.0, 0.01));

      final activeDays = cubit.state.heatmapDays.where(
        (d) => d.focusMinutes > 0,
      );
      expect(activeDays.length, 2);
    });

    test('calculates weekly focus minutes, best streak, and streak milestone badge', () async {
      final now = DateTime.now();
      final sessions = [
        // 4 consecutive days of work sessions
        FocusSession(
          id: 's0',
          mode: FocusMode.work,
          completedAt: now,
          durationSeconds: 7200, // 120 mins (hits daily goal!)
        ),
        FocusSession(
          id: 's1',
          mode: FocusMode.work,
          completedAt: now.subtract(const Duration(days: 1)),
          durationSeconds: 7200, // 120 mins
        ),
        FocusSession(
          id: 's2',
          mode: FocusMode.work,
          completedAt: now.subtract(const Duration(days: 2)),
          durationSeconds: 7200, // 120 mins
        ),
        FocusSession(
          id: 's3',
          mode: FocusMode.work,
          completedAt: now.subtract(const Duration(days: 3)),
          durationSeconds: 7200, // 120 mins
        ),
      ];

      fakeSessionRepository.emitSessions(sessions);
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.currentStreakDays, 4);
      expect(cubit.state.bestStreakDays, 4);
      expect(cubit.state.streakMilestoneBadge, '🚀 Momentum');
      expect(cubit.state.nextStreakMilestone, 7);

      expect(cubit.state.focusMinutesToday, 120);
      expect(cubit.state.isDailyGoalAchieved, isTrue);

      expect(cubit.state.focusMinutesThisWeek, 480);
      expect(cubit.state.weeklyGoalMinutes, 600);
      expect(cubit.state.weeklyGoalProgress, closeTo(480 / 600, 0.001));
      expect(cubit.state.daysGoalMetThisWeek, 4);
      expect(cubit.state.isWeeklyGoalAchieved, isFalse);
    });

    test(
      'calculates category, priority, and top tasks productivity insights',
      () async {
        final now = DateTime.now();
        final tasks = [
          Task(
            id: 't1',
            title: 'Algorithms Midterm Prep',
            category: 'Study',
            priority: TaskPriority.high,
            actualMinutes: 90,
            estimatedMinutes: 120,
            createdAt: now,
          ),
          Task(
            id: 't2',
            title: 'App UI Refactor',
            category: 'Work',
            priority: TaskPriority.medium,
            actualMinutes: 60,
            estimatedMinutes: 60,
            createdAt: now,
          ),
          Task(
            id: 't3',
            title: 'Read Article',
            priority: TaskPriority.low,
            actualMinutes: 30,
            createdAt: now,
          ),
        ];

        fakeTaskRepository.emitTasks(tasks);
        await Future<void>.delayed(Duration.zero);

        // Categories: Study (90m = 50%), Work (60m = 33.3%), General (30m = 16.7%)
        expect(cubit.state.categoryInsights.length, 3);
        expect(cubit.state.categoryInsights[0].category, 'Study');
        expect(cubit.state.categoryInsights[0].minutes, 90);
        expect(cubit.state.categoryInsights[0].percentage, closeTo(0.5, 0.01));
        expect(cubit.state.categoryInsights[1].category, 'Work');
        expect(cubit.state.categoryInsights[2].category, 'General');

        // Priorities: High (90m), Medium (60m), Low (30m)
        expect(cubit.state.priorityInsights.length, 3);
        final highInsight = cubit.state.priorityInsights.firstWhere(
          (p) => p.priority == TaskPriority.high,
        );
        expect(highInsight.minutes, 90);
        expect(highInsight.percentage, closeTo(90 / 180, 0.01));

        // Top tasks: t1 (90m), t2 (60m), t3 (30m)
        expect(cubit.state.topTasksInsights.length, 3);
        expect(
          cubit.state.topTasksInsights[0].title,
          'Algorithms Midterm Prep',
        );
        expect(cubit.state.topTasksInsights[0].actualMinutes, 90);
      },
    );

    test('calculates weeklyReview with comparison and top tasks', () async {
      final now = DateTime(2026, 11, 5, 12, 0);
      final customCubit = TodayCubit(
        sessionRepository: fakeSessionRepository,
        taskRepository: fakeTaskRepository,
        nowProvider: () => now,
      );

      // Save a session this week (e.g. yesterday)
      await fakeSessionRepository.saveSession(
        FocusSession(
          id: 's_this_week',
          mode: FocusMode.work,
          completedAt: now.subtract(const Duration(days: 1)),
          durationSeconds: 3600, // 60 mins
        ),
      );

      // Save a session previous week (e.g. 8 days ago)
      await fakeSessionRepository.saveSession(
        FocusSession(
          id: 's_prev_week',
          mode: FocusMode.work,
          completedAt: now.subtract(const Duration(days: 8)),
          durationSeconds: 1800, // 30 mins
        ),
      );

      // Save a task with focus time
      await fakeTaskRepository.saveTask(
        Task(
          id: 't_review',
          title: 'Review Task',
          category: 'Development',
          priority: TaskPriority.high,
          actualMinutes: 60,
          isCompleted: true,
          createdAt: now.subtract(const Duration(days: 2)),
          completedAt: now.subtract(const Duration(days: 1)),
        ),
      );

      await customCubit.refresh();

      final review = customCubit.state.weeklyReview;
      expect(review, isNotNull);
      expect(review!.focusMinutesThisWeek, 60);
      expect(review.focusMinutesPreviousWeek, 30);
      expect(review.changePercentage, 100.0);
      expect(review.completedSessionsCount, 1);
      expect(review.completedTasksCount, 1);
      expect(review.topCategory, 'Development');
      expect(review.topTasks.length, 1);
      expect(review.topTasks.first.title, 'Review Task');

      await customCubit.close();
    });
  });
}
