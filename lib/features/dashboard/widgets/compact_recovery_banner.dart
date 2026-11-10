import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/editorial_ui.dart';
import '../../analytics/domain/models/health_insight.dart';

class CompactRecoveryBanner extends StatelessWidget {
  final HealthInsight insight;
  final VoidCallback onTapViewAnalysis;

  const CompactRecoveryBanner({
    super.key,
    required this.insight,
    required this.onTapViewAnalysis,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.suhatColors;
    final color = EditorialStatusColors.recovery(insight.level, c);
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);

    final scoreBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${insight.recoveryScore}',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: color,
            height: 1.0,
            letterSpacing: -1,
            fontFeatures: AppTheme.tabularNumbers,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'skor / 100',
          style: TextStyle(
            fontSize: 11,
            color: c.inkSecondary,
            fontFeatures: AppTheme.tabularNumbers,
          ),
        ),
      ],
    );

    final detailBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.spaceBetween,
            children: [
              Text(
                'Kesiapan Fisik',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: c.inkPrimary,
                ),
              ),
              EditorialStatusTag(
                label: insight.level.label,
                color: color,
              ),
            ],
          ),
        ),
        const SizedBox(height: 5),
        Text(
          insight.actionableAdvice.isNotEmpty
              ? insight.actionableAdvice.first
              : insight.headline,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            color: c.inkSecondary,
            height: 1.35,
          ),
        ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: c.hairline, width: 1),
            bottom: BorderSide(color: c.hairline, width: 1),
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTapViewAnalysis,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 300 || textScale > 1.45) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: scoreBlock),
                            Icon(
                              Icons.chevron_right,
                              color: c.inkSecondary,
                              size: 20,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        detailBlock,
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      scoreBlock,
                      const SizedBox(width: 18),
                      Expanded(child: detailBlock),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.chevron_right,
                        color: c.inkSecondary,
                        size: 20,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
