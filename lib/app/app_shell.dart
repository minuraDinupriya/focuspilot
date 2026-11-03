import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focuspilot/features/focus/presentation/controllers/focus_bloc.dart';
import 'package:focuspilot/features/focus/presentation/controllers/focus_event.dart';
import 'package:focuspilot/features/focus/presentation/focus_screen.dart';
import 'package:focuspilot/features/tasks/domain/models/task.dart';
import 'package:focuspilot/features/tasks/presentation/tasks_screen.dart';
import 'package:focuspilot/features/today/presentation/today_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _navigateToFocus() {
    setState(() {
      _selectedIndex = 2; // Index of Focus tab
    });
  }

  void _onFocusTask(Task task) {
    // 1. Link the task directly into the FocusBloc
    context.read<FocusBloc>().add(FocusTaskLinked(task: task));

    // 2. Switch tab to Focus
    _navigateToFocus();
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      TodayScreen(
        onNavigateToFocus: _navigateToFocus,
        onFocusTask: _onFocusTask,
      ),
      const TasksScreen(),
      const FocusScreen(),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('FocusPilot')),
      body: screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.today_outlined),
            selectedIcon: Icon(Icons.today),
            label: 'Today',
          ),
          NavigationDestination(
            icon: Icon(Icons.task_alt_outlined),
            selectedIcon: Icon(Icons.task_alt),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: Icon(Icons.timer_outlined),
            selectedIcon: Icon(Icons.timer),
            label: 'Focus',
          ),
        ],
      ),
    );
  }
}
