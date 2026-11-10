import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/models/health_models.dart';

class StepsCard extends StatelessWidget {
  final int totalSteps;
  final List<StepRecord> stepRecords;
  final DateTime lastFetched;

  const StepsCard({
    super.key,
    required this.totalSteps,
    required this.stepRecords,
    required this.lastFetched,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.suhatColors;
    final numberFormat = NumberFormat('#,###', 'id_ID');
    final formattedSteps = numberFormat.format(totalSteps);

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
                  'Langkah (Steps)',
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
                    fontWeight: FontWeight.w600,
                    color: c.inkSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.end,
            spacing: 8,
            children: [
              Text(
                formattedSteps,
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: c.inkPrimary,
                  letterSpacing: -0.8,
                  fontFeatures: AppTheme.tabularNumbers,
                ),
              ),
              Text(
                'langkah hari ini',
                style: TextStyle(
                  fontSize: 13,
                  color: c.inkSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Periode 00:00 hingga ${DateFormatter.formatTime(lastFetched)} WIB',
            style: TextStyle(
              fontSize: 11,
              color: c.inkSecondary,
              fontFeatures: AppTheme.tabularNumbers,
            ),
          ),
          if (stepRecords.isNotEmpty) ...[
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
                    'Log Interval Langkah',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: c.inkPrimary,
                    ),
                  ),
                  Text(
                    '${stepRecords.length} rekaman',
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
            for (int i = 0; i < (stepRecords.length > 5 ? 5 : stepRecords.length); i++) ...[
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
                            DateFormatter.formatTimeRange(
                                stepRecords[i].startTime, stepRecords[i].endTime),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: c.inkPrimary,
                              fontFeatures: AppTheme.tabularNumbers,
                            ),
                          ),
                          Text(
                            stepRecords[i].source,
                            style: TextStyle(
                              fontSize: 11,
                              color: c.inkSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '+${stepRecords[i].count}',
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
              if (i < (stepRecords.length > 5 ? 5 : stepRecords.length) - 1)
                Divider(height: 1, thickness: 1, color: c.hairline),
            ],
          ],
        ],
      ),
    );
  }
}
