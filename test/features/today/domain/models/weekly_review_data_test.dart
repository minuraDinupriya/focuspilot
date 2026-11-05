import 'package:flutter_test/flutter_test.dart';
import 'package:focuspilot/features/tasks/domain/models/task.dart';
import 'package:focuspilot/features/tasks/domain/models/task_priority.dart';
import 'package:focuspilot/features/today/domain/models/weekly_review_data.dart';

void main() {
  group('WeeklyReviewData Domain Model Tests', () {
    final start = DateTime(2026, 10, 26);
    final end = DateTime(2026, 11, 1);

    test('calculates correct dateRangeText across different months', () {
      final review = WeeklyReviewData(
        startDate: start,
        endDate: end,
        focusMinutesThisWeek: 300,
        focusMinutesPreviousWeek: 200,
        completedSessionsCount: 6,
        completedTasksCount: 4,
        daysGoalMetCount: 5,
        dailyGoalMinutes: 60,
      );

      expect(review.dateRangeText, 'Oct 26 – Nov 1');
    });

    test('calculates dateRangeText within same month', () {
      final review = WeeklyReviewData(
        startDate: DateTime(2026, 11, 1),
        endDate: DateTime(2026, 11, 7),
        focusMinutesThisWeek: 120,
        focusMinutesPreviousWeek: 120,
        completedSessionsCount: 2,
        completedTasksCount: 1,
        daysGoalMetCount: 2,
        dailyGoalMinutes: 60,
      );

      expect(review.dateRangeText, 'Nov 1 – 7');
    });

    test('calculates percentage increase and trend text correctly', () {
      final review = WeeklyReviewData(
        startDate: start,
        endDate: end,
        focusMinutesThisWeek: 300,
        focusMinutesPreviousWeek: 200,
        completedSessionsCount: 6,
        completedTasksCount: 4,
        daysGoalMetCount: 5,
        dailyGoalMinutes: 60,
      );

      expect(review.changePercentage, 50.0);
      expect(review.isPositiveTrend, isTrue);
      expect(review.trendText, '+50% vs last week');
    });

    test('calculates percentage decrease correctly', () {
      final review = WeeklyReviewData(
        startDate: start,
        endDate: end,
        focusMinutesThisWeek: 150,
        focusMinutesPreviousWeek: 200,
        completedSessionsCount: 3,
        completedTasksCount: 2,
        daysGoalMetCount: 2,
        dailyGoalMinutes: 60,
      );

      expect(review.changePercentage, -25.0);
      expect(review.isPositiveTrend, isFalse);
      expect(review.trendText, '-25% vs last week');
    });

    test('handles zero previous week activity gracefully', () {
      final review = WeeklyReviewData(
        startDate: start,
        endDate: end,
        focusMinutesThisWeek: 100,
        focusMinutesPreviousWeek: 0,
        completedSessionsCount: 2,
        completedTasksCount: 1,
        daysGoalMetCount: 1,
        dailyGoalMinutes: 60,
      );

      expect(review.changePercentage, 100.0);
      expect(review.trendText, '+100% vs last week');
    });

    test('handles zero minutes in both weeks', () {
      final review = WeeklyReviewData(
        startDate: start,
        endDate: end,
        focusMinutesThisWeek: 0,
        focusMinutesPreviousWeek: 0,
        completedSessionsCount: 0,
        completedTasksCount: 0,
        daysGoalMetCount: 0,
        dailyGoalMinutes: 60,
      );

      expect(review.changePercentage, isNull);
      expect(review.trendText, 'No prior activity');
      expect(review.focusTimeFormatted, '0m');
    });

    test('formats hours and minutes properly', () {
      expect(WeeklyReviewData.formatMinutes(0), '0m');
      expect(WeeklyReviewData.formatMinutes(45), '45m');
      expect(WeeklyReviewData.formatMinutes(120), '2h');
      expect(WeeklyReviewData.formatMinutes(155), '2h 35m');
    });

    test('computes goalAchievementRate and motivationalMessage', () {
      final greatWeek = WeeklyReviewData(
        startDate: start,
        endDate: end,
        focusMinutesThisWeek: 400,
        focusMinutesPreviousWeek: 300,
        completedSessionsCount: 8,
        completedTasksCount: 5,
        daysGoalMetCount: 6,
        dailyGoalMinutes: 60,
      );
      expect(greatWeek.goalAchievementRate, closeTo(6 / 7, 0.01));
      expect(
        greatWeek.motivationalMessage,
        contains('Outstanding consistency'),
      );

      final zeroWeek = WeeklyReviewData(
        startDate: start,
        endDate: end,
        focusMinutesThisWeek: 0,
        focusMinutesPreviousWeek: 0,
        completedSessionsCount: 0,
        completedTasksCount: 0,
        daysGoalMetCount: 0,
        dailyGoalMinutes: 60,
      );
      expect(zeroWeek.goalAchievementRate, 0.0);
      expect(zeroWeek.motivationalMessage, contains('Start your first focus'));
    });

    test('supports topTasks and equality', () {
      final task = Task(
        id: 't1',
        title: 'Project Setup',
        priority: TaskPriority.high,
        actualMinutes: 45,
        createdAt: DateTime.now(),
      );
      final r1 = WeeklyReviewData(
        startDate: start,
        endDate: end,
        focusMinutesThisWeek: 45,
        focusMinutesPreviousWeek: 0,
        completedSessionsCount: 1,
        completedTasksCount: 1,
        daysGoalMetCount: 1,
        dailyGoalMinutes: 60,
        topTasks: [task],
      );
      final r2 = WeeklyReviewData(
        startDate: start,
        endDate: end,
        focusMinutesThisWeek: 45,
        focusMinutesPreviousWeek: 0,
        completedSessionsCount: 1,
        completedTasksCount: 1,
        daysGoalMetCount: 1,
        dailyGoalMinutes: 60,
        topTasks: [task],
      );

      expect(r1, equals(r2));
    });
  });
}
