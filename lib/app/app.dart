import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focuspilot/app/app_shell.dart';
import 'package:focuspilot/app/desktop/desktop_integration.dart';
import 'package:focuspilot/app/theme/app_theme.dart';
import 'package:focuspilot/features/focus/data/repositories/focus_session_repository_impl.dart';
import 'package:focuspilot/features/focus/data/repositories/in_memory_distraction_notes_repository.dart';
import 'package:focuspilot/features/focus/data/repositories/sqlite_distraction_notes_repository.dart';
import 'package:focuspilot/features/focus/domain/models/focus_mode.dart';
import 'package:focuspilot/features/focus/domain/models/ticker.dart';
import 'package:focuspilot/features/focus/domain/repositories/distraction_notes_repository.dart';
import 'package:focuspilot/features/focus/domain/repositories/focus_session_repository.dart';
import 'package:focuspilot/features/focus/presentation/controllers/focus_bloc.dart';
import 'package:focuspilot/features/settings/data/repositories/in_memory_settings_repository.dart';
import 'package:focuspilot/features/settings/data/repositories/sqlite_settings_repository.dart';
import 'package:focuspilot/features/settings/domain/repositories/settings_repository.dart';
import 'package:focuspilot/features/settings/presentation/controllers/settings_cubit.dart';
import 'package:focuspilot/features/tasks/data/datasources/database/app_database.dart';
import 'package:focuspilot/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:focuspilot/features/tasks/domain/repositories/task_repository.dart';
import 'package:focuspilot/features/tasks/presentation/controllers/tasks_cubit.dart';
import 'package:focuspilot/features/today/presentation/controllers/today_cubit.dart';

class FocusPilotApp extends StatefulWidget {
  const FocusPilotApp({
    super.key,
    this.taskRepository,
    this.focusSessionRepository,
    this.settingsRepository,
  });

  final TaskRepository? taskRepository;
  final FocusSessionRepository? focusSessionRepository;
  final SettingsRepository? settingsRepository;

  @override
  State<FocusPilotApp> createState() => _FocusPilotAppState();
}

class _FocusPilotAppState extends State<FocusPilotApp> {
  static const _desktop = DesktopIntegration();
  late final AppDatabase _database;
  late final DistractionNotesRepository _notesRepository;
  late final TaskRepository _taskRepository;
  late final FocusSessionRepository _focusSessionRepository;
  late final SettingsRepository _settingsRepository;

  @override
  void initState() {
    super.initState();

    if (widget.taskRepository != null &&
        widget.focusSessionRepository != null) {
      _taskRepository = widget.taskRepository!;
      _focusSessionRepository = widget.focusSessionRepository!;
      _notesRepository = InMemoryDistractionNotesRepository();
      _settingsRepository =
          widget.settingsRepository ?? InMemorySettingsRepository();
    } else {
      _database = AppDatabase();
      _notesRepository = SqliteDistractionNotesRepository(_database);
      _taskRepository = widget.taskRepository ?? TaskRepositoryImpl(_database);
      _focusSessionRepository =
          widget.focusSessionRepository ??
          FocusSessionRepositoryImpl(
            _database,
            taskRepository: _taskRepository,
          );
      _settingsRepository =
          widget.settingsRepository ?? SqliteSettingsRepository(_database);
    }
  }

  @override
  void dispose() {
    if (widget.taskRepository == null ||
        widget.focusSessionRepository == null) {
      _database.close();
    }
    super.dispose();
  }

  Future<void> _notifyIntervalEnded(FocusMode mode) async {
    final work = mode == FocusMode.work;
    try {
      await _desktop.showIntervalEnded(
        title: work ? 'Focus target reached' : 'Break finished',
        body: work
            ? 'Finish when you’re ready to save your Flow Time.'
            : 'Your next focus session is ready.',
      );
    } on PlatformException {
      // Notification delivery is best effort, independently of session storage.
    } on MissingPluginException {
      // The timer can also run in an embedded Flutter view.
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<DistractionNotesRepository>.value(
          value: _notesRepository,
        ),
        RepositoryProvider<TaskRepository>.value(value: _taskRepository),
        RepositoryProvider<FocusSessionRepository>.value(
          value: _focusSessionRepository,
        ),
        RepositoryProvider<SettingsRepository>.value(
          value: _settingsRepository,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<SettingsCubit>(
            create: (context) => SettingsCubit(_settingsRepository),
          ),
          BlocProvider<TodayCubit>(
            create: (context) => TodayCubit(
              sessionRepository: _focusSessionRepository,
              taskRepository: _taskRepository,
              settingsRepository: _settingsRepository,
            ),
          ),
          BlocProvider<TasksCubit>(
            create: (context) => TasksCubit(_taskRepository),
          ),
          BlocProvider<FocusBloc>(
            create: (context) {
              final clock = _desktop.isSupported
                  ? (Stopwatch()..start())
                  : null;
              return FocusBloc(
                ticker: const Ticker(),
                sessionRepository: _focusSessionRepository,
                settingsRepository: _settingsRepository,
                taskRepository: _taskRepository,
                elapsedTime: clock == null ? null : () => clock.elapsed,
                onIntervalEnded: _desktop.isSupported
                    ? (mode) => unawaited(_notifyIntervalEnded(mode))
                    : null,
              );
            },
          ),
        ],
        child: BlocBuilder<SettingsCubit, SettingsState>(
          buildWhen: (prev, curr) =>
              prev.settings.themeMode != curr.settings.themeMode,
          builder: (context, state) {
            return MaterialApp(
              title: 'FocusPilot',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: state.settings.themeMode.toFlutterThemeMode(),
              home: const AppShell(),
            );
          },
        ),
      ),
    );
  }
}
