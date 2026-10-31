import 'package:flutter_test/flutter_test.dart';
import 'package:focuspilot/app/app.dart';

void main() {
  testWidgets('FocusPilot launches with the Today screen', (tester) async {
    await tester.pumpWidget(const FocusPilotApp());

    expect(find.text('Welcome to your Today screen'), findsOneWidget);
  });
}
