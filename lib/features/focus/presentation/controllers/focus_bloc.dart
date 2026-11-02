import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focuspilot/features/focus/domain/models/focus_session.dart';
import 'package:focuspilot/features/focus/domain/models/ticker.dart';
import 'package:focuspilot/features/focus/domain/repositories/focus_session_repository.dart';
import 'package:focuspilot/features/focus/presentation/controllers/focus_event.dart';
import 'package:focuspilot/features/focus/presentation/controllers/focus_state.dart';

class FocusBloc extends Bloc<FocusEvent, FocusState> {
  FocusBloc({
    required this.ticker,
    required this.sessionRepository,
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

    add(const FocusSessionsCountRefreshed());
  }

  final Ticker ticker;
  final FocusSessionRepository sessionRepository;
  StreamSubscription<int>? _tickerSubscription;

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
    final defaultDuration = state.mode.defaultDurationSeconds;
    emit(
      state.copyWith(
        status: FocusStatus.initial,
        durationSeconds: defaultDuration,
        totalDurationSeconds: defaultDuration,
      ),
    );
  }

  void _onModeChanged(FocusModeChanged event, Emitter<FocusState> emit) {
    _tickerSubscription?.cancel();
    final defaultDuration = event.mode.defaultDurationSeconds;
    emit(
      state.copyWith(
        status: FocusStatus.initial,
        mode: event.mode,
        durationSeconds: defaultDuration,
        totalDurationSeconds: defaultDuration,
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

  @override
  Future<void> close() {
    _tickerSubscription?.cancel();
    return super.close();
  }
}
