import 'package:flutter/material.dart';
import 'package:suhat/core/theme/app_theme.dart';
import 'package:suhat/features/running_coach/domain/models/running_plan.dart';

class RunningZonesCard extends StatelessWidget {
  final PersonalRunningZones zones;

  const RunningZonesCard({
    super.key,
    required this.zones,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.accentIndigo.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.favorite_border,
                    color: AppTheme.accentIndigo,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '5 Zona Detak Jantung Lari',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Estimasi Max HR: ${zones.maxHeartRate} BPM',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppTheme.borderSubtle),
                  ),
                  child: const Text(
                    'HR Zones',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Text(
              'Panduan intensitas denyut nadi saat berlari agar adaptasi kardiovaskular maksimal tanpa risiko cedera:',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textDark,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 12),

            // Daftar 5 Zona
            ...zones.allZones.map((z) => _buildZoneItem(z)),

            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.accentGreen.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.accentGreen.withOpacity(0.2)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 16,
                    color: AppTheme.accentGreen,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Prinsip Emas Pelari (80/20 Rule): Alokasikan ~80% dari total sesi lari Anda di Zona 2 (Easy Run) dan hanya 20% di Zona 3-4 (Tempo/Interval). Ini mencegah kelelahan berlebih dan membuat Anda berlari lebih cepat secara berkelanjutan.',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textDark,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZoneItem(HeartRateZoneRange zone) {
    final isCoreZone = zone.zoneNumber == 2;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isCoreZone ? zone.color.withOpacity(0.08) : AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isCoreZone ? zone.color.withOpacity(0.4) : AppTheme.borderSubtle,
            width: isCoreZone ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: zone.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Z${zone.zoneNumber}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: zone.color,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          zone.name,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isCoreZone ? FontWeight.bold : FontWeight.w600,
                            color: AppTheme.textDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isCoreZone)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.accentGreen,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Zona Kunci',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    zone.description,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppTheme.textMuted,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${zone.minBpm}-${zone.maxBpm}\nBPM',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: zone.color,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
