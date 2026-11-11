import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:focuspilot/features/tasks/domain/models/task.dart';
import 'package:focuspilot/features/tasks/domain/models/task_priority.dart';
import 'package:focuspilot/features/tasks/presentation/controllers/tasks_cubit.dart';
import 'package:focuspilot/features/tasks/presentation/tasks_screen.dart';
import 'package:focuspilot/features/tasks/presentation/widgets/task_filter_bar.dart';
import 'package:focuspilot/features/tasks/presentation/widgets/task_item_tile.dart';

import '../../fakes/fake_task_repository.dart';

void main() {
  late FakeTaskRepository repository;
  late TasksCubit cubit;

  setUp(() {
    repository = FakeTaskRepository();
  });

  tearDown(() async {
    await cubit.close();
    repository.dispose();
  });

  Widget createWidgetUnderTest() {
    cubit = TasksCubit(repository);
    return MaterialApp(
      home: BlocProvider<TasksCubit>.value(
        value: cubit,
        child: const TasksScreen(),
      ),
    );
  }

  group('TasksScreen', () {
    testWidgets('displays empty state when no tasks exist', (tester) async {
      repository.emitTasks([]);
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('No tasks yet'), findsOneWidget);
      expect(
        find.text('Tap + below to create your first task'),
        findsOneWidget,
      );
      expect(find.byType(TaskFilterBar), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('displays tasks when present', (tester) async {
      final task1 = Task(
        id: 't-1',
        title: 'Complete homework',
        priority: TaskPriority.high,
        createdAt: DateTime(2026, 11, 1),
      );
      final task2 = Task(
        id: 't-2',
        title: 'Walk the dog',
        priority: TaskPriority.low,
        createdAt: DateTime(2026, 11, 1),
      );

      repository.emitTasks([task1, task2]);
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Complete homework'), findsOneWidget);
      expect(find.text('Walk the dog'), findsOneWidget);
      expect(find.byType(TaskItemTile), findsNWidgets(2));
    });

    testWidgets('Priority sorts matching tasks highest first', (tester) async {
      repository.emitTasks([
        Task.create(title: 'Plan notes', priority: TaskPriority.low),
        Task.create(title: 'Plan launch', priority: TaskPriority.high),
        Task.create(title: 'Other task', priority: TaskPriority.high),
        Task.create(title: 'Plan review'),
      ]);
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'plan');
      await tester.tap(find.text('Priority'));
      await tester.pumpAndSettle();

      expect(
        tester
            .widgetList<TaskItemTile>(find.byType(TaskItemTile))
            .map((tile) => tile.task.title),
        ['Plan launch', 'Plan review', 'Plan notes'],
      );
    });

    for (final swipe in [false, true]) {
      testWidgets('can undo deletion by ${swipe ? 'swipe' : 'trash button'}', (
        tester,
      ) async {
        final task = Task.create(title: 'Write a draft');
        repository.emitTasks([task]);
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        if (swipe) {
          await tester.drag(find.byType(Dismissible), const Offset(-500, 0));
        } else {
          await tester.tap(find.byTooltip('Delete task'));
        }
        await tester.pumpAndSettle();
        expect(repository.tasks, isEmpty);
        expect(find.byType(TaskItemTile), findsNothing);
        await tester.tap(find.text('Undo'));
        await tester.pumpAndSettle();
        expect(repository.tasks.single, task);
        expect(find.byType(TaskItemTile), findsOneWidget);
      });
    }

    testWidgets('tapping Add Task opens bottom sheet', (tester) async {
      repository.emitTasks([]);
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('New Task'), findsOneWidget);
      expect(find.text('Create Task'), findsOneWidget);
    });

    testWidgets('tapping a task opens edit sheet with subtasks and details', (
      tester,
    ) async {
      final task1 = Task(
        id: 't-1',
        title: 'Complete homework',
        category: 'Study',
        priority: TaskPriority.high,
        createdAt: DateTime(2026, 11, 1),
      );

      repository.emitTasks([task1]);
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Complete homework'));
      await tester.pumpAndSettle();

      expect(find.text('Edit Task'), findsOneWidget);
      expect(find.text('Save Changes'), findsOneWidget);
      expect(find.text('Subtasks (0/0)'), findsOneWidget);
    });

    testWidgets('typing in search bar filters visible tasks', (tester) async {
      final task1 = Task(
        id: 't-1',
        title: 'Physics Assignment',
        category: 'Study',
        createdAt: DateTime(2026, 11, 1),
      );
      final task2 = Task(
        id: 't-2',
        title: 'Call Plumber',
        category: 'Personal',
        createdAt: DateTime(2026, 11, 1),
      );

      repository.emitTasks([task1, task2]);
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Physics Assignment'), findsOneWidget);
      expect(find.text('Call Plumber'), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, 'physics');
      await tester.pumpAndSettle();

      expect(find.text('Physics Assignment'), findsOneWidget);
      expect(find.text('Call Plumber'), findsNothing);
    });
  });
}
