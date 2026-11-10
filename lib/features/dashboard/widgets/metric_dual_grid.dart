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
    final c = context.suhatColors;
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);

    final hrColumn = _buildEditorialCell(
      c: c,
      onTap: onTapHeartRate,
      icon: Icons.favorite_outline,
      iconColor: c.statusAlert,
      title: 'Detak Jantung',
      mainValue: latestHeartRate != null ? '${latestHeartRate!.bpm}' : '--',
      unit: 'BPM',
      subtext: latestHeartRate != null
          ? DateFormatter.formatTime(latestHeartRate!.timestamp)
          : 'Belum ada data',
    );

    final sleepColumn = _buildEditorialCell(
      c: c,
      onTap: onTapSleep,
      icon: Icons.bedtime_outlined,
      iconColor: c.accentPine,
      title: 'Tidur Semalam',
      mainValue: latestSleep != null
          ? DateFormatter.formatDuration(latestSleep!.totalDuration)
          : '--',
      unit: '',
      subtext: latestSleep != null
          ? '${DateFormatter.formatTime(latestSleep!.startTime)} - ${DateFormatter.formatTime(latestSleep!.endTime)}'
          : 'Belum ada data',
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stackVertically =
              constraints.maxWidth < 300 || textScale > 1.45;

          if (stackVertically) {
            return DecoratedBox(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: c.hairline),
                  bottom: BorderSide(color: c.hairline),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  hrColumn,
                  Divider(height: 1, thickness: 1, color: c.hairline),
                  sleepColumn,
                ],
              ),
            );
          }

          return DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: c.hairline),
                bottom: BorderSide(color: c.hairline),
              ),
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: hrColumn),
                  VerticalDivider(
                    width: 24,
                    thickness: 1,
                    color: c.hairline,
                  ),
                  Expanded(child: sleepColumn),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEditorialCell({
    required SuhatColors c,
    required VoidCallback onTap,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String mainValue,
    required String unit,
    required String subtext,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(icon, color: iconColor, size: 15),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: c.inkSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.end,
                spacing: 4,
                children: [
                  Text(
                    mainValue,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: c.inkPrimary,
                      letterSpacing: -0.5,
                      fontFeatures: AppTheme.tabularNumbers,
                    ),
                  ),
                  if (unit.isNotEmpty)
                    Text(
                      unit,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: c.inkSecondary,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                subtext,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  color: c.inkSecondary,
                  fontFeatures: AppTheme.tabularNumbers,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
