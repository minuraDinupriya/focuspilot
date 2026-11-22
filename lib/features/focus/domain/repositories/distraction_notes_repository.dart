import 'package:focuspilot/features/focus/domain/models/distraction_note.dart';

abstract interface class DistractionNotesRepository {
  Future<void> save(DistractionNote note);

  /// Returns notes from newest to oldest.
  Future<List<DistractionNote>> getAll();
}
