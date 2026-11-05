import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:focuspilot/features/settings/data/repositories/sqlite_settings_repository.dart';
import 'package:focuspilot/features/settings/domain/models/timer_preset.dart';
import 'package:focuspilot/features/settings/domain/models/user_settings.dart';
import 'package:focuspilot/features/tasks/data/datasources/database/app_database.dart';

void main() {
  late AppDatabase database;
  late SqliteSettingsRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = SqliteSettingsRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  group('SqliteSettingsRepository', () {
    test('getSettings returns default UserSettings when empty', () async {
      final settings = await repository.getSettings();

      expect(settings, equals(const UserSettings()));
      expect(settings.workDurationMinutes, 25);
      expect(settings.shortBreakDurationMinutes, 5);
      expect(settings.longBreakDurationMinutes, 15);
      expect(settings.dailyGoalMinutes, 120);
      expect(settings.weeklyGoalMinutes, 600);
    });

    test('saveSettings persists and retrieves updated settings', () async {
      const customSettings = UserSettings(
        workDurationMinutes: 50,
        shortBreakDurationMinutes: 10,
        longBreakDurationMinutes: 20,
        dailyGoalMinutes: 180,
        weeklyGoalMinutes: 900,
      );

      await repository.saveSettings(customSettings);

      final retrieved = await repository.getSettings();
      expect(retrieved, equals(customSettings));
      expect(retrieved.workDurationMinutes, 50);
      expect(retrieved.shortBreakDurationMinutes, 10);
      expect(retrieved.longBreakDurationMinutes, 20);
      expect(retrieved.dailyGoalMinutes, 180);
      expect(retrieved.weeklyGoalMinutes, 900);
    });

    test(
      'watchSettings emits initial and updated settings on change',
      () async {
        final stream = repository.watchSettings();

        const initialSettings = UserSettings();
        const updatedSettings = UserSettings(
          workDurationMinutes: 45,
          shortBreakDurationMinutes: 15,
          longBreakDurationMinutes: 30,
          dailyGoalMinutes: 240,
        );

        final expectation = expectLater(
          stream,
          emitsInOrder([initialSettings, updatedSettings]),
        );

        await pumpEventQueue();

        await repository.saveSettings(updatedSettings);

        await expectation;
      },
    );

    test('getPresets returns default presets on fresh database', () async {
      final presets = await repository.getPresets();

      expect(presets.length, greaterThanOrEqualTo(3));
      expect(presets.any((p) => p.name == 'Classic Pomodoro'), isTrue);
      expect(presets.any((p) => p.name == 'Deep Work'), isTrue);
      expect(presets.any((p) => p.name == 'Quick Sprint'), isTrue);
    });

    test('savePreset persists custom preset', () async {
      final customPreset = TimerPreset.create(
        name: 'Coding Sprint',
        workDurationMinutes: 40,
        shortBreakDurationMinutes: 8,
        longBreakDurationMinutes: 20,
      );

      await repository.savePreset(customPreset);

      final presets = await repository.getPresets();
      expect(presets.any((p) => p.name == 'Coding Sprint'), isTrue);
    });
  });
}
