import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/editorial_ui.dart';
import '../../domain/models/health_models.dart';

class SleepCard extends StatelessWidget {
  final SleepRecord? latestSleep;
  final List<SleepRecord> sleepHistory;

  const SleepCard({
    super.key,
    required this.latestSleep,
    required this.sleepHistory,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.suhatColors;

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
              runSpacing: 4,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  'Tidur (Sleep)',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: c.inkPrimary,
                  ),
                ),
                Text(
                  'Health Connect',
                  style: TextStyle(
                    fontSize: 11,
                    color: c.inkSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          if (latestSleep == null)
            Text(
              'Belum ada sesi tidur dalam 48 jam terakhir di Health Connect. Kenakan jam Supercalla MG5 saat tidur dan buka aplikasi FitBeing untuk menyinkronkan data tidur.',
              style: TextStyle(
                fontSize: 12,
                color: c.inkSecondary,
                height: 1.4,
              ),
            )
          else ...[
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.end,
              spacing: 8,
              children: [
                Text(
                  DateFormatter.formatDuration(latestSleep!.totalDuration),
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: c.inkPrimary,
                    letterSpacing: -0.6,
                    fontFeatures: AppTheme.tabularNumbers,
                  ),
                ),
                Text(
                  'total tidur',
                  style: TextStyle(
                    fontSize: 13,
                    color: c.inkSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${DateFormatter.formatDateTime(latestSleep!.startTime)} - ${DateFormatter.formatTime(latestSleep!.endTime)} WIB • ${latestSleep!.source}',
              style: TextStyle(
                fontSize: 11,
                color: c.inkSecondary,
                fontFeatures: AppTheme.tabularNumbers,
              ),
            ),
            if (latestSleep!.stages.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                'Rincian Tahapan Tidur',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: c.inkPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: latestSleep!.stages.map((stage) {
                  final color = _stageColor(stage.stage, c);
                  return EditorialStatusTag(
                    label:
                        '${stage.stage.label}: ${DateFormatter.formatDuration(stage.duration)}',
                    color: color,
                  );
                }).toList(),
              ),
            ],
            if (sleepHistory.length > 1) ...[
              const SizedBox(height: 16),
              Divider(height: 1, thickness: 1, color: c.hairline),
              const SizedBox(height: 12),
              Text(
                'Sesi Tidur Sebelumnya',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: c.inkPrimary,
                ),
              ),
              const SizedBox(height: 6),
              for (int i = 1; i < (sleepHistory.length > 4 ? 4 : sleepHistory.length); i++) ...[
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
                              '${DateFormatter.formatDate(sleepHistory[i].startTime)} (${DateFormatter.formatTimeRange(sleepHistory[i].startTime, sleepHistory[i].endTime)})',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: c.inkPrimary,
                                fontFeatures: AppTheme.tabularNumbers,
                              ),
                            ),
                            Text(
                              sleepHistory[i].source,
                              style: TextStyle(
                                fontSize: 11,
                                color: c.inkSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        DateFormatter.formatDuration(sleepHistory[i].totalDuration),
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
                if (i < (sleepHistory.length > 4 ? 4 : sleepHistory.length) - 1)
                  Divider(height: 1, thickness: 1, color: c.hairline),
              ],
            ],
          ],
        ],
      ),
    );
  }

  Color _stageColor(SleepStageType stage, SuhatColors c) {
    switch (stage) {
      case SleepStageType.deep:
      case SleepStageType.rem:
        return c.accentPine;
      case SleepStageType.awake:
        return c.statusCaution;
      case SleepStageType.light:
      case SleepStageType.asleep:
      case SleepStageType.unknown:
        return c.inkSecondary;
    }
  }
}
