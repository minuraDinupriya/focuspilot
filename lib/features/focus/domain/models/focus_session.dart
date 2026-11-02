import 'package:equatable/equatable.dart';
import 'package:focuspilot/features/focus/domain/models/focus_mode.dart';
import 'package:uuid/uuid.dart';

class FocusSession extends Equatable {
  const FocusSession({
    required this.id,
    required this.mode,
    required this.durationSeconds,
    required this.completedAt,
    this.taskId,
  });

  final String id;
  final FocusMode mode;
  final int durationSeconds;
  final DateTime completedAt;
  final String? taskId;

  factory FocusSession.create({
    required FocusMode mode,
    required int durationSeconds,
    String? taskId,
  }) {
    return FocusSession(
      id: const Uuid().v4(),
      mode: mode,
      durationSeconds: durationSeconds,
      completedAt: DateTime.now(),
      taskId: taskId,
    );
  }

  @override
  List<Object?> get props => [id, mode, durationSeconds, completedAt, taskId];
}
