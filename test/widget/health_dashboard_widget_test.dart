import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suhat/app/main_screen.dart';
import 'package:suhat/app/providers.dart';
import 'package:suhat/core/theme/app_theme.dart';
import 'package:suhat/core/theme/theme_controller.dart';
import 'package:suhat/features/analytics/pages/analytics_page.dart';
import 'package:suhat/features/health_connect/domain/models/health_models.dart';
import 'package:suhat/features/health_connect/domain/repositories/health_repository.dart';
import 'package:suhat/features/health_connect/presentation/controllers/health_controller.dart';
import 'package:suhat/features/weather_aqi/domain/models/weather_aqi_models.dart';
import 'package:suhat/features/weather_aqi/presentation/controllers/weather_aqi_controller.dart';
import 'package:suhat/main.dart';

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
      totalActiveCaloriesToday: 320.0,
      totalCaloriesBurnedToday: 1980.0,
      totalDistanceToday: 3950.0,
      totalFloorsClimbedToday: 8.0,
      exerciseRecords: [
        ExerciseRecord(
          activityName: 'Jalan Santai',
          duration: const Duration(minutes: 30),
          startTime: DateTime(2026, 10, 16, 6, 30),
          endTime: DateTime(2026, 10, 16, 7, 0),
          caloriesBurned: 120.0,
          distanceMeters: 2000.0,
          source: 'Google Health Connect',
        ),
      ],
      latestHrv: HrvRecord(
        rmssdMillis: 48.0,
        timestamp: DateTime(2026, 10, 16, 7, 0),
        source: 'Google Health Connect',
      ),
      latestRestingHeartRate: RestingHeartRateRecord(
        bpm: 64,
        timestamp: DateTime(2026, 10, 16, 7, 0),
        source: 'Google Health Connect',
      ),
      latestOxygenSaturation: OxygenSaturationRecord(
        percentage: 98.0,
        timestamp: DateTime(2026, 10, 16, 7, 0),
        source: 'Google Health Connect',
      ),
      latestWeight: WeightRecord(
        weightKg: 68.0,
        timestamp: DateTime(2026, 10, 16, 7, 0),
        source: 'Google Health Connect',
      ),
      latestHeight: HeightRecord(
        heightMeters: 1.72,
        timestamp: DateTime(2026, 10, 16, 7, 0),
        source: 'Google Health Connect',
      ),
      lastFetched: DateTime(2026, 10, 16, 9, 30),
    );
  }
}

class FakeWeatherController extends StateNotifier<WeatherAqiState>
    implements WeatherAqiController {
  FakeWeatherController()
      : super(
          const WeatherAqiState(
            isLoading: false,
            selectedLocation: PresetLocation.defaultLocation,
          ),
        );

  @override
  Future<void> fetchCondition({PresetLocation? location, bool forceRefresh = false}) async {}

  @override
  Future<void> changeLocation(PresetLocation newLocation) async {}
}

