import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:focuspilot/features/tasks/domain/models/task.dart';
import 'package:focuspilot/features/tasks/presentation/controllers/tasks_cubit.dart';
import 'package:focuspilot/features/tasks/presentation/widgets/task_detail_sheet.dart';

import '../../fakes/fake_task_repository.dart';

void main() {
  group('TaskDetailSheet Widget Tests', () {
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

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider<TasksCubit>.value(
              value: cubit,
              child: TaskDetailSheet(task: task),
            ),
          ),
        ),
      );

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

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider<TasksCubit>.value(
              value: cubit,
              child: TaskDetailSheet(task: task),
            ),
          ),
        ),
      );

      expect(find.text('Focus Progress'), findsOneWidget);
      expect(find.text('45m / 30m'), findsOneWidget);
      expect(find.text('Exceeded estimate by 15 min'), findsOneWidget);
    });

    testWidgets('allows selecting an estimated focus time option', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider<TasksCubit>.value(
              value: cubit,
              child: const TaskDetailSheet(),
            ),
          ),
        ),
      );

      // Enter a title
      await tester.enterText(
        find.byType(TextFormField).first,
        'New Feature Task',
      );

      // Scroll to estimated options if needed and tap '45 min'
      final chip45Finder = find.widgetWithText(ChoiceChip, '45 min');
      await tester.scrollUntilVisible(
        chip45Finder,
        100,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(chip45Finder);
      await tester.pumpAndSettle();

      // Tap Create Task
      final createButtonFinder = find.text('Create Task');
      await tester.scrollUntilVisible(
        createButtonFinder,
        100,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(createButtonFinder);
      await tester.pumpAndSettle();

      final tasks = await repository.getTasks();
      expect(tasks.length, 1);
      expect(tasks.first.title, 'New Feature Task');
      expect(tasks.first.estimatedMinutes, 45);
    });
  });
}
