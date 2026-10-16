import 'package:flutter/material.dart';
import 'package:suhat/core/theme/app_theme.dart';

class OvertrainingSafetyCard extends StatelessWidget {
  const OvertrainingSafetyCard({super.key});

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
                    color: AppTheme.accentAmber.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.security,
                    color: AppTheme.accentAmber,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pencegahan Cedera & Overtraining',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Tips keselamatan pelari berkelanjutan',
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
              ],
            ),
            const SizedBox(height: 14),

            _buildTipItem(
              Icons.trending_up,
              'Aturan Kenaikan 10% (10% Rule)',
              'Jangan menaikkan total jarak lari mingguan lebih dari 10% dibanding minggu sebelumnya. Kenaikan drastis adalah penyebab nomor satu cedera tulang kering (shin splints) dan tendon achilles.',
            ),
            const SizedBox(height: 10),
            _buildTipItem(
              Icons.favorite_outline,
              'Dengarkan Detak Jantung Istirahat (RHR)',
              'Jika detak jantung istirahat pagi Anda meningkat 5-7 BPM di atas rata-rata normal, ini tanda jelas sistem saraf simpatik belum pulih. Jadikan hari tersebut sebagai Rest Day.',
            ),
            const SizedBox(height: 10),
            _buildTipItem(
              Icons.bedtime_outlined,
              'Tidur adalah Obat Pemulihan Terbaik',
              'Otot kaki tidak berkembang saat Anda berlari, melainkan saat Anda tidur nyenyak (fase Deep Sleep). Pastikan tidur 7-8 jam per malam untuk sintesis jaringan otot.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(IconData icon, String title, String body) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: AppTheme.primaryTeal,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  body,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textMuted,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
