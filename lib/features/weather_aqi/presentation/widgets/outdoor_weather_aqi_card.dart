import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/weather_aqi_models.dart';
import '../controllers/weather_aqi_controller.dart';
import 'city_picker_bottom_sheet.dart';

class OutdoorWeatherAqiCard extends ConsumerWidget {
  const OutdoorWeatherAqiCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherState = ref.watch(weatherAqiControllerProvider);
    final controller = ref.read(weatherAqiControllerProvider.notifier);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Judul & Pemilih Lokasi
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryTeal.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.cloud_outlined,
                      color: AppTheme.primaryTeal,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cuaca & Kualitas Udara',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      Text(
                        'Kondisi Lari Luar Ruangan (AQI)',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Tombol Pemilih Lokasi (Kota)
              InkWell(
                onTap: () {
                  CityPickerBottomSheet.show(
                    context,
                    selectedLocation: weatherState.selectedLocation,
                    onSelectLocation: (loc) => controller.changeLocation(loc),
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.borderSubtle),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: AppTheme.primaryTeal,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        weatherState.selectedLocation.name,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const Icon(
                        Icons.arrow_drop_down,
                        size: 16,
                        color: AppTheme.textMuted,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // State Handler: Loading, Error, atau Content
          if (weatherState.isLoading && weatherState.condition == null) ...[
            _buildLoadingState(),
          ] else if (weatherState.errorMessage != null && weatherState.condition == null) ...[
            _buildErrorState(weatherState.errorMessage!, () {
              controller.fetchCondition(forceRefresh: true);
            }),
          ] else if (weatherState.condition != null) ...[
            _buildConditionContent(context, weatherState.condition!, controller, weatherState.isLoading),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      alignment: Alignment.center,
      child: const Column(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryTeal),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Mengambil data cuaca & AQI real-time...',
            style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message, VoidCallback onRetry) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.accentAmber.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.cloud_off, size: 16, color: AppTheme.accentAmber),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(fontSize: 11, color: AppTheme.textDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 14),
              label: const Text('Coba Lagi', style: TextStyle(fontSize: 11)),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryTeal,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConditionContent(
    BuildContext context,
    OutdoorRunningCondition condition,
    WeatherAqiController controller,
    bool isRefreshing,
  ) {
    final weather = condition.weather;
    final aqi = condition.airQuality;
    final feasibility = condition.feasibility;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Feasibility Banner (Kelayakan Lari Luar Ruangan)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: feasibility.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: feasibility.color.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(feasibility.icon, size: 18, color: feasibility.color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${feasibility.label} • ${weather.weatherDescription}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: feasibility.color,
                  ),
                ),
              ),
              if (isRefreshing) ...[
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryTeal),
                  ),
                ),
              ] else ...[
                InkWell(
                  onTap: () => controller.fetchCondition(forceRefresh: true),
                  child: const Icon(
                    Icons.refresh,
                    size: 16,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 12),

        // 2. Grid 4 Metrik Utama Cuaca & Kualitas Udara
        Row(
          children: [
            // Metrik 1: Suhu & Terasa
            Expanded(
              child: _buildMetricTile(
                icon: weather.weatherIcon,
                iconColor: AppTheme.accentAmber,
                label: 'Suhu Luar',
                value: '${weather.temperature.toStringAsFixed(0)}°C',
                subtext: 'Terasa ${weather.apparentTemperature.toStringAsFixed(0)}°C',
              ),
            ),
            const SizedBox(width: 8),
            // Metrik 2: Kualitas Udara (AQI)
            Expanded(
              child: _buildMetricTile(
                icon: Icons.air,
                iconColor: aqi.level.color,
                label: 'Kualitas Udara',
                value: 'AQI ${aqi.usAqi}',
                subtext: '${aqi.level.label} (PM2.5: ${aqi.pm25.toStringAsFixed(0)})',
                valueColor: aqi.level.color,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        Row(
          children: [
            // Metrik 3: Kelembapan
            Expanded(
              child: _buildMetricTile(
                icon: Icons.water_drop_outlined,
                iconColor: AppTheme.primaryTeal,
                label: 'Kelembapan',
                value: '${weather.relativeHumidity}%',
                subtext: weather.relativeHumidity >= 70
                    ? 'Lembap (Risiko Dehidrasi)'
                    : 'Optimal',
              ),
            ),
            const SizedBox(width: 8),
            // Metrik 4: Angin & Hujan
            Expanded(
              child: _buildMetricTile(
                icon: Icons.speed,
                iconColor: AppTheme.accentGreen,
                label: 'Angin & Presipitasi',
                value: '${weather.windSpeed.toStringAsFixed(0)} km/j',
                subtext: weather.precipitation > 0
                    ? 'Hujan: ${weather.precipitation.toStringAsFixed(1)} mm'
                    : 'Kering',
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // 3. Catatan Fisiologis & Tips Pelari
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.surfaceLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.directions_run,
                    size: 15,
                    color: AppTheme.primaryTeal,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Panduan Fisiologis & Hidrasi:',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                condition.recommendationAdvice,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textDark,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '• ${condition.heatStressNote}',
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textMuted,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required String subtext,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: iconColor),
              const SizedBox(width: 5),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppTheme.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: valueColor ?? AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtext,
            style: const TextStyle(
              fontSize: 9.5,
              color: AppTheme.textMuted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
