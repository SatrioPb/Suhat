import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/models/heart_rate_analysis.dart';

class HeartRateAnalysisCard extends StatelessWidget {
  final HeartRateAnalysis analysis;

  const HeartRateAnalysisCard({
    super.key,
    required this.analysis,
  });

  @override
  Widget build(BuildContext context) {
    if (!analysis.hasData) {
      return const SizedBox.shrink();
    }

    final color = _getStatusColor(analysis.status);

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
                    color: AppTheme.accentRed.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.monitor_heart,
                    color: AppTheme.accentRed,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Analisis Detak Jantung',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Evaluasi beban kardiovaskular',
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
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: color.withOpacity(0.3)),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        analysis.status.shortLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              analysis.statusDescription,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textDark,
                height: 1.35,
              ),
            ),
            if (analysis.latestMeasurementTime != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Pengukuran terbaru: ${DateFormatter.formatDateTime(analysis.latestMeasurementTime!)} WIB',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textMuted,
                  ),
                ),
              ),
            const Divider(height: 24, color: AppTheme.borderSubtle),
            const Text(
              'Distribusi Zona Denyut Jantung:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildZoneTile('Istirahat', analysis.zones.restingCount,
                    AppTheme.primaryTeal),
                const SizedBox(width: 8),
                _buildZoneTile('Fat Burn', analysis.zones.fatBurnCount,
                    AppTheme.accentGreen),
                const SizedBox(width: 8),
                _buildZoneTile('Kardio', analysis.zones.cardioCount,
                    AppTheme.accentAmber),
                const SizedBox(width: 8),
                _buildZoneTile(
                    'Puncak', analysis.zones.peakCount, AppTheme.accentRed),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZoneTile(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
            const Text(
              'sampel',
              style: TextStyle(
                fontSize: 9,
                color: AppTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(HeartRateStatus status) {
    switch (status) {
      case HeartRateStatus.normal:
        return AppTheme.accentGreen;
      case HeartRateStatus.elevated:
        return AppTheme.accentAmber;
      case HeartRateStatus.bradycardia:
        return AppTheme.accentIndigo;
      case HeartRateStatus.tachycardia:
        return AppTheme.accentRed;
      case HeartRateStatus.insufficientData:
        return AppTheme.textMuted;
    }
  }
}
