import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focuspilot/features/settings/presentation/controllers/settings_cubit.dart';

class SettingsSheet extends StatelessWidget {
  const SettingsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const SettingsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final settings = state.settings;

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            left: 24,
            right: 24,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Focus & Timer Settings',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Work Duration
              _DurationSelector(
                title: 'Focus Duration',
                subtitle: 'Length of work sessions',
                selectedValue: settings.workDurationMinutes,
                options: const [15, 20, 25, 30, 45, 50],
                unit: 'min',
                onSelected: (val) {
                  context.read<SettingsCubit>().updateSettings(
                    settings.copyWith(workDurationMinutes: val),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Short Break Duration
              _DurationSelector(
                title: 'Short Break Duration',
                subtitle: 'Rest time between work sessions',
                selectedValue: settings.shortBreakDurationMinutes,
                options: const [3, 5, 10, 15],
                unit: 'min',
                onSelected: (val) {
                  context.read<SettingsCubit>().updateSettings(
                    settings.copyWith(shortBreakDurationMinutes: val),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Daily Goal
              _DurationSelector(
                title: 'Daily Focus Target',
                subtitle: 'Goal displayed on Today screen',
                selectedValue: settings.dailyGoalMinutes,
                options: const [60, 90, 120, 180, 240],
                unit: 'min',
                onSelected: (val) {
                  context.read<SettingsCubit>().updateSettings(
                    settings.copyWith(dailyGoalMinutes: val),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}

class _DurationSelector extends StatelessWidget {
  const _DurationSelector({
    required this.title,
    required this.subtitle,
    required this.selectedValue,
    required this.options,
    required this.unit,
    required this.onSelected,
  });

  final String title;
  final String subtitle;
  final int selectedValue;
  final List<int> options;
  final String unit;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: options.map((opt) {
            final isSelected = opt == selectedValue;
            return ChoiceChip(
              label: Text('$opt $unit'),
              selected: isSelected,
              onSelected: (_) => onSelected(opt),
            );
          }).toList(),
        ),
      ],
    );
  }
}
