import 'package:flutter_test/flutter_test.dart';
import 'package:focuspilot/app/app.dart';

import 'features/focus/fakes/fake_focus_session_repository.dart';
import 'features/tasks/fakes/fake_task_repository.dart';

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

    expect(find.text('Good day!'), findsOneWidget);

    taskRepository.dispose();
    focusRepository.dispose();
  });
}
