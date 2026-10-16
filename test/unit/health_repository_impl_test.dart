import 'package:flutter_test/flutter_test.dart';
import 'package:health/health.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suhat/data/local/preferences_service.dart';
import 'package:suhat/data/repositories/health_repository.dart';
import 'package:suhat/data/services/health_connect_service.dart';
import 'package:suhat/features/health_connect/domain/models/health_models.dart';

class MockHealthConnectService extends HealthConnectService {
  int mockTotalSteps = 6500;
  List<HealthDataPoint> mockDataPoints = [];
  bool mockHasPermissions = true;
  HealthConnectAvailability mockAvailability = HealthConnectAvailability.available;

  @override
  Future<HealthConnectAvailability> checkAvailability() async => mockAvailability;

  @override
  Future<bool> hasPermissions() async => mockHasPermissions;

  @override
  Future<bool> requestPermissions() async => true;

  @override
  Future<int> getTotalSteps(DateTime start, DateTime end) async => mockTotalSteps;

  @override
  Future<List<HealthDataPoint>> getRawDataPoints({
    required List<HealthDataType> dataTypes,
    required DateTime start,
    required DateTime end,
  }) async {
    return mockDataPoints.where((p) => dataTypes.contains(p.type)).toList();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HealthRepositoryImpl Tests', () {
    late MockHealthConnectService mockService;
    late PreferencesService prefsService;
    late HealthRepositoryImpl repository;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      prefsService = PreferencesService(prefs);
      mockService = MockHealthConnectService();
      repository = HealthRepositoryImpl(
        service: mockService,
        preferencesService: prefsService,
      );
    });

    test('fetchDailySteps returns correct total steps and goal', () async {
      mockService.mockTotalSteps = 8200;
      final today = DateTime(2026, 10, 16);

      final result = await repository.fetchDailySteps(today, customGoal: 10000);

      expect(result.totalSteps, 8200);
      expect(result.goalSteps, 10000);
      expect(result.date.day, 16);
      expect(result.progress, 0.82);
    });

    test('fetchWeeklySteps returns exactly 7 days of daily step data', () async {
      mockService.mockTotalSteps = 5000;
      final refDate = DateTime(2026, 10, 16);

      final weekly = await repository.fetchWeeklySteps(
        referenceDate: refDate,
        customGoal: 10000,
      );

      expect(weekly.length, 7);
      expect(weekly.last.date.day, 16); // Last entry is today
      expect(weekly.first.date.day, 10); // First entry is 6 days ago
    });

    test('fetchHeartRate transforms raw points into HeartRateSummary', () async {
      final now = DateTime.now();
      mockService.mockDataPoints = [
        HealthDataPoint(
          uuid: 'hr-1',
          value: NumericHealthValue(numericValue: 70),
          type: HealthDataType.HEART_RATE,
          unit: HealthDataUnit.BEATS_PER_MINUTE,
          dateFrom: now.subtract(const Duration(hours: 2)),
          dateTo: now.subtract(const Duration(hours: 2)),
          sourcePlatform: HealthPlatformType.googleHealthConnect,
          sourceDeviceId: 'dev-1',
          sourceId: 'src-1',
          sourceName: 'Google Health Connect',
          recordingMethod: RecordingMethod.automatic,
        ),
        HealthDataPoint(
          uuid: 'hr-2',
          value: NumericHealthValue(numericValue: 86),
          type: HealthDataType.HEART_RATE,
          unit: HealthDataUnit.BEATS_PER_MINUTE,
          dateFrom: now.subtract(const Duration(hours: 1)),
          dateTo: now.subtract(const Duration(hours: 1)),
          sourcePlatform: HealthPlatformType.googleHealthConnect,
          sourceDeviceId: 'dev-1',
          sourceId: 'src-1',
          sourceName: 'Google Health Connect',
          recordingMethod: RecordingMethod.automatic,
        ),
      ];

      final summary = await repository.fetchHeartRate();

      expect(summary.history.length, 2);
      expect(summary.minBpm, 70);
      expect(summary.maxBpm, 86);
      expect(summary.avgBpm, 78);
      expect(summary.latest?.bpm, 86); // Latest timestamp
    });

    test('fetchSleepSessions maps session and child stages correctly', () async {
      final now = DateTime.now();
      final sleepStart = now.subtract(const Duration(hours: 8));
      final sleepEnd = now;

      mockService.mockDataPoints = [
        HealthDataPoint(
          uuid: 'session-1',
          value: NumericHealthValue(numericValue: 480),
          type: HealthDataType.SLEEP_SESSION,
          unit: HealthDataUnit.MINUTE,
          dateFrom: sleepStart,
          dateTo: sleepEnd,
          sourcePlatform: HealthPlatformType.googleHealthConnect,
          sourceDeviceId: 'dev-1',
          sourceId: 'src-1',
          sourceName: 'Google Health Connect',
          recordingMethod: RecordingMethod.automatic,
        ),
        HealthDataPoint(
          uuid: 'stage-1',
          value: NumericHealthValue(numericValue: 120),
          type: HealthDataType.SLEEP_DEEP,
          unit: HealthDataUnit.MINUTE,
          dateFrom: sleepStart.add(const Duration(minutes: 30)),
          dateTo: sleepStart.add(const Duration(minutes: 150)),
          sourcePlatform: HealthPlatformType.googleHealthConnect,
          sourceDeviceId: 'dev-1',
          sourceId: 'src-1',
          sourceName: 'Google Health Connect',
          recordingMethod: RecordingMethod.automatic,
        ),
      ];

      final sessions = await repository.fetchSleepSessions();

      expect(sessions.length, 1);
      expect(sessions.first.totalSessionDuration, const Duration(hours: 8));
      expect(sessions.first.stages.length, 1);
      expect(sessions.first.stages.first.stage.displayName, contains('Deep'));
    });

    test('fetchHealthSummary consolidates data and updates lastSyncTime', () async {
      mockService.mockTotalSteps = 9400;

      final summary = await repository.fetchHealthSummary();

      expect(summary.todaySteps.totalSteps, 9400);
      expect(summary.weeklySteps.length, 7);
      expect(prefsService.getLastSyncTime(), isNotNull);
    });
  });
}
