import 'package:flutter_test/flutter_test.dart';
import 'package:suhat/features/health_connect/domain/models/health_models.dart';
import 'package:suhat/features/health_connect/domain/repositories/health_repository.dart';
import 'package:suhat/features/health_connect/presentation/controllers/health_controller.dart';

class FakeHealthRepository implements HealthRepository {
  HealthConnectAvailability availabilityResult =
      HealthConnectAvailability.available;
  HealthPermissionStatus permissionResult = HealthPermissionStatus.granted;
  bool requestPermissionResult = true;
  bool openStoreCalled = false;

  int todaySteps = 8450;
  List<HeartRateRecord> heartRateList = [
    HeartRateRecord(
      bpm: 72,
      timestamp: DateTime(2026, 10, 16, 10, 30),
      source: 'Google Health Connect',
    ),
    HeartRateRecord(
      bpm: 78,
      timestamp: DateTime(2026, 10, 16, 8, 15),
      source: 'Google Health Connect',
    ),
  ];
  List<SleepRecord> sleepList = [
    SleepRecord(
      startTime: DateTime(2026, 10, 15, 23, 10),
      endTime: DateTime(2026, 10, 16, 6, 45),
      source: 'Google Health Connect',
      stages: [
        SleepStageRecord(
          stage: SleepStageType.deep,
          startTime: DateTime(2026, 10, 15, 23, 30),
          endTime: DateTime(2026, 10, 16, 1, 30),
        ),
        SleepStageRecord(
          stage: SleepStageType.light,
          startTime: DateTime(2026, 10, 16, 1, 30),
          endTime: DateTime(2026, 10, 16, 4, 30),
        ),
        SleepStageRecord(
          stage: SleepStageType.rem,
          startTime: DateTime(2026, 10, 16, 4, 30),
          endTime: DateTime(2026, 10, 16, 6, 30),
        ),
      ],
    ),
  ];

  @override
  Future<HealthConnectAvailability> checkAvailability() async =>
      availabilityResult;

  @override
  Future<HealthPermissionStatus> checkPermissions() async => permissionResult;

  @override
  Future<bool> requestPermissions() async => requestPermissionResult;

  @override
  Future<void> openHealthConnectInStore() async {
    openStoreCalled = true;
  }

  @override
  Future<int> fetchTodaySteps() async => todaySteps;

  @override
  Future<List<HeartRateRecord>> fetchHeartRate({
    DateTime? startTime,
    DateTime? endTime,
  }) async =>
      heartRateList;

  @override
  Future<List<SleepRecord>> fetchSleep({
    DateTime? startTime,
    DateTime? endTime,
  }) async =>
      sleepList;

  @override
  Future<HealthDataSummary> fetchHealthData({
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    return HealthDataSummary(
      totalStepsToday: todaySteps,
      stepRecords: [
        StepRecord(
          count: todaySteps,
          startTime: DateTime(2026, 10, 16, 0, 0),
          endTime: DateTime(2026, 10, 16, 11, 0),
          source: 'Google Health Connect',
        ),
      ],
      latestHeartRate: heartRateList.first,
      heartRateHistory: heartRateList,
      latestSleep: sleepList.first,
      sleepHistory: sleepList,
      lastFetched: DateTime.now(),
    );
  }
}

void main() {
  group('HealthController Tests', () {
    late FakeHealthRepository fakeRepo;
    late HealthController controller;

    setUp(() {
      fakeRepo = FakeHealthRepository();
      controller = HealthController(fakeRepo);
    });

    test('Initial initialization loads availability and granted data',
        () async {
      await controller.initialize();

      expect(controller.state.availability,
          HealthConnectAvailability.available);
      expect(
          controller.state.permissions, HealthPermissionStatus.granted);
      expect(controller.state.summary.totalStepsToday, 8450);
      expect(controller.state.summary.latestHeartRate?.bpm, 72);
      expect(controller.state.summary.latestSleep?.stages.length, 3);
      expect(controller.state.isDirectBluetoothConnected, false);
    });

    test('Denied permissions correctly updates state with error hint',
        () async {
      fakeRepo.permissionResult = HealthPermissionStatus.denied;
      fakeRepo.requestPermissionResult = false;

      await controller.requestPermissions();

      expect(controller.state.permissions, HealthPermissionStatus.denied);
      expect(controller.state.errorMessage, isNotNull);
      expect(controller.state.isRequestingPermission, false);
    });

    test('Granted permissions triggers fetchHealthData', () async {
      fakeRepo.requestPermissionResult = true;

      await controller.requestPermissions();

      expect(
          controller.state.permissions, HealthPermissionStatus.granted);
      expect(controller.state.summary.totalStepsToday, 8450);
      expect(controller.state.errorMessage, isNull);
    });

    test('Bluetooth flag remains false during Phase 1 Health Connect', () {
      expect(controller.state.isDirectBluetoothConnected, isFalse);
    });
  });
}
