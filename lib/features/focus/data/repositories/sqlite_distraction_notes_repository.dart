import 'package:drift/drift.dart';
import 'package:focuspilot/features/focus/domain/models/distraction_note.dart';
import 'package:focuspilot/features/focus/domain/repositories/distraction_notes_repository.dart';
import 'package:focuspilot/features/tasks/data/datasources/database/app_database.dart';

class SqliteDistractionNotesRepository implements DistractionNotesRepository {
  const SqliteDistractionNotesRepository(this._database);

  final AppDatabase _database;

  @override
  Future<void> save(DistractionNote note) async {
    await _database
        .into(_database.distractionNoteEntries)
        .insertOnConflictUpdate(
          DistractionNoteEntriesCompanion.insert(
            id: note.id,
            body: note.text,
            capturedAt: note.capturedAt,
            taskTitle: Value(note.taskTitle),
          ),
        );
  }

  @override
  Future<List<DistractionNote>> getAll() async {
    final query = _database.select(_database.distractionNoteEntries)
      ..orderBy([
        (table) => OrderingTerm.desc(table.capturedAt),
        (table) => OrderingTerm.asc(table.id),
      ]);
    final rows = await query.get();
    return [
      for (final row in rows)
        DistractionNote(
          id: row.id,
          text: row.body,
          capturedAt: row.capturedAt,
          taskTitle: row.taskTitle,
        ),
    ];
  }
}
