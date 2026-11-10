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
    final c = context.suhatColors;
    final restingBpm = summary.latestRestingHeartRate?.bpm;
    final hrv = summary.latestHrv?.rmssdMillis;
    final spo2 = summary.latestOxygenSaturation?.percentage;
    final weight = summary.latestWeight?.weightKg;
    final height = summary.latestHeight?.heightCentimeters;
    final bmi = summary.bmi;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(height: 1, thickness: 1, color: c.hairline),
          const SizedBox(height: 16),
          Text(
            'Tanda Vital & Biometrik',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: c.inkPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'RHR, HRV, SpO2, dan komposisi fisik dari Health Connect',
            style: TextStyle(
              fontSize: 12,
              color: c.inkSecondary,
            ),
          ),
          const SizedBox(height: 14),
          _buildLedgerRow(
            c: c,
            label: 'Detak Istirahat (RHR)',
            value: restingBpm != null ? '$restingBpm BPM' : '--',
            hint: restingBpm != null
                ? _getRestingHrHint(restingBpm)
                : 'Belum ada data',
            valueColor: c.statusAlert,
          ),
          _buildLedgerRow(
            c: c,
            label: 'Variabilitas Jantung (HRV)',
            value: hrv != null ? '${hrv.toStringAsFixed(0)} ms' : '--',
            hint: hrv != null ? _getHrvHint(hrv) : 'Belum ada data',
            valueColor: c.accentPine,
          ),
          _buildLedgerRow(
            c: c,
            label: 'Saturasi Oksigen (SpO2)',
            value: spo2 != null ? '${spo2.toStringAsFixed(0)}%' : '--',
            hint: spo2 != null
                ? (spo2 >= 95 ? 'Normal (>= 95%)' : 'Perlu dipantau')
                : 'Belum ada data',
            valueColor: spo2 != null && spo2 < 95 ? c.statusCaution : c.inkPrimary,
          ),
          _buildLedgerRow(
            c: c,
            label: 'Berat Badan',
            value: weight != null ? '${weight.toStringAsFixed(1)} kg' : '--',
            hint: summary.latestWeight != null
                ? DateFormatter.formatDate(summary.latestWeight!.timestamp)
                : 'Belum tercatat',
          ),
          _buildLedgerRow(
            c: c,
            label: 'Tinggi Badan',
            value: height != null ? '${height.toStringAsFixed(0)} cm' : '--',
            hint: summary.latestHeight != null
                ? DateFormatter.formatDate(summary.latestHeight!.timestamp)
                : 'Belum tercatat',
          ),
          _buildLedgerRow(
            c: c,
            label: 'Indeks Massa Tubuh (BMI)',
            value: bmi != null ? bmi.toStringAsFixed(1) : '--',
            hint: bmi != null ? _getBmiCategory(bmi) : 'Menunggu berat & tinggi',
            valueColor: bmi != null ? _getBmiColor(bmi, c) : c.inkSecondary,
            showDivider: summary.exerciseRecords.isNotEmpty,
          ),
          if (summary.exerciseRecords.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Sesi Olahraga Terakhir',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: c.inkPrimary,
              ),
            ),
            const SizedBox(height: 6),
            _buildExerciseRow(summary.exerciseRecords.first, c),
          ],
        ],
      ),
    );
  }

  Widget _buildLedgerRow({
    required SuhatColors c,
    required String label,
    required String value,
    required String hint,
    Color? valueColor,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: c.inkPrimary,
                      ),
                    ),
                    Text(
                      hint,
                      style: TextStyle(
                        fontSize: 11,
                        color: c.inkSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: valueColor ?? c.inkPrimary,
                  fontFeatures: AppTheme.tabularNumbers,
                ),
              ),
            ],
          ),
        ),
        if (showDivider) Divider(height: 1, thickness: 1, color: c.hairline),
      ],
    );
  }

  Widget _buildExerciseRow(ExerciseRecord ex, SuhatColors c) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: c.surfaceSubtle,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.fitness_center, size: 16, color: c.accentPine),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ex.activityName,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: c.inkPrimary,
                  ),
                ),
                Text(
                  '${DateFormatter.formatDuration(ex.duration)}'
                  '${ex.caloriesBurned != null ? " • ${ex.caloriesBurned!.round()} kkal" : ""}',
                  style: TextStyle(
                    fontSize: 11,
                    color: c.inkSecondary,
                    fontFeatures: AppTheme.tabularNumbers,
                  ),
                ),
              ],
            ),
          ),
          Text(
            DateFormatter.formatDate(ex.startTime),
            style: TextStyle(
              fontSize: 11,
              color: c.inkSecondary,
              fontFeatures: AppTheme.tabularNumbers,
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

  Color _getBmiColor(double bmi, SuhatColors c) {
    if (bmi < 18.5 || bmi >= 25.0 && bmi < 30.0) return c.statusCaution;
    if (bmi >= 30.0) return c.statusAlert;
    return c.accentPine;
  }
}
