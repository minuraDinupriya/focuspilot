import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:focuspilot/features/tasks/domain/models/subtask.dart';
import 'package:focuspilot/features/tasks/domain/models/task.dart';
import 'package:focuspilot/features/tasks/domain/models/task_details.dart';
import 'package:focuspilot/features/tasks/presentation/controllers/tasks_cubit.dart';
import 'package:focuspilot/features/tasks/presentation/widgets/task_detail_sheet.dart';

import '../../fakes/fake_task_repository.dart';

class _RetryTaskRepository extends FakeTaskRepository {
  final firstSave = Completer<bool>();
  var saveAttempts = 0;

  @override
  Future<bool> updateTaskDetails(String id, TaskDetails details) {
    saveAttempts++;
    if (saveAttempts == 1) return firstSave.future;
    return super.updateTaskDetails(id, details);
  }
}

Future<void> _openEditor(
  WidgetTester tester,
  FakeTaskRepository repository, {
  Task? task,
}) async {
  tester.view.physicalSize = const Size(800, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(repository.dispose);

  if (task != null) await repository.saveTask(task);
  await tester.pumpWidget(
    MaterialApp(
      home: BlocProvider(
        create: (_) => TasksCubit(repository),
        child: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => TaskDetailSheet.show(
                context,
                task: repository.tasks
                    .where((t) => t.id == task?.id)
                    .firstOrNull,
              ),
              child: const Text('Open task editor'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('Open task editor'));
  await tester.pumpAndSettle();
}

Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('creates a task with a validated custom estimate', (
    tester,
  ) async {
    final repository = FakeTaskRepository();
    await _openEditor(tester, repository);
    await tester.enterText(find.byType(TextFormField).first, 'Prepare slides');
    await _tapVisible(tester, find.text('Custom'));

    final minutes = find.widgetWithText(TextFormField, 'Minutes');
    await tester.enterText(minutes, '0');
    await _tapVisible(tester, find.text('Set estimate'));
    expect(
      find.text('Enter a positive whole number of minutes.'),
      findsOneWidget,
    );
    await tester.enterText(minutes, '12.5');
    await _tapVisible(tester, find.text('Set estimate'));
    expect(find.text('Custom task estimate'), findsOneWidget);

    await tester.enterText(minutes, '75');
    await _tapVisible(tester, find.text('Set estimate'));
    expect(find.text('75 min · Custom'), findsOneWidget);
    await _tapVisible(tester, find.text('Create Task'));
    expect(repository.tasks.single.estimatedMinutes, 75);
  });

  testWidgets('reopens, edits, and clears a custom estimate', (tester) async {
    final repository = FakeTaskRepository();
    final task = Task.create(title: 'Prepare slides', estimatedMinutes: 75);
    await _openEditor(tester, repository, task: task);

    await _tapVisible(tester, find.text('75 min · Custom'));
    final minutes = find.widgetWithText(TextFormField, 'Minutes');
    expect(tester.widget<TextFormField>(minutes).initialValue, '75');
    await tester.enterText(minutes, '120');
    await _tapVisible(
      tester,
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Cancel'),
      ),
    );
    expect(find.text('75 min · Custom'), findsOneWidget);

    await _tapVisible(tester, find.text('75 min · Custom'));
    await tester.enterText(minutes, '120');
    await _tapVisible(tester, find.text('Set estimate'));
    await _tapVisible(tester, find.text('Save Changes'));
    expect(repository.tasks.single.estimatedMinutes, 120);

    await _tapVisible(tester, find.text('Open task editor'));
    expect(find.text('120 min · Custom'), findsOneWidget);
    await _tapVisible(tester, find.byTooltip('Clear custom estimate'));
    await _tapVisible(tester, find.text('Save Changes'));
    expect(repository.tasks.single.estimatedMinutes, isNull);
  });

  testWidgets('can choose a start date and time when creating a task', (
    tester,
  ) async {
    final repository = FakeTaskRepository();
    await _openEditor(tester, repository);
    await tester.enterText(
      find.byType(TextFormField).first,
      'Scheduled review',
    );
    await _tapVisible(tester, find.text('Set start date and time'));
    expect(find.text('Choose a start date'), findsOneWidget);
    await _tapVisible(tester, find.text('OK'));
    expect(find.text('Choose a start time'), findsOneWidget);
    await _tapVisible(tester, find.text('OK'));
    await _tapVisible(tester, find.text('Create Task'));

    final task = repository.tasks.single;
    expect(task.scheduledStart, isNotNull);
    expect(task.dueDate, isNull);
  });

  testWidgets('can clear a planned start while retaining the due date', (
    tester,
  ) async {
    final repository = FakeTaskRepository();
    final due = DateTime(2026, 11, 20);
    final task = Task.create(
      title: 'Review graphs',
      dueDate: due,
      scheduledStart: DateTime(2026, 11, 19, 9),
    );
    await _openEditor(tester, repository, task: task);
    await _tapVisible(tester, find.byTooltip('Clear planned start'));
    await _tapVisible(tester, find.text('Save Changes'));

    expect(repository.tasks.single.scheduledStart, isNull);
    expect(repository.tasks.single.dueDate, due);
  });

  testWidgets(
    'checklist updates live and remains intact after saving details',
    (tester) async {
      final repository = FakeTaskRepository();
      final task = Task(
        id: 'checklist-task',
        title: 'Prepare report',
        createdAt: DateTime(2026, 11, 7),
        subtasks: const [
          Subtask(
            id: 'keep',
            taskId: 'checklist-task',
            title: 'Gather sources',
          ),
          Subtask(
            id: 'remove',
            taskId: 'checklist-task',
            title: 'Discard draft',
            orderIndex: 1,
          ),
        ],
      );
      await _openEditor(tester, repository, task: task);
      await tester.enterText(
        find.byType(TextFormField).first,
        'Finalize report',
      );

      await _tapVisible(
        tester,
        find.descendant(
          of: find.widgetWithText(ListTile, 'Gather sources'),
          matching: find.byType(Checkbox),
        ),
      );
      expect(find.text('Subtasks (1/2)'), findsOneWidget);
      await _tapVisible(
        tester,
        find.descendant(
          of: find.widgetWithText(ListTile, 'Discard draft'),
          matching: find.byTooltip('Delete subtask'),
        ),
      );
      expect(find.text('Discard draft'), findsNothing);
      expect(find.text('Subtasks (1/1)'), findsOneWidget);

      final addField = find.widgetWithText(TextField, 'Add a subtask...');
      await tester.ensureVisible(addField);
      await tester.enterText(addField, 'Review citations');
      await _tapVisible(tester, find.byTooltip('Add subtask'));
      expect(find.widgetWithText(ListTile, 'Review citations'), findsOneWidget);
      expect(find.text('Subtasks (1/2)'), findsOneWidget);

      await _tapVisible(tester, find.text('Save Changes'));
      expect(find.byType(TaskDetailSheet), findsNothing);
      final saved = (await repository.getTaskById(task.id))!;
      expect(saved.title, 'Finalize report');
      expect(saved.subtasks.map((subtask) => subtask.title), [
        'Gather sources',
        'Review citations',
      ]);
      expect(saved.subtasks.first.isCompleted, isTrue);
    },
  );

  testWidgets(
    'saving a cleared description preserves newly logged focus time',
    (tester) async {
      final repository = FakeTaskRepository();
      final task = Task(
        id: 'focus-task',
        title: 'Read Chapter 4',
        description: 'Temporary notes',
        actualMinutes: 10,
        estimatedMinutes: 30,
        createdAt: DateTime(2026, 11, 7),
      );
      await _openEditor(tester, repository, task: task);
      await tester.enterText(find.byType(TextFormField).at(1), '   ');
      await repository.addActualMinutes(task.id, 15);
      await tester.pumpAndSettle();
      expect(find.text('25m / 30m'), findsOneWidget);

      await _tapVisible(tester, find.text('Save Changes'));
      final saved = (await repository.getTaskById(task.id))!;
      expect(saved.description, isNull);
      expect(saved.actualMinutes, 25);
    },
  );

  testWidgets('a failed save keeps the draft available for retry', (
    tester,
  ) async {
    final repository = _RetryTaskRepository();
    final task = Task(
      id: 'retry-task',
      title: 'Prepare slides',
      createdAt: DateTime(2026, 11, 7),
    );
    await _openEditor(tester, repository, task: task);
    await tester.enterText(find.byType(TextFormField).first, 'Rehearse slides');

    final saveButton = find.widgetWithText(FilledButton, 'Save Changes');
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pump();
    final savingButton = find.widgetWithText(FilledButton, 'Saving...');
    expect(tester.widget<FilledButton>(savingButton).onPressed, isNull);
    expect(repository.saveAttempts, 1);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    final fields = tester.widgetList<EditableText>(find.byType(EditableText));
    expect(fields.every((field) => !field.focusNode.canRequestFocus), isTrue);

    repository.firstSave.completeError(StateError('Save failed'));
    await tester.pumpAndSettle();
    expect(find.byType(TaskDetailSheet), findsOneWidget);
    expect(find.text('Could not save this task. Try again.'), findsOneWidget);
    expect(find.text('Rehearse slides'), findsOneWidget);
    expect((await repository.getTaskById(task.id))!.title, task.title);

    await _tapVisible(tester, saveButton);
    expect(find.byType(TaskDetailSheet), findsNothing);
    expect((await repository.getTaskById(task.id))!.title, 'Rehearse slides');
  });

  testWidgets('a deleted task becomes unavailable in the editor', (
    tester,
  ) async {
    final repository = FakeTaskRepository();
    final task = Task(
      id: 'deleted-task',
      title: 'Read notes',
      createdAt: DateTime(2026, 11, 7),
    );
    await _openEditor(tester, repository, task: task);

    await repository.deleteTask(task.id);
    await tester.pumpAndSettle();
    expect(find.text('This task is no longer available.'), findsOneWidget);
    final saveButton = find.widgetWithText(FilledButton, 'Save Changes');
    expect(tester.widget<FilledButton>(saveButton).onPressed, isNull);
  });

  group('TaskDetailSheet Widget Tests', () {
    testWidgets('renders focus progress card with remaining estimate', (
      tester,
    ) async {
      final task = Task(
        id: 't-detail',
        title: 'Complete Lab Report',
        createdAt: DateTime.now(),
        estimatedMinutes: 60,
        actualMinutes: 40,
      );

      await _openEditor(tester, FakeTaskRepository(), task: task);

      expect(find.text('Focus Progress'), findsOneWidget);
      expect(find.text('40m / 60m'), findsOneWidget);
      expect(find.text('20 min remaining of estimate'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('renders exceeded estimate warning in focus progress card', (
      tester,
    ) async {
      final task = Task(
        id: 't-exceeded',
        title: 'Project Presentation',
        createdAt: DateTime.now(),
        estimatedMinutes: 30,
        actualMinutes: 45,
      );

      await _openEditor(tester, FakeTaskRepository(), task: task);

      expect(find.text('Focus Progress'), findsOneWidget);
      expect(find.text('45m / 30m'), findsOneWidget);
      expect(find.text('Exceeded estimate by 15 min'), findsOneWidget);
    });

    testWidgets('allows selecting an estimated focus time option', (
      tester,
    ) async {
      final repository = FakeTaskRepository();
      await _openEditor(tester, repository);

      await tester.enterText(
        find.byType(TextFormField).first,
        'New Feature Task',
      );

      await _tapVisible(tester, find.widgetWithText(ChoiceChip, '45 min'));
      await _tapVisible(tester, find.text('Create Task'));

      final tasks = await repository.getTasks();
      expect(tasks.length, 1);
      expect(tasks.first.title, 'New Feature Task');
      expect(tasks.first.estimatedMinutes, 45);
    });
  });
}
