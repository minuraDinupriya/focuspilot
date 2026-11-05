import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:focuspilot/features/focus/domain/models/focus_mode.dart';
import 'package:focuspilot/features/focus/domain/models/ticker.dart';
import 'package:focuspilot/features/focus/presentation/controllers/focus_bloc.dart';
import 'package:focuspilot/features/focus/presentation/controllers/focus_event.dart';
import 'package:focuspilot/features/focus/presentation/controllers/focus_state.dart';
import 'package:focuspilot/features/settings/data/repositories/in_memory_settings_repository.dart';
import 'package:focuspilot/features/settings/domain/models/user_settings.dart';
import 'package:focuspilot/features/tasks/domain/models/task.dart';

import '../../../tasks/fakes/fake_task_repository.dart';
import '../../fakes/fake_focus_session_repository.dart';

class FakeTicker extends Ticker {
  const FakeTicker({this.stream});

  final Stream<int>? stream;

  @override
  Stream<int> tick({required int ticks}) {
    return stream ?? Stream.fromIterable([ticks - 1, ticks - 2, 0]);
  }
}

void main() {
  late FakeFocusSessionRepository repository;
  late FocusBloc bloc;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    repository = FakeFocusSessionRepository();
    bloc = FocusBloc(ticker: const FakeTicker(), sessionRepository: repository);
  });

  tearDown(() async {
    await bloc.close();
    repository.dispose();
  });

  group('FocusBloc', () {
    test('initial state has default work values and initial status', () {
      expect(bloc.state.status, FocusStatus.initial);
      expect(bloc.state.mode, FocusMode.work);
      expect(bloc.state.durationSeconds, 25 * 60);
      expect(bloc.state.timerString, '25:00');
      expect(bloc.state.progress, 0.0);
    });

    test('FocusModeChanged updates mode and duration', () async {
      bloc.add(const FocusModeChanged(mode: FocusMode.shortBreak));
      await pumpEventQueue();

      expect(bloc.state.mode, FocusMode.shortBreak);
      expect(bloc.state.durationSeconds, 5 * 60);
      expect(bloc.state.timerString, '05:00');
    });

    test('FocusStarted and FocusPaused transitions state', () async {
      final controller = StreamController<int>();
      final controlledBloc = FocusBloc(
        ticker: FakeTicker(stream: controller.stream),
        sessionRepository: repository,
      );

      controlledBloc.add(const FocusStarted(durationSeconds: 10));
      await pumpEventQueue();

      expect(controlledBloc.state.isRunning, isTrue);

      controlledBloc.add(const FocusPaused());
      await pumpEventQueue();

      expect(controlledBloc.state.isPaused, isTrue);

      controlledBloc.add(const FocusResumed());
      await pumpEventQueue();

      expect(controlledBloc.state.isRunning, isTrue);

      await controlledBloc.close();
      await controller.close();
    });

    test('FocusReset cancels ticker and resets to initial', () async {
      bloc.add(const FocusStarted(durationSeconds: 10));
      await pumpEventQueue();

      bloc.add(const FocusReset());
      await pumpEventQueue();

      expect(bloc.state.isInitial, isTrue);
      expect(bloc.state.durationSeconds, 25 * 60);
    });

    test('FocusTicked reaching 0 saves session and marks completed', () async {
      bloc.add(const FocusTicked(durationSeconds: 0));
      await pumpEventQueue();

      expect(bloc.state.isCompleted, isTrue);
      final sessions = await repository.getSessions();
      expect(sessions.length, 1);
    });

    test('FocusBloc dynamically adapts to custom settings durations', () async {
      final settingsRepo = InMemorySettingsRepository();
      final customBloc = FocusBloc(
        ticker: const FakeTicker(),
        sessionRepository: repository,
        settingsRepository: settingsRepo,
      );

      await pumpEventQueue();

      // Update custom settings
      await settingsRepo.saveSettings(
        const UserSettings(
          workDurationMinutes: 45,
          shortBreakDurationMinutes: 8,
          longBreakDurationMinutes: 20,
        ),
      );
      await pumpEventQueue();

      expect(customBloc.state.durationSeconds, 45 * 60);
      expect(customBloc.state.timerString, '45:00');

      // Mode change to short break uses 8 min
      customBloc.add(const FocusModeChanged(mode: FocusMode.shortBreak));
      await pumpEventQueue();
      expect(customBloc.state.durationSeconds, 8 * 60);
      expect(customBloc.state.timerString, '08:00');

      // Mode change to long break uses 20 min
      customBloc.add(const FocusModeChanged(mode: FocusMode.longBreak));
      await pumpEventQueue();
      expect(customBloc.state.durationSeconds, 20 * 60);
      expect(customBloc.state.timerString, '20:00');

      await customBloc.close();
      settingsRepo.dispose();
    });

    test('FocusStarted sets targetEndTime and FocusPaused clears it', () async {
      var currentTime = DateTime(2026, 11, 4, 10, 0, 0);
      final testBloc = FocusBloc(
        ticker: const FakeTicker(stream: Stream.empty()),
        sessionRepository: repository,
        now: () => currentTime,
      );

      testBloc.add(const FocusStarted(durationSeconds: 1500));
      await pumpEventQueue();

      expect(testBloc.state.isRunning, isTrue);
      expect(testBloc.state.targetEndTime, DateTime(2026, 11, 4, 10, 25, 0));

      testBloc.add(const FocusPaused());
      await pumpEventQueue();

      expect(testBloc.state.isPaused, isTrue);
      expect(testBloc.state.targetEndTime, isNull);

      // Advance time by 5 minutes while paused
      currentTime = currentTime.add(const Duration(minutes: 5));

      testBloc.add(const FocusResumed());
      await pumpEventQueue();

      expect(testBloc.state.isRunning, isTrue);
      // targetEndTime recomputed from current time + remaining seconds (1500)
      expect(
        testBloc.state.targetEndTime,
        currentTime.add(const Duration(seconds: 1500)),
      );

      await testBloc.close();
    });

    test(
      'FocusAppForegrounded reconciles elapsed time while backgrounded',
      () async {
        var currentTime = DateTime(2026, 11, 4, 10, 0, 0);
        final testBloc = FocusBloc(
          ticker: const FakeTicker(stream: Stream.empty()),
          sessionRepository: repository,
          now: () => currentTime,
        );

        testBloc.add(const FocusStarted(durationSeconds: 1500));
        await pumpEventQueue();

        expect(testBloc.state.durationSeconds, 1500);

        // Simulate 500 seconds passing in background
        currentTime = currentTime.add(const Duration(seconds: 500));
        testBloc.add(const FocusAppForegrounded());
        await pumpEventQueue();

        expect(testBloc.state.durationSeconds, 1000);
        expect(testBloc.state.isRunning, isTrue);

        await testBloc.close();
      },
    );

    test(
      'FocusAppForegrounded completes session if timer expired in background',
      () async {
        var currentTime = DateTime(2026, 11, 4, 10, 0, 0);
        final testBloc = FocusBloc(
          ticker: const FakeTicker(stream: Stream.empty()),
          sessionRepository: repository,
          now: () => currentTime,
        );

        testBloc.add(const FocusStarted(durationSeconds: 300));
        await pumpEventQueue();

        // Simulate 350 seconds passing in background (exceeds 300s)
        currentTime = currentTime.add(const Duration(seconds: 350));
        testBloc.add(const FocusAppForegrounded());
        await pumpEventQueue();

        expect(testBloc.state.isCompleted, isTrue);
        expect(testBloc.state.durationSeconds, 0);
        final sessions = await repository.getSessions();
        expect(sessions.length, 1);
        expect(sessions.first.durationSeconds, 300);

        await testBloc.close();
      },
    );

    test('FocusDistractionRecorded increments distractionCount during active session', () async {
      final controlledBloc = FocusBloc(
        ticker: const FakeTicker(stream: Stream.empty()),
        sessionRepository: repository,
      );

      controlledBloc.add(const FocusStarted(durationSeconds: 1500));
      await pumpEventQueue();

      expect(controlledBloc.state.isRunning, isTrue);
      expect(controlledBloc.state.distractionCount, 0);

      controlledBloc.add(const FocusDistractionRecorded());
      await pumpEventQueue();
      expect(controlledBloc.state.distractionCount, 1);

      controlledBloc.add(const FocusDistractionRecorded());
      await pumpEventQueue();
      expect(controlledBloc.state.distractionCount, 2);

      controlledBloc.add(const FocusReset());
      await pumpEventQueue();
      expect(controlledBloc.state.distractionCount, 0);

      await controlledBloc.close();
    });

    test('FocusSkipped saves skipped session and switches mode', () async {
      final controlledBloc = FocusBloc(
        ticker: const FakeTicker(stream: Stream.empty()),
        sessionRepository: repository,
      );

      controlledBloc.add(const FocusStarted(durationSeconds: 1500));
      await pumpEventQueue();

      controlledBloc.add(const FocusDistractionRecorded());
      await pumpEventQueue();

      // Trigger skip
      controlledBloc.add(const FocusSkipped());
      await pumpEventQueue();

      expect(controlledBloc.state.mode, FocusMode.shortBreak);
      expect(controlledBloc.state.isInitial, isTrue);
      expect(controlledBloc.state.distractionCount, 0);

      await controlledBloc.close();
    });

    test(
      'Auto-start next session automatically transitions and runs next timer',
      () async {
        final settingsRepo = InMemorySettingsRepository();
        await settingsRepo.saveSettings(
          const UserSettings(
            workDurationMinutes: 25,
            shortBreakDurationMinutes: 5,
            autoStartNextSession: true,
          ),
        );

        final autoBloc = FocusBloc(
          ticker: const FakeTicker(stream: Stream.empty()),
          sessionRepository: repository,
          settingsRepository: settingsRepo,
        );
        await pumpEventQueue();

        autoBloc.add(const FocusStarted(durationSeconds: 10));
        await pumpEventQueue();

        // Skip current session
        autoBloc.add(const FocusSkipped());
        await pumpEventQueue();

        // With autoStartNextSession: true, it should immediately be running the next mode
        expect(autoBloc.state.mode, FocusMode.shortBreak);
        expect(autoBloc.state.isRunning, isTrue);
        expect(autoBloc.state.durationSeconds, 5 * 60);

        await autoBloc.close();
        settingsRepo.dispose();
      },
    );

    test('Session completion updates actualMinutes on linkedTask in taskRepository and state', () async {
      final taskRepo = FakeTaskRepository();
      final testTask = Task.create(
        title: 'Math Homework',
        estimatedMinutes: 60,
      );
      await taskRepo.saveTask(testTask);

      final taskBloc = FocusBloc(
        ticker: const FakeTicker(stream: Stream.empty()),
        sessionRepository: repository,
        taskRepository: taskRepo,
      );
      await pumpEventQueue();

      taskBloc.add(FocusTaskLinked(task: testTask));
      await pumpEventQueue();

      // Start 25-minute session
      taskBloc.add(const FocusStarted(durationSeconds: 25 * 60));
      await pumpEventQueue();

      // Tick to 0 to complete session
      taskBloc.add(const FocusTicked(durationSeconds: 0));
      await pumpEventQueue();

      // Task repository should have 25 minutes logged
      final updatedTask = await taskRepo.getTaskById(testTask.id);
      expect(updatedTask, isNotNull);
      expect(updatedTask!.actualMinutes, 25);
      expect(taskBloc.state.linkedTask?.actualMinutes, 25);

      await taskBloc.close();
      taskRepo.dispose();
    });

    test('Skipping session with elapsed focus time attributes minutes to linked task', () async {
      final taskRepo = FakeTaskRepository();
      final testTask = Task.create(
        title: 'Writing Paper',
        estimatedMinutes: 45,
      );
      await taskRepo.saveTask(testTask);

      var fakeNow = DateTime(2026, 11, 5, 10, 0);
      final taskBloc = FocusBloc(
        ticker: const FakeTicker(stream: Stream.empty()),
        sessionRepository: repository,
        taskRepository: taskRepo,
        now: () => fakeNow,
      );
      await pumpEventQueue();

      taskBloc.add(FocusTaskLinked(task: testTask));
      await pumpEventQueue();

      // Start 25-minute session
      taskBloc.add(const FocusStarted(durationSeconds: 25 * 60));
      await pumpEventQueue();

      // Advance simulated time by 10 minutes
      fakeNow = fakeNow.add(const Duration(minutes: 10));
      taskBloc.add(const FocusTicked());
      await pumpEventQueue();

      // Skip session
      taskBloc.add(const FocusSkipped());
      await pumpEventQueue();

      final updatedTask = await taskRepo.getTaskById(testTask.id);
      expect(updatedTask, isNotNull);
      expect(updatedTask!.actualMinutes, 10);
      expect(taskBloc.state.linkedTask?.actualMinutes, 10);

      await taskBloc.close();
      taskRepo.dispose();
    });
  });
}
