import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focuspilot/features/settings/domain/models/user_settings.dart';
import 'package:focuspilot/features/settings/domain/repositories/settings_repository.dart';

enum SettingsStatus { initial, loading, loaded, error }

class SettingsState extends Equatable {
  const SettingsState({
    this.status = SettingsStatus.initial,
    this.settings = const UserSettings(),
    this.errorMessage,
  });

  final SettingsStatus status;
  final UserSettings settings;
  final String? errorMessage;

  SettingsState copyWith({
    SettingsStatus? status,
    UserSettings? settings,
    String? errorMessage,
  }) {
    return SettingsState(
      status: status ?? this.status,
      settings: settings ?? this.settings,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, settings, errorMessage];
}

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._settingsRepository) : super(const SettingsState()) {
    _init();
  }

  final SettingsRepository _settingsRepository;
  StreamSubscription<UserSettings>? _subscription;

  void _init() {
    emit(state.copyWith(status: SettingsStatus.loading));
    _subscription = _settingsRepository.watchSettings().listen(
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
  }

  Future<void> updateSettings(UserSettings settings) async {
    try {
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

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
