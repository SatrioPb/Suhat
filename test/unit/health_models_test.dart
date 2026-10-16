import 'package:flutter_test/flutter_test.dart';
import 'package:suhat/data/models/heart_rate_sample.dart';
import 'package:suhat/data/models/sleep_session.dart';
import 'package:suhat/data/models/step_data.dart';

void main() {
  group('Domain & Data Models Tests', () {
    test('DailyStepData computes progress and goal accurately', () {
      final stepData = DailyStepData(
        date: DateTime(2026, 10, 16),
        totalSteps: 7500,
        goalSteps: 10000,
      );

      expect(stepData.progress, 0.75);
      expect(stepData.isGoalReached, isFalse);

      final reachedGoal = stepData.copyWith(totalSteps: 10500);
      expect(reachedGoal.progress, 1.05);
      expect(reachedGoal.isGoalReached, isTrue);
    });

    test('HeartRateSummary calculates min, max, avg and handles empty state', () {
      final emptySummary = HeartRateSummary.fromSamples([]);
      expect(emptySummary.minBpm, 0);
      expect(emptySummary.maxBpm, 0);
      expect(emptySummary.avgBpm, 0);
      expect(emptySummary.latest, isNull);

      final samples = [
        HeartRateSample(
          bpm: 60,
          timestamp: DateTime(2026, 10, 16, 8, 0),
          source: 'Google Health Connect',
        ),
        HeartRateSample(
          bpm: 100,
          timestamp: DateTime(2026, 10, 16, 10, 0),
          source: 'Google Health Connect',
        ),
        HeartRateSample(
          bpm: 80,
          timestamp: DateTime(2026, 10, 16, 9, 0),
          source: 'Google Health Connect',
        ),
      ];

      final summary = HeartRateSummary.fromSamples(samples);
      expect(summary.minBpm, 60);
      expect(summary.maxBpm, 100);
      expect(summary.avgBpm, 80);
      expect(summary.latest?.bpm, 100); // Latest timestamp is 10:00
      expect(summary.history.length, 3);
    });

    test('SleepSession computes total duration and effective sleep correctly', () {
      final start = DateTime(2026, 10, 15, 23, 0);
      final end = DateTime(2026, 10, 16, 7, 0); // 8 hours total (480 minutes)

      final session = SleepSession(
        startTime: start,
        endTime: end,
        source: 'Google Health Connect',
        stages: [
          SleepStageItem(
            stage: SleepStage.deep,
            startTime: DateTime(2026, 10, 15, 23, 30),
            endTime: DateTime(2026, 10, 16, 1, 30), // 2 hours
          ),
          SleepStageItem(
            stage: SleepStage.awake,
            startTime: DateTime(2026, 10, 16, 3, 0),
            endTime: DateTime(2026, 10, 16, 3, 30), // 30 mins awake
          ),
          SleepStageItem(
            stage: SleepStage.light,
            startTime: DateTime(2026, 10, 16, 3, 30),
            endTime: DateTime(2026, 10, 16, 6, 30), // 3 hours
          ),
        ],
      );

      expect(session.totalSessionDuration, const Duration(hours: 8));
      // Effective duration: 480 - 30 = 450 minutes (7 hours 30 minutes)
      expect(session.effectiveSleepDuration, const Duration(hours: 7, minutes: 30));
    });
  });
}
