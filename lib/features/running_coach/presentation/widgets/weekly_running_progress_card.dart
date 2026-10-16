import 'package:flutter/material.dart';
import 'package:suhat/core/theme/app_theme.dart';
import 'package:suhat/core/utils/date_formatter.dart';
import 'package:suhat/features/running_coach/domain/models/running_plan.dart';

class WeeklyRunningProgressCard extends StatelessWidget {
  final WeeklyRunningSummary summary;

  const WeeklyRunningProgressCard({
    super.key,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final progress = summary.weeklyProgressPercent;
    final isTargetMet = summary.completedRunsThisWeek >= summary.targetRunsPerWeek;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Baris
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGreen.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.event_repeat,
                    color: AppTheme.accentGreen,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Target Lari Mingguan',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Target 3-4x seminggu (${summary.targetRunsPerWeek} sesi)',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isTargetMet
                        ? AppTheme.accentGreen.withOpacity(0.12)
                        : AppTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isTargetMet
                          ? AppTheme.accentGreen.withOpacity(0.3)
                          : AppTheme.borderSubtle,
                    ),
                  ),
                  child: Text(
                    isTargetMet ? 'Target Tercapai!' : 'Aktif',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isTargetMet ? AppTheme.accentGreen : AppTheme.textMuted,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Progress Bar & Counter
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${summary.completedRunsThisWeek} dari ${summary.targetRunsPerWeek} sesi selesai',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
                ),
                Text(
                  '${(progress * 100).round()}%',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryTeal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: AppTheme.surfaceLight,
                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accentGreen),
              ),
            ),

            const SizedBox(height: 14),

            // Statistik Akumulasi (Jarak, Durasi, Kalori)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.borderSubtle),
              ),
              child: Row(
                children: [
                  _buildStatTile(
                    'Total Jarak',
                    '${summary.totalWeeklyDistanceKm.toStringAsFixed(1)} Km',
                    AppTheme.primaryTeal,
                  ),
                  _buildDivider(),
                  _buildStatTile(
                    'Total Waktu',
                    '${summary.totalWeeklyDuration.inMinutes} Menit',
                    AppTheme.textDark,
                  ),
                  _buildDivider(),
                  _buildStatTile(
                    'Kalori Lari',
                    '${summary.totalCaloriesBurned.round()} Kcal',
                    AppTheme.accentAmber,
                  ),
                ],
              ),
            ),

            // Peringatan Beban Lari / Overtraining jika ada
            if (summary.overtrainingWarning != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.accentAmber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.accentAmber.withOpacity(0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      size: 16,
                      color: AppTheme.accentAmber,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        summary.overtrainingWarning!,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textDark,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Sesi Lari Terakhir
            if (summary.recentRuns.isNotEmpty) ...[
              const Divider(height: 24, color: AppTheme.borderSubtle),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Riwayat Sesi Lari Tercatat',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  Text(
                    '${summary.recentRuns.length} sesi',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: summary.recentRuns.length > 3 ? 3 : summary.recentRuns.length,
                separatorBuilder: (context, index) =>
                    const Divider(height: 10, color: AppTheme.borderSubtle),
                itemBuilder: (context, index) {
                  final run = summary.recentRuns[index];
                  final km = (run.distanceMeters ?? 0.0) / 1000.0;
                  final mins = run.duration.inMinutes;

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormatter.formatDateTime(run.startTime),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textDark,
                            ),
                          ),
                          Text(
                            run.activityName,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          if (km > 0)
                            Text(
                              '${km.toStringAsFixed(1)} Km  •  ',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryTeal,
                              ),
                            ),
                          Text(
                            '$mins m',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textDark,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatTile(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppTheme.textMuted,
              ),
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 20,
      color: AppTheme.borderSubtle,
    );
  }
}
