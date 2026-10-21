import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/models/weather_aqi_models.dart';

/// Layanan pengambil data cuaca dan kualitas udara terbuka dari Open-Meteo
class WeatherAqiService {
  final http.Client _client;

  WeatherAqiService({http.Client? client}) : _client = client ?? http.Client();

  /// Mengambil data cuaca dan kualitas udara terkini secara real-time
  Future<OutdoorRunningCondition> fetchOutdoorCondition({
    required double latitude,
    required double longitude,
    required String locationName,
  }) async {
    final weatherUri = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
      '?latitude=$latitude&longitude=$longitude'
      '&current=temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m'
      '&timezone=auto',
    );

    final aqiUri = Uri.parse(
      'https://air-quality-api.open-meteo.com/v1/air-quality'
      '?latitude=$latitude&longitude=$longitude'
      '&current=us_aqi,pm2_5,pm10'
      '&timezone=auto',
    );

    try {
      // Panggil kedua API secara paralel untuk kecepatan maksimal
      final responses = await Future.wait([
        _client.get(weatherUri).timeout(const Duration(seconds: 10)),
        _client.get(aqiUri).timeout(const Duration(seconds: 10)),
      ]);

      final weatherRes = responses[0];
      final aqiRes = responses[1];

      if (weatherRes.statusCode != 200) {
        throw Exception(
          'Gagal memuat data cuaca (HTTP ${weatherRes.statusCode}). Silakan coba beberapa saat lagi.',
        );
      }

      if (aqiRes.statusCode != 200) {
        throw Exception(
          'Gagal memuat data kualitas udara (HTTP ${aqiRes.statusCode}). Silakan coba beberapa saat lagi.',
        );
      }

      final weatherJson = jsonDecode(weatherRes.body) as Map<String, dynamic>;
      final aqiJson = jsonDecode(aqiRes.body) as Map<String, dynamic>;

      final currentWeatherData = weatherJson['current'] as Map<String, dynamic>? ?? {};
      final currentAqiData = aqiJson['current'] as Map<String, dynamic>? ?? {};

      final weather = WeatherData.fromJson(currentWeatherData);
      final airQuality = AirQualityData.fromJson(currentAqiData);

      return OutdoorRunningCondition.evaluate(
        weather: weather,
        airQuality: airQuality,
        locationName: locationName,
        latitude: latitude,
        longitude: longitude,
      );
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Terjadi kendala koneksi saat mengambil data cuaca: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}
