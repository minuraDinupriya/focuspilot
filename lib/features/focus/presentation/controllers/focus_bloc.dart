import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focuspilot/features/focus/domain/models/focus_mode.dart';
import 'package:focuspilot/features/focus/domain/models/focus_session.dart';
import 'package:focuspilot/features/focus/domain/models/ticker.dart';
import 'package:focuspilot/features/focus/domain/repositories/focus_session_repository.dart';
import 'package:focuspilot/features/focus/presentation/controllers/focus_event.dart';
import 'package:focuspilot/features/focus/presentation/controllers/focus_state.dart';
import 'package:focuspilot/features/settings/domain/models/user_settings.dart';
import 'package:focuspilot/features/settings/domain/repositories/settings_repository.dart';
import 'package:focuspilot/features/tasks/domain/models/task.dart';
import 'package:focuspilot/features/tasks/domain/repositories/task_repository.dart';

class FocusBloc extends Bloc<FocusEvent, FocusState> {
  FocusBloc({
    required this.ticker,
    required this.sessionRepository,
    this.settingsRepository,
    this.taskRepository,
    DateTime Function()? now,
    this._elapsedTime,
    this._onIntervalEnded,
    FocusState? initialState,
  }) : now = now ?? DateTime.now,
       super(initialState ?? const FocusState()) {
    on<FocusStarted>(_onStarted);
    on<FocusQuickStarted>(_onQuickStarted);
    on<FocusTicked>(_onTicked);
    on<FocusPaused>(_onPaused);
    on<FocusResumed>(_onResumed);
    on<FocusReset>(_onReset);
    on<FocusModeChanged>(_onModeChanged);
    on<FocusTaskLinked>(_onTaskLinked);
    on<FocusSessionsCountRefreshed>(_onSessionsCountRefreshed);
    on<FocusSettingsChanged>(_onSettingsChanged);
    on<FocusAppForegrounded>(_onAppForegrounded);
    on<FocusDistractionRecorded>(_onDistractionRecorded);
    on<FocusSkipped>(_onSkipped);
    on<FocusOvertimeFinished>(_onOvertimeFinished);

    add(const FocusSessionsCountRefreshed());

    if (settingsRepository != null) {
      _settingsSubscription = settingsRepository!.watchSettings().listen(
        (settings) => add(FocusSettingsChanged(settings: settings)),
      );
    }
  }

  final Ticker ticker;
  final FocusSessionRepository sessionRepository;
  final SettingsRepository? settingsRepository;
  final TaskRepository? taskRepository;
  final DateTime Function() now;
  final Duration Function()? _elapsedTime;
  final void Function(FocusMode mode)? _onIntervalEnded;
  Duration? _elapsedDeadline;
  // The signed time to the deadline is frozen during pause, including Flow Time.
  Duration? _pausedInterval;
  StreamSubscription<void>? _tickerSubscription;
  StreamSubscription<UserSettings>? _settingsSubscription;
  UserSettings _settings = const UserSettings();
  FocusSession? _workCheckpoint;
  Future<bool>? _checkpointSave;

  int _durationForMode(FocusMode mode) => switch (mode) {
    FocusMode.work => _settings.workDurationSeconds,
    FocusMode.shortBreak => _settings.shortBreakDurationSeconds,
    FocusMode.longBreak => _settings.longBreakDurationSeconds,
  };

  FocusState _readyState(FocusState previous, FocusMode mode) {
    final duration = _durationForMode(mode);
    return previous.copyWith(
      status: FocusStatus.initial,
      mode: mode,
      durationSeconds: duration,
      totalDurationSeconds: duration,
      clearTargetEndTime: true,
      clearOvertime: true,
      distractionCount: 0,
      hasSaveError: false,
    );
  }

  void _stopTicker() {
    unawaited(_tickerSubscription?.cancel());
    _tickerSubscription = null;
  }

  void _startTicker({int? countdownSeconds}) {
    _stopTicker();
    if (countdownSeconds == null) {
      _tickerSubscription = ticker.pulse().listen(
        (_) => add(const FocusTicked()),
      );
    } else {
      _tickerSubscription = ticker
          .tick(ticks: countdownSeconds)
          .listen((duration) => add(FocusTicked(durationSeconds: duration)));
    }
  }

