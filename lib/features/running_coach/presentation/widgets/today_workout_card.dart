import 'package:flutter/material.dart';
import 'package:suhat/core/theme/app_theme.dart';
import 'package:suhat/core/widgets/editorial_ui.dart';
import 'package:suhat/features/running_coach/domain/models/running_plan.dart';

class TodayWorkoutCard extends StatelessWidget {
  final RunningWorkoutRecommendation recommendation;

  const TodayWorkoutCard({
    super.key,
    required this.recommendation,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.suhatColors;
    final workout = recommendation.workoutType;
    final color = workout.resolveColor(c);

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
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(workout.icon, color: color, size: 20),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Rekomendasi Lari Hari Ini',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: c.inkSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                EditorialStatusTag(
                  label: workout.shortLabel,
                  color: color,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            workout.label,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: c.inkPrimary,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 16),

          // Target Preskripsi (Responsive 3-Metric Strip)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: c.surfaceSubtle,
              borderRadius: BorderRadius.circular(8),
            ),
            child: EditorialMetricStrip(
              collapseBreakpoint: 290,
              items: [
                EditorialMetricItem(
                  label: 'Durasi Target',
                  value: recommendation.targetDurationMinutes > 0
                      ? '${recommendation.targetDurationMinutes}'
                      : 'Rest',
                  unit: recommendation.targetDurationMinutes > 0 ? 'mnt' : null,
                  valueColor: color,
                ),
                EditorialMetricItem(
                  label: 'Estimasi Jarak',
                  value: recommendation.targetDistanceKm != null
                      ? '${recommendation.targetDistanceKm}'
                      : '-',
                  unit: recommendation.targetDistanceKm != null ? 'km' : null,
                ),
                EditorialMetricItem(
                  label: 'Zona Target',
                  value: recommendation.targetZoneLabel.split('(').first.trim(),
                  valueColor: color,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'Analisis Fisiologis',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: c.inkPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            recommendation.rationale,
            style: TextStyle(
              fontSize: 12,
              color: c.inkSecondary,
              height: 1.45,
            ),
          ),

          const SizedBox(height: 14),
          Divider(height: 1, thickness: 1, color: c.hairline),
          const SizedBox(height: 12),

          Text(
            'Panduan Ritme (Pacing)',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            recommendation.pacingTips,
            style: TextStyle(
              fontSize: 12,
              color: c.inkPrimary,
              height: 1.4,
            ),
          ),

          if (recommendation.checklist.isNotEmpty) ...[
            const SizedBox(height: 14),
            Divider(height: 1, thickness: 1, color: c.hairline),
            const SizedBox(height: 12),
            Text(
              'Persiapan Sesi',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: c.inkPrimary,
              ),
            ),
            const SizedBox(height: 8),
            for (int i = 0; i < recommendation.checklist.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${i + 1}.',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: c.accentPine,
                        fontFeatures: AppTheme.tabularNumbers,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        recommendation.checklist[i],
                        style: TextStyle(
                          fontSize: 12,
                          color: c.inkPrimary,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}
