import 'dart:async';

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

class FocusBloc extends Bloc<FocusEvent, FocusState> {
  FocusBloc({
    required this.ticker,
    required this.sessionRepository,
    this.settingsRepository,
    DateTime Function()? now,
    FocusState? initialState,
  }) : now = now ?? DateTime.now,
       super(initialState ?? const FocusState()) {
    on<FocusStarted>(_onStarted);
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
  final DateTime Function() now;
  StreamSubscription<int>? _tickerSubscription;
  StreamSubscription<UserSettings>? _settingsSubscription;
  UserSettings _settings = const UserSettings();

  int _durationForMode(FocusMode mode, UserSettings settings) {
    switch (mode) {
      case FocusMode.work:
        return settings.workDurationSeconds;
      case FocusMode.shortBreak:
        return settings.shortBreakDurationSeconds;
      case FocusMode.longBreak:
        return settings.longBreakDurationSeconds;
    }
  }

  void _onStarted(FocusStarted event, Emitter<FocusState> emit) {
    final target = now().add(Duration(seconds: event.durationSeconds));
    emit(
      state.copyWith(
        status: FocusStatus.running,
        durationSeconds: event.durationSeconds,
        totalDurationSeconds: event.durationSeconds,
        targetEndTime: target,
      ),
    );

    _tickerSubscription?.cancel();
    _tickerSubscription = ticker
        .tick(ticks: event.durationSeconds)
        .listen((duration) => add(FocusTicked(durationSeconds: duration)));
  }

  Future<void> _onTicked(FocusTicked event, Emitter<FocusState> emit) async {
    final int remaining;
    if (state.targetEndTime != null) {
      final diff = state.targetEndTime!.difference(now()).inSeconds;
      if (event.durationSeconds != null && event.durationSeconds! <= 0) {
        remaining = 0;
      } else {
        remaining = diff < 0 ? 0 : diff;
      }
    } else {
      remaining = event.durationSeconds ?? (state.durationSeconds - 1);
    }

    if (remaining > 0) {
      emit(
        state.copyWith(status: FocusStatus.running, durationSeconds: remaining),
      );
    } else {
      await _completeSession(emit);
    }
  }

  Future<void> _onAppForegrounded(
    FocusAppForegrounded event,
    Emitter<FocusState> emit,
  ) async {
    if (!state.isRunning || state.targetEndTime == null) return;

    final remaining = state.targetEndTime!.difference(now()).inSeconds;
    if (remaining <= 0) {
      await _completeSession(emit);
    } else {
      emit(state.copyWith(durationSeconds: remaining));
    }
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
    await _tickerSubscription?.cancel();

    final elapsedSeconds = state.totalDurationSeconds - state.durationSeconds;
    if (elapsedSeconds > 0) {
      try {
        final session = FocusSession.create(
          mode: state.mode,
          durationSeconds: elapsedSeconds,
          taskId: state.linkedTask?.id,
          distractionCount: state.distractionCount,
          status: SessionStatus.skipped,
        );
        await sessionRepository.saveSession(session);
      } catch (_) {}
    }

    final nextMode = state.mode == FocusMode.work
        ? FocusMode.shortBreak
        : FocusMode.work;
    final nextDuration = _durationForMode(nextMode, _settings);

    if (_settings.autoStartNextSession) {
      final target = now().add(Duration(seconds: nextDuration));
      emit(
        state.copyWith(
          status: FocusStatus.running,
          mode: nextMode,
          durationSeconds: nextDuration,
          totalDurationSeconds: nextDuration,
          targetEndTime: target,
          distractionCount: 0,
        ),
      );
      _tickerSubscription = ticker
          .tick(ticks: nextDuration)
          .listen((duration) => add(FocusTicked(durationSeconds: duration)));
    } else {
      emit(
        state.copyWith(
          status: FocusStatus.initial,
          mode: nextMode,
          durationSeconds: nextDuration,
          totalDurationSeconds: nextDuration,
          clearTargetEndTime: true,
          distractionCount: 0,
        ),
      );
    }
  }

  Future<void> _completeSession(Emitter<FocusState> emit) async {
    await _tickerSubscription?.cancel();

    try {
      final session = FocusSession.create(
        mode: state.mode,
        durationSeconds: state.totalDurationSeconds,
        taskId: state.linkedTask?.id,
        distractionCount: state.distractionCount,
        status: SessionStatus.completed,
      );
      await sessionRepository.saveSession(session);
      if (_settings.hapticEnabled) {
        HapticFeedback.vibrate();
      }
      if (_settings.soundEnabled) {
        SystemSound.play(SystemSoundType.alert);
      }
    } catch (_) {
      // Continue even if logging fails
    }

    final count = await sessionRepository.getCompletedSessionsCountToday();

    if (_settings.autoStartNextSession) {
      final nextMode = state.mode == FocusMode.work
          ? FocusMode.shortBreak
          : FocusMode.work;
      final nextDuration = _durationForMode(nextMode, _settings);
      final target = now().add(Duration(seconds: nextDuration));

      emit(
        state.copyWith(
          status: FocusStatus.running,
          mode: nextMode,
          durationSeconds: nextDuration,
          totalDurationSeconds: nextDuration,
          targetEndTime: target,
          distractionCount: 0,
          sessionsCompletedToday: count,
        ),
      );

      _tickerSubscription = ticker
          .tick(ticks: nextDuration)
          .listen((duration) => add(FocusTicked(durationSeconds: duration)));
    } else {
      emit(
        state.copyWith(
          status: FocusStatus.completed,
          durationSeconds: 0,
          clearTargetEndTime: true,
          distractionCount: 0,
          sessionsCompletedToday: count,
        ),
      );
    }
  }

  void _onPaused(FocusPaused event, Emitter<FocusState> emit) {
    if (state.isRunning) {
      _tickerSubscription?.pause();
      emit(
        state.copyWith(status: FocusStatus.paused, clearTargetEndTime: true),
      );
    }
  }

  void _onResumed(FocusResumed event, Emitter<FocusState> emit) {
    if (state.isPaused) {
      final target = now().add(Duration(seconds: state.durationSeconds));
      _tickerSubscription?.resume();
      emit(state.copyWith(status: FocusStatus.running, targetEndTime: target));
    }
  }

  void _onReset(FocusReset event, Emitter<FocusState> emit) {
    _tickerSubscription?.cancel();
    final duration = _durationForMode(state.mode, _settings);
    emit(
      state.copyWith(
        status: FocusStatus.initial,
        durationSeconds: duration,
        totalDurationSeconds: duration,
        clearTargetEndTime: true,
        distractionCount: 0,
      ),
    );
  }

  void _onModeChanged(FocusModeChanged event, Emitter<FocusState> emit) {
    _tickerSubscription?.cancel();
    final duration = _durationForMode(event.mode, _settings);
    emit(
      state.copyWith(
        status: FocusStatus.initial,
        mode: event.mode,
        durationSeconds: duration,
        totalDurationSeconds: duration,
        clearTargetEndTime: true,
        distractionCount: 0,
      ),
    );
  }

  void _onTaskLinked(FocusTaskLinked event, Emitter<FocusState> emit) {
    emit(
      state.copyWith(
        linkedTask: event.task,
        clearLinkedTask: event.task == null,
      ),
    );
  }

  Future<void> _onSessionsCountRefreshed(
    FocusSessionsCountRefreshed event,
    Emitter<FocusState> emit,
  ) async {
    final count = await sessionRepository.getCompletedSessionsCountToday();
    emit(state.copyWith(sessionsCompletedToday: count));
  }

  void _onSettingsChanged(
    FocusSettingsChanged event,
    Emitter<FocusState> emit,
  ) {
    _settings = event.settings;
    if (state.isInitial) {
      final duration = _durationForMode(state.mode, _settings);
      emit(
        state.copyWith(
          durationSeconds: duration,
          totalDurationSeconds: duration,
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _tickerSubscription?.cancel();
    _settingsSubscription?.cancel();
    return super.close();
  }
}
