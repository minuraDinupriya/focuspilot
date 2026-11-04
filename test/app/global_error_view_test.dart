import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:focuspilot/app/global_error_view.dart';

void main() {
  testWidgets('GlobalErrorView displays polite error message and icon', (
    tester,
  ) async {
    final details = FlutterErrorDetails(
      exception: Exception('Simulated test exception'),
    );

    await tester.pumpWidget(
      MaterialApp(home: GlobalErrorView(errorDetails: details)),
    );

    expect(find.text('Something unexpected happened'), findsOneWidget);
    expect(find.byIcon(Icons.report_problem_outlined), findsOneWidget);
    expect(find.text('Return to Home'), findsOneWidget);
  });
}
