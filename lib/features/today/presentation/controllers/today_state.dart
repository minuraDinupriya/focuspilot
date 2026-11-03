import 'package:equatable/equatable.dart';

enum TodayStatus { initial, loading, loaded, error }

class TodayState extends Equatable {
  const TodayState({
    this.status = TodayStatus.initial,
    this.focusMinutesToday = 0,
    this.dailyGoalMinutes = 120,
    this.completedSessionsToday = 0,
    this.completedTasksToday = 0,
    this.errorMessage,
  });

  final TodayStatus status;
  final int focusMinutesToday;
  final int dailyGoalMinutes;
  final int completedSessionsToday;
  final int completedTasksToday;
  final String? errorMessage;

  double get goalProgress {
    if (dailyGoalMinutes <= 0) return 0.0;
    final progress = focusMinutesToday / dailyGoalMinutes;
    return progress.clamp(0.0, 1.0);
  }

  TodayState copyWith({
    TodayStatus? status,
    int? focusMinutesToday,
    int? dailyGoalMinutes,
    int? completedSessionsToday,
    int? completedTasksToday,
    String? errorMessage,
  }) {
    return TodayState(
      status: status ?? this.status,
      focusMinutesToday: focusMinutesToday ?? this.focusMinutesToday,
      dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
      completedSessionsToday:
          completedSessionsToday ?? this.completedSessionsToday,
      completedTasksToday: completedTasksToday ?? this.completedTasksToday,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    focusMinutesToday,
    dailyGoalMinutes,
    completedSessionsToday,
    completedTasksToday,
    errorMessage,
  ];
}

