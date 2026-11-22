class DistractionNote {
  const DistractionNote({
    required this.id,
    required this.text,
    required this.capturedAt,
    this.taskTitle,
  });

  static const maxLength = 500;

  final String id;
  final String text;
  final DateTime capturedAt;
  final String? taskTitle;
}
