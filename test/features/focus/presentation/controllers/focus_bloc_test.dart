import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:focuspilot/features/focus/domain/models/focus_mode.dart';
import 'package:focuspilot/features/focus/domain/models/ticker.dart';
import 'package:focuspilot/features/focus/presentation/controllers/focus_bloc.dart';
import 'package:focuspilot/features/focus/presentation/controllers/focus_event.dart';
import 'package:focuspilot/features/focus/presentation/controllers/focus_state.dart';

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
  });
}
