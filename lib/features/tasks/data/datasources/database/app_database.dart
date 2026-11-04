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

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [TaskEntries, FocusSessionEntries, UserSettingsEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 3;

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
