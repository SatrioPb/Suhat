import 'package:flutter_test/flutter_test.dart';
import 'package:suhat/features/health_connect/domain/models/health_models.dart';

void main() {
  group('Extended Health Models & Biomarkers Tests', () {
    final now = DateTime(2026, 10, 16, 12, 0);

    test('DistanceRecord converts meters to km accurately', () {
      final record = DistanceRecord(
        distanceMeters: 5432.1,
        startTime: now.subtract(const Duration(hours: 1)),
        endTime: now,
        source: 'Health Connect',
      );

      expect(record.distanceKm, closeTo(5.4321, 0.001));
    });

    test('HeightRecord converts meters to cm accurately', () {
      final record = HeightRecord(
        heightMeters: 1.75,
        timestamp: now,
        source: 'Health Connect',
      );

      expect(record.heightCentimeters, closeTo(175.0, 0.01));
    });

    test('HealthDataSummary computes BMI accurately when weight and height are present', () {
      final summary = HealthDataSummary(
        totalStepsToday: 6000,
        stepRecords: const [],
        latestWeight: WeightRecord(weightKg: 70.0, timestamp: now, source: 'Health Connect'),
        latestHeight: HeightRecord(heightMeters: 1.75, timestamp: now, source: 'Health Connect'),
        lastFetched: now,
      );

      // BMI = 70 / (1.75 * 1.75) = 70 / 3.0625 = 22.857
      expect(summary.bmi, isNotNull);
      expect(summary.bmi!, closeTo(22.86, 0.01));
    });

    test('HealthDataSummary returns null BMI if weight or height is missing or zero', () {
      final noWeight = HealthDataSummary(
        totalStepsToday: 0,
        stepRecords: const [],
        latestHeight: HeightRecord(heightMeters: 1.75, timestamp: now, source: 'Health Connect'),
        lastFetched: now,
      );
      expect(noWeight.bmi, isNull);

      final zeroHeight = HealthDataSummary(
        totalStepsToday: 0,
        stepRecords: const [],
        latestWeight: WeightRecord(weightKg: 70.0, timestamp: now, source: 'Health Connect'),
        latestHeight: HeightRecord(heightMeters: 0.0, timestamp: now, source: 'Health Connect'),
        lastFetched: now,
      );
      expect(zeroHeight.bmi, isNull);
    });

    test('HealthDataSummary holds all 10 new data types correctly', () {
      final summary = HealthDataSummary(
        totalStepsToday: 7500,
        stepRecords: const [],
        totalActiveCaloriesToday: 350.5,
        activeCaloriesRecords: [
          ActiveCaloriesRecord(
            kcal: 350.5,
            startTime: now.subtract(const Duration(hours: 2)),
            endTime: now,
            source: 'Health Connect',
          ),
        ],
        totalCaloriesBurnedToday: 2150.0,
        totalCaloriesRecords: [
          TotalCaloriesRecord(
            kcal: 2150.0,
            startTime: now.subtract(const Duration(hours: 12)),
            endTime: now,
            source: 'Health Connect',
          ),
        ],
        totalDistanceToday: 5200.0,
        distanceRecords: [
          DistanceRecord(
            distanceMeters: 5200.0,
            startTime: now.subtract(const Duration(hours: 2)),
            endTime: now,
            source: 'Health Connect',
          ),
        ],
        totalFloorsClimbedToday: 12.0,
        elevationRecords: [
          ElevationRecord(
            floorsClimbed: 12.0,
            startTime: now.subtract(const Duration(hours: 1)),
            endTime: now,
            source: 'Health Connect',
          ),
        ],
        exerciseRecords: [
          ExerciseRecord(
            activityName: 'Running',
            duration: const Duration(minutes: 35),
            startTime: now.subtract(const Duration(minutes: 35)),
            endTime: now,
            caloriesBurned: 320.0,
            distanceMeters: 4500.0,
            source: 'Health Connect',
          ),
        ],
        latestHrv: HrvRecord(
          rmssdMillis: 54.2,
          timestamp: now,
          source: 'Health Connect',
        ),
        latestRestingHeartRate: RestingHeartRateRecord(
          bpm: 62,
          timestamp: now,
          source: 'Health Connect',
        ),
        latestOxygenSaturation: OxygenSaturationRecord(
          percentage: 98.5,
          timestamp: now,
          source: 'Health Connect',
        ),
        latestWeight: WeightRecord(
          weightKg: 68.5,
          timestamp: now,
          source: 'Health Connect',
        ),
        latestHeight: HeightRecord(
          heightMeters: 1.72,
          timestamp: now,
          source: 'Health Connect',
        ),
        lastFetched: now,
      );

      expect(summary.totalActiveCaloriesToday, 350.5);
      expect(summary.totalCaloriesBurnedToday, 2150.0);
      expect(summary.totalDistanceToday, 5200.0);
      expect(summary.distanceKmToday, 5.2);
      expect(summary.totalFloorsClimbedToday, 12.0);
      expect(summary.exerciseRecords.first.activityName, 'Running');
      expect(summary.latestHrv?.rmssdMillis, 54.2);
      expect(summary.latestRestingHeartRate?.bpm, 62);
      expect(summary.latestOxygenSaturation?.percentage, 98.5);
      expect(summary.latestWeight?.weightKg, 68.5);
      expect(summary.latestHeight?.heightCentimeters, 172.0);
    });
  });
}
