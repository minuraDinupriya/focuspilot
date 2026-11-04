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
    FocusState? initialState,
  }) : super(initialState ?? const FocusState()) {
    on<FocusStarted>(_onStarted);
    on<FocusTicked>(_onTicked);
    on<FocusPaused>(_onPaused);
    on<FocusResumed>(_onResumed);
    on<FocusReset>(_onReset);
    on<FocusModeChanged>(_onModeChanged);
    on<FocusTaskLinked>(_onTaskLinked);
    on<FocusSessionsCountRefreshed>(_onSessionsCountRefreshed);
    on<FocusSettingsChanged>(_onSettingsChanged);

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
    emit(
      state.copyWith(
        status: FocusStatus.running,
        durationSeconds: event.durationSeconds,
        totalDurationSeconds: event.durationSeconds,
      ),
    );

    _tickerSubscription?.cancel();
    _tickerSubscription = ticker
        .tick(ticks: event.durationSeconds)
        .listen((duration) => add(FocusTicked(durationSeconds: duration)));
  }

  Future<void> _onTicked(FocusTicked event, Emitter<FocusState> emit) async {
    if (event.durationSeconds > 0) {
      emit(
        state.copyWith(
          status: FocusStatus.running,
          durationSeconds: event.durationSeconds,
        ),
      );
    } else {
      await _tickerSubscription?.cancel();

      try {
        final session = FocusSession.create(
          mode: state.mode,
          durationSeconds: state.totalDurationSeconds,
          taskId: state.linkedTask?.id,
        );
        await sessionRepository.saveSession(session);
        HapticFeedback.vibrate();
      } catch (_) {
        // Continue even if logging fails
      }

      final count = await sessionRepository.getCompletedSessionsCountToday();

      emit(
        state.copyWith(
          status: FocusStatus.completed,
          durationSeconds: 0,
          sessionsCompletedToday: count,
        ),
      );
    }
  }

  void _onPaused(FocusPaused event, Emitter<FocusState> emit) {
    if (state.isRunning) {
      _tickerSubscription?.pause();
      emit(state.copyWith(status: FocusStatus.paused));
    }
  }

  void _onResumed(FocusResumed event, Emitter<FocusState> emit) {
    if (state.isPaused) {
      _tickerSubscription?.resume();
      emit(state.copyWith(status: FocusStatus.running));
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
