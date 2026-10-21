import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:suhat/features/weather_aqi/data/services/weather_aqi_service.dart';
import 'package:suhat/features/weather_aqi/domain/models/weather_aqi_models.dart';

void main() {
  group('Weather & AQI Models & Physiological Logic Tests', () {
    test('AirQualityLevel.fromAqi categorizes index accurately', () {
      expect(AirQualityLevel.fromAqi(25), AirQualityLevel.good);
      expect(AirQualityLevel.fromAqi(50), AirQualityLevel.good);
      expect(AirQualityLevel.fromAqi(75), AirQualityLevel.moderate);
      expect(AirQualityLevel.fromAqi(100), AirQualityLevel.moderate);
      expect(AirQualityLevel.fromAqi(125), AirQualityLevel.unhealthyForSensitive);
      expect(AirQualityLevel.fromAqi(150), AirQualityLevel.unhealthyForSensitive);
      expect(AirQualityLevel.fromAqi(175), AirQualityLevel.unhealthy);
      expect(AirQualityLevel.fromAqi(200), AirQualityLevel.unhealthy);
      expect(AirQualityLevel.fromAqi(250), AirQualityLevel.veryUnhealthy);
      expect(AirQualityLevel.fromAqi(350), AirQualityLevel.hazardous);
    });

    test('WeatherData.fromJson correctly extracts WMO codes and metrics', () {
      final json = {
        'temperature_2m': 27.5,
        'apparent_temperature': 30.1,
        'relative_humidity_2m': 65,
        'weather_code': 2,
        'wind_speed_10m': 11.2,
        'precipitation': 0.0,
      };

      final data = WeatherData.fromJson(json);

      expect(data.temperature, 27.5);
      expect(data.apparentTemperature, 30.1);
      expect(data.relativeHumidity, 65);
      expect(data.weatherCode, 2);
      expect(data.weatherDescription, 'Cerah Berawan');
      expect(data.windSpeed, 11.2);
      expect(data.precipitation, 0.0);
    });

    test('AirQualityData.fromJson correctly maps US AQI and PM metrics', () {
      final json = {
        'us_aqi': 42,
        'pm2_5': 9.8,
        'pm10': 15.2,
      };

      final data = AirQualityData.fromJson(json);

      expect(data.usAqi, 42);
      expect(data.pm25, 9.8);
      expect(data.pm10, 15.2);
      expect(data.level, AirQualityLevel.good);
    });

    test('OutdoorRunningCondition.evaluate identifies optimal condition', () {
      const weather = WeatherData(
        temperature: 24.0,
        apparentTemperature: 25.0,
        relativeHumidity: 60,
        weatherCode: 1,
        windSpeed: 8.0,
        precipitation: 0.0,
      );

      const aqi = AirQualityData(
        usAqi: 35,
        pm25: 8.0,
        pm10: 12.0,
        level: AirQualityLevel.good,
      );

      final result = OutdoorRunningCondition.evaluate(
        weather: weather,
        airQuality: aqi,
        locationName: 'Bandung',
        latitude: -6.9175,
        longitude: 107.6191,
      );

      expect(result.feasibility, RunningFeasibility.optimal);
      expect(result.recommendationAdvice, contains('sangat prima'));
    });

    test('OutdoorRunningCondition.evaluate detects high heat stress and cardiac drift risk', () {
      const weather = WeatherData(
        temperature: 33.0,
        apparentTemperature: 37.0, // High apparent temp
        relativeHumidity: 75,      // High humidity
        weatherCode: 0,
        windSpeed: 5.0,
        precipitation: 0.0,
      );

      const aqi = AirQualityData(
        usAqi: 65,
        pm25: 18.0,
        pm10: 25.0,
        level: AirQualityLevel.moderate,
      );

      final result = OutdoorRunningCondition.evaluate(
        weather: weather,
        airQuality: aqi,
        locationName: 'Jakarta',
        latitude: -6.2088,
        longitude: 106.8456,
      );

      expect(result.feasibility, RunningFeasibility.caution);
      expect(result.recommendationAdvice, contains('Cardiac Drift'));
      expect(result.heatStressNote, contains('dehidrasi'));
    });

    test('OutdoorRunningCondition.evaluate flags poor air quality as not recommended', () {
      const weather = WeatherData(
        temperature: 28.0,
        apparentTemperature: 29.0,
        relativeHumidity: 55,
        weatherCode: 1,
        windSpeed: 6.0,
        precipitation: 0.0,
      );

      const aqi = AirQualityData(
        usAqi: 165, // Unhealthy
        pm25: 85.0,
        pm10: 120.0,
        level: AirQualityLevel.unhealthy,
      );

      final result = OutdoorRunningCondition.evaluate(
        weather: weather,
        airQuality: aqi,
        locationName: 'Jakarta',
        latitude: -6.2088,
        longitude: 106.8456,
      );

      expect(result.feasibility, RunningFeasibility.notRecommended);
      expect(result.recommendationAdvice, contains('ventilasi paru'));
    });

    test('OutdoorRunningCondition.evaluate flags storm or heavy rain as not recommended', () {
      const weather = WeatherData(
        temperature: 23.0,
        apparentTemperature: 23.0,
        relativeHumidity: 90,
        weatherCode: 95, // Thunderstorm
        windSpeed: 25.0,
        precipitation: 12.0,
      );

      const aqi = AirQualityData(
        usAqi: 20,
        pm25: 4.0,
        pm10: 6.0,
        level: AirQualityLevel.good,
      );

      final result = OutdoorRunningCondition.evaluate(
        weather: weather,
        airQuality: aqi,
        locationName: 'Bogor',
        latitude: -6.5971,
        longitude: 106.8060,
      );

      expect(result.feasibility, RunningFeasibility.notRecommended);
      expect(result.recommendationAdvice, contains('badai petir'));
    });
  });

  group('WeatherAqiService HTTP Integration Tests', () {
    test('fetchOutdoorCondition parses both endpoints into OutdoorRunningCondition', () async {
      final mockClient = MockClient((request) async {
        if (request.url.host == 'api.open-meteo.com') {
          return http.Response(
            jsonEncode({
              'current': {
                'temperature_2m': 28.2,
                'apparent_temperature': 31.0,
                'relative_humidity_2m': 62,
                'weather_code': 1,
                'wind_speed_10m': 7.5,
                'precipitation': 0.0,
              }
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        } else if (request.url.host == 'air-quality-api.open-meteo.com') {
          return http.Response(
            jsonEncode({
              'current': {
                'us_aqi': 45,
                'pm2_5': 11.0,
                'pm10': 18.0,
              }
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('Not Found', 404);
      });

      final service = WeatherAqiService(client: mockClient);

      final condition = await service.fetchOutdoorCondition(
        latitude: -6.2088,
        longitude: 106.8456,
        locationName: 'Jakarta',
      );

      expect(condition.locationName, 'Jakarta');
      expect(condition.weather.temperature, 28.2);
      expect(condition.airQuality.usAqi, 45);
      expect(condition.feasibility, RunningFeasibility.acceptable);
    });

    test('fetchOutdoorCondition throws Exception on HTTP error', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Server error', 500);
      });

      final service = WeatherAqiService(client: mockClient);

      expect(
        () => service.fetchOutdoorCondition(
          latitude: -6.2088,
          longitude: 106.8456,
          locationName: 'Jakarta',
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
