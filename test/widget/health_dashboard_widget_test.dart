import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suhat/app/main_screen.dart';
import 'package:suhat/app/providers.dart';
import 'package:suhat/features/analytics/pages/analytics_page.dart';
import 'package:suhat/features/health_connect/domain/models/health_models.dart';
import 'package:suhat/features/health_connect/domain/repositories/health_repository.dart';
import 'package:suhat/features/health_connect/presentation/controllers/health_controller.dart';

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
        stages: [
          SleepStageRecord(
            stage: SleepStageType.deep,
            startTime: DateTime(2026, 10, 15, 23, 30),
            endTime: DateTime(2026, 10, 16, 1, 30),
          ),
        ],
      ),
      sleepHistory: [],
      lastFetched: DateTime(2026, 10, 16, 9, 30),
    );
  }
}

void main() {
  testWidgets(
      'MainScreen displays minimalist dashboard and navigates to dedicated menus',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'daily_step_goal': 10000});
    final prefs = await SharedPreferences.getInstance();
    final mockRepo = MockHealthRepository();

    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          healthConnectRepositoryProvider.overrideWithValue(mockRepo),
        ],
        child: const MaterialApp(
          home: MainScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // 1. Verify Minimalist Dashboard Content
    expect(find.text('Supercalla Health'), findsOneWidget);
    expect(find.text('Kesiapan Fisik'), findsOneWidget);
    expect(find.text('Langkah Hari Ini'), findsOneWidget);
    expect(find.text('5.230'), findsOneWidget);
    expect(find.text('Detak Jantung'), findsOneWidget);
    expect(find.text('74'), findsOneWidget);
    expect(find.text('Tidur Semalam'), findsOneWidget);
    expect(find.text('8j'), findsOneWidget);

    // Verify Navigation Destinations
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Analisis'), findsOneWidget);
    expect(find.text('Riwayat'), findsOneWidget);
    expect(find.text('Perangkat'), findsOneWidget);

    // 2. Switch to Analisis Tab
    await tester.tap(find.text('Analisis'));
    await tester.pumpAndSettle();

    expect(find.text('Analisis Kesehatan'), findsOneWidget);
    expect(find.text('Kesiapan & Pemulihan Fisik'), findsOneWidget);
    expect(find.text('Analisis Detak Jantung'), findsOneWidget);
    expect(find.text('Analisis Kualitas Tidur'), findsOneWidget);

    // 3. Switch to Perangkat Tab
    await tester.tap(find.text('Perangkat'));
    await tester.pumpAndSettle();

    expect(find.text('Perangkat & Pengaturan'), findsOneWidget);
    expect(find.text('Panduan Smartwatch Supercalla'), findsOneWidget);
    expect(find.text('Status Bluetooth: Tidak Aktif Langsung'), findsOneWidget);
  });

  testWidgets(
      'Analisis tab renders cleanly without overflow on compact 360x800 screen',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'daily_step_goal': 10000});
    final prefs = await SharedPreferences.getInstance();
    final mockRepo = MockHealthRepository();

    // Standard compact mobile viewport: 360 x 800 logical pixels
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          healthConnectRepositoryProvider.overrideWithValue(mockRepo),
        ],
        child: const MaterialApp(
          home: MainScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Tap on Analisis tab
    await tester.tap(find.text('Analisis'));
    await tester.pumpAndSettle();

    expect(find.text('Analisis Kesehatan'), findsOneWidget);
    expect(find.text('Kesiapan & Pemulihan Fisik'), findsOneWidget);

    // Scroll to reveal subsequent cards in AnalyticsPage ListView
    final analyticsList = find.descendant(
      of: find.byType(AnalyticsPage),
      matching: find.byType(ListView),
    );

    await tester.drag(analyticsList, const Offset(0, -400));
    await tester.pumpAndSettle();

    expect(find.text('Analisis Detak Jantung'), findsOneWidget);

    await tester.drag(analyticsList, const Offset(0, -400));
    await tester.pumpAndSettle();

    expect(find.text('Analisis Kualitas Tidur'), findsOneWidget);

    // Verify no Flutter exceptions / overflows occurred
    expect(tester.takeException(), isNull);
  });
}
