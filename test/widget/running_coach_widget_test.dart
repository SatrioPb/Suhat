import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suhat/app/main_screen.dart';
import 'package:suhat/app/providers.dart';
import 'package:suhat/features/health_connect/domain/models/health_models.dart';
import 'package:suhat/features/health_connect/domain/repositories/health_repository.dart';
import 'package:suhat/features/health_connect/presentation/controllers/health_controller.dart';
import 'package:suhat/features/running_coach/pages/running_coach_page.dart';
import 'package:suhat/features/running_coach/presentation/widgets/today_workout_card.dart';

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
  Future<int> fetchTodaySteps() async => 6500;

  @override
  Future<List<HeartRateRecord>> fetchHeartRate({
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    final now = DateTime.now();
    return [
      HeartRateRecord(
        bpm: 72,
        timestamp: now.subtract(const Duration(hours: 1)),
        source: 'Google Health Connect',
      ),
      HeartRateRecord(
        bpm: 76,
        timestamp: now.subtract(const Duration(hours: 2)),
        source: 'Google Health Connect',
      ),
    ];
  }

  @override
  Future<List<SleepRecord>> fetchSleep({
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    final now = DateTime.now();
    return [
      SleepRecord(
        startTime: now.subtract(const Duration(hours: 8)),
        endTime: now,
        source: 'Google Health Connect',
        stages: [
          SleepStageRecord(
            stage: SleepStageType.deep,
            startTime: now.subtract(const Duration(hours: 8)),
            endTime: now.subtract(const Duration(hours: 6)),
          ),
          SleepStageRecord(
            stage: SleepStageType.light,
            startTime: now.subtract(const Duration(hours: 6)),
            endTime: now,
          ),
        ],
      ),
    ];
  }

  @override
  Future<HealthDataSummary> fetchHealthData({
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    final now = DateTime.now();
    return HealthDataSummary(
      totalStepsToday: 6500,
      stepRecords: const [],
      latestHeartRate: HeartRateRecord(
        bpm: 72,
        timestamp: now.subtract(const Duration(hours: 1)),
        source: 'Google Health Connect',
      ),
      heartRateHistory: [
        HeartRateRecord(
          bpm: 72,
          timestamp: now.subtract(const Duration(hours: 1)),
          source: 'Google Health Connect',
        ),
      ],
      latestSleep: SleepRecord(
        startTime: now.subtract(const Duration(hours: 8)),
        endTime: now,
        source: 'Google Health Connect',
      ),
      sleepHistory: const [],
      exerciseRecords: [
        ExerciseRecord(
          activityName: 'Outdoor Running',
          duration: const Duration(minutes: 42),
          startTime: now.subtract(const Duration(days: 2)),
          endTime: now.subtract(const Duration(days: 2, minutes: -42)),
          distanceMeters: 5400,
          caloriesBurned: 430,
          source: 'Google Health Connect',
        ),
      ],
      latestHrv: HrvRecord(
        rmssdMillis: 48,
        timestamp: now,
        source: 'Google Health Connect',
      ),
      latestRestingHeartRate: RestingHeartRateRecord(
        bpm: 62,
        timestamp: now,
        source: 'Google Health Connect',
      ),
      lastFetched: now,
    );
  }
}

void main() {
  testWidgets('RunningCoachPage renders all core running coach cards cleanly',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'daily_step_goal': 10000});
    final prefs = await SharedPreferences.getInstance();
    final mockRepo = MockHealthRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          healthConnectRepositoryProvider.overrideWithValue(mockRepo),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: RunningCoachPage(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Pelatih Lari Cerdas'), findsOneWidget);
    expect(find.text('Rekomendasi Lari Hari Ini'), findsOneWidget);
    expect(find.text('Target Lari Mingguan'), findsOneWidget);

    // Scroll to reveal remaining cards in outer ListView
    await tester.scrollUntilVisible(
      find.text('5 Zona Detak Jantung Lari'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('5 Zona Detak Jantung Lari'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Pencegahan Cedera & Overtraining'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Pencegahan Cedera & Overtraining'), findsOneWidget);
  });

  testWidgets('MainScreen navigates to Pelatih Lari tab via bottom nav bar and compact dashboard banner',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'daily_step_goal': 10000});
    final prefs = await SharedPreferences.getInstance();
    final mockRepo = MockHealthRepository();

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

    // 1. Verify CompactRunningBanner exists on Dashboard
    expect(find.text('Pelatih Lari'), findsWidgets); // Nav label & banner header

    // 2. Tap on Pelatih Lari bottom navigation tab
    await tester.tap(find.byIcon(Icons.directions_run_outlined));
    await tester.pumpAndSettle();

    // Verify we are on RunningCoachPage
    expect(find.byType(RunningCoachPage), findsOneWidget);
    expect(find.byType(TodayWorkoutCard), findsOneWidget);

    // Scroll to reveal RunningZonesCard
    final runningList = find.descendant(
      of: find.byType(RunningCoachPage),
      matching: find.byType(ListView),
    );
    await tester.drag(runningList.first, const Offset(0, -400));
    await tester.pumpAndSettle();

    expect(find.text('5 Zona Detak Jantung Lari'), findsOneWidget);
  });
}
