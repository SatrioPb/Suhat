import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/editorial_ui.dart';
import '../../../health_connect/domain/models/health_models.dart';

class BiometricsHistoryCard extends StatelessWidget {
  final HealthDataSummary summary;

  const BiometricsHistoryCard({
    super.key,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.suhatColors;
    final restingHr = summary.latestRestingHeartRate;
    final hrv = summary.latestHrv;
    final spo2 = summary.latestOxygenSaturation;
    final weight = summary.latestWeight;
    final height = summary.latestHeight;
    final bmi = summary.bmi;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: c.surfaceSubtle,
        borderRadius: BorderRadius.circular(10),
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
                      'Tanda Vital & Komposisi Tubuh',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: c.inkPrimary,
                      ),
                    ),
                    Text(
                      'RHR, HRV, SpO2, berat, dan tinggi badan',
                      style: TextStyle(
                        fontSize: 12,
                        color: c.inkSecondary,
                      ),
                    ),
                  ],
                ),
                EditorialStatusTag(
                  label: 'Log Terbaru',
                  color: c.accentPine,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _buildLogRow(
            c: c,
            title: 'Detak Jantung Istirahat (RHR)',
            value: restingHr != null ? '${restingHr.bpm} BPM' : '--',
            subtext: restingHr != null
                ? 'Diukur: ${DateFormatter.formatDateTime(restingHr.timestamp)} WIB (${restingHr.source})'
                : 'Belum ada rekaman RHR di Health Connect',
            valueColor: c.statusAlert,
          ),
          Divider(height: 1, thickness: 1, color: c.hairline),
          _buildLogRow(
            c: c,
            title: 'Variabilitas Detak Jantung (HRV)',
            value: hrv != null ? '${hrv.rmssdMillis.toStringAsFixed(1)} ms' : '--',
            subtext: hrv != null
                ? 'Diukur: ${DateFormatter.formatDateTime(hrv.timestamp)} WIB (${hrv.source})'
                : 'Belum ada rekaman HRV di Health Connect',
            valueColor: c.accentPine,
          ),
          Divider(height: 1, thickness: 1, color: c.hairline),
          _buildLogRow(
            c: c,
            title: 'Saturasi Oksigen Darah (SpO2)',
            value: spo2 != null ? '${spo2.percentage.toStringAsFixed(1)}%' : '--',
            subtext: spo2 != null
                ? 'Diukur: ${DateFormatter.formatDateTime(spo2.timestamp)} WIB (${spo2.source})'
                : 'Belum ada rekaman SpO2 di Health Connect',
            valueColor: c.accentPine,
          ),
          Divider(height: 1, thickness: 1, color: c.hairline),
          _buildLogRow(
            c: c,
            title: 'Berat Badan & BMI',
            value: weight != null
                ? '${weight.weightKg.toStringAsFixed(1)} kg${bmi != null ? " • BMI ${bmi.toStringAsFixed(1)}" : ""}'
                : '--',
            subtext: weight != null
                ? 'Diukur: ${DateFormatter.formatDate(weight.timestamp)} (${weight.source})'
                : 'Belum ada rekaman berat badan di Health Connect',
            valueColor: c.statusCaution,
          ),
          Divider(height: 1, thickness: 1, color: c.hairline),
          _buildLogRow(
            c: c,
            title: 'Tinggi Badan',
            value: height != null
                ? '${height.heightCentimeters.toStringAsFixed(0)} cm'
                : '--',
            subtext: height != null
                ? 'Diukur: ${DateFormatter.formatDate(height.timestamp)} (${height.source})'
                : 'Belum ada rekaman tinggi badan di Health Connect',
            valueColor: c.inkPrimary,
          ),
        ],
      ),
    );
  }

  Widget _buildLogRow({
    required SuhatColors c,
    required String title,
    required String value,
    required String subtext,
    required Color valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: c.inkPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtext,
                  style: TextStyle(
                    fontSize: 11,
                    color: c.inkSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: valueColor,
              fontFeatures: AppTheme.tabularNumbers,
            ),
          ),
        ],
      ),
    );
  }
}
