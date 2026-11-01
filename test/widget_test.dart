import 'package:flutter_test/flutter_test.dart';
import 'package:focuspilot/app/app.dart';

import 'features/tasks/presentation/controllers/tasks_cubit_test.dart';

void main() {
  testWidgets('FocusPilot launches with the Today screen', (tester) async {
    final taskRepository = FakeTaskRepository();
    await tester.pumpWidget(FocusPilotApp(taskRepository: taskRepository));
    await tester.pumpAndSettle();

    expect(find.text('Welcome to your Today screen'), findsOneWidget);
    taskRepository.dispose();
  });
}
