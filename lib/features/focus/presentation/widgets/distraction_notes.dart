import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focuspilot/features/focus/domain/models/distraction_note.dart';
import 'package:focuspilot/features/focus/domain/repositories/distraction_notes_repository.dart';
import 'package:uuid/uuid.dart';

abstract final class DistractionNotes {
  static bool isAvailable(BuildContext context) =>
      context.read<DistractionNotesRepository?>() != null;

  static Future<bool> showCapture(
    BuildContext context, {
    String? taskTitle,
  }) async {
    final repository = context.read<DistractionNotesRepository>();
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          _CaptureDialog(repository: repository, taskTitle: taskTitle),
    );
    return saved ?? false;
  }

  static Future<void> showHistory(BuildContext context) {
    final repository = context.read<DistractionNotesRepository>();
    return showDialog<void>(
      context: context,
      builder: (_) => _HistoryDialog(repository: repository),
    );
  }
}

class _CaptureDialog extends StatefulWidget {
  const _CaptureDialog({required this.repository, required this.taskTitle});

  final DistractionNotesRepository repository;
  final String? taskTitle;

  @override
  State<_CaptureDialog> createState() => _CaptureDialogState();
}

class _CaptureDialogState extends State<_CaptureDialog> {
  final _controller = TextEditingController();
  final _noteId = const Uuid().v4();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _saving) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.repository.save(
        DistractionNote(
          id: _noteId,
          text: text,
          capturedAt: DateTime.now(),
          taskTitle: widget.taskTitle,
        ),
      );
    } on Exception {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = 'Couldn’t save this note. Try again.';
      });
      return;
    }
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_saving,
      child: AlertDialog(
        title: const Text('Capture a distraction'),
        scrollable: true,
        content: SizedBox(
          width: 440,
          child: TextField(
            controller: _controller,
            autofocus: true,
            readOnly: _saving,
            maxLength: DistractionNote.maxLength,
            minLines: 2,
            maxLines: 4,
            onChanged: (_) => setState(() => _error = null),
            decoration: InputDecoration(
              labelText: 'Note',
              hintText: 'What do you want to come back to?',
              errorText: _error,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: _saving || _controller.text.trim().isEmpty
                ? null
                : _save,
            child: Text(_saving ? 'Saving…' : 'Save note'),
          ),
        ],
      ),
    );
  }
}

class _HistoryDialog extends StatefulWidget {
  const _HistoryDialog({required this.repository});

  final DistractionNotesRepository repository;

  @override
  State<_HistoryDialog> createState() => _HistoryDialogState();
}

class _HistoryDialogState extends State<_HistoryDialog> {
  late Future<List<DistractionNote>> _notes = widget.repository.getAll();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = MaterialLocalizations.of(context);
    return AlertDialog(
      title: const Text('Distraction notes'),
      content: SizedBox(
        width: 480,
        child: FutureBuilder<List<DistractionNote>>(
          future: _notes,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(
                heightFactor: 1,
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.hasError) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Couldn’t load your notes.'),
                  TextButton(
                    onPressed: () => setState(() {
                      _notes = widget.repository.getAll();
                    }),
                    child: const Text('Retry'),
                  ),
                ],
              );
            }
            final notes = snapshot.requireData;
            if (notes.isEmpty) return const Text('No distraction notes yet.');

            return ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 400),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: notes.length,
                separatorBuilder: (_, _) => const Divider(height: 24),
                itemBuilder: (context, index) {
                  final note = notes[index];
                  final date = note.capturedAt.toLocal();
                  final time = localizations.formatTimeOfDay(
                    TimeOfDay.fromDateTime(date),
                    alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(
                      context,
                    ),
                  );
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SelectableText(note.text),
                      const SizedBox(height: 4),
                      Text(
                        '${localizations.formatShortDate(date)} · $time',
                        style: theme.textTheme.bodySmall,
                      ),
                      if (note.taskTitle case final title?)
                        Text(title, style: theme.textTheme.bodySmall),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
