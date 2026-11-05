import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focuspilot/features/settings/domain/models/app_theme_mode.dart';
import 'package:focuspilot/features/settings/domain/models/timer_preset.dart';
import 'package:focuspilot/features/settings/domain/models/user_settings.dart';
import 'package:focuspilot/features/settings/domain/repositories/settings_repository.dart';

enum SettingsStatus { initial, loading, loaded, error }

class SettingsState extends Equatable {
  const SettingsState({
    this.status = SettingsStatus.initial,
    this.settings = const UserSettings(),
    this.presets = const [],
    this.errorMessage,
  });

  final SettingsStatus status;
  final UserSettings settings;
  final List<TimerPreset> presets;
  final String? errorMessage;

  TimerPreset? get activePreset {
    try {
      return presets.firstWhere((p) => p.id == settings.activePresetId);
    } catch (_) {
      return null;
    }
  }

  SettingsState copyWith({
    SettingsStatus? status,
    UserSettings? settings,
    List<TimerPreset>? presets,
    String? errorMessage,
  }) {
    return SettingsState(
      status: status ?? this.status,
      settings: settings ?? this.settings,
      presets: presets ?? this.presets,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, settings, presets, errorMessage];
}

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._settingsRepository) : super(const SettingsState()) {
    _init();
  }

  final SettingsRepository _settingsRepository;
  StreamSubscription<UserSettings>? _settingsSubscription;
  StreamSubscription<List<TimerPreset>>? _presetsSubscription;

  void _init() {
    emit(state.copyWith(status: SettingsStatus.loading));

    _settingsSubscription = _settingsRepository.watchSettings().listen(
      (settings) {
        if (!isClosed) {
          emit(
            state.copyWith(status: SettingsStatus.loaded, settings: settings),
          );
        }
      },
      onError: (e) {
        if (!isClosed) {
          emit(
            state.copyWith(
              status: SettingsStatus.error,
              errorMessage: e.toString(),
            ),
          );
        }
      },
    );

    _presetsSubscription = _settingsRepository.watchPresets().listen(
      (presets) {
        if (!isClosed) {
          emit(state.copyWith(status: SettingsStatus.loaded, presets: presets));
        }
      },
      onError: (e) {
        if (!isClosed) {
          emit(
            state.copyWith(
              status: SettingsStatus.error,
              errorMessage: e.toString(),
            ),
          );
        }
      },
    );
  }

  Future<void> updateSettings(UserSettings settings) async {
    try {
      emit(state.copyWith(status: SettingsStatus.loaded, settings: settings));
      await _settingsRepository.saveSettings(settings);
    } catch (e) {
      if (!isClosed) {
        emit(
          state.copyWith(
            status: SettingsStatus.error,
            errorMessage: e.toString(),
          ),
        );
      }
    }
  }

  Future<void> updateThemeMode(AppThemeMode themeMode) async {
    final updated = state.settings.copyWith(themeMode: themeMode);
    await updateSettings(updated);
  }

  Future<void> selectPreset(TimerPreset preset) async {
    final updatedSettings = state.settings.copyWith(
      activePresetId: preset.id,
      workDurationMinutes: preset.workDurationMinutes,
      shortBreakDurationMinutes: preset.shortBreakDurationMinutes,
      longBreakDurationMinutes: preset.longBreakDurationMinutes,
    );
    await updateSettings(updatedSettings);
  }

  Future<void> createPreset({
    required String name,
    required int workDurationMinutes,
    required int shortBreakDurationMinutes,
    required int longBreakDurationMinutes,
    int longBreakInterval = 4,
  }) async {
    try {
      final preset = TimerPreset.create(
        name: name,
        workDurationMinutes: workDurationMinutes,
        shortBreakDurationMinutes: shortBreakDurationMinutes,
        longBreakDurationMinutes: longBreakDurationMinutes,
        longBreakInterval: longBreakInterval,
      );
      await _settingsRepository.savePreset(preset);
      await selectPreset(preset);
    } catch (e) {
      if (!isClosed) {
        emit(
          state.copyWith(
            status: SettingsStatus.error,
            errorMessage: e.toString(),
          ),
        );
      }
    }
  }

  Future<void> deletePreset(String id) async {
    try {
      await _settingsRepository.deletePreset(id);
    } catch (e) {
      if (!isClosed) {
        emit(
          state.copyWith(
            status: SettingsStatus.error,
            errorMessage: e.toString(),
          ),
        );
      }
    }
  }

  @override
  Future<void> close() {
    _settingsSubscription?.cancel();
    _presetsSubscription?.cancel();
    return super.close();
  }
}