  void _startCountdown(Emitter<FocusState> emit, FocusState next) {
    if (emit.isDone) return;
    final seconds = next.durationSeconds;
    emit(
      next.copyWith(
        status: FocusStatus.running,
        targetEndTime: _anchorInterval(Duration(seconds: seconds)),
      ),
    );
    _startTicker(countdownSeconds: seconds);
  }

  void _onStarted(FocusStarted event, Emitter<FocusState> emit) {
    if (!state.isInitial && !state.isCompleted) return;

    final duration = event.durationSeconds > 0
        ? event.durationSeconds
        : _durationForMode(state.mode);
    _startCountdown(
      emit,
      state.copyWith(durationSeconds: duration, totalDurationSeconds: duration),
    );
  }

  void _onQuickStarted(FocusQuickStarted event, Emitter<FocusState> emit) {
    if (state.isSessionActive) return;
    _startCountdown(emit, _readyState(state, FocusMode.work));
  }

  DateTime _anchorInterval(Duration untilDeadline) {
    final elapsed = _elapsedTime?.call();
    _elapsedDeadline = elapsed == null ? null : elapsed + untilDeadline;
    _pausedInterval = null;
    return now().add(untilDeadline);
  }

  // The elapsed clock drives timing when available. Calendar timestamps are
  // still used when saving a session in the user's history.
  Duration? _timeUntilDeadline(DateTime current) {
    final elapsedDeadline = _elapsedDeadline;
    return elapsedDeadline == null
        ? state.targetEndTime?.difference(current)
        : elapsedDeadline - _elapsedTime!();
  }

  void _clearDeadline({Duration? pausedInterval}) {
    _pausedInterval = _elapsedDeadline == null ? null : pausedInterval;
    _elapsedDeadline = null;
  }

  int _remainingSeconds(Duration untilDeadline) {
    final remaining = untilDeadline.inMicroseconds;
    const microsPerSecond = Duration.microsecondsPerSecond;
    return math.max(0, (remaining + microsPerSecond - 1) ~/ microsPerSecond);
  }

  int _overtimeAt(Duration? untilDeadline) {
    final displayed = state.overtimeSeconds ?? 0;
    return untilDeadline == null
        ? displayed
        : math.max(displayed, (-untilDeadline).inSeconds);
  }

  Future<void> _onTicked(FocusTicked event, Emitter<FocusState> emit) {
    return _reconcileClock(emit, lastCountdownTick: event.durationSeconds == 0);
  }

  Future<void> _onAppForegrounded(
    FocusAppForegrounded event,
    Emitter<FocusState> emit,
  ) => _reconcileClock(emit);

  Future<void> _onPaused(FocusPaused event, Emitter<FocusState> emit) {
    return _reconcileClock(emit, pause: true);
  }

  Future<void> _reconcileClock(
    Emitter<FocusState> emit, {
    bool pause = false,
    bool lastCountdownTick = false,
  }) async {
    if (!state.isRunning) return;

    final current = now();
    final untilDeadline = _timeUntilDeadline(current);
    if (state.isOvertime ||
        untilDeadline == null ||
        untilDeadline > Duration.zero) {
      final remaining = untilDeadline == null || state.isOvertime
          ? state.durationSeconds
          : _remainingSeconds(untilDeadline);
      if (pause) {
        _stopTicker();
        _clearDeadline(pausedInterval: untilDeadline);
      }
      emit(
        state.copyWith(
          status: pause ? FocusStatus.paused : FocusStatus.running,
          durationSeconds: remaining,
          overtimeSeconds: state.isOvertime ? _overtimeAt(untilDeadline) : null,
          clearTargetEndTime: pause,
        ),
      );
      if (!pause &&
          !state.isOvertime &&
          lastCountdownTick &&
          untilDeadline != null) {
        // The ticker can finish before the deadline after a clock adjustment
        // or when a paused countdown resumes with fractional seconds.
        _startTicker(countdownSeconds: remaining);
      }
      return;
    }

    final completedAt = _elapsedDeadline == null
        ? state.targetEndTime!
        : current.add(untilDeadline);
    if (state.mode == FocusMode.work) {
      await _beginOvertime(emit, completedAt, untilDeadline, pause: pause);
    } else {
      await _completeBreak(emit, completedAt);
    }
  }

