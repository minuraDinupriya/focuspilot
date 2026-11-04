import 'package:equatable/equatable.dart';
import 'package:focuspilot/features/focus/domain/models/focus_mode.dart';
import 'package:focuspilot/features/tasks/domain/models/task.dart';

enum FocusStatus { initial, running, paused, completed }

class FocusState extends Equatable {
  const FocusState({
    this.status = FocusStatus.initial,
    this.mode = FocusMode.work,
    int? durationSeconds,
    int? totalDurationSeconds,
    this.linkedTask,
    this.sessionsCompletedToday = 0,
    this.targetEndTime,
  }) : durationSeconds = durationSeconds ?? 25 * 60,
       totalDurationSeconds = totalDurationSeconds ?? 25 * 60;

  final FocusStatus status;
  final FocusMode mode;
  final int durationSeconds;
  final int totalDurationSeconds;
  final Task? linkedTask;
  final int sessionsCompletedToday;
  final DateTime? targetEndTime;

  double get progress {
    if (totalDurationSeconds <= 0) return 0.0;
    final elapsed = totalDurationSeconds - durationSeconds;
    return (elapsed / totalDurationSeconds).clamp(0.0, 1.0);
  }

  String get timerString {
    final minutes = (durationSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (durationSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  bool get isRunning => status == FocusStatus.running;
  bool get isPaused => status == FocusStatus.paused;
  bool get isInitial => status == FocusStatus.initial;
  bool get isCompleted => status == FocusStatus.completed;

  FocusState copyWith({
    FocusStatus? status,
    FocusMode? mode,
    int? durationSeconds,
    int? totalDurationSeconds,
    Task? linkedTask,
    bool clearLinkedTask = false,
    int? sessionsCompletedToday,
    DateTime? targetEndTime,
    bool clearTargetEndTime = false,
  }) {
    return FocusState(
      status: status ?? this.status,
      mode: mode ?? this.mode,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      totalDurationSeconds: totalDurationSeconds ?? this.totalDurationSeconds,
      linkedTask: clearLinkedTask ? null : (linkedTask ?? this.linkedTask),
      sessionsCompletedToday:
          sessionsCompletedToday ?? this.sessionsCompletedToday,
      targetEndTime: clearTargetEndTime
          ? null
          : (targetEndTime ?? this.targetEndTime),
    );
  }

  @override
  List<Object?> get props => [
    status,
    mode,
    durationSeconds,
    totalDurationSeconds,
    linkedTask,
    sessionsCompletedToday,
    targetEndTime,
  ];
}
