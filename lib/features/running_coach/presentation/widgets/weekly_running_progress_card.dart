import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:suhat/core/theme/app_theme.dart';
import 'package:suhat/core/utils/date_formatter.dart';
import 'package:suhat/core/widgets/editorial_ui.dart';
import 'package:suhat/features/running_coach/domain/models/running_plan.dart';
import 'package:suhat/features/running_coach/presentation/controllers/running_coach_controller.dart';

class WeeklyRunningProgressCard extends ConsumerWidget {
  final WeeklyRunningSummary summary;

  const WeeklyRunningProgressCard({
    super.key,
    required this.summary,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.suhatColors;
    final progress = summary.weeklyProgressPercent;
    final isTargetMet =
        summary.completedRunsThisWeek >= summary.targetRunsPerWeek;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(height: 1, thickness: 1, color: c.hairline),
          const SizedBox(height: 16),
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
                      'Target Lari Mingguan',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: c.inkPrimary,
                      ),
                    ),
                    Text(
                      'Target ${summary.targetRunsPerWeek} sesi per minggu',
                      style: TextStyle(
                        fontSize: 12,
                        color: c.inkSecondary,
                      ),
                    ),
                  ],
                ),
                EditorialStatusTag(
                  label: isTargetMet ? 'Target Tercapai' : 'Aktif',
                  color: isTargetMet ? c.accentPine : c.inkSecondary,
                  icon: isTargetMet ? Icons.check_circle_outline : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Pilihan Target Mingguan Interaktif (3 atau 4 sesi)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Frekuensi:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: c.inkSecondary,
                ),
              ),
              for (final target in [3, 4, 5])
                ChoiceChip(
                  label: Text('${target}x / minggu'),
                  selected: summary.targetRunsPerWeek == target,
                  selectedColor: c.accentPine,
                  backgroundColor: c.surfaceSubtle,
                  side: BorderSide(
                    color: summary.targetRunsPerWeek == target
                        ? c.accentPine
                        : c.controlBorder,
                  ),
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: summary.targetRunsPerWeek == target
                        ? c.onAccentPine
                        : c.inkPrimary,
                    fontFeatures: AppTheme.tabularNumbers,
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.padded,
                  onSelected: (selected) {
                    if (selected) {
                      ref
                          .read(runningWeeklyTargetRunsProvider.notifier)
                          .setTarget(target);
                    }
                  },
                ),
            ],
          ),

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
                  '${summary.completedRunsThisWeek} dari ${summary.targetRunsPerWeek} sesi selesai',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: c.inkPrimary,
                    fontFeatures: AppTheme.tabularNumbers,
                  ),
                ),
                Text(
                  '${(progress * 100).round()}%',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: c.accentPine,
                    fontFeatures: AppTheme.tabularNumbers,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: c.surfaceSubtle,
              valueColor: AlwaysStoppedAnimation<Color>(c.accentPine),
            ),
          ),

          const SizedBox(height: 16),

          EditorialMetricStrip(
            collapseBreakpoint: 290,
            items: [
              EditorialMetricItem(
                label: 'Total Jarak',
                value: summary.totalWeeklyDistanceKm.toStringAsFixed(1),
                unit: 'km',
                valueColor: c.accentPine,
              ),
              EditorialMetricItem(
                label: 'Total Waktu',
                value: '${summary.totalWeeklyDuration.inMinutes}',
                unit: 'mnt',
              ),
              EditorialMetricItem(
                label: 'Kalori Lari',
                value: '${summary.totalCaloriesBurned.round()}',
                unit: 'kkal',
                valueColor: c.statusCaution,
              ),
            ],
          ),

          if (summary.overtrainingWarning != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: c.surfaceSubtle,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: c.statusCaution.withOpacity(0.5)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 16,
                    color: c.statusCaution,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      summary.overtrainingWarning!,
                      style: TextStyle(
                        fontSize: 12,
                        color: c.inkPrimary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (summary.recentRuns.isNotEmpty) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'Riwayat Sesi Lari Tercatat',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: c.inkPrimary,
                    ),
                  ),
                  Text(
                    '${summary.recentRuns.length} sesi',
                    style: TextStyle(
                      fontSize: 11,
                      color: c.inkSecondary,
                      fontFeatures: AppTheme.tabularNumbers,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            for (int i = 0;
                i <
                    (summary.recentRuns.length > 3
                        ? 3
                        : summary.recentRuns.length);
                i++) ...[
              _buildRunRow(summary.recentRuns[i], c),
              if (i <
                  (summary.recentRuns.length > 3
                          ? 3
                          : summary.recentRuns.length) -
                      1)
                Divider(height: 1, thickness: 1, color: c.hairline),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildRunRow(dynamic run, SuhatColors c) {
    final km = (run.distanceMeters ?? 0.0) / 1000.0;
    final mins = run.duration.inMinutes;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormatter.formatDateTime(run.startTime),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: c.inkPrimary,
                    fontFeatures: AppTheme.tabularNumbers,
                  ),
                ),
                Text(
                  run.activityName,
                  style: TextStyle(
                    fontSize: 11,
                    color: c.inkSecondary,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (km > 0) ...[
                Text(
                  '${km.toStringAsFixed(1)} km',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: c.accentPine,
                    fontFeatures: AppTheme.tabularNumbers,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                '$mins mnt',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: c.inkPrimary,
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
