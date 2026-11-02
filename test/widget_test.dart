import 'package:flutter_test/flutter_test.dart';
import 'package:focuspilot/app/app.dart';

import 'features/focus/fakes/fake_focus_session_repository.dart';
import 'features/tasks/presentation/controllers/tasks_cubit_test.dart';

void main() {
  testWidgets('FocusPilot launches with the Today screen', (tester) async {
    final taskRepository = FakeTaskRepository();
    final focusRepository = FakeFocusSessionRepository();

    await tester.pumpWidget(
      FocusPilotApp(
        taskRepository: taskRepository,
        focusSessionRepository: focusRepository,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Welcome to your Today screen'), findsOneWidget);

    taskRepository.dispose();
    focusRepository.dispose();
  });
}
