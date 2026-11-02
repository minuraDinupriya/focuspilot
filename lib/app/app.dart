import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focuspilot/app/app_shell.dart';
import 'package:focuspilot/features/focus/data/repositories/focus_session_repository_impl.dart';
import 'package:focuspilot/features/focus/domain/models/ticker.dart';
import 'package:focuspilot/features/focus/domain/repositories/focus_session_repository.dart';
import 'package:focuspilot/features/focus/presentation/controllers/focus_bloc.dart';
import 'package:focuspilot/features/tasks/data/datasources/database/app_database.dart';
import 'package:focuspilot/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:focuspilot/features/tasks/domain/repositories/task_repository.dart';
import 'package:focuspilot/features/tasks/presentation/controllers/tasks_cubit.dart';

class FocusPilotApp extends StatefulWidget {
  const FocusPilotApp({
    super.key,
    this.taskRepository,
    this.focusSessionRepository,
  });

  final TaskRepository? taskRepository;
  final FocusSessionRepository? focusSessionRepository;

  @override
  State<FocusPilotApp> createState() => _FocusPilotAppState();
}

class _FocusPilotAppState extends State<FocusPilotApp> {
  late final AppDatabase _database;
  late final TaskRepository _taskRepository;
  late final FocusSessionRepository _focusSessionRepository;

  @override
  void initState() {
    super.initState();
    if (widget.taskRepository != null &&
        widget.focusSessionRepository != null) {
      _taskRepository = widget.taskRepository!;
      _focusSessionRepository = widget.focusSessionRepository!;
    } else {
      _database = AppDatabase();
      _taskRepository = widget.taskRepository ?? TaskRepositoryImpl(_database);
      _focusSessionRepository =
          widget.focusSessionRepository ??
          FocusSessionRepositoryImpl(_database);
    }
  }

  @override
  void dispose() {
    if (widget.taskRepository == null &&
        widget.focusSessionRepository == null) {
      _database.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<TaskRepository>.value(value: _taskRepository),
        RepositoryProvider<FocusSessionRepository>.value(
          value: _focusSessionRepository,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<TasksCubit>(
            create: (context) => TasksCubit(_taskRepository),
          ),
          BlocProvider<FocusBloc>(
            create: (context) => FocusBloc(
              ticker: const Ticker(),
              sessionRepository: _focusSessionRepository,
            ),
          ),
        ],
        child: MaterialApp(
          title: 'FocusPilot',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          ),
          home: const AppShell(),
        ),
      ),
    );
  }
}
