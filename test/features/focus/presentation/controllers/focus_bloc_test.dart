import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:focuspilot/features/focus/domain/models/focus_mode.dart';
import 'package:focuspilot/features/focus/domain/models/focus_session.dart';
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
  const FakeTicker({this.stream = const Stream.empty(), this.overtime});

  final Stream<int> stream;
  final Stream<void>? overtime;

  @override
  Stream<int> tick({required int ticks}) => stream;

  @override
  Stream<void> pulse() => overtime ?? const Stream.empty();
}

class _CountdownSpy extends FakeTicker {
  final startedCountdowns = <int>[];

  @override
  Stream<int> tick({required int ticks}) {
    startedCountdowns.add(ticks);
    return super.tick(ticks: ticks);
  }
}

class _ControlledWorkRepository extends FakeFocusSessionRepository {
  Completer<void>? nextWrite;
  int workWrites = 0;

  @override
  Future<void> recordWorkSession(FocusSession session) async {
    workWrites++;
    final gate = nextWrite;
    nextWrite = null;
    if (gate != null) await gate.future;
    await super.recordWorkSession(session);
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
      final controller = StreamController<int>.broadcast();
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

    test('break expiry still completes without entering overtime', () async {
      var currentTime = DateTime(2026, 11, 4, 10);
      final testBloc = FocusBloc(
        ticker: const FakeTicker(),
        sessionRepository: repository,
        now: () => currentTime,
      );
      addTearDown(testBloc.close);

      testBloc.add(const FocusModeChanged(mode: FocusMode.shortBreak));
      testBloc.add(const FocusStarted(durationSeconds: 300));
      await pumpEventQueue();

      currentTime = currentTime.add(const Duration(minutes: 5));
      testBloc.add(const FocusTicked(durationSeconds: 0));
      await pumpEventQueue();

      expect(testBloc.state.isCompleted, isTrue);
      expect(testBloc.state.isOvertime, isFalse);
      final session = (await repository.getSessions()).single;
      expect(session.mode, FocusMode.shortBreak);
      expect(session.status, SessionStatus.completed);
      expect(session.durationSeconds, 300);
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
      'foreground recovery and pulses count from the work deadline',
      () async {
        var currentTime = DateTime(2026, 11, 4, 10);
        final overtime = StreamController<void>.broadcast();
        final testBloc = FocusBloc(
          ticker: FakeTicker(overtime: overtime.stream),
          sessionRepository: repository,
          now: () => currentTime,
        );
        addTearDown(overtime.close);
        addTearDown(testBloc.close);

        testBloc.add(const FocusStarted(durationSeconds: 300));
        await pumpEventQueue();

        currentTime = currentTime.add(const Duration(seconds: 350));
        testBloc.add(const FocusAppForegrounded());
        await pumpEventQueue();

        expect(testBloc.state.isRunning, isTrue);
        expect(testBloc.state.isOvertime, isTrue);
        expect(testBloc.state.mode, FocusMode.work);
        expect(testBloc.state.overtimeSeconds, 50);
        expect(testBloc.state.timerString, '+00:50');
        expect(testBloc.state.progress, 1.0);
        final plannedSession = (await repository.getSessions()).single;
        expect(plannedSession.durationSeconds, 300);
        expect(plannedSession.status, SessionStatus.completed);

        currentTime = currentTime.add(const Duration(seconds: 20));
        overtime.add(null);
        await pumpEventQueue();

        expect(testBloc.state.overtimeSeconds, 70);
        expect(testBloc.state.timerString, '+01:10');
      },
    );

    test('paused overtime excludes time away before resuming', () async {
      var currentTime = DateTime(2026, 11, 4, 10);
      final testBloc = FocusBloc(
        ticker: const FakeTicker(),
        sessionRepository: repository,
        now: () => currentTime,
      );
      addTearDown(testBloc.close);

      testBloc.add(const FocusStarted(durationSeconds: 300));
      await pumpEventQueue();
      currentTime = currentTime.add(const Duration(seconds: 350));
      testBloc.add(const FocusAppForegrounded());
      await pumpEventQueue();

      currentTime = currentTime.add(const Duration(seconds: 10));
      testBloc.add(const FocusPaused());
      await pumpEventQueue();
      expect(testBloc.state.isPaused, isTrue);
      expect(testBloc.state.overtimeSeconds, 60);

      currentTime = currentTime.add(const Duration(minutes: 2));
      testBloc.add(const FocusAppForegrounded());
      await pumpEventQueue();
      expect(testBloc.state.overtimeSeconds, 60);

      testBloc.add(const FocusResumed());
      await pumpEventQueue();
      currentTime = currentTime.add(const Duration(seconds: 15));
      testBloc.add(const FocusAppForegrounded());
      await pumpEventQueue();
      expect(testBloc.state.overtimeSeconds, 75);

      testBloc.add(const FocusOvertimeFinished());
      await pumpEventQueue();
      expect((await repository.getSessions()).single.durationSeconds, 375);
    });

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

    test(
      'custom work duration enters overtime before an automatic break',
      () async {
        var currentTime = DateTime(2026, 11, 4, 10);
        final settings = InMemorySettingsRepository(
          const UserSettings(
            workDurationMinutes: 40,
            shortBreakDurationMinutes: 7,
            autoStartNextSession: true,
          ),
        );
        final autoBloc = FocusBloc(
          ticker: const FakeTicker(),
          sessionRepository: repository,
          settingsRepository: settings,
          now: () => currentTime,
        );
        addTearDown(settings.dispose);
        addTearDown(autoBloc.close);
        await pumpEventQueue();

        autoBloc.add(
          FocusStarted(durationSeconds: autoBloc.state.durationSeconds),
        );
        await pumpEventQueue();
        final deadline = currentTime.add(const Duration(minutes: 40));

        currentTime = deadline.subtract(const Duration(milliseconds: 1));
        autoBloc.add(const FocusTicked(durationSeconds: 0));
        await pumpEventQueue();
        expect(autoBloc.state.isOvertime, isFalse);
        expect(await repository.getSessions(), isEmpty);

        currentTime = deadline;
        autoBloc.add(const FocusAppForegrounded());
        await pumpEventQueue();
        expect(autoBloc.state.isRunning, isTrue);
        expect(autoBloc.state.mode, FocusMode.work);
        expect(autoBloc.state.overtimeSeconds, 0);
        expect(autoBloc.state.timerString, '+00:00');
        expect(
          (await repository.getSessions()).single.durationSeconds,
          40 * 60,
        );

        autoBloc.add(const FocusOvertimeFinished());
        await pumpEventQueue();
        expect(autoBloc.state.mode, FocusMode.shortBreak);
        expect(autoBloc.state.isRunning, isTrue);
        expect(autoBloc.state.isOvertime, isFalse);
        expect(autoBloc.state.durationSeconds, 7 * 60);
      },
    );

    test(
      'overtime extends the same work session and credits the linked task',
      () async {
        final taskRepo = FakeTaskRepository();
        final sessionRepo = FakeFocusSessionRepository(
          taskRepository: taskRepo,
        );
        final testTask = Task.create(
          title: 'Math Homework',
          estimatedMinutes: 60,
          actualMinutes: 4,
        );
        final otherTask = Task.create(title: 'Chemistry');
        await taskRepo.saveTask(testTask);
        await taskRepo.saveTask(otherTask);

        final today = DateTime.now();
        var currentTime = DateTime(today.year, today.month, today.day, 12);
        final taskBloc = FocusBloc(
          ticker: const FakeTicker(),
          sessionRepository: sessionRepo,
          taskRepository: taskRepo,
          now: () => currentTime,
        );
        addTearDown(taskRepo.dispose);
        addTearDown(sessionRepo.dispose);
        addTearDown(taskBloc.close);

        taskBloc.add(FocusTaskLinked(task: testTask));
        await pumpEventQueue();
        taskBloc.add(const FocusStarted(durationSeconds: 25 * 60));
        await pumpEventQueue();
        currentTime = currentTime.add(const Duration(minutes: 25));
        // Quick Focus can arrive at the deadline before the next clock tick.
        taskBloc.add(FocusTaskLinked(task: otherTask));
        await pumpEventQueue();

        expect(taskBloc.state.isOvertime, isTrue);
        final plannedSession = (await sessionRepo.getSessions()).single;
        expect(plannedSession.durationSeconds, 25 * 60);
        expect((await taskRepo.getTaskById(testTask.id))?.actualMinutes, 29);
        expect(await sessionRepo.getCompletedSessionsCountToday(), 1);

        // Quick Focus on another task must preserve the active session's link.
        taskBloc.add(FocusTaskLinked(task: otherTask));
        await pumpEventQueue();
        currentTime = currentTime.add(const Duration(minutes: 7, seconds: 30));
        taskBloc.add(const FocusOvertimeFinished());
        await pumpEventQueue();

        final savedSession = (await sessionRepo.getSessions()).single;
        expect(savedSession.id, plannedSession.id);
        expect(savedSession.durationSeconds, 32 * 60 + 30);
        expect(savedSession.taskId, testTask.id);
        expect(await sessionRepo.getCompletedSessionsCountToday(), 1);
        expect(await sessionRepo.getTodayFocusMinutes(), 33);
        final updatedTask = await taskRepo.getTaskById(testTask.id);
        expect(updatedTask?.actualMinutes, 37);
        expect((await taskRepo.getTaskById(otherTask.id))?.actualMinutes, 0);
        expect(taskBloc.state.linkedTask?.actualMinutes, 37);
        expect(taskBloc.state.mode, FocusMode.shortBreak);
        expect(taskBloc.state.isInitial, isTrue);
      },
    );

    test(
      'logging planned time only leaves the work checkpoint unchanged',
      () async {
        var currentTime = DateTime(2026, 11, 4, 10);
        final testBloc = FocusBloc(
          ticker: const FakeTicker(),
          sessionRepository: repository,
          now: () => currentTime,
        );
        addTearDown(testBloc.close);

        testBloc.add(const FocusStarted(durationSeconds: 300));
        await pumpEventQueue();
        currentTime = currentTime.add(const Duration(minutes: 12));
        testBloc.add(const FocusAppForegrounded());
        await pumpEventQueue();
        expect(testBloc.state.overtimeSeconds, 7 * 60);
        final plannedSession = (await repository.getSessions()).single;

        testBloc.add(const FocusOvertimeFinished(includeOvertime: false));
        await pumpEventQueue();

        final savedSession = (await repository.getSessions()).single;
        expect(savedSession.id, plannedSession.id);
        expect(savedSession.durationSeconds, 300);
        expect(testBloc.state.isOvertime, isFalse);
        expect(testBloc.state.isInitial, isTrue);
        expect(testBloc.state.mode, FocusMode.shortBreak);
      },
    );

    test('duplicate timer and finish events do not add writes, and a failed finish can be retried', () async {
      var currentTime = DateTime(2026, 11, 4, 10);
      final sessionRepo = _ControlledWorkRepository();
      final testBloc = FocusBloc(
        ticker: const FakeTicker(),
        sessionRepository: sessionRepo,
        now: () => currentTime,
      );
      addTearDown(sessionRepo.dispose);
      addTearDown(testBloc.close);

      testBloc.add(const FocusStarted(durationSeconds: 300));
      await pumpEventQueue();
      currentTime = currentTime.add(const Duration(minutes: 7));
      testBloc.add(const FocusTicked(durationSeconds: 0));
      testBloc.add(const FocusAppForegrounded());
      await pumpEventQueue();
      expect(testBloc.state.overtimeSeconds, 120);
      expect(sessionRepo.workWrites, 1);
      final plannedSession = (await sessionRepo.getSessions()).single;

      final gate = Completer<void>();
      addTearDown(() {
        if (!gate.isCompleted) gate.complete();
      });
      sessionRepo.nextWrite = gate;
      testBloc.add(const FocusOvertimeFinished());
      await pumpEventQueue();
      expect(testBloc.state.isSaving, isTrue);
      testBloc.add(const FocusOvertimeFinished(includeOvertime: false));
      testBloc.add(const FocusAppForegrounded());
      await pumpEventQueue();
      expect(sessionRepo.workWrites, 2);

      currentTime = currentTime.add(const Duration(minutes: 3));
      gate.completeError(StateError('Write failed'));
      await pumpEventQueue();
      expect(testBloc.state.hasSaveError, isTrue);
      expect(testBloc.state.isPaused, isTrue);
      expect(testBloc.state.overtimeSeconds, 120);
      expect((await sessionRepo.getSessions()).single, plannedSession);

      testBloc.add(const FocusOvertimeFinished());
      await pumpEventQueue();
      expect(sessionRepo.workWrites, 3);
      expect(testBloc.state.hasSaveError, isFalse);
      expect(testBloc.state.mode, FocusMode.shortBreak);
      final savedSession = (await sessionRepo.getSessions()).single;
      expect(savedSession.id, plannedSession.id);
      expect(savedSession.durationSeconds, 420);
    });

    test(
      'finishing a pending save after close does not start a break ticker',
      () async {
        var currentTime = DateTime(2026, 11, 4, 10);
        final ticker = _CountdownSpy();
        final sessionRepo = _ControlledWorkRepository();
        final settings = InMemorySettingsRepository(
          const UserSettings(autoStartNextSession: true),
        );
        final testBloc = FocusBloc(
          ticker: ticker,
          sessionRepository: sessionRepo,
          settingsRepository: settings,
          now: () => currentTime,
        );
        final gate = Completer<void>();
        addTearDown(settings.dispose);
        addTearDown(sessionRepo.dispose);
        addTearDown(() async {
          if (!gate.isCompleted) gate.complete();
          if (!testBloc.isClosed) await testBloc.close();
        });
        await pumpEventQueue();

        testBloc.add(const FocusStarted(durationSeconds: 300));
        await pumpEventQueue();
        currentTime = currentTime.add(const Duration(minutes: 7));
        testBloc.add(const FocusAppForegrounded());
        await pumpEventQueue();

        sessionRepo.nextWrite = gate;
        testBloc.add(const FocusOvertimeFinished());
        await pumpEventQueue();
        expect(testBloc.state.isSaving, isTrue);
        expect(sessionRepo.workWrites, 2);

        final closing = testBloc.close();
        await pumpEventQueue();
        gate.complete();
        await closing;
        await pumpEventQueue();

        expect(ticker.startedCountdowns, [300]);
        expect((await sessionRepo.getSessions()).single.durationSeconds, 420);
      },
    );

    test('Skipping session with elapsed focus time attributes minutes to linked task', () async {
      final taskRepo = FakeTaskRepository();
      final sessionRepo = FakeFocusSessionRepository(taskRepository: taskRepo);
      final testTask = Task.create(
        title: 'Writing Paper',
        estimatedMinutes: 45,
      );
      await taskRepo.saveTask(testTask);

      var fakeNow = DateTime(2026, 11, 5, 10, 0);
      final taskBloc = FocusBloc(
        ticker: const FakeTicker(stream: Stream.empty()),
        sessionRepository: sessionRepo,
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
      sessionRepo.dispose();
      taskRepo.dispose();
    });
  });
}
