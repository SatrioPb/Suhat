import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../app/providers.dart';
import '../../data/services/weather_aqi_service.dart';
import '../../domain/models/weather_aqi_models.dart';

class WeatherAqiState {
  final bool isLoading;
  final OutdoorRunningCondition? condition;
  final String? errorMessage;
  final PresetLocation selectedLocation;

  const WeatherAqiState({
    this.isLoading = false,
    this.condition,
    this.errorMessage,
    this.selectedLocation = PresetLocation.defaultLocation,
  });

  WeatherAqiState copyWith({
    bool? isLoading,
    OutdoorRunningCondition? condition,
    String? errorMessage,
    PresetLocation? selectedLocation,
    bool clearError = false,
  }) {
    return WeatherAqiState(
      isLoading: isLoading ?? this.isLoading,
      condition: condition ?? this.condition,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      selectedLocation: selectedLocation ?? this.selectedLocation,
    );
  }
}

final weatherAqiServiceProvider = Provider<WeatherAqiService>((ref) {
  final service = WeatherAqiService();
  ref.onDispose(() => service.dispose());
  return service;
});

class WeatherAqiController extends StateNotifier<WeatherAqiState> {
  final WeatherAqiService _service;
  final SharedPreferences? _prefs;

  WeatherAqiController(this._service, [this._prefs]) : super(const WeatherAqiState()) {
    _initFromPreferences();
  }

  void _initFromPreferences() {
    if (_prefs != null) {
      final savedName = _prefs.getString('weather_loc_name');
      final savedLat = _prefs.getDouble('weather_loc_lat');
      final savedLng = _prefs.getDouble('weather_loc_lng');
      final savedSub = _prefs.getString('weather_loc_sub');

      if (savedName != null && savedLat != null && savedLng != null) {
        final loc = PresetLocation(
          name: savedName,
          subtitle: savedSub ?? '',
          latitude: savedLat,
          longitude: savedLng,
        );
        state = state.copyWith(selectedLocation: loc);
      }
    }

    // Ambil data cuaca saat startup
    fetchCondition();
  }

  /// Mengambil data cuaca & AQI terbaru
  Future<void> fetchCondition({
    PresetLocation? location,
    bool forceRefresh = false,
  }) async {
    final targetLoc = location ?? state.selectedLocation;

    // Jika data masih segar (< 15 menit) dan lokasi sama serta bukan force refresh, gunakan cache
    if (!forceRefresh &&
        state.condition != null &&
        state.selectedLocation.name == targetLoc.name) {
      final age = DateTime.now().difference(state.condition!.updatedAt);
      if (age.inMinutes < 15) {
        return;
      }
    }

    state = state.copyWith(
      isLoading: true,
      selectedLocation: targetLoc,
      clearError: true,
    );

    try {
      final condition = await _service.fetchOutdoorCondition(
        latitude: targetLoc.latitude,
        longitude: targetLoc.longitude,
        locationName: targetLoc.name,
      );

      state = state.copyWith(
        isLoading: false,
        condition: condition,
        selectedLocation: targetLoc,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  /// Mengganti kota/lokasi lari dan menyimpannya di SharedPreferences
  Future<void> changeLocation(PresetLocation newLocation) async {
    if (_prefs != null) {
      await _prefs.setString('weather_loc_name', newLocation.name);
      await _prefs.setDouble('weather_loc_lat', newLocation.latitude);
      await _prefs.setDouble('weather_loc_lng', newLocation.longitude);
      await _prefs.setString('weather_loc_sub', newLocation.subtitle);
    }

    await fetchCondition(location: newLocation, forceRefresh: true);
  }
}

final weatherAqiControllerProvider =
    StateNotifierProvider<WeatherAqiController, WeatherAqiState>((ref) {
  final service = ref.watch(weatherAqiServiceProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  return WeatherAqiController(service, prefs);
});
