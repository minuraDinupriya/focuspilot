import 'package:equatable/equatable.dart';

class UserSettings extends Equatable {
  const UserSettings({
    this.workDurationMinutes = 25,
    this.shortBreakDurationMinutes = 5,
    this.longBreakDurationMinutes = 15,
    this.dailyGoalMinutes = 120,
    this.activePresetId = 'preset-classic',
  });

  final int workDurationMinutes;
  final int shortBreakDurationMinutes;
  final int longBreakDurationMinutes;
  final int dailyGoalMinutes;
  final String? activePresetId;

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
    );
  }

  @override
  List<Object?> get props => [
    workDurationMinutes,
    shortBreakDurationMinutes,
    longBreakDurationMinutes,
    dailyGoalMinutes,
    activePresetId,
  ];
}
