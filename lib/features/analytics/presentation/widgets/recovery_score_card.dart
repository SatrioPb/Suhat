import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/editorial_ui.dart';
import '../../domain/models/health_insight.dart';

class RecoveryScoreCard extends StatelessWidget {
  final HealthInsight insight;

  const RecoveryScoreCard({
    super.key,
    required this.insight,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.suhatColors;
    final statusColor = EditorialStatusColors.recovery(insight.level, c);
    final scoreRatio = (insight.recoveryScore / 100).clamp(0.0, 1.0);

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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kesiapan & Pemulihan Fisik',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: c.inkPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      insight.heartRateAnalysis.hasData
                          ? 'Berdasarkan denyut jantung dan tidur riil'
                          : 'Berdasarkan sesi tidur (menunggu denyut riil)',
                      style: TextStyle(
                        fontSize: 12,
                        color: c.inkSecondary,
                      ),
                    ),
                  ],
                ),
                EditorialStatusTag(
                  label: insight.level.shortLabel,
                  color: statusColor,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.end,
            spacing: 6,
            children: [
              Text(
                '${insight.recoveryScore}',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  color: statusColor,
                  height: 1.0,
                  letterSpacing: -1.2,
                  fontFeatures: AppTheme.tabularNumbers,
                ),
              ),
              Text(
                '/ 100',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: c.inkSecondary,
                  fontFeatures: AppTheme.tabularNumbers,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: scoreRatio,
              minHeight: 5,
              backgroundColor: c.surfaceSubtle,
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            insight.headline,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: c.inkPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            insight.summary,
            style: TextStyle(
              fontSize: 12,
              color: c.inkSecondary,
              height: 1.4,
            ),
          ),
          if (insight.actionableAdvice.isNotEmpty) ...[
            const SizedBox(height: 16),
            Divider(height: 1, thickness: 1, color: c.hairline),
            const SizedBox(height: 12),
            Text(
              'Langkah Disarankan',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: c.inkPrimary,
              ),
            ),
            const SizedBox(height: 8),
            for (int i = 0; i < insight.actionableAdvice.length; i++)
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
                        insight.actionableAdvice[i],
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
          const SizedBox(height: 10),
          Text(
            insight.medicalDisclaimer,
            style: TextStyle(
              fontSize: 10.5,
              color: c.inkSecondary,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
