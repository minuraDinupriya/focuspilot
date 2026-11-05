import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:focuspilot/features/today/presentation/widgets/goal_streaks_card.dart';

void main() {
  group('GoalStreaksCard Widget Tests', () {
    testWidgets(
      'renders streak, milestone, daily and weekly goals in progress',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: GoalStreaksCard(
                currentStreakDays: 5,
                bestStreakDays: 8,
                nextMilestoneDays: 7,
                streakBadge: '🚀 Momentum',
                focusMinutesToday: 60,
                dailyGoalMinutes: 120,
                dailyGoalProgress: 0.5,
                isDailyGoalAchieved: false,
                focusMinutesThisWeek: 300,
                weeklyGoalMinutes: 600,
                weeklyGoalProgress: 0.5,
                isWeeklyGoalAchieved: false,
                daysGoalMetThisWeek: 2,
              ),
            ),
          ),
        );

        expect(find.text('5 Day Streak'), findsOneWidget);
        expect(find.text('🚀 Momentum'), findsOneWidget);
        expect(find.text('Best: 8 d • Next milestone: 7 d'), findsOneWidget);

        expect(find.text('60m / 120m (50%)'), findsOneWidget);
        expect(
          find.text('60m remaining to achieve daily goal'),
          findsOneWidget,
        );

        expect(find.text('300m / 600m (50%)'), findsOneWidget);
        expect(find.textContaining('2/7 days met daily goal'), findsOneWidget);
      },
    );

    testWidgets(
      'renders celebratory messages when daily and weekly goals are achieved',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: GoalStreaksCard(
                currentStreakDays: 14,
                bestStreakDays: 14,
                nextMilestoneDays: 21,
                streakBadge: '⚡ Champion Streak',
                focusMinutesToday: 130,
                dailyGoalMinutes: 120,
                dailyGoalProgress: 1.0,
                isDailyGoalAchieved: true,
                focusMinutesThisWeek: 650,
                weeklyGoalMinutes: 600,
                weeklyGoalProgress: 1.0,
                isWeeklyGoalAchieved: true,
                daysGoalMetThisWeek: 5,
              ),
            ),
          ),
        );

        expect(find.text('14 Day Streak'), findsOneWidget);
        expect(find.text('⚡ Champion Streak'), findsOneWidget);
        expect(
          find.text('🎉 Daily goal reached! Excellent work.'),
          findsOneWidget,
        );
        expect(
          find.text('🏆 Weekly target completed! (5/7 days met daily goal)'),
          findsOneWidget,
        );
      },
    );

    testWidgets('renders inactive streak state when streak is 0', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GoalStreaksCard(
              currentStreakDays: 0,
              bestStreakDays: 3,
              nextMilestoneDays: 3,
              streakBadge: '🌱 Building Habit',
              focusMinutesToday: 0,
              dailyGoalMinutes: 120,
              dailyGoalProgress: 0.0,
              isDailyGoalAchieved: false,
              focusMinutesThisWeek: 0,
              weeklyGoalMinutes: 600,
              weeklyGoalProgress: 0.0,
              isWeeklyGoalAchieved: false,
              daysGoalMetThisWeek: 0,
            ),
          ),
        ),
      );

      expect(find.text('No Active Streak'), findsOneWidget);
      expect(find.text('🌱 Building Habit'), findsOneWidget);
      expect(find.text('120m remaining to achieve daily goal'), findsOneWidget);
    });
  });
}
