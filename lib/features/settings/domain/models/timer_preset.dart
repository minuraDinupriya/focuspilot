import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

class TimerPreset extends Equatable {
  const TimerPreset({
    required this.id,
    required this.name,
    required this.workDurationMinutes,
    required this.shortBreakDurationMinutes,
    required this.longBreakDurationMinutes,
    this.longBreakInterval = 4,
    this.isDefault = false,
  });

  final String id;
  final String name;
  final int workDurationMinutes;
  final int shortBreakDurationMinutes;
  final int longBreakDurationMinutes;
  final int longBreakInterval;
  final bool isDefault;

  int get workDurationSeconds => workDurationMinutes * 60;
  int get shortBreakDurationSeconds => shortBreakDurationMinutes * 60;
  int get longBreakDurationSeconds => longBreakDurationMinutes * 60;

  factory TimerPreset.create({
    required String name,
    required int workDurationMinutes,
    required int shortBreakDurationMinutes,
    required int longBreakDurationMinutes,
    int longBreakInterval = 4,
    bool isDefault = false,
  }) {
    return TimerPreset(
      id: const Uuid().v4(),
      name: name.trim(),
      workDurationMinutes: workDurationMinutes,
      shortBreakDurationMinutes: shortBreakDurationMinutes,
      longBreakDurationMinutes: longBreakDurationMinutes,
      longBreakInterval: longBreakInterval,
      isDefault: isDefault,
    );
  }

  static const TimerPreset classic = TimerPreset(
    id: 'preset-classic',
    name: 'Classic Pomodoro',
    workDurationMinutes: 25,
    shortBreakDurationMinutes: 5,
    longBreakDurationMinutes: 15,
    longBreakInterval: 4,
    isDefault: true,
  );

  static const TimerPreset deepWork = TimerPreset(
    id: 'preset-deep-work',
    name: 'Deep Work',
    workDurationMinutes: 50,
    shortBreakDurationMinutes: 10,
    longBreakDurationMinutes: 30,
    longBreakInterval: 2,
    isDefault: true,
  );

  static const TimerPreset quickSprint = TimerPreset(
    id: 'preset-quick-sprint',
    name: 'Quick Sprint',
    workDurationMinutes: 15,
    shortBreakDurationMinutes: 3,
    longBreakDurationMinutes: 10,
    longBreakInterval: 4,
    isDefault: true,
  );

  static List<TimerPreset> get defaultPresets => [
    classic,
    deepWork,
    quickSprint,
  ];

  TimerPreset copyWith({
    String? id,
    String? name,
    int? workDurationMinutes,
    int? shortBreakDurationMinutes,
    int? longBreakDurationMinutes,
    int? longBreakInterval,
    bool? isDefault,
  }) {
    return TimerPreset(
      id: id ?? this.id,
      name: name ?? this.name,
      workDurationMinutes: workDurationMinutes ?? this.workDurationMinutes,
      shortBreakDurationMinutes:
          shortBreakDurationMinutes ?? this.shortBreakDurationMinutes,
      longBreakDurationMinutes:
          longBreakDurationMinutes ?? this.longBreakDurationMinutes,
      longBreakInterval: longBreakInterval ?? this.longBreakInterval,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    workDurationMinutes,
    shortBreakDurationMinutes,
    longBreakDurationMinutes,
    longBreakInterval,
    isDefault,
  ];
}
