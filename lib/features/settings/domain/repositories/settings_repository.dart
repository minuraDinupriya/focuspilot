import 'package:focuspilot/features/settings/domain/models/user_settings.dart';

abstract class SettingsRepository {
  Stream<UserSettings> watchSettings();
  Future<UserSettings> getSettings();
  Future<void> saveSettings(UserSettings settings);
}
