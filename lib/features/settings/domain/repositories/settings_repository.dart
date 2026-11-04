import 'package:focuspilot/features/settings/domain/models/timer_preset.dart';
import 'package:focuspilot/features/settings/domain/models/user_settings.dart';

abstract class SettingsRepository {
  Stream<UserSettings> watchSettings();
  Future<UserSettings> getSettings();
  Future<void> saveSettings(UserSettings settings);

  Stream<List<TimerPreset>> watchPresets();
  Future<List<TimerPreset>> getPresets();
  Future<void> savePreset(TimerPreset preset);
  Future<void> deletePreset(String id);
}
