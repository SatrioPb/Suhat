import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../health_connect/domain/models/health_models.dart';

class VitalsBiometricsCard extends StatelessWidget {
  final HealthDataSummary summary;

  const VitalsBiometricsCard({
    super.key,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final restingBpm = summary.latestRestingHeartRate?.bpm;
    final hrv = summary.latestHrv?.rmssdMillis;
    final spo2 = summary.latestOxygenSaturation?.percentage;
    final weight = summary.latestWeight?.weightKg;
    final height = summary.latestHeight?.heightCentimeters;
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
                    color: AppTheme.primaryTeal.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.health_and_safety,
                    color: AppTheme.primaryTeal,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tanda Vital & Biometrik',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'RHR, HRV, SpO2, dan Komposisi Fisik',
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
                      color: AppTheme.primaryTeal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: AppTheme.primaryTeal.withOpacity(0.3)),
                    ),
                    child: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Health Connect',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryTeal,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Bagian 1: Tanda Vital (RHR, HRV, SpO2)
            const Text(
              'Tanda Vital & Pemulihan Sistem Syaraf:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    label: 'Detak Istirahat',
                    value: restingBpm != null ? '$restingBpm' : '--',
                    unit: 'BPM',
                    color: AppTheme.accentRed,
                    hint: restingBpm != null ? _getRestingHrHint(restingBpm) : 'Belum ada data',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricTile(
                    label: 'HRV (RMSSD)',
                    value: hrv != null ? hrv.toStringAsFixed(0) : '--',
                    unit: 'ms',
                    color: AppTheme.accentIndigo,
                    hint: hrv != null ? _getHrvHint(hrv) : 'Belum ada data',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricTile(
                    label: 'SpO2 Oksigen',
                    value: spo2 != null ? '${spo2.toStringAsFixed(0)}%' : '--',
                    unit: '',
                    color: AppTheme.accentGreen,
                    hint: spo2 != null ? (spo2 >= 95 ? 'Normal (≥95%)' : 'Perlu dipantau') : 'Belum ada data',
                  ),
                ),
              ],
            ),

            const Divider(height: 24, color: AppTheme.borderSubtle),

            // Bagian 2: Metrik Tubuh (Berat, Tinggi, BMI)
            const Text(
              'Biometrik & Komposisi Tubuh:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    label: 'Berat Badan',
                    value: weight != null ? weight.toStringAsFixed(1) : '--',
                    unit: 'kg',
                    color: AppTheme.textDark,
                    hint: summary.latestWeight != null
                        ? DateFormatter.formatDate(summary.latestWeight!.timestamp)
                        : 'Belum tercatat',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricTile(
                    label: 'Tinggi Badan',
                    value: height != null ? height.toStringAsFixed(0) : '--',
                    unit: 'cm',
                    color: AppTheme.textDark,
                    hint: summary.latestHeight != null
                        ? DateFormatter.formatDate(summary.latestHeight!.timestamp)
                        : 'Belum tercatat',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricTile(
                    label: 'Indeks BMI',
                    value: bmi != null ? bmi.toStringAsFixed(1) : '--',
                    unit: '',
                    color: bmi != null ? _getBmiColor(bmi) : AppTheme.textMuted,
                    hint: bmi != null ? _getBmiCategory(bmi) : 'Menunggu data',
                  ),
                ),
              ],
            ),

            // Bagian 3: Olahraga Terbaru jika tersedia
            if (summary.exerciseRecords.isNotEmpty) ...[
              const Divider(height: 24, color: AppTheme.borderSubtle),
              const Text(
                'Sesi Olahraga Terakhir:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 8),
              _buildExerciseSnippet(summary.exerciseRecords.first),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required String unit,
    required Color color,
    required String hint,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppTheme.textMuted,
              ),
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                if (unit.isNotEmpty) ...[
                  const SizedBox(width: 2),
                  Text(
                    unit,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            hint,
            style: const TextStyle(
              fontSize: 9,
              color: AppTheme.textMuted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseSnippet(ExerciseRecord ex) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.primaryTeal.withOpacity(0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.primaryTeal.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.fitness_center,
            size: 18,
            color: AppTheme.primaryTeal,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ex.activityName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${DateFormatter.formatDuration(ex.duration)} '
                  '${ex.caloriesBurned != null ? "• ${ex.caloriesBurned!.round()} kkal" : ""}',
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
          Text(
            DateFormatter.formatDate(ex.startTime),
            style: const TextStyle(
              fontSize: 10,
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  String _getRestingHrHint(int bpm) {
    if (bpm < 60) return 'Optimal atletik';
    if (bpm <= 80) return 'Normal & sehat';
    return 'Cenderung tinggi';
  }

  String _getHrvHint(double rmssd) {
    if (rmssd >= 50) return 'Pemulihan tinggi';
    if (rmssd >= 30) return 'Pemulihan sedang';
    return 'Beban stres fisik';
  }

  String _getBmiCategory(double bmi) {
    if (bmi < 18.5) return 'Berat kurang';
    if (bmi < 25.0) return 'Ideal / Normal';
    if (bmi < 30.0) return 'Kelebihan berat';
    return 'Obesitas';
  }

  Color _getBmiColor(double bmi) {
    if (bmi < 18.5) return AppTheme.accentAmber;
    if (bmi < 25.0) return AppTheme.accentGreen;
    if (bmi < 30.0) return AppTheme.accentAmber;
    return AppTheme.accentRed;
  }
}
