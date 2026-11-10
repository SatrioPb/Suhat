import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/editorial_ui.dart';
import '../../running_coach/domain/models/running_plan.dart';
import '../../weather_aqi/presentation/controllers/weather_aqi_controller.dart';

class CompactRunningBanner extends ConsumerWidget {
  final RunningWorkoutRecommendation recommendation;
  final VoidCallback onTapViewCoach;

  const CompactRunningBanner({
    super.key,
    required this.recommendation,
    required this.onTapViewCoach,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.suhatColors;
    final workout = recommendation.workoutType;
    final color = workout.resolveColor(c);
    final weatherState = ref.watch(weatherAqiControllerProvider);
    final condition = weatherState.condition;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: c.surfaceSubtle,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTapViewCoach,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                Icon(
                  workout.icon,
                  color: color,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            'Pelatih Lari',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: c.inkSecondary,
                            ),
                          ),
                          EditorialStatusTag(
                            label: workout.shortLabel,
                            color: color,
                          ),
                          if (condition != null) ...[
                            Text(
                              '${condition.weather.temperature.toStringAsFixed(0)}°C',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: c.inkPrimary,
                                fontFeatures: AppTheme.tabularNumbers,
                              ),
                            ),
                            Text(
                              'AQI ${condition.airQuality.usAqi}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: condition.airQuality.level.resolveColor(c),
                                fontFeatures: AppTheme.tabularNumbers,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        recommendation.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: c.inkPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: c.inkSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
