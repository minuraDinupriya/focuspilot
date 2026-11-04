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

    testWidgets('renders all options and updates settings on choice tap', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider<SettingsCubit>.value(
              value: cubit,
              child: const SettingsSheet(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Focus & Timer Settings'), findsOneWidget);
      expect(find.text('Focus Duration'), findsOneWidget);
      expect(find.text('50 min'), findsOneWidget);

      await tester.tap(find.text('50 min'));
      await tester.pumpAndSettle();

      expect(cubit.state.settings.workDurationMinutes, 50);
    });
  });
}
