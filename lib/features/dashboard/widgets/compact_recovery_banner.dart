import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
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
    final color = _getLevelColor(insight.level);

    return InkWell(
      onTap: onTapViewAnalysis,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
        child: Row(
          children: [
            // Circular Score
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.1),
                border: Border.all(color: color.withOpacity(0.3), width: 2),
              ),
              child: Center(
                child: Text(
                  '${insight.recoveryScore}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          insight.level.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Kesiapan Fisik',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    insight.actionableAdvice.isNotEmpty
                        ? insight.actionableAdvice.first
                        : insight.headline,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textMuted,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right,
              color: AppTheme.textMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Color _getLevelColor(RecoveryLevel level) {
    switch (level) {
      case RecoveryLevel.optimal:
        return AppTheme.accentGreen;
      case RecoveryLevel.good:
        return AppTheme.primaryTeal;
      case RecoveryLevel.attentionNeeded:
        return AppTheme.accentAmber;
      case RecoveryLevel.restRequired:
        return AppTheme.accentRed;
      case RecoveryLevel.insufficientData:
        return AppTheme.textMuted;
    }
  }
}
