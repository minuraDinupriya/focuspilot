import 'package:flutter/material.dart';

class DesktopSidebar extends StatelessWidget {
  const DesktopSidebar({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      extended: true,
      minExtendedWidth: 176,
      scrollable: true,
      selectedIndex: selectedIndex,
      onDestinationSelected: onSelected,
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.today_outlined),
          selectedIcon: Icon(Icons.today),
          label: Text('Dashboard'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.task_alt_outlined),
          selectedIcon: Icon(Icons.task_alt),
          label: Text('Tasks'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.timer_outlined),
          selectedIcon: Icon(Icons.timer),
          label: Text('Focus'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.calendar_month_outlined),
          selectedIcon: Icon(Icons.calendar_month),
          label: Text('Planner'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: Text('Settings'),
        ),
      ],
    );
  }
}
