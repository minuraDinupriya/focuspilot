import 'package:focuspilot/features/focus/domain/models/distraction_note.dart';
import 'package:focuspilot/features/focus/domain/repositories/distraction_notes_repository.dart';

class InMemoryDistractionNotesRepository implements DistractionNotesRepository {
  final _notes = <String, DistractionNote>{};

  @override
  Future<void> save(DistractionNote note) async {
    _notes[note.id] = note;
  }

  @override
  Future<List<DistractionNote>> getAll() async =>
      _notes.values.toList()..sort((a, b) {
        final byDate = b.capturedAt.compareTo(a.capturedAt);
        return byDate != 0 ? byDate : a.id.compareTo(b.id);
      });
}
