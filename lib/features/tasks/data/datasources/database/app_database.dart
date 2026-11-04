import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

class TaskEntries extends Table {
  TextColumn get id => text()();
  TextColumn get title => text().withLength(min: 1, max: 200)();
  TextColumn get description => text().nullable()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  TextColumn get priority => text().withDefault(const Constant('medium'))();
  DateTimeColumn get dueDate => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class FocusSessionEntries extends Table {
  TextColumn get id => text()();
  TextColumn get mode => text()();
  IntColumn get durationSeconds => integer()();
  DateTimeColumn get completedAt => dateTime()();
  TextColumn get taskId => text().nullable()();
  IntColumn get distractionCount => integer().withDefault(const Constant(0))();
  TextColumn get status => text().withDefault(const Constant('completed'))();

  @override
  Set<Column> get primaryKey => {id};
}

class UserSettingsEntries extends Table {
  TextColumn get id => text()();
  IntColumn get workDurationMinutes =>
      integer().withDefault(const Constant(25))();
  IntColumn get shortBreakDurationMinutes =>
      integer().withDefault(const Constant(5))();
  IntColumn get longBreakDurationMinutes =>
      integer().withDefault(const Constant(15))();
  IntColumn get dailyGoalMinutes =>
      integer().withDefault(const Constant(120))();
  TextColumn get activePresetId =>
      text().nullable().withDefault(const Constant('preset-classic'))();
  BoolColumn get autoStartNextSession =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get soundEnabled => boolean().withDefault(const Constant(true))();
  BoolColumn get hapticEnabled => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

class TimerPresetEntries extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get workDurationMinutes => integer()();
  IntColumn get shortBreakDurationMinutes => integer()();
  IntColumn get longBreakDurationMinutes => integer()();
  IntColumn get longBreakInterval => integer().withDefault(const Constant(4))();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    TaskEntries,
    FocusSessionEntries,
    UserSettingsEntries,
    TimerPresetEntries,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(focusSessionEntries);
      }
      if (from < 3) {
        await m.createTable(userSettingsEntries);
      }
      if (from < 4) {
        await m.addColumn(
          userSettingsEntries,
          userSettingsEntries.activePresetId,
        );
        await m.createTable(timerPresetEntries);
      }
      if (from < 5) {
        await m.addColumn(
          focusSessionEntries,
          focusSessionEntries.distractionCount,
        );
        await m.addColumn(focusSessionEntries, focusSessionEntries.status);
        await m.addColumn(
          userSettingsEntries,
          userSettingsEntries.autoStartNextSession,
        );
        await m.addColumn(
          userSettingsEntries,
          userSettingsEntries.soundEnabled,
        );
        await m.addColumn(
          userSettingsEntries,
          userSettingsEntries.hapticEnabled,
        );
      }
    },
  );

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'focuspilot.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }
}
