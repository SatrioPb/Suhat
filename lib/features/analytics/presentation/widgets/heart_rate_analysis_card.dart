import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/editorial_ui.dart';
import '../../domain/models/heart_rate_analysis.dart';

class HeartRateAnalysisCard extends StatelessWidget {
  final HeartRateAnalysis analysis;

  const HeartRateAnalysisCard({
    super.key,
    required this.analysis,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.suhatColors;
    if (!analysis.hasData) {
      return _buildEmptyState(c);
    }

    final statusColor = EditorialStatusColors.heartRate(analysis.status, c);
    final totalCount = analysis.zones.restingCount +
        analysis.zones.fatBurnCount +
        analysis.zones.cardioCount +
        analysis.zones.peakCount;

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
                      'Analisis Detak Jantung',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: c.inkPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${analysis.recordCount} rekaman denyut riil dianalisis',
                      style: TextStyle(
                        fontSize: 12,
                        color: c.inkSecondary,
                        fontFeatures: AppTheme.tabularNumbers,
                      ),
                    ),
                  ],
                ),
                EditorialStatusTag(
                  label: analysis.status.shortLabel,
                  color: statusColor,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            analysis.statusDescription,
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
                label: 'Terkini',
                value: '${analysis.latestBpm}',
                unit: 'BPM',
                valueColor: c.statusAlert,
              ),
              EditorialMetricItem(
                label: 'Rata-rata',
                value: '${analysis.avgBpm}',
                unit: 'BPM',
              ),
              EditorialMetricItem(
                label: 'Rentang',
                value: '${analysis.minBpm}-${analysis.maxBpm}',
                unit: 'BPM',
              ),
            ],
          ),
          if (analysis.latestMeasurementTime != null) ...[
            const SizedBox(height: 12),
            Text(
              'Pengukuran terakhir: ${DateFormatter.formatDateTime(analysis.latestMeasurementTime!)} WIB'
              '${analysis.latestSource != null && analysis.latestSource!.isNotEmpty ? " (${analysis.latestSource})" : ""}',
              style: TextStyle(
                fontSize: 11,
                color: c.inkSecondary,
                fontFeatures: AppTheme.tabularNumbers,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Text(
            'Distribusi Zona Denyut Jantung (${totalCount > 0 ? "$totalCount sampel" : "0 sampel"})',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: c.inkPrimary,
            ),
          ),
          const SizedBox(height: 10),
          _buildZoneRow(
            'Istirahat',
            analysis.zones.restingCount,
            totalCount,
            c.accentPine,
            c,
          ),
          _buildZoneRow(
            'Fat Burn',
            analysis.zones.fatBurnCount,
            totalCount,
            c.inkPrimary,
            c,
          ),
          _buildZoneRow(
            'Kardio',
            analysis.zones.cardioCount,
            totalCount,
            c.statusCaution,
            c,
          ),
          _buildZoneRow(
            'Puncak',
            analysis.zones.peakCount,
            totalCount,
            c.statusAlert,
            c,
          ),
        ],
      ),
    );
  }

  Widget _buildZoneRow(
    String label,
    int count,
    int total,
    Color barColor,
    SuhatColors c,
  ) {
    final ratio = total > 0 ? (count / total).clamp(0.0, 1.0) : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 68,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: c.inkPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 6,
                backgroundColor: c.surfaceSubtle,
                valueColor: AlwaysStoppedAnimation<Color>(barColor),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 34,
            child: Text(
              '$count',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: c.inkPrimary,
                fontFeatures: AppTheme.tabularNumbers,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(SuhatColors c) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(height: 1, thickness: 1, color: c.hairline),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Analisis Detak Jantung',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: c.inkPrimary,
                  ),
                ),
              ),
              EditorialStatusTag(
                label: 'Menunggu Data Riil',
                color: c.inkSecondary,
                icon: Icons.schedule,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Belum ada rekaman detak jantung asli yang terbaca dari Google Health Connect. '
            'Buka aplikasi FitBeing dan pastikan sinkronisasi ke Health Connect aktif agar data jam tangan terbaca di sini.',
            style: TextStyle(
              fontSize: 12,
              color: c.inkSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