  Future<void> _beginOvertime(
    Emitter<FocusState> emit,
    DateTime completedAt,
    Duration untilDeadline, {
    required bool pause,
  }) async {
    final checkpoint = FocusSession.create(
      mode: FocusMode.work,
      durationSeconds: state.totalDurationSeconds,
      completedAt: completedAt,
      taskId: state.linkedTask?.id,
      distractionCount: state.distractionCount,
    );
    _workCheckpoint = checkpoint;
    _stopTicker();
    if (pause) _clearDeadline(pausedInterval: untilDeadline);
    emit(
      state.copyWith(
        status: pause ? FocusStatus.paused : FocusStatus.running,
        durationSeconds: 0,
        overtimeSeconds: (-untilDeadline).inSeconds,
        clearTargetEndTime: pause,
      ),
    );
    if (!pause) _startTicker();
    _signalIntervalEnded(checkpoint.mode);

    final save = _recordSession(checkpoint);
    _checkpointSave = save;
    if (await save) {
      final summary = await _withUpdatedSummary(state);
      if (!emit.isDone && !state.isSaving && _workCheckpoint == checkpoint) {
        emit(
          state.copyWith(
            sessionsCompletedToday: summary.sessionsCompletedToday,
            linkedTask: summary.linkedTask,
          ),
        );
      }
    }
  }

  Future<void> _onOvertimeFinished(
    FocusOvertimeFinished event,
    Emitter<FocusState> emit,
  ) async {
    final checkpoint = _workCheckpoint;
    if (checkpoint == null || state.isSaving) return;

    final untilDeadline = _timeUntilDeadline(now());
    final overtime = _overtimeAt(untilDeadline);
    final session = FocusSession(
      id: checkpoint.id,
      mode: checkpoint.mode,
      durationSeconds:
          checkpoint.durationSeconds + (event.includeOvertime ? overtime : 0),
      completedAt: checkpoint.completedAt,
      taskId: checkpoint.taskId,
      distractionCount: event.includeOvertime
          ? state.distractionCount
          : checkpoint.distractionCount,
    );
    _stopTicker();
    if (state.isRunning) _clearDeadline(pausedInterval: untilDeadline);
    emit(
      state.copyWith(
        status: FocusStatus.saving,
        overtimeSeconds: overtime,
        clearTargetEndTime: true,
        hasSaveError: false,
      ),
    );

    // Use the same row for the planned work and the user's final duration.
    await _checkpointSave;
    if (!await _recordSession(session)) {
      emit(state.copyWith(status: FocusStatus.paused, hasSaveError: true));
      return;
    }

    _workCheckpoint = null;
    _checkpointSave = null;
    final summary = await _withUpdatedSummary(state);
    _moveToNextTimer(emit, summary);
  }

  void _onDistractionRecorded(
    FocusDistractionRecorded event,
    Emitter<FocusState> emit,
  ) {
    if (state.isRunning || state.isPaused) {
      emit(state.copyWith(distractionCount: state.distractionCount + 1));
    }
  }

  Future<void> _onSkipped(FocusSkipped event, Emitter<FocusState> emit) async {
    if (state.isOvertime || state.isSaving) return;

    final current = now();
    final untilDeadline = _timeUntilDeadline(current);
    if (state.isRunning &&
        untilDeadline != null &&
        untilDeadline <= Duration.zero) {
      await _reconcileClock(emit);
      return;
    }

    _stopTicker();
    if (!state.isRunning && !state.isPaused) {
      _moveToNextTimer(emit, state);
      return;
    }

    final remaining = untilDeadline == null
        ? state.durationSeconds
        : _remainingSeconds(untilDeadline);
    final elapsed = state.totalDurationSeconds - remaining;
    if (elapsed > 0) {
      _clearDeadline();
      emit(
        state.copyWith(status: FocusStatus.saving, clearTargetEndTime: true),
      );
      await _recordSession(
        FocusSession.create(
          mode: state.mode,
          durationSeconds: elapsed,
          completedAt: current,
          taskId: state.linkedTask?.id,
          distractionCount: state.distractionCount,
          status: SessionStatus.skipped,
        ),
      );
      final summary = await _withUpdatedSummary(state);
      _moveToNextTimer(emit, summary);
    } else {
      _moveToNextTimer(emit, state);
    }
  }

