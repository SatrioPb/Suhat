import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../health_connect/domain/models/health_models.dart';

class MetricDualGrid extends StatelessWidget {
  final HeartRateRecord? latestHeartRate;
  final SleepRecord? latestSleep;
  final VoidCallback onTapHeartRate;
  final VoidCallback onTapSleep;

  const MetricDualGrid({
    super.key,
    required this.latestHeartRate,
    required this.latestSleep,
    required this.onTapHeartRate,
    required this.onTapSleep,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          // Heart Rate Card
          Expanded(
            child: _buildTile(
              onTap: onTapHeartRate,
              icon: Icons.favorite,
              iconColor: AppTheme.accentRed,
              title: 'Detak Jantung',
              mainValue: latestHeartRate != null ? '${latestHeartRate!.bpm}' : '--',
              unit: 'BPM',
              subtext: latestHeartRate != null
                  ? DateFormatter.formatTime(latestHeartRate!.timestamp)
                  : 'Belum ada data',
              tag: '24 jam',
            ),
          ),
          const SizedBox(width: 12),
          // Sleep Card
          Expanded(
            child: _buildTile(
              onTap: onTapSleep,
              icon: Icons.bedtime,
              iconColor: AppTheme.accentIndigo,
              title: 'Tidur Semalam',
              mainValue: latestSleep != null
                  ? DateFormatter.formatDuration(latestSleep!.totalDuration)
                  : '--',
              unit: '',
              subtext: latestSleep != null
                  ? '${DateFormatter.formatTime(latestSleep!.startTime)} - ${DateFormatter.formatTime(latestSleep!.endTime)}'
                  : 'Belum ada data',
              tag: 'Sesi terakhir',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTile({
    required VoidCallback onTap,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String mainValue,
    required String unit,
    required String subtext,
    required String tag,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderSubtle),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    tag,
                    textAlign: TextAlign.end,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    mainValue,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.textDark,
                    ),
                  ),
                  if (unit.isNotEmpty) ...[
                    const SizedBox(width: 4),
                    Text(
                      unit,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtext,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
