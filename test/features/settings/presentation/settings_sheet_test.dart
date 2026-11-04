import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:focuspilot/features/settings/data/repositories/in_memory_settings_repository.dart';
import 'package:focuspilot/features/settings/presentation/controllers/settings_cubit.dart';
import 'package:focuspilot/features/settings/presentation/widgets/settings_sheet.dart';

void main() {
  group('SettingsSheet Widget Tests', () {
    late InMemorySettingsRepository repository;
    late SettingsCubit cubit;

    setUp(() {
      repository = InMemorySettingsRepository();
      cubit = SettingsCubit(repository);
    });

    tearDown(() {
      cubit.close();
      repository.dispose();
    });

    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: Scaffold(
          body: BlocProvider<SettingsCubit>.value(
            value: cubit,
            child: const SettingsSheet(),
          ),
        ),
      );
    }

    testWidgets('renders all options and updates settings on choice tap', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Focus & Timer Settings'), findsOneWidget);
      expect(find.text('Timer Presets'), findsOneWidget);
      expect(find.text('Focus Duration'), findsOneWidget);
      expect(find.text('Short Break Duration'), findsOneWidget);
      expect(find.text('Long Break Duration'), findsOneWidget);
      expect(find.text('Daily Focus Target'), findsOneWidget);
      expect(find.text('50 min'), findsOneWidget);

      await tester.tap(find.text('50 min'));
      await tester.pumpAndSettle();

      expect(cubit.state.settings.workDurationMinutes, 50);
    });

    testWidgets('tapping Custom opens dialog and sets custom duration', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Tap first "Custom..." button (for Focus duration)
      final customButtons = find.text('Custom...');
      expect(customButtons, findsWidgets);

      await tester.tap(customButtons.first);
      await tester.pumpAndSettle();

      // Dialog is open
      expect(find.text('Custom Focus Duration'), findsOneWidget);

      // Enter 38 in the text field
      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);
      await tester.enterText(textField, '38');
      await tester.pumpAndSettle();

      // Tap Save
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(cubit.state.settings.workDurationMinutes, 38);
      expect(find.text('38 min (Custom)'), findsOneWidget);
    });

    testWidgets('selecting a preset updates durations', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Find Deep Work (50/10) chip
      final deepWorkChip = find.text('Deep Work (50/10)');
      expect(deepWorkChip, findsOneWidget);

      await tester.tap(deepWorkChip);
      await tester.pumpAndSettle();

      expect(cubit.state.settings.workDurationMinutes, 50);
      expect(cubit.state.settings.shortBreakDurationMinutes, 10);
      expect(cubit.state.settings.longBreakDurationMinutes, 30);
      expect(cubit.state.settings.activePresetId, 'preset-deep-work');
    });
  });
}
