import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Tingkat Kualitas Udara (Air Quality Index - US AQI Standard)
enum AirQualityLevel {
  good,
  moderate,
  unhealthyForSensitive,
  unhealthy,
  veryUnhealthy,
  hazardous;

  static AirQualityLevel fromAqi(int aqi) {
    if (aqi <= 50) return AirQualityLevel.good;
    if (aqi <= 100) return AirQualityLevel.moderate;
    if (aqi <= 150) return AirQualityLevel.unhealthyForSensitive;
    if (aqi <= 200) return AirQualityLevel.unhealthy;
    if (aqi <= 300) return AirQualityLevel.veryUnhealthy;
    return AirQualityLevel.hazardous;
  }

  String get label {
    switch (this) {
      case AirQualityLevel.good:
        return 'Sangat Baik';
      case AirQualityLevel.moderate:
        return 'Sedang';
      case AirQualityLevel.unhealthyForSensitive:
        return 'Sensitif';
      case AirQualityLevel.unhealthy:
        return 'Tidak Sehat';
      case AirQualityLevel.veryUnhealthy:
        return 'Sangat Buruk';
      case AirQualityLevel.hazardous:
        return 'Berbahaya';
    }
  }

  Color resolveColor(SuhatColors colors) {
    switch (this) {
      case AirQualityLevel.good:
        return colors.accentPine;
      case AirQualityLevel.moderate:
      case AirQualityLevel.unhealthyForSensitive:
        return colors.statusCaution;
      case AirQualityLevel.unhealthy:
      case AirQualityLevel.veryUnhealthy:
      case AirQualityLevel.hazardous:
        return colors.statusAlert;
    }
  }

  Color get color => resolveColor(SuhatColors.light);

  String get description {
    switch (this) {
      case AirQualityLevel.good:
        return 'Udara bersih & segar. Sangat ideal untuk olahraga lari luar ruangan.';
      case AirQualityLevel.moderate:
        return 'Kualitas udara dapat diterima. Aman bagi sebagian besar pelari.';
      case AirQualityLevel.unhealthyForSensitive:
        return 'Dapat mengiritasi saluran pernapasan pelari dengan riwayat asma atau alergi.';
      case AirQualityLevel.unhealthy:
        return 'Udara tidak sehat. Disarankan berlari di dalam ruangan (treadmill).';
      case AirQualityLevel.veryUnhealthy:
        return 'Peringatan kesehatan. Hindari olahraga luar ruangan berdurasi lama.';
      case AirQualityLevel.hazardous:
        return 'Kondisi udara darurat. Wajib hindari aktivitas luar ruangan.';
    }
  }
}

/// Kelayakan Kondisi Cuaca untuk Olahraga Lari Luar Ruangan
enum RunningFeasibility {
  optimal,
  acceptable,
  caution,
  notRecommended;

  String get label {
    switch (this) {
      case RunningFeasibility.optimal:
        return 'Kondisi Sangat Baik';
      case RunningFeasibility.acceptable:
        return 'Cukup Baik';
      case RunningFeasibility.caution:
        return 'Perlu Perhatian';
      case RunningFeasibility.notRecommended:
        return 'Tidak Disarankan';
    }
  }

  Color resolveColor(SuhatColors colors) {
    switch (this) {
      case RunningFeasibility.optimal:
      case RunningFeasibility.acceptable:
        return colors.accentPine;
      case RunningFeasibility.caution:
        return colors.statusCaution;
      case RunningFeasibility.notRecommended:
        return colors.statusAlert;
    }
  }

  Color get color => resolveColor(SuhatColors.light);

  IconData get icon {
    switch (this) {
      case RunningFeasibility.optimal:
        return Icons.verified;
      case RunningFeasibility.acceptable:
        return Icons.check_circle_outline;
      case RunningFeasibility.caution:
        return Icons.warning_amber_rounded;
      case RunningFeasibility.notRecommended:
        return Icons.cancel_outlined;
    }
  }
}

/// Data Cuaca Terkini dari Open-Meteo
class WeatherData {
  final double temperature;
  final double apparentTemperature;
  final int relativeHumidity;
  final int weatherCode;
  final double windSpeed;
  final double precipitation;

