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
    cubit = TasksCubit(repository);
  });

  tearDown(() async {
    await cubit.close();
    repository.dispose();
  });

  Widget createWidgetUnderTest() {
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

    testWidgets('tapping Add Task opens bottom sheet', (tester) async {
      repository.emitTasks([]);
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('New Task'), findsOneWidget);
      expect(find.text('Save Task'), findsOneWidget);
    });
  });
}
