import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/editorial_ui.dart';
import '../../../health_connect/domain/models/health_models.dart';

class ActivityMetricsCard extends StatelessWidget {
  final HealthDataSummary summary;

  const ActivityMetricsCard({
    super.key,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.suhatColors;
    final activeCal = summary.totalActiveCaloriesToday;
    final totalCal = summary.totalCaloriesBurnedToday;
    final distanceKm = summary.distanceKmToday;
    final floors = summary.totalFloorsClimbedToday;
    final workouts = summary.exerciseRecords;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: c.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.hairline, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: Wrap(
              spacing: 8,
              runSpacing: 6,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kalori, Jarak & Olahraga',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: c.inkPrimary,
                      ),
                    ),
                    Text(
                      'Akumulasi energi dan sesi latihan',
                      style: TextStyle(
                        fontSize: 12,
                        color: c.inkSecondary,
                      ),
                    ),
                  ],
                ),
                EditorialStatusTag(
                  label: 'Hari Ini',
                  color: c.accentPine,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          EditorialMetricStrip(
            collapseBreakpoint: 290,
            items: [
              EditorialMetricItem(
                label: 'Kalori Aktif',
                value: activeCal > 0 ? '${activeCal.round()}' : '--',
                unit: 'kkal',
                subtext: 'Gerak fisik',
                valueColor: c.statusCaution,
              ),
              EditorialMetricItem(
                label: 'Total Kalori',
                value: totalCal > 0 ? '${totalCal.round()}' : '--',
                unit: 'kkal',
                subtext: 'Aktif + BMR',
                valueColor: c.statusAlert,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(height: 1, thickness: 1, color: c.hairline),
          const SizedBox(height: 14),
          EditorialMetricStrip(
            collapseBreakpoint: 290,
            items: [
              EditorialMetricItem(
                label: 'Jarak Tempuh',
                value: distanceKm > 0 ? distanceKm.toStringAsFixed(2) : '--',
                unit: 'km',
                subtext: summary.totalDistanceToday > 0
                    ? '${summary.totalDistanceToday.round()} meter'
                    : 'Belum tercatat',
                valueColor: c.accentPine,
              ),
              EditorialMetricItem(
                label: 'Elevasi Dinaiki',
                value: floors > 0 ? '${floors.round()}' : '--',
                unit: 'lantai',
                subtext: 'Floors climbed',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(height: 1, thickness: 1, color: c.hairline),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  'Sesi Latihan / Olahraga',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: c.inkPrimary,
                  ),
                ),
                Text(
                  '${workouts.length} sesi',
                  style: TextStyle(
                    fontSize: 11,
                    color: c.inkSecondary,
                    fontFeatures: AppTheme.tabularNumbers,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (workouts.isEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              width: double.infinity,
              decoration: BoxDecoration(
                color: c.surfaceSubtle,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Belum ada sesi olahraga dalam 7 hari terakhir di Health Connect. Mulai olahraga di jam Supercalla MG5 dan sinkronkan FitBeing untuk melihat riwayatnya di sini.',
                style: TextStyle(
                  fontSize: 12,
                  color: c.inkSecondary,
                  height: 1.4,
                ),
              ),
            )
          else ...[
            for (int i = 0; i < (workouts.length > 5 ? 5 : workouts.length); i++) ...[
              _buildWorkoutRow(workouts[i], c),
              if (i < (workouts.length > 5 ? 5 : workouts.length) - 1)
                Divider(height: 1, thickness: 1, color: c.hairline),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildWorkoutRow(ExerciseRecord w, SuhatColors c) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  w.activityName,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: c.inkPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${DateFormatter.formatDateTime(w.startTime)} WIB',
                  style: TextStyle(
                    fontSize: 11,
                    color: c.inkSecondary,
                    fontFeatures: AppTheme.tabularNumbers,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                DateFormatter.formatDuration(w.duration),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: c.accentPine,
                  fontFeatures: AppTheme.tabularNumbers,
                ),
              ),
              if (w.caloriesBurned != null)
                Text(
                  '${w.caloriesBurned!.round()} kkal',
                  style: TextStyle(
                    fontSize: 11,
                    color: c.inkSecondary,
                    fontFeatures: AppTheme.tabularNumbers,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
