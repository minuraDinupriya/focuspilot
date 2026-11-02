import 'package:flutter_test/flutter_test.dart';
import 'package:focuspilot/features/focus/domain/models/focus_mode.dart';

void main() {
  group('FocusMode', () {
    test('displayName returns expected values', () {
      expect(FocusMode.work.displayName, 'Focus');
      expect(FocusMode.shortBreak.displayName, 'Short Break');
      expect(FocusMode.longBreak.displayName, 'Long Break');
    });

    test('defaultDurationSeconds matches standard Pomodoro specs', () {
      expect(FocusMode.work.defaultDurationSeconds, 25 * 60);
      expect(FocusMode.shortBreak.defaultDurationSeconds, 5 * 60);
      expect(FocusMode.longBreak.defaultDurationSeconds, 15 * 60);
    });

    test('fromString parses correctly and defaults to work', () {
      expect(FocusMode.fromString('shortBreak'), FocusMode.shortBreak);
      expect(FocusMode.fromString('longBreak'), FocusMode.longBreak);
      expect(FocusMode.fromString('unknown'), FocusMode.work);
    });
  });
}
