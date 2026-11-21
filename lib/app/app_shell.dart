import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focuspilot/app/widgets/page_content.dart';
import 'package:focuspilot/features/focus/presentation/controllers/focus_bloc.dart';
import 'package:focuspilot/features/focus/presentation/controllers/focus_event.dart';
import 'package:focuspilot/features/focus/presentation/focus_screen.dart';
import 'package:focuspilot/features/focus/presentation/mini_timer_window.dart';
import 'package:focuspilot/features/focus/presentation/widgets/mini_timer_view.dart';
import 'package:focuspilot/features/settings/presentation/widgets/settings_sheet.dart';
import 'package:focuspilot/features/tasks/domain/models/task.dart';
import 'package:focuspilot/features/tasks/presentation/planner_screen.dart';
import 'package:focuspilot/features/tasks/presentation/tasks_screen.dart';
import 'package:focuspilot/features/today/presentation/today_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with WidgetsBindingObserver {
  static const _focusIndex = 2;
  static const _miniTimerWindow = MiniTimerWindow();
  int _selectedIndex = 0;
  bool _miniTimerEnabled = false;
  bool _changingWindow = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<FocusBloc>().add(const FocusAppForegrounded());
    }
  }

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _navigateToFocus() {
    setState(() {
      _selectedIndex = _focusIndex;
    });
  }

  void _onFocusTask(Task task) {
    final bloc = context.read<FocusBloc>();
    if (!bloc.state.isOvertime && !bloc.state.isSaving) {
      bloc.add(FocusTaskLinked(task: task));
    }
    _navigateToFocus();
  }

  Future<void> _setMiniTimerEnabled(bool enabled) async {
    if (_changingWindow || _miniTimerEnabled == enabled) return;

    _changingWindow = true;
    try {
      await _miniTimerWindow.setEnabled(enabled);
      if (!mounted) return;
      setState(() {
        _miniTimerEnabled = enabled;
        if (enabled) _selectedIndex = _focusIndex;
      });
    } on PlatformException {
      _showWindowError(enabled);
    } on MissingPluginException {
      _showWindowError(enabled);
    } finally {
      _changingWindow = false;
    }
  }

  void _showWindowError(bool enabling) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          enabling
              ? 'Couldn’t open the mini timer.'
              : 'Couldn’t restore the main window.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sessionActive = context.select(
      (FocusBloc bloc) => bloc.state.isSessionActive,
    );
    final isFocusTab = _selectedIndex == _focusIndex;
    final hideNavigation = isFocusTab && (sessionActive || _miniTimerEnabled);
    final canOpenMiniTimer = isFocusTab && _miniTimerWindow.isSupported;
    final screens = [
      TodayScreen(
        onNavigateToFocus: _navigateToFocus,
        onFocusTask: _onFocusTask,
      ),
      const TasksScreen(),
      FocusScreen(
        isMiniTimer: _miniTimerEnabled,
        onOpenMiniTimer: canOpenMiniTimer && sessionActive
            ? () => _setMiniTimerEnabled(true)
            : null,
        onRestoreWindow: () => _setMiniTimerEnabled(false),
      ),
      const PlannerScreen(),
    ];

    return Scaffold(
      appBar: hideNavigation
          ? null
          : AppBar(
              title: const Text('FocusPilot'),
              actions: [
                if (canOpenMiniTimer)
                  KeepOnTopButton(onPressed: () => _setMiniTimerEnabled(true)),
                IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  tooltip: 'Settings',
                  onPressed: () => SettingsSheet.show(context),
                ),
              ],
            ),
      body: screens[_selectedIndex],
      bottomNavigationBar: hideNavigation
          ? null
          : ColoredBox(
              color:
                  NavigationBarTheme.of(context).backgroundColor ??
                  Theme.of(context).colorScheme.surface,
              child: PageContent(
                maxWidth: 560,
                child: NavigationBar(
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
                    NavigationDestination(
                      icon: Icon(Icons.calendar_month_outlined),
                      selectedIcon: Icon(Icons.calendar_month),
                      label: 'Planner',
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
