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
  });
}
