import 'package:drift/drift.dart';
import 'package:focuspilot/features/settings/domain/models/timer_preset.dart';
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
            weeklyGoalMinutes: Value(settings.weeklyGoalMinutes),
            activePresetId: Value(settings.activePresetId),
            autoStartNextSession: Value(settings.autoStartNextSession),
            soundEnabled: Value(settings.soundEnabled),
            hapticEnabled: Value(settings.hapticEnabled),
          ),
        );
  }

  @override
  Stream<List<TimerPreset>> watchPresets() {
    _ensureDefaultPresetsSeeded();
    final query = _database.select(_database.timerPresetEntries)
      ..orderBy([
        (tbl) => OrderingTerm.desc(tbl.isDefault),
        (tbl) => OrderingTerm.asc(tbl.name),
      ]);

    return query.watch().map((rows) => rows.map(_presetToDomain).toList());
  }

  @override
  Future<List<TimerPreset>> getPresets() async {
    await _ensureDefaultPresetsSeeded();
    final query = _database.select(_database.timerPresetEntries)
      ..orderBy([
        (tbl) => OrderingTerm.desc(tbl.isDefault),
        (tbl) => OrderingTerm.asc(tbl.name),
      ]);

    final rows = await query.get();
    return rows.map(_presetToDomain).toList();
  }

  @override
  Future<void> savePreset(TimerPreset preset) async {
    await _database
        .into(_database.timerPresetEntries)
        .insertOnConflictUpdate(
          TimerPresetEntriesCompanion.insert(
            id: preset.id,
            name: preset.name,
            workDurationMinutes: preset.workDurationMinutes,
            shortBreakDurationMinutes: preset.shortBreakDurationMinutes,
            longBreakDurationMinutes: preset.longBreakDurationMinutes,
            longBreakInterval: Value(preset.longBreakInterval),
            isDefault: Value(preset.isDefault),
          ),
        );
  }

  @override
  Future<void> deletePreset(String id) async {
    final query = _database.delete(_database.timerPresetEntries)
      ..where((tbl) => tbl.id.equals(id) & tbl.isDefault.equals(false));
    await query.go();
  }

  Future<void> _ensureDefaultPresetsSeeded() async {
    final countQuery = _database.selectOnly(_database.timerPresetEntries)
      ..addColumns([_database.timerPresetEntries.id.count()]);
    final count = await countQuery
        .map((row) => row.read<int>(_database.timerPresetEntries.id.count()))
        .getSingle();

    if (count == null || count == 0) {
      for (final preset in TimerPreset.defaultPresets) {
        await savePreset(preset);
      }
    }
  }

  UserSettings _toDomain(UserSettingsEntry entry) {
    return UserSettings(
      workDurationMinutes: entry.workDurationMinutes,
      shortBreakDurationMinutes: entry.shortBreakDurationMinutes,
      longBreakDurationMinutes: entry.longBreakDurationMinutes,
      dailyGoalMinutes: entry.dailyGoalMinutes,
      weeklyGoalMinutes: entry.weeklyGoalMinutes,
      activePresetId: entry.activePresetId,
      autoStartNextSession: entry.autoStartNextSession,
      soundEnabled: entry.soundEnabled,
      hapticEnabled: entry.hapticEnabled,
    );
  }

  TimerPreset _presetToDomain(TimerPresetEntry entry) {
    return TimerPreset(
      id: entry.id,
      name: entry.name,
      workDurationMinutes: entry.workDurationMinutes,
      shortBreakDurationMinutes: entry.shortBreakDurationMinutes,
      longBreakDurationMinutes: entry.longBreakDurationMinutes,
      longBreakInterval: entry.longBreakInterval,
      isDefault: entry.isDefault,
    );
  }
}
