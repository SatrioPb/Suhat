import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/editorial_ui.dart';
import '../../domain/models/health_models.dart';

class HeartRateCard extends StatelessWidget {
  final HeartRateRecord? latestRecord;
  final List<HeartRateRecord> history;

  const HeartRateCard({
    super.key,
    required this.latestRecord,
    required this.history,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.suhatColors;
    int? minBpm;
    int? maxBpm;
    int? avgBpm;

    if (history.isNotEmpty) {
      final bpms = history.map((e) => e.bpm).toList();
      minBpm = bpms.reduce((curr, next) => curr < next ? curr : next);
      maxBpm = bpms.reduce((curr, next) => curr > next ? curr : next);
      avgBpm = (bpms.reduce((a, b) => a + b) / bpms.length).round();
    }

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
              runSpacing: 4,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  'Detak Jantung (Heart Rate)',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: c.inkPrimary,
                  ),
                ),
                Text(
                  '${history.length} data',
                  style: TextStyle(
                    fontSize: 11,
                    color: c.inkSecondary,
                    fontFeatures: AppTheme.tabularNumbers,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          if (latestRecord == null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: c.surfaceSubtle,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Belum ada rekaman detak jantung dalam 24 jam terakhir di Health Connect. Pastikan sensor denyut jam Supercalla MG5 menyala dan sinkronkan FitBeing.',
                style: TextStyle(
                  fontSize: 12,
                  color: c.inkSecondary,
                  height: 1.4,
                ),
              ),
            )
          else ...[
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.end,
              spacing: 6,
              children: [
                Text(
                  '${latestRecord!.bpm}',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    color: c.statusAlert,
                    letterSpacing: -0.8,
                    fontFeatures: AppTheme.tabularNumbers,
                  ),
                ),
                Text(
                  'BPM terkini',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: c.inkSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Diukur ${DateFormatter.formatDateTime(latestRecord!.timestamp)} WIB • ${latestRecord!.source}',
              style: TextStyle(
                fontSize: 11,
                color: c.inkSecondary,
                fontFeatures: AppTheme.tabularNumbers,
              ),
            ),
            if (history.length > 1) ...[
              const SizedBox(height: 14),
              EditorialMetricStrip(
                items: [
                  EditorialMetricItem(label: 'Min', value: '$minBpm', unit: 'BPM'),
                  EditorialMetricItem(
                      label: 'Rata-rata', value: '$avgBpm', unit: 'BPM'),
                  EditorialMetricItem(label: 'Maks', value: '$maxBpm', unit: 'BPM'),
                ],
              ),
            ],
            const SizedBox(height: 12),
            for (int i = 0; i < (history.length > 4 ? 4 : history.length); i++) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormatter.formatDateTime(history[i].timestamp),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: c.inkPrimary,
                              fontFeatures: AppTheme.tabularNumbers,
                            ),
                          ),
                          Text(
                            history[i].source,
                            style: TextStyle(
                              fontSize: 11,
                              color: c.inkSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${history[i].bpm} BPM',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: c.statusAlert,
                        fontFeatures: AppTheme.tabularNumbers,
                      ),
                    ),
                  ],
                ),
              ),
              if (i < (history.length > 4 ? 4 : history.length) - 1)
                Divider(height: 1, thickness: 1, color: c.hairline),
            ],
          ],
        ],
      ),
    );
  }
}
