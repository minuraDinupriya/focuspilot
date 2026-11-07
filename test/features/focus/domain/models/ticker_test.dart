import 'package:flutter_test/flutter_test.dart';
import 'package:focuspilot/features/focus/domain/models/ticker.dart';

void main() {
  group('Ticker', () {
    test('tick emits countdown values', () async {
      const ticker = Ticker();
      final stream = ticker.tick(ticks: 3);

      expect(stream, emitsInOrder([2, 1, 0, emitsDone]));
    });

    test('pulse keeps emitting until the subscriber stops it', () async {
      const ticker = Ticker();
      await expectLater(
        ticker.pulse().take(2),
        emitsInOrder([emits(anything), emits(anything), emitsDone]),
      );
    });
  });
}
