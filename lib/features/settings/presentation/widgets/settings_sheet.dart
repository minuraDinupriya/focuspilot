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
                    settings.copyWith(workDurationMinutes: val),
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
                    settings.copyWith(shortBreakDurationMinutes: val),
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
                    settings.copyWith(longBreakDurationMinutes: val),
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
              const SizedBox(height: 12),
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

    final customVal = await showDialog<int>(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('Custom $title'),
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
                  SizedBox(
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
