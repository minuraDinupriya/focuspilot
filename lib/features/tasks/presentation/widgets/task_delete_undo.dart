import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focuspilot/features/tasks/presentation/controllers/tasks_cubit.dart';

Future<bool> deleteTaskWithUndo(
  BuildContext context,
  String id, {
  VoidCallback? onFailure,
}) async {
  final cubit = context.read<TasksCubit>();
  final messenger = ScaffoldMessenger.of(context);
  try {
    final task = await cubit.deleteTask(id);
    if (task == null) return false;

    void showUndo(String message) {
      if (!messenger.mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(message, maxLines: 2, overflow: TextOverflow.ellipsis),
          duration: const Duration(seconds: 8),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () async {
              try {
                await cubit.restoreTask(task);
              } catch (_) {
                showUndo('Couldn’t restore “${task.title}”. Try Undo again.');
              }
            },
          ),
        ),
      );
    }

    showUndo('Deleted “${task.title}”');
    return true;
  } catch (_) {
    if (onFailure != null) {
      onFailure();
    } else if (messenger.mounted) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Couldn’t delete the task. Try again.')),
      );
    }
    return false;
  }
}
