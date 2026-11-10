import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/editorial_ui.dart';

class MinimalStepCard extends StatelessWidget {
  final int totalSteps;
  final int stepGoal;
  final double? realDistanceMeters;
  final double? realActiveCaloriesKcal;
  final VoidCallback? onTap;

  const MinimalStepCard({
    super.key,
    required this.totalSteps,
    this.stepGoal = 10000,
    this.realDistanceMeters,
    this.realActiveCaloriesKcal,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.suhatColors;
    final numberFormat = NumberFormat('#,###', 'id_ID');
    final formattedSteps = numberFormat.format(totalSteps);
    final formattedGoal = numberFormat.format(stepGoal);
    final progress =
        stepGoal > 0 ? (totalSteps / stepGoal).clamp(0.0, 1.0) : 0.0;
    final percentage = (progress * 100).toStringAsFixed(0);

    // Hanya tampilkan angka jarak & kalori nyata dari Health Connect (R-17)
    final hasRealDist = realDistanceMeters != null && realDistanceMeters! > 0;
    final hasRealCal =
        realActiveCaloriesKcal != null && realActiveCaloriesKcal! > 0;
    final distText =
        hasRealDist ? '${(realDistanceMeters! / 1000.0).toStringAsFixed(1)} km' : '-- km';
    final calText =
        hasRealCal ? '${realActiveCaloriesKcal!.round()} kkal' : '-- kkal';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: c.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.hairline, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(20),
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
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.directions_walk,
                            color: c.accentPine,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'Langkah Hari Ini',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: c.inkPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      EditorialStatusTag(
                        label: '$percentage% target',
                        color: progress >= 1.0 ? c.accentPine : c.inkSecondary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.end,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Text(
                      formattedSteps,
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        color: c.inkPrimary,
                        letterSpacing: -1.2,
                        height: 1.0,
                        fontFeatures: AppTheme.tabularNumbers,
                      ),
                    ),
                    Text(
                      'dari $formattedGoal langkah',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: c.inkSecondary,
                        fontFeatures: AppTheme.tabularNumbers,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 5,
                    backgroundColor: c.surfaceSubtle,
                    valueColor: AlwaysStoppedAnimation<Color>(c.accentPine),
                  ),
                ),
                const SizedBox(height: 16),
                Divider(height: 1, thickness: 1, color: c.hairline),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 6,
                    alignment: WrapAlignment.spaceBetween,
                    children: [
                      _buildBaselineStat('Jarak', distText, c),
                      _buildBaselineStat('Kalori Aktif', calText, c),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBaselineStat(String label, String value, SuhatColors c) {
    return Wrap(
      spacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          '$label:',
          style: TextStyle(
            fontSize: 12,
            color: c.inkSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: c.inkPrimary,
            fontFeatures: AppTheme.tabularNumbers,
          ),
        ),
      ],
    );
  }
}
