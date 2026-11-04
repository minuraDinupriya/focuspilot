import 'package:equatable/equatable.dart';
import 'package:focuspilot/features/focus/domain/models/focus_mode.dart';
import 'package:uuid/uuid.dart';

enum SessionStatus {
  completed,
  skipped,
  interrupted;

  static SessionStatus fromString(String val) {
    return SessionStatus.values.firstWhere(
      (s) => s.name.toLowerCase() == val.toLowerCase(),
      orElse: () => SessionStatus.completed,
    );
  }
}

class FocusSession extends Equatable {
  const FocusSession({
    required this.id,
    required this.mode,
    required this.durationSeconds,
    required this.completedAt,
    this.taskId,
    this.distractionCount = 0,
    this.status = SessionStatus.completed,
  });

  final String id;
  final FocusMode mode;
  final int durationSeconds;
  final DateTime completedAt;
  final String? taskId;
  final int distractionCount;
  final SessionStatus status;

  factory FocusSession.create({
    required FocusMode mode,
    required int durationSeconds,
    String? taskId,
    int distractionCount = 0,
    SessionStatus status = SessionStatus.completed,
  }) {
    return FocusSession(
      id: const Uuid().v4(),
      mode: mode,
      durationSeconds: durationSeconds,
      completedAt: DateTime.now(),
      taskId: taskId,
      distractionCount: distractionCount,
      status: status,
    );
  }

  @override
  List<Object?> get props => [
    id,
    mode,
    durationSeconds,
    completedAt,
    taskId,
    distractionCount,
    status,
  ];
}