void main() {
  testWidgets(
      'MainScreen displays editorial minimalist dashboard and navigates across all tabs cleanly',
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
          weatherAqiControllerProvider.overrideWith((ref) => FakeWeatherController()),
        ],
        child: const SuhatApp(),
      ),
    );

    await tester.pumpAndSettle();

    // 1. Verify Minimalist Editorial Dashboard Content
    expect(find.text('Supercalla Health'), findsOneWidget);
    expect(find.text('Kesiapan Fisik'), findsOneWidget);
    expect(find.text('Langkah Hari Ini'), findsOneWidget);
    expect(find.text('5.230'), findsOneWidget);
    expect(find.text('Detak Jantung'), findsOneWidget);
    expect(find.text('74'), findsOneWidget);
    expect(find.text('Tidur Semalam'), findsOneWidget);
    expect(find.text('8j'), findsOneWidget);

    // Toggle Dark Mode from AppBar and verify theme switches without crash
    await tester.tap(find.byTooltip('Beralih ke Mode Gelap'));
    await tester.pumpAndSettle();
    final container = ProviderScope.containerOf(
      tester.element(find.byType(MainScreen)),
    );
    expect(container.read(themeModeProvider), ThemeMode.dark);
    expect(tester.takeException(), isNull);

    // Verify Navigation Destinations
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Analisis'), findsOneWidget);
    expect(find.text('Pelatih Lari'), findsWidgets);
    expect(find.text('Riwayat'), findsOneWidget);
    expect(find.text('Perangkat'), findsOneWidget);

    // 2. Switch to Analisis Tab (in Dark Mode!)
    await tester.tap(find.text('Analisis'));
    await tester.pumpAndSettle();

    expect(find.text('Analisis Kesehatan'), findsOneWidget);
    expect(find.text('Kesiapan & Pemulihan Fisik'), findsOneWidget);
    expect(find.text('Analisis Detak Jantung'), findsOneWidget);
    expect(find.text('Analisis Kualitas Tidur'), findsOneWidget);
    expect(find.text('Tanda Vital & Biometrik'), findsOneWidget);

    // 3. Switch to Riwayat Tab
    await tester.tap(find.text('Riwayat'));
    await tester.pumpAndSettle();

    expect(find.text('Riwayat Aktivitas & Vitalitas'), findsOneWidget);
    expect(find.text('Kalori, Jarak & Olahraga'), findsOneWidget);
    expect(find.text('Tanda Vital & Komposisi Tubuh'), findsOneWidget);

    // 4. Switch to Perangkat Tab and switch back to Light Mode + update step goal
    await tester.tap(find.text('Perangkat'));
    await tester.pumpAndSettle();

    expect(find.text('Perangkat & Pengaturan'), findsOneWidget);
    expect(find.text('Panduan Smartwatch Supercalla'), findsOneWidget);
    expect(find.text('Sumber Data: Google Health Connect'), findsOneWidget);

    await tester.tap(find.text('Terang'));
    await tester.pumpAndSettle();
    expect(container.read(themeModeProvider), ThemeMode.light);

    await tester.tap(find.text('12.000'));
    await tester.pumpAndSettle();
    expect(container.read(dailyStepGoalProvider), 12000);

    // Verify Dashboard reflects updated 12.000 goal
    await tester.tap(find.text('Dashboard'));
    await tester.pumpAndSettle();
    expect(find.text('dari 12.000 langkah'), findsOneWidget);
  });

  testWidgets(
      'Analisis and Dashboard hold up without overflow on compact 360x800 screen and 200% font scale',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'daily_step_goal': 10000});
    final prefs = await SharedPreferences.getInstance();
    final mockRepo = MockHealthRepository();

    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          healthConnectRepositoryProvider.overrideWithValue(mockRepo),
          weatherAqiControllerProvider.overrideWith((ref) => FakeWeatherController()),
        ],
        child: MediaQuery(
          data: const MediaQueryData(
            size: Size(360, 800),
            textScaler: TextScaler.linear(2.0),
          ),
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const MainScreen(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Switch to Analisis tab under 200% zoom and scroll
    await tester.tap(find.text('Analisis'));
    await tester.pumpAndSettle();

    expect(find.text('Analisis Kesehatan'), findsOneWidget);

    final analyticsScrollable = find.descendant(
      of: find.byType(AnalyticsPage),
      matching: find.byType(Scrollable),
    ).first;

    await tester.scrollUntilVisible(
      find.text('Analisis Detak Jantung'),
      300,
      scrollable: analyticsScrollable,
    );
    await tester.pumpAndSettle();

    expect(find.text('Analisis Detak Jantung'), findsOneWidget);

    // Check Pelatih Lari, Riwayat & Perangkat under 200% zoom as well
    await tester.tap(find.text('Pelatih Lari'));
    await tester.pumpAndSettle();
    expect(find.text('Rekomendasi Lari Hari Ini'), findsOneWidget);

    await tester.tap(find.text('Riwayat'));
    await tester.pumpAndSettle();
    expect(find.text('Riwayat Aktivitas & Vitalitas'), findsOneWidget);

    await tester.tap(find.text('Perangkat'));
    await tester.pumpAndSettle();
    expect(find.text('Perangkat & Pengaturan'), findsOneWidget);
  });
}
