import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:focuspilot/features/focus/data/repositories/sqlite_distraction_notes_repository.dart';
import 'package:focuspilot/features/focus/domain/models/distraction_note.dart';
import 'package:focuspilot/features/tasks/data/datasources/database/app_database.dart';
import 'package:focuspilot/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:focuspilot/features/tasks/domain/models/task.dart';
import 'package:path/path.dart' as p;

class _VersionTenDatabase extends AppDatabase {
  _VersionTenDatabase(super.executor);

  @override
  int get schemaVersion => 10;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      for (final table in allTables) {
        if (table != distractionNoteEntries) {
          await migrator.createTable(table);
        }
      }
    },
  );
}

void main() {
  test('v10 data survives migration and notes survive reopening', () async {
    final directory = await Directory.systemTemp.createTemp('focuspilot_notes');
    addTearDown(() => directory.delete(recursive: true));
    final file = File(p.join(directory.path, 'focuspilot.sqlite'));
    final task = Task.create(title: 'Review schema');

    final oldDatabase = _VersionTenDatabase(NativeDatabase(file));
    try {
      await TaskRepositoryImpl(oldDatabase).saveTask(task);
    } finally {
      await oldDatabase.close();
    }

    final upgradedDatabase = AppDatabase(NativeDatabase(file));
    try {
      final repository = SqliteDistractionNotesRepository(upgradedDatabase);
      expect(await repository.getAll(), isEmpty);
      await repository.save(
        DistractionNote(
          id: 'recent',
          text: 'Check tomorrow’s calendar',
          capturedAt: DateTime(2026, 11, 21, 15),
          taskTitle: task.title,
        ),
      );
      final olderNote = DistractionNote(
        id: 'earlier',
        text: 'Review downloads',
        capturedAt: DateTime(2026, 11, 21, 14),
      );
      await repository.save(olderNote);
      await repository.save(olderNote);
    } finally {
      await upgradedDatabase.close();
    }

    final reopened = AppDatabase(NativeDatabase(file));
    addTearDown(reopened.close);
    final notes = await SqliteDistractionNotesRepository(reopened).getAll();
    expect(notes.map((note) => note.id), ['recent', 'earlier']);
    expect(notes.first.text, 'Check tomorrow’s calendar');
    expect(notes.first.taskTitle, 'Review schema');
    expect(notes.last.taskTitle, isNull);
    expect(
      (await TaskRepositoryImpl(reopened).getTaskById(task.id))?.title,
      task.title,
    );
  });
}
