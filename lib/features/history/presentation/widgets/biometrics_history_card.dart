import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../health_connect/domain/models/health_models.dart';

class BiometricsHistoryCard extends StatelessWidget {
  final HealthDataSummary summary;

  const BiometricsHistoryCard({
    super.key,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final restingHr = summary.latestRestingHeartRate;
    final hrv = summary.latestHrv;
    final spo2 = summary.latestOxygenSaturation;
    final weight = summary.latestWeight;
    final height = summary.latestHeight;
    final bmi = summary.bmi;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.accentIndigo.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.accessibility_new,
                    color: AppTheme.accentIndigo,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tanda Vital & Komposisi Tubuh',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'RHR, HRV, SpO2, Berat & Tinggi',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 105),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.accentIndigo.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: AppTheme.accentIndigo.withOpacity(0.3)),
                    ),
                    child: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Log Terbaru',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accentIndigo,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Item 1: Detak Jantung Istirahat (Resting Heart Rate)
            _buildLogTile(
              icon: Icons.favorite_border,
              iconColor: AppTheme.accentRed,
              title: 'Detak Jantung Istirahat (RHR)',
              value: restingHr != null ? '${restingHr.bpm} BPM' : '--',
              subtext: restingHr != null
                  ? 'Diukur: ${DateFormatter.formatDateTime(restingHr.timestamp)} WIB (${restingHr.source})'
                  : 'Belum ada rekaman RHR di Health Connect',
            ),
            const SizedBox(height: 8),

            // Item 2: Heart Rate Variability (HRV RMSSD)
            _buildLogTile(
              icon: Icons.timeline,
              iconColor: AppTheme.primaryTeal,
              title: 'Variabilitas Detak Jantung (HRV)',
              value: hrv != null ? '${hrv.rmssdMillis.toStringAsFixed(1)} ms' : '--',
              subtext: hrv != null
                  ? 'Diukur: ${DateFormatter.formatDateTime(hrv.timestamp)} WIB (${hrv.source})'
                  : 'Belum ada rekaman HRV di Health Connect',
            ),
            const SizedBox(height: 8),

            // Item 3: Saturasi Oksigen Darah (SpO2)
            _buildLogTile(
              icon: Icons.water_drop_outlined,
              iconColor: AppTheme.accentGreen,
              title: 'Saturasi Oksigen Darah (SpO2)',
              value: spo2 != null ? '${spo2.percentage.toStringAsFixed(1)}%' : '--',
              subtext: spo2 != null
                  ? 'Diukur: ${DateFormatter.formatDateTime(spo2.timestamp)} WIB (${spo2.source})'
                  : 'Belum ada rekaman SpO2 di Health Connect',
            ),
            const SizedBox(height: 8),

            // Item 4: Berat Badan & BMI
            _buildLogTile(
              icon: Icons.scale_outlined,
              iconColor: AppTheme.accentAmber,
              title: 'Berat Badan & BMI',
              value: weight != null
                  ? '${weight.weightKg.toStringAsFixed(1)} kg ${bmi != null ? "• BMI ${bmi.toStringAsFixed(1)}" : ""}'
                  : '--',
              subtext: weight != null
                  ? 'Diukur: ${DateFormatter.formatDate(weight.timestamp)} (${weight.source})'
                  : 'Belum ada rekaman berat badan di Health Connect',
            ),
            const SizedBox(height: 8),

            // Item 5: Tinggi Badan
            _buildLogTile(
              icon: Icons.height,
              iconColor: AppTheme.textMuted,
              title: 'Tinggi Badan',
              value: height != null
                  ? '${height.heightCentimeters.toStringAsFixed(0)} cm (${height.heightMeters.toStringAsFixed(2)} m)'
                  : '--',
              subtext: height != null
                  ? 'Diukur: ${DateFormatter.formatDate(height.timestamp)} (${height.source})'
                  : 'Belum ada rekaman tinggi badan di Health Connect',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtext,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: iconColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtext,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppTheme.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
