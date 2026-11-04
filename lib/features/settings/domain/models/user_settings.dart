import 'package:equatable/equatable.dart';

class UserSettings extends Equatable {
  const UserSettings({
    this.workDurationMinutes = 25,
    this.shortBreakDurationMinutes = 5,
    this.longBreakDurationMinutes = 15,
    this.dailyGoalMinutes = 120,
    this.activePresetId = 'preset-classic',
    this.autoStartNextSession = false,
    this.soundEnabled = true,
    this.hapticEnabled = true,
  });

  final int workDurationMinutes;
  final int shortBreakDurationMinutes;
  final int longBreakDurationMinutes;
  final int dailyGoalMinutes;
  final String? activePresetId;
  final bool autoStartNextSession;
  final bool soundEnabled;
  final bool hapticEnabled;

  int get workDurationSeconds => workDurationMinutes * 60;
  int get shortBreakDurationSeconds => shortBreakDurationMinutes * 60;
  int get longBreakDurationSeconds => longBreakDurationMinutes * 60;

  UserSettings copyWith({
    int? workDurationMinutes,
    int? shortBreakDurationMinutes,
    int? longBreakDurationMinutes,
    int? dailyGoalMinutes,
    String? activePresetId,
    bool clearActivePresetId = false,
    bool? autoStartNextSession,
    bool? soundEnabled,
    bool? hapticEnabled,
  }) {
    return UserSettings(
      workDurationMinutes: workDurationMinutes ?? this.workDurationMinutes,
      shortBreakDurationMinutes:
          shortBreakDurationMinutes ?? this.shortBreakDurationMinutes,
      longBreakDurationMinutes:
          longBreakDurationMinutes ?? this.longBreakDurationMinutes,
      dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
      activePresetId: clearActivePresetId
          ? null
          : (activePresetId ?? this.activePresetId),
      autoStartNextSession: autoStartNextSession ?? this.autoStartNextSession,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticEnabled: hapticEnabled ?? this.hapticEnabled,
    );
  }

  @override
  List<Object?> get props => [
    workDurationMinutes,
    shortBreakDurationMinutes,
    longBreakDurationMinutes,
    dailyGoalMinutes,
    activePresetId,
    autoStartNextSession,
    soundEnabled,
    hapticEnabled,
  ];
}
