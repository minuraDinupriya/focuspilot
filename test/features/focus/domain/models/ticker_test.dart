import 'package:flutter_test/flutter_test.dart';
import 'package:focuspilot/features/focus/domain/models/ticker.dart';

void main() {
  group('Ticker', () {
    test('tick emits countdown values', () async {
      const ticker = Ticker();
      final stream = ticker.tick(ticks: 3);

      expect(stream, emitsInOrder([2, 1, 0, emitsDone]));
    });
  });
}
