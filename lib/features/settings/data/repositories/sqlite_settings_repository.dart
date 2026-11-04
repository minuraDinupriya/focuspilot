import 'package:drift/drift.dart';
import 'package:focuspilot/features/settings/domain/models/user_settings.dart';
import 'package:focuspilot/features/settings/domain/repositories/settings_repository.dart';
import 'package:focuspilot/features/tasks/data/datasources/database/app_database.dart';

class SqliteSettingsRepository implements SettingsRepository {
  SqliteSettingsRepository(this._database);

  final AppDatabase _database;
  static const String _settingsId = 'default_settings';

  @override
  Stream<UserSettings> watchSettings() {
    final query = _database.select(_database.userSettingsEntries)
      ..where((tbl) => tbl.id.equals(_settingsId));

    return query.watchSingleOrNull().map((entry) {
      if (entry == null) {
        return const UserSettings();
      }
      return _toDomain(entry);
    });
  }

  @override
  Future<UserSettings> getSettings() async {
    final query = _database.select(_database.userSettingsEntries)
      ..where((tbl) => tbl.id.equals(_settingsId));
    final entry = await query.getSingleOrNull();
    if (entry == null) {
      return const UserSettings();
    }
    return _toDomain(entry);
  }

  @override
  Future<void> saveSettings(UserSettings settings) async {
    await _database
        .into(_database.userSettingsEntries)
        .insertOnConflictUpdate(
          UserSettingsEntriesCompanion.insert(
            id: _settingsId,
            workDurationMinutes: Value(settings.workDurationMinutes),
            shortBreakDurationMinutes: Value(
              settings.shortBreakDurationMinutes,
            ),
            longBreakDurationMinutes: Value(settings.longBreakDurationMinutes),
            dailyGoalMinutes: Value(settings.dailyGoalMinutes),
          ),
        );
  }

  UserSettings _toDomain(UserSettingsEntry entry) {
    return UserSettings(
      workDurationMinutes: entry.workDurationMinutes,
      shortBreakDurationMinutes: entry.shortBreakDurationMinutes,
      longBreakDurationMinutes: entry.longBreakDurationMinutes,
      dailyGoalMinutes: entry.dailyGoalMinutes,
    );
  }
}
