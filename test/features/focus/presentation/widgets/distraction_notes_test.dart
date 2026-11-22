import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:focuspilot/features/focus/data/repositories/in_memory_distraction_notes_repository.dart';
import 'package:focuspilot/features/focus/domain/models/distraction_note.dart';
import 'package:focuspilot/features/focus/domain/repositories/distraction_notes_repository.dart';
import 'package:focuspilot/features/focus/presentation/widgets/distraction_notes.dart';

class _FailOnceRepository extends InMemoryDistractionNotesRepository {
  bool _fail = true;

  @override
  Future<void> save(DistractionNote note) async {
    if (_fail) {
      _fail = false;
      throw Exception('Disk write failed');
    }
    await super.save(note);
  }
}

Widget _host(DistractionNotesRepository repository) {
  return RepositoryProvider<DistractionNotesRepository>.value(
    value: repository,
    child: MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => Column(
            children: [
              TextButton(
                onPressed: () => DistractionNotes.showCapture(
                  context,
                  taskTitle: 'Review schema',
                ),
                child: const Text('Capture'),
              ),
              TextButton(
                onPressed: () => DistractionNotes.showHistory(context),
                child: const Text('Open notes'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('saved note and task title can be reopened from history', (
    tester,
  ) async {
    final repository = InMemoryDistractionNotesRepository();
    await tester.pumpWidget(_host(repository));
    await tester.tap(find.text('Capture'));
    await tester.pumpAndSettle();

    final save = find.widgetWithText(FilledButton, 'Save note');
    await tester.enterText(find.byType(TextField), '    ');
    await tester.pump();
    expect(tester.widget<FilledButton>(save).onPressed, isNull);
    await tester.enterText(
      find.byType(TextField),
      '  Read about transactions  ',
    );
    await tester.pump();
    await tester.tap(save);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open notes'));
    await tester.pumpAndSettle();
    expect(
      find.widgetWithText(SelectableText, 'Read about transactions'),
      findsOneWidget,
    );
    expect(find.text('Review schema'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a save failure leaves the draft available for retry', (
    tester,
  ) async {
    final repository = _FailOnceRepository();
    await tester.pumpWidget(_host(repository));
    await tester.tap(find.text('Capture'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Check downloads');
    await tester.pump();
    await tester.tap(find.text('Save note'));
    await tester.pumpAndSettle();

    expect(find.text('Couldn’t save this note. Try again.'), findsOneWidget);
    expect(find.text('Check downloads'), findsOneWidget);
    expect(await repository.getAll(), isEmpty);

    await tester.tap(find.text('Save note'));
    await tester.pumpAndSettle();
    expect(find.text('Capture a distraction'), findsNothing);
    expect((await repository.getAll()).single.text, 'Check downloads');
  });
}
