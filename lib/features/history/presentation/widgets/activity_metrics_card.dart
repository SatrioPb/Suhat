import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../health_connect/domain/models/health_models.dart';

class ActivityMetricsCard extends StatelessWidget {
  final HealthDataSummary summary;

  const ActivityMetricsCard({
    super.key,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final activeCal = summary.totalActiveCaloriesToday;
    final totalCal = summary.totalCaloriesBurnedToday;
    final distanceKm = summary.distanceKmToday;
    final floors = summary.totalFloorsClimbedToday;
    final workouts = summary.exerciseRecords;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.accentAmber.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.local_fire_department,
                    color: AppTheme.accentAmber,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kalori, Jarak & Olahraga',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Aktivitas Fisik & Beban Energi',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 105),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.accentAmber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: AppTheme.accentAmber.withOpacity(0.3)),
                    ),
                    child: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Hari Ini',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accentAmber,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Grid 2x2: Kalori Aktif, Total Kalori, Jarak, Elevasi
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
                    label: 'Kalori Aktif',
                    value: activeCal > 0 ? '${activeCal.round()}' : '--',
                    unit: 'kkal',
                    color: AppTheme.accentAmber,
                    subtext: 'Energi gerak fisik',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricItem(
                    label: 'Total Kalori',
                    value: totalCal > 0 ? '${totalCal.round()}' : '--',
                    unit: 'kkal',
                    color: AppTheme.accentRed,
                    subtext: 'Aktif + Basal (BMR)',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
                    label: 'Jarak Tempuh',
                    value: distanceKm > 0 ? distanceKm.toStringAsFixed(2) : '--',
                    unit: 'km',
                    color: AppTheme.primaryTeal,
                    subtext: summary.totalDistanceToday > 0
                        ? '${summary.totalDistanceToday.round()} meter'
                        : 'Belum ada data',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricItem(
                    label: 'Elevasi Dinaiki',
                    value: floors > 0 ? '${floors.round()}' : '--',
                    unit: 'lantai',
                    color: AppTheme.accentIndigo,
                    subtext: 'Floors climbed',
                  ),
                ),
              ],
            ),

            // Daftar Sesi Olahraga
            const Divider(height: 24, color: AppTheme.borderSubtle),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Sesi Latihan / Olahraga:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                Text(
                  '${workouts.length} sesi',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (workouts.isEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Belum ada sesi latihan atau olahraga yang tercatat dalam 7 hari terakhir di Health Connect.',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.textMuted,
                  ),
                ),
              )
            else
              ...workouts.take(5).map((w) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.borderSubtle),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.sports,
                            size: 16,
                            color: AppTheme.primaryTeal,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  w.activityName,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textDark,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${DateFormatter.formatDateTime(w.startTime)} WIB',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppTheme.textMuted,
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
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryTeal,
                                ),
                              ),
                              if (w.caloriesBurned != null)
                                Text(
                                  '${w.caloriesBurned!.round()} kkal',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppTheme.textMuted,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem({
    required String label,
    required String value,
    required String unit,
    required Color color,
    required String subtext,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppTheme.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                if (unit.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  Text(
                    unit,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtext,
            style: const TextStyle(
              fontSize: 9,
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