  const WeatherData({
    required this.temperature,
    required this.apparentTemperature,
    required this.relativeHumidity,
    required this.weatherCode,
    required this.windSpeed,
    required this.precipitation,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      temperature: (json['temperature_2m'] as num?)?.toDouble() ?? 0.0,
      apparentTemperature: (json['apparent_temperature'] as num?)?.toDouble() ??
          (json['temperature_2m'] as num?)?.toDouble() ??
          0.0,
      relativeHumidity: (json['relative_humidity_2m'] as num?)?.toInt() ?? 0,
      weatherCode: (json['weather_code'] as num?)?.toInt() ?? 0,
      windSpeed: (json['wind_speed_10m'] as num?)?.toDouble() ?? 0.0,
      precipitation: (json['precipitation'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Deskripsi cuaca berdasarkan WMO Weather Interpretation Codes
  String get weatherDescription {
    if (weatherCode == 0) return 'Cerah';
    if (weatherCode == 1) return 'Sebagian Besar Cerah';
    if (weatherCode == 2) return 'Cerah Berawan';
    if (weatherCode == 3) return 'Mendung Berawan';
    if (weatherCode == 45 || weatherCode == 48) return 'Berkabut';
    if (weatherCode >= 51 && weatherCode <= 57) return 'Gerimis';
    if (weatherCode >= 61 && weatherCode <= 65) return 'Hujan';
    if (weatherCode >= 80 && weatherCode <= 82) return 'Hujan Deras';
    if (weatherCode >= 95) return 'Badai Petir';
    return 'Berawan';
  }

  IconData get weatherIcon {
    if (weatherCode == 0) return Icons.wb_sunny;
    if (weatherCode == 1 || weatherCode == 2) return Icons.wb_cloudy;
    if (weatherCode == 3) return Icons.cloud;
    if (weatherCode == 45 || weatherCode == 48) return Icons.foggy;
    if (weatherCode >= 51 && weatherCode <= 57) return Icons.grain;
    if (weatherCode >= 61 && weatherCode <= 67) return Icons.water_drop;
    if (weatherCode >= 80 && weatherCode <= 82) return Icons.thunderstorm;
    if (weatherCode >= 95) return Icons.flash_on;
    return Icons.cloud_queue;
  }
}

/// Data Kualitas Udara Terkini dari Open-Meteo Air Quality
class AirQualityData {
  final int usAqi;
  final double pm25;
  final double pm10;
  final AirQualityLevel level;

  const AirQualityData({
    required this.usAqi,
    required this.pm25,
    required this.pm10,
    required this.level,
  });

  factory AirQualityData.fromJson(Map<String, dynamic> json) {
    final aqi = (json['us_aqi'] as num?)?.toInt() ?? 25;
    final pm25Val = (json['pm2_5'] as num?)?.toDouble() ?? 0.0;
    final pm10Val = (json['pm10'] as num?)?.toDouble() ?? 0.0;

    return AirQualityData(
      usAqi: aqi,
      pm25: pm25Val,
      pm10: pm10Val,
      level: AirQualityLevel.fromAqi(aqi),
    );
  }
}

/// Kondisi Gabungan Cuaca, Kualitas Udara, dan Rekomendasi Fisiologis Lari
class OutdoorRunningCondition {
  final WeatherData weather;
  final AirQualityData airQuality;
  final String locationName;
  final double latitude;
  final double longitude;
  final DateTime updatedAt;
  final RunningFeasibility feasibility;
  final String recommendationAdvice;
  final String heatStressNote;

  const OutdoorRunningCondition({
    required this.weather,
    required this.airQuality,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.updatedAt,
    required this.feasibility,
    required this.recommendationAdvice,
    required this.heatStressNote,
  });

  /// Evaluasi kelayakan lari dan saran fisiologis komprehensif
  factory OutdoorRunningCondition.evaluate({
    required WeatherData weather,
    required AirQualityData airQuality,
    required String locationName,
    required double latitude,
    required double longitude,
    DateTime? timestamp,
  }) {
    final time = timestamp ?? DateTime.now();

    // 1. Cek Badai & Hujan Ekstrem
    if (weather.weatherCode >= 95 || weather.precipitation >= 5.0) {
      return OutdoorRunningCondition(
        weather: weather,
        airQuality: airQuality,
        locationName: locationName,
        latitude: latitude,
        longitude: longitude,
        updatedAt: time,
        feasibility: RunningFeasibility.notRecommended,
        recommendationAdvice:
            'Cuaca berisiko (hujan deras/badai petir). Jalur lari licin dan jarak pandang rendah. '
            'Sangat disarankan beralih ke latihan dalam ruangan (treadmill atau latihan kekuatan otot inti).',
        heatStressNote: 'Prioritaskan keselamatan dari petir dan permukaan jalan licin.',
      );
    }

    // 2. Cek Kualitas Udara Buruk (AQI > 150)
    if (airQuality.usAqi > 150) {
      return OutdoorRunningCondition(
        weather: weather,
        airQuality: airQuality,
        locationName: locationName,
        latitude: latitude,
        longitude: longitude,
        updatedAt: time,
        feasibility: RunningFeasibility.notRecommended,
        recommendationAdvice:
            'Indeks Kualitas Udara tidak sehat (AQI ${airQuality.usAqi}, PM2.5 ${airQuality.pm25.toStringAsFixed(1)} µg/m³). '
            'Saat berlari, volume ventilasi paru meningkat hingga 10x lipat sehingga partikel polusi masuk lebih dalam. Sebaiknya lari di ruang ber-AC.',
        heatStressNote: 'Hindari hiperventilasi di udara terbuka saat polusi pekat.',
      );
    }

    // 3. Cek Kelembapan & Suhu Terasa (Heat Index & Cardiac Drift)
    final feelsLike = weather.apparentTemperature;
    final humidity = weather.relativeHumidity;
    final isHighHeatStress = feelsLike >= 33.0 && humidity >= 65;
    final isModerateHeatStress = feelsLike >= 30.0;

    if (isHighHeatStress || airQuality.usAqi > 100) {
      return OutdoorRunningCondition(
        weather: weather,
        airQuality: airQuality,
        locationName: locationName,
        latitude: latitude,
        longitude: longitude,
        updatedAt: time,
        feasibility: RunningFeasibility.caution,
        recommendationAdvice:
            'Suhu terasa panas (${feelsLike.toStringAsFixed(1)}°C) dengan kelembapan tinggi ($humidity%). '
            'Tubuh sulit mendinginkan diri melalui penguapan keringat, memicu "Cardiac Drift" (detak jantung naik 5-10 BPM lebih tinggi pada pace yang sama). '
            'Turunkan pace target 15-20 detik/km dan perbanyak hidrasi elektrolit.',
        heatStressNote:
            'Waspadai dehidrasi cepat. Minum 150-250 ml air setiap 15-20 menit berlari.',
      );
    }

    if (isModerateHeatStress || weather.precipitation > 0.5) {
      return OutdoorRunningCondition(
        weather: weather,
        airQuality: airQuality,
        locationName: locationName,
        latitude: latitude,
        longitude: longitude,
        updatedAt: time,
        feasibility: RunningFeasibility.acceptable,
        recommendationAdvice:
            'Kondisi cukup baik untuk berlari santai (Zona 2 Easy Run). '
            '${weather.precipitation > 0 ? "Terdapat rintik gerimis ringan, gunakan topi lari pelindung mata. " : ""}'
            'Kualitas udara tergolong aman (AQI ${airQuality.usAqi}). Pastikan pendinginan optimal setelah selesai.',
        heatStressNote: 'Pemanasan dinamis 5 menit sebelum memulai sesi lari.',
      );
    }

    // 4. Kondisi Optimal / Prima
    return OutdoorRunningCondition(
      weather: weather,
      airQuality: airQuality,
      locationName: locationName,
      latitude: latitude,
      longitude: longitude,
      updatedAt: time,
      feasibility: RunningFeasibility.optimal,
      recommendationAdvice:
          'Kondisi udara dan cuaca sangat prima untuk berlari di luar ruangan! '
          'Suhu sejuk (${weather.temperature.toStringAsFixed(1)}°C) dan udara bersih (AQI ${airQuality.usAqi}) '
          'sangat mendukung efisiensi kardiovaskular dan menjaga detak jantung tetap stabil di zona target.',
      heatStressNote: 'Cuaca sempurna untuk latihan lari berkualitas atau long run santai.',
    );
  }
}

/// Lokasi Pilihan / Preset Pelari Indonesia
class PresetLocation {
  final String name;
  final String subtitle;
  final double latitude;
  final double longitude;

  const PresetLocation({
    required this.name,
    required this.subtitle,
    required this.latitude,
    required this.longitude,
  });

  static const PresetLocation defaultLocation = PresetLocation(
    name: 'Jakarta',
    subtitle: 'GBK / Monas / Sudirman',
    latitude: -6.2088,
    longitude: 106.8456,
  );

  static const List<PresetLocation> defaultPresets = [
    defaultLocation,
    PresetLocation(
      name: 'Bandung',
      subtitle: 'Gasibu / Dago / Saparua',
      latitude: -6.9175,
      longitude: 107.6191,
    ),
    PresetLocation(
      name: 'Surabaya',
      subtitle: 'Taman Bungkul / Kenjeran',
      latitude: -7.2575,
      longitude: 112.7521,
    ),
    PresetLocation(
      name: 'Yogyakarta',
      subtitle: 'UGM / Malioboro / Kaliurang',
      latitude: -7.7956,
      longitude: 110.3695,
    ),
    PresetLocation(
      name: 'Semarang',
      subtitle: 'Simpang Lima / Gombel',
      latitude: -6.9667,
      longitude: 110.4167,
    ),
    PresetLocation(
      name: 'Denpasar / Bali',
      subtitle: 'Sanur / Renon / Kuta',
      latitude: -8.6705,
      longitude: 115.2126,
    ),
    PresetLocation(
      name: 'Bogor',
      subtitle: 'Kebun Raya / Sempur',
      latitude: -6.5971,
      longitude: 106.8060,
    ),
    PresetLocation(
      name: 'Malang',
      subtitle: 'Ijen / Rampal',
      latitude: -7.9666,
      longitude: 112.6326,
    ),
    PresetLocation(
      name: 'Medan',
      subtitle: 'Lapangan Merdeka / Polonia',
      latitude: -3.5952,
      longitude: 98.6722,
    ),
    PresetLocation(
      name: 'Makassar',
      subtitle: 'Pantai Losari / Karebosi',
      latitude: -5.1477,
      longitude: 119.4327,
    ),
  ];
}
