import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

class Subtask extends Equatable {
  const Subtask({
    required this.id,
    required this.taskId,
    required this.title,
    this.isCompleted = false,
    this.orderIndex = 0,
  });

  final String id;
  final String taskId;
  final String title;
  final bool isCompleted;
  final int orderIndex;

  factory Subtask.create({
    required String taskId,
    required String title,
    int orderIndex = 0,
  }) {
    return Subtask(
      id: const Uuid().v4(),
      taskId: taskId,
      title: title.trim(),
      isCompleted: false,
      orderIndex: orderIndex,
    );
  }

  Subtask copyWith({
    String? id,
    String? taskId,
    String? title,
    bool? isCompleted,
    int? orderIndex,
  }) {
    return Subtask(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }

  @override
  List<Object?> get props => [id, taskId, title, isCompleted, orderIndex];
}
