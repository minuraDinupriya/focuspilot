import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focuspilot/app/desktop/desktop_integration.dart';
import 'package:focuspilot/app/widgets/desktop_sidebar.dart';
import 'package:focuspilot/app/widgets/page_content.dart';
import 'package:focuspilot/features/focus/presentation/controllers/focus_bloc.dart';
import 'package:focuspilot/features/focus/presentation/controllers/focus_event.dart';
import 'package:focuspilot/features/focus/presentation/controllers/focus_state.dart';
import 'package:focuspilot/features/focus/presentation/focus_screen.dart';
import 'package:focuspilot/features/focus/presentation/mini_timer_window.dart';
import 'package:focuspilot/features/focus/presentation/widgets/mini_timer_view.dart';
import 'package:focuspilot/features/settings/presentation/controllers/settings_cubit.dart';
import 'package:focuspilot/features/settings/presentation/widgets/settings_sheet.dart';
import 'package:focuspilot/features/tasks/domain/models/task.dart';
import 'package:focuspilot/features/tasks/presentation/planner_screen.dart';
import 'package:focuspilot/features/tasks/presentation/tasks_screen.dart';
import 'package:focuspilot/features/tasks/presentation/widgets/task_detail_sheet.dart';
import 'package:focuspilot/features/today/presentation/today_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with WidgetsBindingObserver {
  static const _focusIndex = 2;
  static const _settingsIndex = 4;
  static const _desktop = DesktopIntegration();
  static const _miniTimerWindow = MiniTimerWindow();
  int _selectedIndex = 0;
  int _tabBeforeSettings = 0;
  bool _miniTimerEnabled = false;
  bool _changingWindow = false;
  bool _showFocusNavigation = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _desktop.setCommandHandler(_onDesktopCommand);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _desktop.setCommandHandler(null);
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
      if (index == _settingsIndex && _selectedIndex != _settingsIndex) {
        _tabBeforeSettings = _selectedIndex;
      }
      _selectedIndex = index;
    });
  }

  void _navigateToFocus() {
    _onDestinationSelected(_focusIndex);
  }

  void _quickStartFocus() {
    context.read<FocusBloc>().add(const FocusQuickStarted());
    _navigateToFocus();
  }

  void _onFocusTask(Task task) {
    final bloc = context.read<FocusBloc>();
    if (!bloc.state.isOvertime && !bloc.state.isSaving) {
      bloc.add(FocusTaskLinked(task: task));
    }
    _navigateToFocus();
  }

  void _onDesktopCommand(String command) {
    if (!mounted) return;
    if (command == 'togglePause') {
      _togglePause();
    } else if (command == 'shown') {
      context.read<FocusBloc>().add(const FocusAppForegrounded());
    }
  }

  void _togglePause() {
    final bloc = context.read<FocusBloc>();
    if (bloc.state.isRunning) {
      bloc.add(const FocusPaused());
    } else if (bloc.state.isPaused) {
      bloc.add(const FocusResumed());
    }
  }

  void _onFocusShortcut() {
    final state = context.read<FocusBloc>().state;
    if (state.isSessionActive) {
      _togglePause();
      _navigateToFocus();
    } else {
      _quickStartFocus();
    }
  }

  Future<void> _createTask() async {
    if (_miniTimerEnabled) await _setMiniTimerEnabled(false);
    if (!mounted || _miniTimerEnabled) return;
    await TaskDetailSheet.show(context);
  }

  String _trayStatus(FocusState state) {
    if (!state.isSessionActive) return 'FocusPilot · Ready';
    if (state.isSaving) return 'FocusPilot · Saving';
    final mode = state.isOvertime ? 'Flow Time' : state.mode.displayName;
    if (state.isPaused) return 'FocusPilot · $mode paused';
    final minutes = state.isOvertime
        ? state.overtimeSeconds! ~/ 60
        : (state.durationSeconds + 59) ~/ 60;
    final time = state.isOvertime ? '+${minutes}m' : '${minutes}m left';
    return 'FocusPilot · $mode · $time';
  }

  Future<void> _updateTray(FocusState state) => _desktop.updateTray(
    status: _trayStatus(state),
    isRunning: state.isRunning,
    isPaused: state.isPaused,
  );

  Future<void> _syncTray(FocusState state) async {
    try {
      await _updateTray(state);
    } on PlatformException {
      // Tray updates are optional while the app is visible.
    } on MissingPluginException {
      // A runner without desktop integration still supports the timer.
    }
  }

  Future<void> _hideToTray() async {
    try {
      await _updateTray(context.read<FocusBloc>().state);
      if (mounted) await _desktop.hideToTray();
    } on PlatformException {
      _showError('Couldn’t minimize FocusPilot to the tray.');
    } on MissingPluginException {
      _showError('Couldn’t minimize FocusPilot to the tray.');
    }
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
      _showMiniTimerError(enabled);
    } on MissingPluginException {
      _showMiniTimerError(enabled);
    } finally {
      _changingWindow = false;
    }
  }

  void _showMiniTimerError(bool enabling) => _showError(
    enabling
        ? 'Couldn’t open the mini timer.'
        : 'Couldn’t restore the main window.',
  );

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final sessionActive = context.select(
      (FocusBloc bloc) => bloc.state.isSessionActive,
    );
    final isFocusTab = _selectedIndex == _focusIndex;
    final hideNavigation =
        isFocusTab &&
        (_miniTimerEnabled || (sessionActive && !_showFocusNavigation));
    final canOpenMiniTimer = isFocusTab && _miniTimerWindow.isSupported;
    final desktop = _desktop.isSupported;
    final showSidebar =
        desktop && MediaQuery.sizeOf(context).width >= 960 && !hideNavigation;
    final isSettings = _selectedIndex == _settingsIndex;
    final workDuration = context.select(
      (SettingsCubit cubit) => cubit.state.settings.workDurationMinutes,
    );
    final screens = [
      TodayScreen(
        onNavigateToFocus: _navigateToFocus,
        onStartFocus: _quickStartFocus,
        onFocusTask: _onFocusTask,
        workDurationMinutes: workDuration,
        sessionActive: sessionActive,
      ),
      const TasksScreen(),
      FocusScreen(
        isMiniTimer: _miniTimerEnabled,
        onOpenMiniTimer: canOpenMiniTimer && hideNavigation
            ? () => _setMiniTimerEnabled(true)
            : null,
        onRestoreWindow: () => _setMiniTimerEnabled(false),
        onHideToTray: desktop && hideNavigation ? _hideToTray : null,
        onToggleNavigation: desktop && sessionActive
            ? () => setState(() => _showFocusNavigation = !_showFocusNavigation)
            : null,
        navigationVisible: _showFocusNavigation,
      ),
      const PlannerScreen(),
      const PageContent(maxWidth: 640, child: SettingsSheet(embedded: true)),
    ];

    final scaffold = Scaffold(
      appBar: hideNavigation
          ? null
          : AppBar(
              title: const Text('FocusPilot'),
              leading: isSettings && !showSidebar
                  ? BackButton(
                      onPressed: () =>
                          _onDestinationSelected(_tabBeforeSettings),
                    )
                  : null,
              actions: [
                if (canOpenMiniTimer)
                  KeepOnTopButton(onPressed: () => _setMiniTimerEnabled(true)),
                if (desktop)
                  IconButton(
                    icon: const Icon(Icons.move_to_inbox_outlined),
                    tooltip: 'Minimize to tray',
                    onPressed: _hideToTray,
                  ),
                if (!showSidebar && !isSettings)
                  IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    tooltip: 'Settings',
                    onPressed: () => SettingsSheet.show(context),
                  ),
              ],
            ),
      body: Row(
        children: [
          if (showSidebar)
            DesktopSidebar(
              selectedIndex: _selectedIndex,
              onSelected: _onDestinationSelected,
            ),
          Expanded(child: screens[_selectedIndex]),
        ],
      ),
      bottomNavigationBar: hideNavigation || showSidebar || isSettings
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
    if (!desktop) return scaffold;

    return BlocListener<FocusBloc, FocusState>(
      listenWhen: (previous, current) =>
          _trayStatus(previous) != _trayStatus(current),
      listener: (context, state) => unawaited(_syncTray(state)),
      child: CallbackShortcuts(
        bindings: {
          const SingleActivator(
            LogicalKeyboardKey.keyN,
            control: true,
            includeRepeats: false,
          ): _createTask,
          const SingleActivator(
            LogicalKeyboardKey.keyF,
            control: true,
            shift: true,
            includeRepeats: false,
          ): _onFocusShortcut,
          const SingleActivator(
            LogicalKeyboardKey.keyM,
            control: true,
            shift: true,
            includeRepeats: false,
          ): () =>
              _setMiniTimerEnabled(!_miniTimerEnabled),
        },
        child: Focus(autofocus: true, child: scaffold),
      ),
    );
  }
}
