import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focuspilot/app/widgets/adaptive_segmented_button.dart';
import 'package:focuspilot/features/settings/domain/models/app_theme_mode.dart';
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

  void _showNewPresetDialog(BuildContext context) {
    final nameController = TextEditingController();
    final workController = TextEditingController(text: '30');
    final shortBreakController = TextEditingController(text: '5');
    final longBreakController = TextEditingController(text: '15');

    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Create Timer Preset'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Preset Name',
                  hintText: 'e.g., Code Review, Exam Prep',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: workController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Focus Duration (min)',
                  suffixText: 'min',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: shortBreakController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Short Break (min)',
                  suffixText: 'min',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: longBreakController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Long Break (min)',
                  suffixText: 'min',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final name = nameController.text.trim();
              final work = int.tryParse(workController.text) ?? 25;
              final shortBreak = int.tryParse(shortBreakController.text) ?? 5;
              final longBreak = int.tryParse(longBreakController.text) ?? 15;

              if (name.isNotEmpty) {
                context.read<SettingsCubit>().createPreset(
                  name: name,
                  workDurationMinutes: work.clamp(1, 180),
                  shortBreakDurationMinutes: shortBreak.clamp(1, 60),
                  longBreakDurationMinutes: longBreak.clamp(1, 90),
                );
                Navigator.pop(dialogCtx);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final settings = state.settings;
        final presets = state.presets;

        return SingleChildScrollView(
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
                  Flexible(
                    child: Text(
                      'Focus & Timer Settings',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Timer Presets Section
              Wrap(
                spacing: 12,
                runSpacing: 8,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'Timer Presets',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('New Preset'),
                    onPressed: () => _showNewPresetDialog(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (presets.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: presets.map((preset) {
                    final isSelected = settings.activePresetId == preset.id;
                    return ChoiceChip(
                      label: Text(
                        '${preset.name} (${preset.workDurationMinutes}/${preset.shortBreakDurationMinutes})',
                      ),
                      selected: isSelected,
                      onSelected: (_) {
                        context.read<SettingsCubit>().selectPreset(preset);
                      },
                    );
                  }).toList(),
                ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              // Work / Focus Duration
              _DurationSelector(
                title: 'Focus Duration',
                subtitle: 'Length of work sessions',
                selectedValue: settings.workDurationMinutes,
                options: const [15, 20, 25, 30, 45, 50],
                unit: 'min',
                minVal: 1,
                maxVal: 180,
                onSelected: (val) {
                  context.read<SettingsCubit>().updateSettings(
                    settings.copyWith(
                      workDurationMinutes: val,
                      clearActivePresetId: true,
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Short Break Duration
              _DurationSelector(
                title: 'Short Break Duration',
                subtitle: 'Rest time between work sessions',
                selectedValue: settings.shortBreakDurationMinutes,
                options: const [3, 5, 10, 15],
                unit: 'min',
                minVal: 1,
                maxVal: 60,
                onSelected: (val) {
                  context.read<SettingsCubit>().updateSettings(
                    settings.copyWith(
                      shortBreakDurationMinutes: val,
                      clearActivePresetId: true,
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Long Break Duration
              _DurationSelector(
                title: 'Long Break Duration',
                subtitle: 'Extended rest after focus cycles',
                selectedValue: settings.longBreakDurationMinutes,
                options: const [10, 15, 20, 25, 30],
                unit: 'min',
                minVal: 1,
                maxVal: 90,
                onSelected: (val) {
                  context.read<SettingsCubit>().updateSettings(
                    settings.copyWith(
                      longBreakDurationMinutes: val,
                      clearActivePresetId: true,
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Daily Goal
              _DurationSelector(
                title: 'Daily Focus Target',
                subtitle: 'Goal displayed on Today screen',
                selectedValue: settings.dailyGoalMinutes,
                options: const [60, 90, 120, 180, 240],
                unit: 'min',
                minVal: 15,
                maxVal: 720,
                onSelected: (val) {
                  context.read<SettingsCubit>().updateSettings(
                    settings.copyWith(dailyGoalMinutes: val),
                  );
                },
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),

              Text(
                'Timer Automation & Alerts',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Auto-start Next Session'),
                subtitle: const Text(
                  'Start breaks when you finish focus and restart focus when a break ends.',
                ),
                value: settings.autoStartNextSession,
                onChanged: (val) {
                  context.read<SettingsCubit>().updateSettings(
                    settings.copyWith(autoStartNextSession: val),
                  );
                },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Sound Alerts'),
                subtitle: const Text('Play a sound when a session finishes'),
                value: settings.soundEnabled,
                onChanged: (val) {
                  context.read<SettingsCubit>().updateSettings(
                    settings.copyWith(soundEnabled: val),
                  );
                },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Vibration Feedback'),
                subtitle: const Text('Haptic vibration on session completion'),
                value: settings.hapticEnabled,
                onChanged: (val) {
                  context.read<SettingsCubit>().updateSettings(
                    settings.copyWith(hapticEnabled: val),
                  );
                },
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),

              // Appearance / Theme Section (FOC-36)
              Text(
                'Appearance',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Customize how FocusPilot looks on your device',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: AdaptiveSegmentedButton<AppThemeMode>(
                  buttonKey: const Key('theme_mode_segmented_button'),
                  segments: AppThemeMode.values.map((mode) {
                    return ButtonSegment<AppThemeMode>(
                      value: mode,
                      label: Text(mode.displayName),
                      icon: Icon(mode.icon, size: 18),
                    );
                  }).toList(),
                  selected: {settings.themeMode},
                  onSelectionChanged: (selected) {
                    if (selected.isNotEmpty) {
                      context.read<SettingsCubit>().updateThemeMode(
                        selected.first,
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),
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
    required this.minVal,
    required this.maxVal,
    required this.onSelected,
  });

  final String title;
  final String subtitle;
  final int selectedValue;
  final List<int> options;
  final String unit;
  final int minVal;
  final int maxVal;
  final ValueChanged<int> onSelected;

  Future<void> _showCustomDialog(BuildContext context) async {
    int current = selectedValue;
    final controller = TextEditingController(text: current.toString());

    await showDialog<int>(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('Custom $title'),
          scrollable: true,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Enter duration between $minVal and $maxVal $unit',
                style: Theme.of(ctx).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton.filledTonal(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      if (current > minVal) {
                        setDialogState(() {
                          current = (current - 5).clamp(minVal, maxVal);
                          controller.text = current.toString();
                        });
                      }
                    },
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: SizedBox(
                      width: 90,
                      child: TextField(
                        controller: controller,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: Theme.of(ctx).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          suffixText: unit,
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 8,
                          ),
                        ),
                        onChanged: (text) {
                          final val = int.tryParse(text);
                          if (val != null) {
                            setDialogState(() => current = val);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton.filledTonal(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      if (current < maxVal) {
                        setDialogState(() {
                          current = (current + 5).clamp(minVal, maxVal);
                          controller.text = current.toString();
                        });
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final parsed = int.tryParse(controller.text) ?? current;
                final clamped = parsed.clamp(minVal, maxVal);
                onSelected(clamped);
                Navigator.pop(dialogCtx, clamped);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCustomValue = !options.contains(selectedValue);

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
          runSpacing: 8,
          children: [
            ...options.map((opt) {
              final isSelected = opt == selectedValue;
              return ChoiceChip(
                label: Text('$opt $unit'),
                selected: isSelected,
                onSelected: (_) => onSelected(opt),
              );
            }),
            if (isCustomValue)
              ChoiceChip(
                label: Text('$selectedValue $unit (Custom)'),
                selected: true,
                onSelected: (_) => _showCustomDialog(context),
              ),
            ActionChip(
              avatar: const Icon(Icons.tune, size: 16),
              label: const Text('Custom...'),
              onPressed: () => _showCustomDialog(context),
            ),
          ],
        ),
      ],
    );
  }
}
