import 'dart:async';

import 'package:focuspilot/features/settings/domain/models/timer_preset.dart';
import 'package:focuspilot/features/settings/domain/models/user_settings.dart';
import 'package:focuspilot/features/settings/domain/repositories/settings_repository.dart';

class InMemorySettingsRepository implements SettingsRepository {
  InMemorySettingsRepository([
    UserSettings? initialSettings,
    List<TimerPreset>? initialPresets,
  ]) : _current = initialSettings ?? const UserSettings(),
       _presets = initialPresets ?? List.of(TimerPreset.defaultPresets) {
    _controller = StreamController<UserSettings>.broadcast();
    _presetsController = StreamController<List<TimerPreset>>.broadcast();
  }

  UserSettings _current;
  final List<TimerPreset> _presets;
  late final StreamController<UserSettings> _controller;
  late final StreamController<List<TimerPreset>> _presetsController;

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

  @override
  Stream<List<TimerPreset>> watchPresets() {
    scheduleMicrotask(
      () => _presetsController.add(List.unmodifiable(_presets)),
    );
    return _presetsController.stream;
  }

  @override
  Future<List<TimerPreset>> getPresets() async => List.unmodifiable(_presets);

  @override
  Future<void> savePreset(TimerPreset preset) async {
    final index = _presets.indexWhere((p) => p.id == preset.id);
    if (index >= 0) {
      _presets[index] = preset;
    } else {
      _presets.add(preset);
    }
    _presetsController.add(List.unmodifiable(_presets));
  }

  @override
  Future<void> deletePreset(String id) async {
    _presets.removeWhere((p) => p.id == id && !p.isDefault);
    _presetsController.add(List.unmodifiable(_presets));
  }

  void dispose() {
    _controller.close();
    _presetsController.close();
  }
}
