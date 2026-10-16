import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_formatter.dart';
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

    final durationColor = _getDurationColor(analysis.durationCategory);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.accentIndigo.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.nights_stay,
                    color: AppTheme.accentIndigo,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Analisis Kualitas Tidur',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Evaluasi efisiensi & tahapan',
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
                      color: durationColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: durationColor.withOpacity(0.3)),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        analysis.durationCategory.shortLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: durationColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              analysis.summaryDescription,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textDark,
                height: 1.35,
              ),
            ),
            if (analysis.sessionStart != null && analysis.sessionEnd != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Sesi: ${DateFormatter.formatDateTime(analysis.sessionStart!)} - ${DateFormatter.formatTime(analysis.sessionEnd!)} WIB',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textMuted,
                  ),
                ),
              ),
            const Divider(height: 24, color: AppTheme.borderSubtle),
            Row(
              children: [
                Expanded(
                  child: _buildMetricColumn(
                    'Durasi Efektif',
                    DateFormatter.formatDuration(analysis.effectiveDuration),
                    AppTheme.primaryTeal,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricColumn(
                    'Total di Ranjang',
                    DateFormatter.formatDuration(analysis.totalDuration),
                    AppTheme.textMuted,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricColumn(
                    'Efisiensi Tidur',
                    '${analysis.efficiencyPercentage.toStringAsFixed(1)}%',
                    analysis.efficiencyPercentage >= 85
                        ? AppTheme.accentGreen
                        : AppTheme.accentAmber,
                  ),
                ),
              ],
            ),
            if (analysis.hasStages) ...[
              const SizedBox(height: 16),
              const Text(
                'Proporsi Tahapan Tidur:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SizedBox(
                  height: 10,
                  child: Row(
                    children: [
                      if (analysis.deepSleepPercent.round() > 0)
                        Expanded(
                          flex: analysis.deepSleepPercent.round(),
                          child: Container(color: const Color(0xFF3B82F6)),
                        ),
                      if (analysis.remSleepPercent.round() > 0)
                        Expanded(
                          flex: analysis.remSleepPercent.round(),
                          child: Container(color: const Color(0xFF8B5CF6)),
                        ),
                      if (analysis.lightSleepPercent.round() > 0)
                        Expanded(
                          flex: analysis.lightSleepPercent.round(),
                          child: Container(color: const Color(0xFF60A5FA)),
                        ),
                      if (analysis.awakePercent.round() > 0)
                        Expanded(
                          flex: analysis.awakePercent.round(),
                          child: Container(color: const Color(0xFFF59E0B)),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 4,
                children: [
                  _buildStageLegend('Deep', '${analysis.deepSleepPercent.toStringAsFixed(0)}%', const Color(0xFF3B82F6)),
                  _buildStageLegend('REM', '${analysis.remSleepPercent.toStringAsFixed(0)}%', const Color(0xFF8B5CF6)),
                  _buildStageLegend('Light', '${analysis.lightSleepPercent.toStringAsFixed(0)}%', const Color(0xFF60A5FA)),
                  _buildStageLegend('Awake', '${analysis.awakePercent.toStringAsFixed(0)}%', const Color(0xFFF59E0B)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetricColumn(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11,
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
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStageLegend(String label, String percent, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$label $percent',
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppTheme.textDark,
          ),
        ),
      ],
    );
  }

  Color _getDurationColor(SleepDurationCategory cat) {
    switch (cat) {
      case SleepDurationCategory.optimal:
        return AppTheme.accentGreen;
      case SleepDurationCategory.fair:
        return AppTheme.primaryTeal;
      case SleepDurationCategory.short:
        return AppTheme.accentAmber;
      case SleepDurationCategory.long:
        return AppTheme.accentIndigo;
      case SleepDurationCategory.noData:
        return AppTheme.textMuted;
    }
  }
}
