import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suhat/app/providers.dart';
import 'package:suhat/core/theme/app_theme.dart';
import 'package:suhat/features/dashboard/widgets/compact_running_banner.dart';
import 'package:suhat/features/running_coach/domain/models/running_plan.dart';
import 'package:suhat/features/weather_aqi/domain/models/weather_aqi_models.dart';
import 'package:suhat/features/weather_aqi/presentation/controllers/weather_aqi_controller.dart';
import 'package:suhat/features/weather_aqi/presentation/widgets/city_picker_bottom_sheet.dart';
import 'package:suhat/features/weather_aqi/presentation/widgets/outdoor_weather_aqi_card.dart';

void main() {
  const dummyWeather = WeatherData(
    temperature: 24.5,
    apparentTemperature: 25.0,
    relativeHumidity: 60,
    weatherCode: 0,
    windSpeed: 8.5,
    precipitation: 0.0,
  );

  const dummyAqi = AirQualityData(
    usAqi: 35,
    pm25: 8.5,
    pm10: 12.0,
    level: AirQualityLevel.good,
  );

  final dummyCondition = OutdoorRunningCondition.evaluate(
    weather: dummyWeather,
    airQuality: dummyAqi,
    locationName: 'Jakarta',
    latitude: -6.2088,
    longitude: 106.8456,
  );

  testWidgets('OutdoorWeatherAqiCard renders all metrics cleanly when condition is loaded',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          weatherAqiControllerProvider.overrideWith(
            (ref) => FakeWeatherAqiController(
              WeatherAqiState(
                isLoading: false,
                condition: dummyCondition,
                selectedLocation: PresetLocation.defaultLocation,
              ),
            ),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: SingleChildScrollView(
              child: OutdoorWeatherAqiCard(),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Title & Location
    expect(find.text('Cuaca & Kualitas Udara'), findsOneWidget);
    expect(find.text('Jakarta'), findsOneWidget);

    // Verify Feasibility Banner
    expect(find.textContaining('Kondisi Sangat Baik'), findsOneWidget);
    expect(find.textContaining('Cerah'), findsOneWidget);

    // Verify Metric Tiles
    expect(find.text('Suhu Luar'), findsOneWidget);
    expect(find.text('25°C'), findsOneWidget);
    expect(find.text('Kualitas Udara'), findsOneWidget);
    expect(find.text('AQI 35'), findsOneWidget);
    expect(find.text('Kelembapan'), findsOneWidget);
    expect(find.text('60%'), findsOneWidget);
    expect(find.text('Angin & Presipitasi'), findsOneWidget);
    expect(find.text('9 km/j'), findsOneWidget);

    // Verify Physiological running guide
    expect(find.text('Panduan Fisiologis & Hidrasi:'), findsOneWidget);
    expect(find.textContaining('efisiensi kardiovaskular'), findsOneWidget);
  });

  testWidgets('CityPickerBottomSheet displays preset cities and allows selection',
      (WidgetTester tester) async {
    PresetLocation? selected;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                CityPickerBottomSheet.show(
                  context,
                  selectedLocation: PresetLocation.defaultLocation,
                  onSelectLocation: (loc) => selected = loc,
                );
              },
              child: const Text('Buka Modal'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Buka Modal'));
    await tester.pumpAndSettle();

    expect(find.text('Pilih Lokasi Lari'), findsOneWidget);
    expect(find.text('Bandung'), findsOneWidget);
    expect(find.text('Surabaya'), findsOneWidget);
    expect(find.text('Yogyakarta'), findsOneWidget);

    // Tap on Bandung
    await tester.tap(find.text('Bandung'));
    await tester.pumpAndSettle();

    expect(selected?.name, 'Bandung');
  });

  testWidgets('CompactRunningBanner displays weather & AQI badge when condition is loaded',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    const recommendation = RunningWorkoutRecommendation(
      workoutType: RunningWorkoutType.easyRun,
      title: 'Easy Base Run (Zona 2)',
      targetDurationMinutes: 35,
      targetDistanceKm: 4.5,
      targetZoneLabel: 'Zona 2 (138-150 BPM)',
      rationale: 'Kondisi tubuh optimal.',
      pacingTips: 'Santai.',
      warmupCooldown: 'Pemanasan 5 mnt.',
      checklist: ['Minum air'],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          weatherAqiControllerProvider.overrideWith(
            (ref) => FakeWeatherAqiController(
              WeatherAqiState(
                isLoading: false,
                condition: dummyCondition,
                selectedLocation: PresetLocation.defaultLocation,
              ),
            ),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: CompactRunningBanner(
              recommendation: recommendation,
              onTapViewCoach: () {},
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Pelatih Lari'), findsOneWidget);
    expect(find.text('Easy Base Run (Zona 2)'), findsOneWidget);
    expect(find.text('25°C'), findsOneWidget);
    expect(find.text('AQI 35'), findsOneWidget);
  });

  testWidgets('OutdoorWeatherAqiCard renders explicit loading and error retry states',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    // 1. Loading State
    await tester.pumpWidget(
      ProviderScope(
        key: const ValueKey('loading-scope'),
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          weatherAqiControllerProvider.overrideWith(
            (ref) => FakeWeatherAqiController(
              const WeatherAqiState(
                isLoading: true,
                condition: null,
                selectedLocation: PresetLocation.defaultLocation,
              ),
            ),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: OutdoorWeatherAqiCard(),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Mengambil data cuaca & AQI real-time...'), findsOneWidget);

    // 2. Error State with Retry Action
    final retryController = FakeWeatherAqiController(
      const WeatherAqiState(
        isLoading: false,
        condition: null,
        errorMessage: 'Koneksi gagal',
        selectedLocation: PresetLocation.defaultLocation,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        key: const ValueKey('error-scope'),
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          weatherAqiControllerProvider.overrideWith((ref) => retryController),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: OutdoorWeatherAqiCard(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Koneksi gagal'), findsOneWidget);
    expect(find.text('Coba Lagi'), findsOneWidget);
    await tester.tap(find.text('Coba Lagi'));
    expect(retryController.fetchCalled, isTrue);
  });
}

class FakeWeatherAqiController extends StateNotifier<WeatherAqiState>
    implements WeatherAqiController {
  bool fetchCalled = false;
  FakeWeatherAqiController(super.state);

  @override
  Future<void> fetchCondition({PresetLocation? location, bool forceRefresh = false}) async {
    fetchCalled = true;
  }

  @override
  Future<void> changeLocation(PresetLocation newLocation) async {}
}
