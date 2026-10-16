import 'package:flutter_test/flutter_test.dart';
import 'package:suhat/features/analytics/domain/models/health_insight.dart';
import 'package:suhat/features/analytics/domain/models/heart_rate_analysis.dart';
import 'package:suhat/features/analytics/domain/models/sleep_analysis.dart';
import 'package:suhat/features/health_connect/domain/models/health_models.dart';
import 'package:suhat/features/running_coach/domain/models/running_plan.dart';
import 'package:suhat/features/running_coach/domain/services/running_coach_service.dart';

void main() {
  group('RunningCoachService Tests', () {
    late RunningCoachService service;

    setUp(() {
      service = RunningCoachService();
    });

    test('calculateRunningZones calculates accurate 5 zones for age 30', () {
      final zones = service.calculateRunningZones(30);

      expect(zones.maxHeartRate, 190);
      expect(zones.zone1.zoneNumber, 1);
      expect(zones.zone1.minBpm, 95); // 50% of 190
      expect(zones.zone2.zoneNumber, 2);
      expect(zones.zone2.minBpm, 114); // 60% of 190
      expect(zones.zone3.zoneNumber, 3);
      expect(zones.zone3.minBpm, 133); // 70% of 190
      expect(zones.zone4.zoneNumber, 4);
      expect(zones.zone4.minBpm, 152); // 80% of 190
      expect(zones.zone5.zoneNumber, 5);
      expect(zones.zone5.minBpm, 171); // 90% of 190
      expect(zones.zone5.maxBpm, 190);
      expect(zones.allZones.length, 5);
    });

    test('calculateWeeklySummary filters running workouts and sums stats correctly', () {
      final now = DateTime(2026, 10, 15, 14, 0); // Thursday
      final summary = HealthDataSummary(
        totalStepsToday: 8000,
        stepRecords: const [],
        exerciseRecords: [
          ExerciseRecord(
            activityName: 'Outdoor Running',
            duration: const Duration(minutes: 40),
            startTime: DateTime(2026, 10, 13, 6, 30), // Tuesday
            endTime: DateTime(2026, 10, 13, 7, 10),
            distanceMeters: 5200,
            caloriesBurned: 420,
            source: 'Health Connect',
          ),
          ExerciseRecord(
            activityName: 'Jogging',
            duration: const Duration(minutes: 30),
            startTime: DateTime(2026, 10, 14, 6, 30), // Wednesday
            endTime: DateTime(2026, 10, 14, 7, 0),
            distanceMeters: 4000,
            caloriesBurned: 310,
            source: 'Health Connect',
          ),
          ExerciseRecord(
            activityName: 'Yoga', // Non-running
            duration: const Duration(minutes: 45),
            startTime: DateTime(2026, 10, 14, 18, 0),
            endTime: DateTime(2026, 10, 14, 18, 45),
            distanceMeters: 0,
            caloriesBurned: 150,
            source: 'Health Connect',
          ),
        ],
        lastFetched: now,
      );

      final weekly = service.calculateWeeklySummary(
        summary,
        targetRuns: 4,
        referenceDate: now,
      );

      expect(weekly.completedRunsThisWeek, 2);
      expect(weekly.totalWeeklyDistanceKm, closeTo(9.2, 0.01));
      expect(weekly.totalWeeklyDuration.inMinutes, 70);
      expect(weekly.totalCaloriesBurned, 730);
      expect(weekly.weeklyProgressPercent, 0.5); // 2 of 4 = 50%
    });

    test('recommendTodayWorkout recommends Rest Day if user already ran today', () {
      final now = DateTime(2026, 10, 15, 16, 0);
      final summary = HealthDataSummary(
        totalStepsToday: 10000,
        stepRecords: const [],
        exerciseRecords: [
          ExerciseRecord(
            activityName: 'Morning Run',
            duration: const Duration(minutes: 35),
            startTime: DateTime(2026, 10, 15, 6, 0), // Today
            endTime: DateTime(2026, 10, 15, 6, 35),
            distanceMeters: 4500,
            source: 'Health Connect',
          ),
        ],
        lastFetched: now,
      );

      final insight = HealthInsight(
        recoveryScore: 85,
        level: RecoveryLevel.optimal,
        headline: 'Prima',
        summary: 'Kondisi bagus',
        actionableAdvice: const [],
        heartRateAnalysis: HeartRateAnalysis.empty(),
        sleepAnalysis: SleepAnalysis.empty(),
        generatedAt: now,
      );

      final rec = service.recommendTodayWorkout(
        insight: insight,
        summary: summary,
        now: now,
      );

      expect(rec.workoutType, RunningWorkoutType.restDay);
      expect(rec.title, contains('Pemulihan Pasca Lari Hari Ini'));
    });

    test('recommendTodayWorkout recommends Rest Day if recovery score is low (< 45)', () {
      final now = DateTime(2026, 10, 15, 8, 0);
      final summary = HealthDataSummary.empty();
      final insight = HealthInsight(
        recoveryScore: 40,
        level: RecoveryLevel.restRequired,
        headline: 'Butuh Istirahat',
        summary: 'Kurang tidur',
        actionableAdvice: const [],
        heartRateAnalysis: HeartRateAnalysis.empty(),
        sleepAnalysis: SleepAnalysis.empty(),
        generatedAt: now,
      );

      final rec = service.recommendTodayWorkout(
        insight: insight,
        summary: summary,
        now: now,
      );

      expect(rec.workoutType, RunningWorkoutType.restDay);
      expect(rec.title, contains('Rest Day'));
      expect(rec.rationale, contains('Skor pemulihan rendah'));
    });

    test('recommendTodayWorkout recommends Tempo Run when recovery is optimal (>= 80) and base is built', () {
      final now = DateTime(2026, 10, 15, 8, 0); // Thursday
      final summary = HealthDataSummary(
        totalStepsToday: 2000,
        stepRecords: const [],
        exerciseRecords: [
          ExerciseRecord(
            activityName: 'Outdoor Running',
            duration: const Duration(minutes: 35),
            startTime: DateTime(2026, 10, 13, 6, 0), // Tuesday run
            endTime: DateTime(2026, 10, 13, 6, 35),
            distanceMeters: 4500,
            source: 'Health Connect',
          ),
        ],
        latestHrv: HrvRecord(
          rmssdMillis: 55,
          timestamp: now,
          source: 'Health Connect',
        ),
        lastFetched: now,
      );

      final insight = HealthInsight(
        recoveryScore: 88,
        level: RecoveryLevel.optimal,
        headline: 'Prima',
        summary: 'Kondisi sangat baik',
        actionableAdvice: const [],
        heartRateAnalysis: const HeartRateAnalysis(
          avgBpm: 70,
          status: HeartRateStatus.normal,
          statusDescription: 'Normal',
        ),
        sleepAnalysis: SleepAnalysis.empty(),
        generatedAt: now,
      );

      final rec = service.recommendTodayWorkout(
        insight: insight,
        summary: summary,
        now: now,
      );

      expect(rec.workoutType, RunningWorkoutType.tempoRun);
      expect(rec.title, contains('Tempo'));
      expect(rec.targetZoneLabel, contains('Zona 3'));
    });

    test('recommendTodayWorkout recommends Easy Run (Zone 2) for standard healthy condition', () {
      final now = DateTime(2026, 10, 15, 8, 0);
      final summary = HealthDataSummary.empty();
      final insight = HealthInsight(
        recoveryScore: 72,
        level: RecoveryLevel.good,
        headline: 'Baik',
        summary: 'Kondisi baik',
        actionableAdvice: const [],
        heartRateAnalysis: HeartRateAnalysis.empty(),
        sleepAnalysis: SleepAnalysis.empty(),
        generatedAt: now,
      );

      final rec = service.recommendTodayWorkout(
        insight: insight,
        summary: summary,
        now: now,
      );

      expect(rec.workoutType, RunningWorkoutType.easyRun);
      expect(rec.title, contains('Easy Base Run'));
      expect(rec.targetZoneLabel, contains('Zona 2'));
    });
  });
}
