import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:suhat/core/theme/app_theme.dart';
import 'package:suhat/core/widgets/editorial_ui.dart';
import 'package:suhat/features/running_coach/domain/models/running_plan.dart';
import 'package:suhat/features/running_coach/presentation/controllers/running_coach_controller.dart';

class RunningZonesCard extends ConsumerWidget {
  final PersonalRunningZones zones;

  const RunningZonesCard({
    super.key,
    required this.zones,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.suhatColors;
    final runnerAge = ref.watch(runnerAgeProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
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
                      '5 Zona Detak Jantung Lari',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: c.inkPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Metode Karvonen HRR (MHR ${zones.maxHeartRate}, RHR ${zones.restingHeartRate} BPM)',
                      style: TextStyle(
                        fontSize: 11,
                        color: c.inkSecondary,
                        fontFeatures: AppTheme.tabularNumbers,
                      ),
                    ),
                  ],
                ),
                EditorialStatusTag(
                  label: 'Metode Karvonen',
                  color: c.accentPine,
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Kontrol Usia Pelari untuk kalkulasi MHR = 220 - Usia
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: c.surfaceSubtle,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Usia Pelari: $runnerAge tahun',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: c.inkPrimary,
                          fontFeatures: AppTheme.tabularNumbers,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Kurangi usia',
                      onPressed: runnerAge > 14
                          ? () => ref
                              .read(runnerAgeProvider.notifier)
                              .setAge(runnerAge - 1)
                          : null,
                      icon: const Icon(Icons.remove, size: 18),
                    ),
                    IconButton(
                      tooltip: 'Tambah usia',
                      onPressed: runnerAge < 90
                          ? () => ref
                              .read(runnerAgeProvider.notifier)
                              .setAge(runnerAge + 1)
                          : null,
                      icon: const Icon(Icons.add, size: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Target HR = (MHR - RHR) × %HRR + RHR  |  Cadangan (HRR): ${zones.heartRateReserve} BPM',
                  style: TextStyle(
                    fontSize: 11,
                    color: c.inkSecondary,
                    fontFeatures: AppTheme.tabularNumbers,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          for (int i = 0; i < zones.allZones.length; i++) ...[
            _buildZoneRow(zones.allZones[i], c),
            if (i < zones.allZones.length - 1)
              Divider(height: 1, thickness: 1, color: c.hairline),
          ],

          const SizedBox(height: 12),
          Divider(height: 1, thickness: 1, color: c.hairline),
          const SizedBox(height: 10),
          Text(
            'Aturan 80/20: Alokasikan sekitar 80% porsi lari mingguan di Zona 2 (Easy Run) dan 20% di Zona 3-4 untuk membangun daya tahan tanpa kelelahan berlebih.',
            style: TextStyle(
              fontSize: 11,
              color: c.inkSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZoneRow(HeartRateZoneRange zone, SuhatColors c) {
    final isCoreZone = zone.zoneNumber == 2;
    final zoneColor = EditorialStatusColors.runningZone(zone.zoneNumber, c);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: isCoreZone
          ? BoxDecoration(
              color: c.accentPine.withOpacity(0.08),
              border: Border(
                left: BorderSide(color: c.accentPine, width: 3),
              ),
            )
          : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 30,
            child: Text(
              'Z${zone.zoneNumber}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: zoneColor,
                fontFeatures: AppTheme.tabularNumbers,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 2,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      zone.name,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            isCoreZone ? FontWeight.w800 : FontWeight.w600,
                        color: c.inkPrimary,
                      ),
                    ),
                    if (isCoreZone)
                      EditorialStatusTag(
                        label: 'Zona Kunci',
                        color: c.accentPine,
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  zone.description,
                  style: TextStyle(
                    fontSize: 11,
                    color: c.inkSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '${zone.minBpm}-${zone.maxBpm}\nBPM',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: zoneColor,
              height: 1.25,
              fontFeatures: AppTheme.tabularNumbers,
            ),
          ),
        ],
      ),
    );
  }
}
