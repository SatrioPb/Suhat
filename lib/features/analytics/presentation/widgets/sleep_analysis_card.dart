import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/editorial_ui.dart';
import '../../domain/models/sleep_analysis.dart';

class SleepAnalysisCard extends StatelessWidget {
  final SleepAnalysis analysis;

  const SleepAnalysisCard({
    super.key,
    required this.analysis,
  });

  @override
  Widget build(BuildContext context) {
    if (!analysis.hasData) {
      return const SizedBox.shrink();
    }

    final c = context.suhatColors;
    final durationColor =
        EditorialStatusColors.sleepDuration(analysis.durationCategory, c);

    // Bangun daftar segmen tahapan tidur non-nol
    final segments = <_SleepBarSegment>[
      if (analysis.deepSleepPercent.round() > 0)
        _SleepBarSegment(
          label: 'Deep',
          percent: analysis.deepSleepPercent,
          color: c.inkPrimary,
        ),
      if (analysis.remSleepPercent.round() > 0)
        _SleepBarSegment(
          label: 'REM',
          percent: analysis.remSleepPercent,
          color: c.accentPine,
        ),
      if (analysis.lightSleepPercent.round() > 0)
        _SleepBarSegment(
          label: 'Light',
          percent: analysis.lightSleepPercent,
          color: c.controlBorder,
        ),
      if (analysis.awakePercent.round() > 0)
        _SleepBarSegment(
          label: 'Awake',
          percent: analysis.awakePercent,
          color: c.statusCaution,
        ),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
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
              runSpacing: 6,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Analisis Kualitas Tidur',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: c.inkPrimary,
                      ),
                    ),
                    if (analysis.sessionStart != null &&
                        analysis.sessionEnd != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        '${DateFormatter.formatDateTime(analysis.sessionStart!)} - ${DateFormatter.formatTime(analysis.sessionEnd!)} WIB',
                        style: TextStyle(
                          fontSize: 11,
                          color: c.inkSecondary,
                          fontFeatures: AppTheme.tabularNumbers,
                        ),
                      ),
                    ],
                  ],
                ),
                EditorialStatusTag(
                  label: analysis.durationCategory.shortLabel,
                  color: durationColor,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            analysis.summaryDescription,
            style: TextStyle(
              fontSize: 12,
              color: c.inkPrimary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          EditorialMetricStrip(
            items: [
              EditorialMetricItem(
                label: 'Durasi Efektif',
                value: DateFormatter.formatDuration(analysis.effectiveDuration),
                valueColor: c.accentPine,
              ),
              EditorialMetricItem(
                label: 'Total di Ranjang',
                value: DateFormatter.formatDuration(analysis.totalDuration),
              ),
              EditorialMetricItem(
                label: 'Efisiensi Tidur',
                value: '${analysis.efficiencyPercentage.toStringAsFixed(1)}%',
                valueColor: analysis.efficiencyPercentage >= 85
                    ? c.accentPine
                    : c.statusCaution,
              ),
            ],
          ),
          if (analysis.hasStages && segments.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Proporsi Tahapan Tidur',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: c.inkPrimary,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 8,
              child: Row(
                children: [
                  for (int i = 0; i < segments.length; i++) ...[
                    Expanded(
                      flex: segments[i].percent.round().clamp(1, 100),
                      child: Container(
                        decoration: BoxDecoration(
                          color: segments[i].color,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    if (i < segments.length - 1) const SizedBox(width: 3),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 14,
              runSpacing: 6,
              children: segments
                  .map(
                    (s) => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 9,
                          height: 9,
                          decoration: BoxDecoration(
                            color: s.color,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '${s.label} ${s.percent.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: c.inkPrimary,
                            fontFeatures: AppTheme.tabularNumbers,
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _SleepBarSegment {
  final String label;
  final double percent;
  final Color color;

  const _SleepBarSegment({
    required this.label,
    required this.percent,
    required this.color,
  });
}
