enum RecurrenceType {
  none,
  daily,
  weekdays,
  weekly,
  monthly;

  String get displayName {
    switch (this) {
      case RecurrenceType.none:
        return 'Does not repeat';
      case RecurrenceType.daily:
        return 'Daily';
      case RecurrenceType.weekdays:
        return 'Every Weekday (Mon-Fri)';
      case RecurrenceType.weekly:
        return 'Weekly';
      case RecurrenceType.monthly:
        return 'Monthly';
    }
  }

  static RecurrenceType fromString(String? val) {
    if (val == null || val.isEmpty) return RecurrenceType.none;
    return RecurrenceType.values.firstWhere(
      (r) => r.name.toLowerCase() == val.toLowerCase(),
      orElse: () => RecurrenceType.none,
    );
  }

  DateTime calculateNextDueDate(DateTime fromDate) {
    switch (this) {
      case RecurrenceType.none:
        return fromDate;
      case RecurrenceType.daily:
        return fromDate.add(const Duration(days: 1));
      case RecurrenceType.weekdays:
        if (fromDate.weekday >= DateTime.monday &&
            fromDate.weekday < DateTime.friday) {
          return fromDate.add(const Duration(days: 1));
        } else if (fromDate.weekday == DateTime.friday) {
          return fromDate.add(const Duration(days: 3));
        } else if (fromDate.weekday == DateTime.saturday) {
          return fromDate.add(const Duration(days: 2));
        } else {
          return fromDate.add(const Duration(days: 1));
        }
      case RecurrenceType.weekly:
        return fromDate.add(const Duration(days: 7));
      case RecurrenceType.monthly:
        final nextMonth = fromDate.month == 12 ? 1 : fromDate.month + 1;
        final nextYear = fromDate.month == 12
            ? fromDate.year + 1
            : fromDate.year;
        return DateTime(
          nextYear,
          nextMonth,
          fromDate.day,
          fromDate.hour,
          fromDate.minute,
        );
    }
  }
}
