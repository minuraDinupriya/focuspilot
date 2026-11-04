import 'dart:async';

import 'package:focuspilot/features/settings/domain/models/user_settings.dart';
import 'package:focuspilot/features/settings/domain/repositories/settings_repository.dart';

class InMemorySettingsRepository implements SettingsRepository {
  InMemorySettingsRepository([UserSettings? initialSettings])
    : _current = initialSettings ?? const UserSettings() {
    _controller = StreamController<UserSettings>.broadcast();
  }

  UserSettings _current;
  late final StreamController<UserSettings> _controller;

  @override
  Stream<UserSettings> watchSettings() {
    scheduleMicrotask(() => _controller.add(_current));
    return _controller.stream;
  }

  @override
  Future<UserSettings> getSettings() async => _current;

  @override
  Future<void> saveSettings(UserSettings settings) async {
    _current = settings;
    _controller.add(_current);
  }

  void dispose() {
    _controller.close();
  }
}
