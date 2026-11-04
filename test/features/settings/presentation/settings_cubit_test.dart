import 'package:flutter_test/flutter_test.dart';
import 'package:focuspilot/features/settings/data/repositories/in_memory_settings_repository.dart';
import 'package:focuspilot/features/settings/domain/models/user_settings.dart';
import 'package:focuspilot/features/settings/presentation/controllers/settings_cubit.dart';

void main() {
  group('SettingsCubit', () {
    late InMemorySettingsRepository repository;
    late SettingsCubit cubit;

    setUp(() {
      repository = InMemorySettingsRepository();
      cubit = SettingsCubit(repository);
    });

    tearDown(() {
      cubit.close();
      repository.dispose();
    });

    test('initial state has default settings', () async {
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.status, SettingsStatus.loaded);
      expect(cubit.state.settings.workDurationMinutes, 25);
      expect(cubit.state.settings.shortBreakDurationMinutes, 5);
      expect(cubit.state.settings.dailyGoalMinutes, 120);
    });

    test('updateSettings emits new state when saved', () async {
      await Future<void>.delayed(Duration.zero);

      const newSettings = UserSettings(
        workDurationMinutes: 50,
        shortBreakDurationMinutes: 10,
        longBreakDurationMinutes: 20,
        dailyGoalMinutes: 180,
      );

      await cubit.updateSettings(newSettings);
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.settings.workDurationMinutes, 50);
      expect(cubit.state.settings.shortBreakDurationMinutes, 10);
      expect(cubit.state.settings.dailyGoalMinutes, 180);
    });
  });
}
