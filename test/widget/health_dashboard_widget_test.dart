import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:suhat/features/health_connect/domain/models/health_models.dart';
import 'package:suhat/features/health_connect/domain/repositories/health_repository.dart';
import 'package:suhat/features/health_connect/presentation/controllers/health_controller.dart';
import 'package:suhat/features/health_connect/presentation/screens/health_dashboard_screen.dart';

class MockHealthRepository implements HealthRepository {
  @override
  Future<HealthConnectAvailability> checkAvailability() async =>
      HealthConnectAvailability.available;

  @override
  Future<HealthPermissionStatus> checkPermissions() async =>
      HealthPermissionStatus.granted;

  @override
  Future<bool> requestPermissions() async => true;

  @override
  Future<void> openHealthConnectInStore() async {}

  @override
  Future<int> fetchTodaySteps() async => 5230;

  @override
  Future<List<HeartRateRecord>> fetchHeartRate({
    DateTime? startTime,
    DateTime? endTime,
  }) async =>
      [
        HeartRateRecord(
          bpm: 74,
          timestamp: DateTime(2026, 10, 16, 9, 30),
          source: 'Google Health Connect',
        ),
      ];

  @override
  Future<List<SleepRecord>> fetchSleep({
    DateTime? startTime,
    DateTime? endTime,
  }) async =>
      [
        SleepRecord(
          startTime: DateTime(2026, 10, 15, 23, 0),
          endTime: DateTime(2026, 10, 16, 7, 0),
          source: 'Google Health Connect',
          stages: [
            SleepStageRecord(
              stage: SleepStageType.deep,
              startTime: DateTime(2026, 10, 15, 23, 30),
              endTime: DateTime(2026, 10, 16, 1, 30),
            ),
          ],
        ),
      ];

  @override
  Future<HealthDataSummary> fetchHealthData({
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    return HealthDataSummary(
      totalStepsToday: 5230,
      stepRecords: [
        StepRecord(
          count: 5230,
          startTime: DateTime(2026, 10, 16, 0, 0),
          endTime: DateTime(2026, 10, 16, 9, 30),
          source: 'Google Health Connect',
        ),
      ],
      latestHeartRate: HeartRateRecord(
        bpm: 74,
        timestamp: DateTime(2026, 10, 16, 9, 30),
        source: 'Google Health Connect',
      ),
      heartRateHistory: [
        HeartRateRecord(
          bpm: 74,
          timestamp: DateTime(2026, 10, 16, 9, 30),
          source: 'Google Health Connect',
        ),
      ],
      latestSleep: SleepRecord(
        startTime: DateTime(2026, 10, 15, 23, 0),
        endTime: DateTime(2026, 10, 16, 7, 0),
        source: 'Google Health Connect',
      ),
      sleepHistory: [],
      lastFetched: DateTime(2026, 10, 16, 9, 30),
    );
  }
}

void main() {
  testWidgets('HealthDashboardScreen renders all cards, values, and disclaimers',
      (WidgetTester tester) async {
    final mockRepo = MockHealthRepository();

    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          healthRepositoryProvider.overrideWithValue(mockRepo),
        ],
        child: const MaterialApp(
          home: HealthDashboardScreen(),
        ),
      ),
    );

    // Initial pump & settlement
    await tester.pumpAndSettle();

    // Verify Title & Badges
    expect(find.text('Suhat'), findsOneWidget);
    expect(find.text('Fase 1: Health Connect'), findsOneWidget);

    // Verify Status Card & Explicit Provenance Note
    expect(find.text('Integrasi Health Connect'), findsOneWidget);
    expect(find.text('Izin Membaca: Aktif'), findsOneWidget);
    expect(find.text('Catatan Sumber Data (Fase 1)'), findsOneWidget);

    // Verify Steps Card
    expect(find.text('Langkah (Steps)'), findsOneWidget);
    expect(find.textContaining('5'), findsWidgets);

    // Verify Heart Rate Card
    expect(find.text('Detak Jantung (Heart Rate)'), findsOneWidget);
    expect(find.text('74'), findsOneWidget);
    expect(find.text('BPM'), findsOneWidget);

    // Verify Sleep Card
    expect(find.text('Tidur (Sleep)'), findsOneWidget);
    expect(find.text('8j'), findsOneWidget);

    // Verify Honest Bluetooth Disclaimer Footer
    expect(find.text('Koneksi Bluetooth Langsung: Belum Aktif'), findsOneWidget);
    expect(
        find.textContaining(
            'tidak mengklaim koneksi langsung melalui Bluetooth'),
        findsOneWidget);
  });
}
