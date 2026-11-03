import 'package:flutter_test/flutter_test.dart';
import 'package:focuspilot/features/focus/domain/models/focus_mode.dart';
import 'package:focuspilot/features/focus/domain/models/focus_session.dart';
import 'package:focuspilot/features/tasks/domain/models/task.dart';
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

    test('updates completed tasks count when task repository emits', () async {
      final now = DateTime.now();
      final task1 = Task(
        id: 't1',
        title: 'Task 1',
        isCompleted: true,
        createdAt: now,
      );
      final task2 = Task(
        id: 't2',
        title: 'Task 2',
        isCompleted: false,
        createdAt: now,
      );
      final task3 = Task(
        id: 't3',
        title: 'Task 3',
        isCompleted: true,
        createdAt: now,
      );

      fakeTaskRepository.emitTasks([task1, task2, task3]);
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.status, TodayStatus.loaded);
      expect(cubit.state.completedTasksToday, 2);
    });
  });
}
