enum FocusMode {
  work,
  shortBreak,
  longBreak;

  String get displayName {
    switch (this) {
      case FocusMode.work:
        return 'Focus';
      case FocusMode.shortBreak:
        return 'Short Break';
      case FocusMode.longBreak:
        return 'Long Break';
    }
  }

  int get defaultDurationSeconds {
    switch (this) {
      case FocusMode.work:
        return 25 * 60; // 25 minutes
      case FocusMode.shortBreak:
        return 5 * 60; // 5 minutes
      case FocusMode.longBreak:
        return 15 * 60; // 15 minutes
    }
  }

  static FocusMode fromString(String value) {
    return FocusMode.values.firstWhere(
      (m) => m.name.toLowerCase() == value.toLowerCase(),
      orElse: () => FocusMode.work,
    );
  }
}
