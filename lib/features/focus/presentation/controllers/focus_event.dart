import 'package:equatable/equatable.dart';
import 'package:focuspilot/features/focus/domain/models/focus_mode.dart';
import 'package:focuspilot/features/settings/domain/models/user_settings.dart';
import 'package:focuspilot/features/tasks/domain/models/task.dart';

abstract class FocusEvent extends Equatable {
  const FocusEvent();

  @override
  List<Object?> get props => [];
}

class FocusStarted extends FocusEvent {
  const FocusStarted({required this.durationSeconds});

  final int durationSeconds;

  @override
  List<Object?> get props => [durationSeconds];
}

class FocusPaused extends FocusEvent {
  const FocusPaused();
}

class FocusResumed extends FocusEvent {
  const FocusResumed();
}

class FocusReset extends FocusEvent {
  const FocusReset();
}

class FocusTicked extends FocusEvent {
  const FocusTicked({this.durationSeconds});

  final int? durationSeconds;

  @override
  List<Object?> get props => [durationSeconds];
}

class FocusModeChanged extends FocusEvent {
  const FocusModeChanged({required this.mode});

  final FocusMode mode;

  @override
  List<Object?> get props => [mode];
}

class FocusTaskLinked extends FocusEvent {
  const FocusTaskLinked({this.task});

  final Task? task;

  @override
  List<Object?> get props => [task];
}

class FocusSessionsCountRefreshed extends FocusEvent {
  const FocusSessionsCountRefreshed();
}

class FocusSettingsChanged extends FocusEvent {
  const FocusSettingsChanged({required this.settings});

  final UserSettings settings;

  @override
  List<Object?> get props => [settings];
}

class FocusAppForegrounded extends FocusEvent {
  const FocusAppForegrounded();
}

class FocusDistractionRecorded extends FocusEvent {
  const FocusDistractionRecorded();
}

class FocusSkipped extends FocusEvent {
  const FocusSkipped();
}