  Future<void> _completeBreak(
    Emitter<FocusState> emit,
    DateTime completedAt,
  ) async {
    _stopTicker();
    _clearDeadline();
    final session = FocusSession.create(
      mode: state.mode,
      durationSeconds: state.totalDurationSeconds,
      completedAt: completedAt,
      taskId: state.linkedTask?.id,
      distractionCount: state.distractionCount,
    );
    emit(state.copyWith(status: FocusStatus.saving, clearTargetEndTime: true));
    await _recordSession(session);
    _signalIntervalEnded(session.mode);

    if (_settings.autoStartNextSession) {
      _moveToNextTimer(emit, state);
    } else {
      emit(
        state.copyWith(
          status: FocusStatus.completed,
          durationSeconds: 0,
          distractionCount: 0,
        ),
      );
    }
  }

  Future<bool> _recordSession(FocusSession session) async {
    try {
      if (session.mode == FocusMode.work) {
        await sessionRepository.recordWorkSession(session);
      } else {
        await sessionRepository.saveSession(session);
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  void _signalIntervalEnded(FocusMode mode) {
    if (_settings.hapticEnabled) unawaited(HapticFeedback.vibrate());
    if (_settings.soundEnabled) {
      unawaited(SystemSound.play(SystemSoundType.alert));
    }
    try {
      _onIntervalEnded?.call(mode);
    } catch (error, stackTrace) {
      addError(error, stackTrace);
    }
  }

  void _moveToNextTimer(Emitter<FocusState> emit, FocusState previous) {
    final mode = previous.mode == FocusMode.work
        ? FocusMode.shortBreak
        : FocusMode.work;
    final next = _readyState(previous, mode);
    if (_settings.autoStartNextSession) {
      _startCountdown(emit, next);
    } else {
      _clearDeadline();
      emit(next);
    }
  }

  void _onResumed(FocusResumed event, Emitter<FocusState> emit) {
    if (!state.isPaused) return;

    final untilDeadline =
        _pausedInterval ??
        Duration(
          seconds: state.isOvertime
              ? -state.overtimeSeconds!
              : state.durationSeconds,
        );
    emit(
      state.copyWith(
        status: FocusStatus.running,
        targetEndTime: _anchorInterval(untilDeadline),
      ),
    );
    _startTicker(
      countdownSeconds: state.isOvertime ? null : state.durationSeconds,
    );
  }

  void _onReset(FocusReset event, Emitter<FocusState> emit) {
    if (state.isOvertime || state.isSaving) return;
    _stopTicker();
    _clearDeadline();
    emit(_readyState(state, state.mode));
  }

  void _onModeChanged(FocusModeChanged event, Emitter<FocusState> emit) {
    if (state.isOvertime || state.isSaving) return;
    _stopTicker();
    _clearDeadline();
    emit(_readyState(state, event.mode));
  }

  Future<void> _onTaskLinked(
    FocusTaskLinked event,
    Emitter<FocusState> emit,
  ) async {
    if (state.isOvertime || state.isSaving) return;
    final untilDeadline = _timeUntilDeadline(now());
    if (state.isRunning &&
        state.mode == FocusMode.work &&
        untilDeadline != null &&
        untilDeadline <= Duration.zero) {
      await _reconcileClock(emit);
      return;
    }

    emit(
      state.copyWith(
        linkedTask: event.task,
        clearLinkedTask: event.task == null,
      ),
    );
  }

  Future<Task?> _getLinkedTask(Task? previous) async {
    if (previous == null || taskRepository == null) return previous;
    try {
      return await taskRepository!.getTaskById(previous.id) ?? previous;
    } catch (_) {
      return previous;
    }
  }

  Future<int> _getCompletedCount() async {
    try {
      return await sessionRepository.getCompletedSessionsCountToday();
    } catch (_) {
      return state.sessionsCompletedToday;
    }
  }

  Future<FocusState> _withUpdatedSummary(FocusState previous) async {
    final count = await _getCompletedCount();
    final task = await _getLinkedTask(previous.linkedTask);
    return previous.copyWith(sessionsCompletedToday: count, linkedTask: task);
  }

  Future<void> _onSessionsCountRefreshed(
    FocusSessionsCountRefreshed event,
    Emitter<FocusState> emit,
  ) async {
    final count = await _getCompletedCount();
    emit(state.copyWith(sessionsCompletedToday: count));
  }

  void _onSettingsChanged(
    FocusSettingsChanged event,
    Emitter<FocusState> emit,
  ) {
    _settings = event.settings;
    if (state.isInitial) emit(_readyState(state, state.mode));
  }

  @override
  Future<void> close() {
    _stopTicker();
    unawaited(_settingsSubscription?.cancel());
    return super.close();
  }
}
