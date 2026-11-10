import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/editorial_ui.dart';
import '../../domain/models/weather_aqi_models.dart';
import '../controllers/weather_aqi_controller.dart';
import 'city_picker_bottom_sheet.dart';

class OutdoorWeatherAqiCard extends ConsumerWidget {
  const OutdoorWeatherAqiCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.suhatColors;
    final weatherState = ref.watch(weatherAqiControllerProvider);
    final controller = ref.read(weatherAqiControllerProvider.notifier);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.surfaceSubtle,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cuaca & Kualitas Udara',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: c.inkPrimary,
                      ),
                    ),
                    Text(
                      'Kondisi lari luar ruangan',
                      style: TextStyle(
                        fontSize: 11,
                        color: c.inkSecondary,
                      ),
                    ),
                  ],
                ),
                // Pemilih lokasi dengan area sentuh minimal 44x44px (R-03)
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 44, minWidth: 44),
                  child: InkWell(
                    onTap: () {
                      CityPickerBottomSheet.show(
                        context,
                        selectedLocation: weatherState.selectedLocation,
                        onSelectLocation: (loc) => controller.changeLocation(loc),
                      );
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: c.surfaceElevated,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: c.controlBorder, width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 15,
                            color: c.accentPine,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            weatherState.selectedLocation.name,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: c.inkPrimary,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Icon(
                            Icons.arrow_drop_down,
                            size: 16,
                            color: c.inkSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          if (weatherState.isLoading && weatherState.condition == null) ...[
            _buildLoadingState(c),
          ] else if (weatherState.errorMessage != null &&
              weatherState.condition == null) ...[
            _buildErrorState(
              c,
              weatherState.errorMessage!,
              () => controller.fetchCondition(forceRefresh: true),
            ),
          ] else if (weatherState.condition != null) ...[
            _buildConditionContent(
              context,
              c,
              weatherState.condition!,
              controller,
              weatherState.isLoading,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingState(SuhatColors c) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: c.accentPine,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Mengambil data cuaca & AQI real-time...',
            style: TextStyle(fontSize: 12, color: c.inkSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    SuhatColors c,
    String message,
    VoidCallback onRetry,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.surfaceElevated,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: c.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.cloud_off, size: 16, color: c.statusCaution),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(fontSize: 12, color: c.inkPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 15),
              label: const Text('Coba Lagi'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConditionContent(
    BuildContext context,
    SuhatColors c,
    OutdoorRunningCondition condition,
    WeatherAqiController controller,
    bool isRefreshing,
  ) {
    final weather = condition.weather;
    final aqi = condition.airQuality;
    final feasibility = condition.feasibility;
    final feasColor = feasibility.resolveColor(c);
    final aqiColor = aqi.level.resolveColor(c);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Baris Kelayakan Lari + Refresh >= 44x44px
        Row(
          children: [
            Expanded(
              child: EditorialStatusTag(
                label: '${feasibility.label} • ${weather.weatherDescription}',
                color: feasColor,
                icon: feasibility.icon,
              ),
            ),
            const SizedBox(width: 6),
            IconButton(
              tooltip: 'Muat ulang cuaca & AQI',
              onPressed: isRefreshing
                  ? null
                  : () => controller.fetchCondition(forceRefresh: true),
              icon: isRefreshing
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: c.accentPine,
                      ),
                    )
                  : Icon(Icons.refresh, size: 18, color: c.inkSecondary),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // 4 Metrik Cuaca & AQI Responsif
        EditorialMetricStrip(
          collapseBreakpoint: 300,
          items: [
            EditorialMetricItem(
              label: 'Suhu Luar',
              value: '${weather.temperature.toStringAsFixed(0)}°C',
              subtext:
                  'Terasa ${weather.apparentTemperature.toStringAsFixed(0)}°C',
            ),
            EditorialMetricItem(
              label: 'Kualitas Udara',
              value: 'AQI ${aqi.usAqi}',
              subtext: '${aqi.level.label} (PM2.5: ${aqi.pm25.toStringAsFixed(0)})',
              valueColor: aqiColor,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Divider(height: 1, thickness: 1, color: c.hairline),
        const SizedBox(height: 12),
        EditorialMetricStrip(
          collapseBreakpoint: 300,
          items: [
            EditorialMetricItem(
              label: 'Kelembapan',
              value: '${weather.relativeHumidity}%',
              subtext: weather.relativeHumidity >= 70
                  ? 'Lembap (waspadai dehidrasi)'
                  : 'Optimal',
            ),
            EditorialMetricItem(
              label: 'Angin & Presipitasi',
              value: '${weather.windSpeed.toStringAsFixed(0)} km/j',
              subtext: weather.precipitation > 0
                  ? 'Hujan: ${weather.precipitation.toStringAsFixed(1)} mm'
                  : 'Kering',
            ),
          ],
        ),

        const SizedBox(height: 14),
        Divider(height: 1, thickness: 1, color: c.hairline),
        const SizedBox(height: 12),

        Text(
          'Panduan Fisiologis & Hidrasi:',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: c.inkPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          condition.recommendationAdvice,
          style: TextStyle(
            fontSize: 12,
            color: c.inkPrimary,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Catatan: ${condition.heatStressNote}',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: c.inkSecondary,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}
