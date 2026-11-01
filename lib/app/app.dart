import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focuspilot/app/app_shell.dart';
import 'package:focuspilot/features/tasks/data/datasources/database/app_database.dart';
import 'package:focuspilot/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:focuspilot/features/tasks/domain/repositories/task_repository.dart';
import 'package:focuspilot/features/tasks/presentation/controllers/tasks_cubit.dart';

class FocusPilotApp extends StatefulWidget {
  const FocusPilotApp({super.key, this.taskRepository});

  final TaskRepository? taskRepository;

  @override
  State<FocusPilotApp> createState() => _FocusPilotAppState();
}

class _FocusPilotAppState extends State<FocusPilotApp> {
  late final AppDatabase _database;
  late final TaskRepository _taskRepository;

  @override
  void initState() {
    super.initState();
    if (widget.taskRepository != null) {
      _taskRepository = widget.taskRepository!;
    } else {
      _database = AppDatabase();
      _taskRepository = TaskRepositoryImpl(_database);
    }
  }

  @override
  void dispose() {
    if (widget.taskRepository == null) {
      _database.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<TaskRepository>.value(value: _taskRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<TasksCubit>(
            create: (context) => TasksCubit(_taskRepository),
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
