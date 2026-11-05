import 'package:flutter_test/flutter_test.dart';
import 'package:focuspilot/features/today/domain/models/heatmap_day.dart';

void main() {
  group('HeatmapDay model', () {
    final fixedDate = DateTime(2026, 11, 5);

    test('calculateLevel assigns correct intensity levels', () {
      expect(HeatmapDay.calculateLevel(0), 0);
      expect(HeatmapDay.calculateLevel(-5), 0);
      expect(HeatmapDay.calculateLevel(10), 1);
      expect(HeatmapDay.calculateLevel(24), 1);
      expect(HeatmapDay.calculateLevel(25), 2);
      expect(HeatmapDay.calculateLevel(59), 2);
      expect(HeatmapDay.calculateLevel(60), 3);
      expect(HeatmapDay.calculateLevel(119), 3);
      expect(HeatmapDay.calculateLevel(120), 4);
      expect(HeatmapDay.calculateLevel(250), 4);
    });

    test('fromMinutes constructs HeatmapDay with calculated level', () {
      final day = HeatmapDay.fromMinutes(date: fixedDate, focusMinutes: 75);
      expect(day.date, fixedDate);
      expect(day.focusMinutes, 75);
      expect(day.level, 3);
    });

    test('supports value equality', () {
      final dayA = HeatmapDay(date: fixedDate, focusMinutes: 50, level: 2);
      final dayB = HeatmapDay(date: fixedDate, focusMinutes: 50, level: 2);
      expect(dayA, equals(dayB));
    });
  });
}
